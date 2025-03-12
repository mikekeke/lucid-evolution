import {
  Effect,
  pipe,
  Array as _Array,
  BigInt as _BigInt,
  Layer,
} from "effect";
import {
  Address,
  Assets,
  OutRef,
  Unit,
  UTxO,
  Wallet,
} from "@lucid-evolution/core-types";
import {
  ERROR_MESSAGE,
  RunTimeError,
  TransactionError,
} from "../../../Errors.js";
import { CML, makeReturn } from "../../../core.js";
import * as TxBuilder from "../../TxBuilder.js";
import * as TxSignBuilder from "../../../tx-sign-builder/TxSignBuilder.js";
import { TxConfig } from "../Service.js";
import * as CompleteTxBuilder from "../CompleteTxBuilder.js";
import {
  completeTxError,
  mkBalanceRequest,
  parseSuccessResponse,
  pisaBalanceError,
  PisaRequest,
} from "./PisaCompleteTxTypes.js";
import { Either } from "effect/Either";

export type PisaCompleteOptions = {
  changeAddress?: Address;
  collateral?: OutRef;
};

export type Pisa = {
  /**
   * Set a builder whose transaction should be completed with Pisa Fees service.
   */
  usingBuilder: (builder: TxBuilder.TxBuilder) => {
    completeSafe: (
      position: OutRef,
      swapAssets: Unit[],
      options?: PisaCompleteOptions,
    ) => Promise<Either<TxSignBuilder.TxSignBuilder, TransactionError>>;

    /**
     * Complete transaction of selected builder using Pisa Fees service to balance transaction and pay fee with token(s).
     *
     * **Warning:** If `OutRef` of collateral is passed via options, this UTxO will be used exclusively as collateral
     *  and will be excluded from balancing.
     *
     * **Warning:** Due to some technical limitations, all UTxOs w/o scripts and Datums sent to change address
     * (most certainly) will be combined into single change UTxO.
     */
    complete: (
      position: OutRef,
      swapAssets: Unit[],
      options?: PisaCompleteOptions,
    ) => Promise<TxSignBuilder.TxSignBuilder>;
  };
  /**
   * Close web socket connection to Pisa Fees service.
   */
  finalize: () => void;
};

/**
 * Provides access to Pisa Fees balancing service to balance transaction and pay fee with token(s).
 *
 * **Warning:** When initiated, opens web socket connection.
 *  User should close connection when needed by calling `.finalize()`.
 *
 * @example
 * ```ts
 * const pisaUrl = 'https://8.8.8.8:8888';
 * const swapPosition: OutRef = {
 *   txHash: "4d3cf2ee492d688be15967e5d0dc695defaf46a5674cfbee684e64b341b1839a",
 *   outputIndex: 1
 * };
 * const swapAssets: Unit[] = [
 *   somePolicyId + fromText("TokenToPayFee")
 * ];
 *
 * const txBuilder = lucid
 *   .newTx()
 *   .pay.ToAddress(payToAddr, { [somePolicyId + fromText("SomeToken")]: 1n });
 *
 * const pisa = await Pisa(pisaUrl);
 *
 * const tx: TxSignBuilder =
 *  await pisa.usingBuilder(txBuilder)
 *    .complete(swapPosition, swapAssets);
 *
 * pisa.finalize(); // can be called anywhere when needed, to close web socket connection
 * const signedTx = await tx.sign.withWallet().complete();
 * await signedTx.submit();
 * ```
 */
export const Pisa = async (pisaUrl: string): Promise<Pisa> => {
  const pws: PisaSocket = await connect(pisaUrl);

  const mkProgram = (
    builder: TxBuilder.TxBuilder,
    position: OutRef,
    swapAssets: Unit[],
    options: PisaCompleteOptions = {},
  ) => {
    const configLayer = Layer.succeed(TxConfig, {
      config: builder.rawConfig(),
    });
    return pipe(
      completeWithDummyInput(pws, position, swapAssets, options),
      Effect.provide(configLayer),
      Effect.map((result) => result),
    );
  };
  return {
    usingBuilder: (builder: TxBuilder.TxBuilder) => {
      return {
        completeSafe: (
          position: OutRef,
          swapAssets: Unit[],
          options: PisaCompleteOptions = {},
        ) => {
          return makeReturn(
            mkProgram(builder, position, swapAssets, options),
          ).safeRun();
        },
        complete: (
          position: OutRef,
          swapAssets: Unit[],
          options: PisaCompleteOptions = {},
        ) => {
          return makeReturn(
            mkProgram(builder, position, swapAssets, options),
          ).unsafeRun();
        },
      };
    },
    finalize: () => {
      console.log("Closing Pisa WS connection");
      pws.shutDown();
    },
  };
};
/**
 * Returns `Effect` that will open web socket, perform balancing using Pisa Fees service,
 * close web socket and return result of type `TxSignBuilder`.
 * Used in `TxSignBuilder.completeWithPisa(...)`
 */
export const completeSingle = (
  pisaUrl: string,
  position: OutRef,
  swapAssets: Unit[],
  options: PisaCompleteOptions = {},
) => {
  const acquireWs = Effect.tryPromise({
    try: () => connect(pisaUrl),
    catch: () => pisaBalanceError("Pisa web socket connection error"),
  });

  const releaseWs = (res: PisaSocket) =>
    Effect.gen(function* () {
      res.shutDown();
    });

  const wsResource = Effect.acquireRelease(acquireWs, releaseWs);

  return Effect.scoped(
    Effect.gen(function* () {
      const pws = yield* wsResource;
      return yield* completeWithDummyInput(pws, position, swapAssets, options);
    }),
  );
};

/**
 * Ideally we want completely unbalanced transaction with non-adjusted outputs,
 * but it seems to be impossible to get using CML transaction builder.
 * To mitigate consequences of balancing, this function uses following approach:
 *
 * - figure out total value of outputs produced by transaction
 * - make dummy UTxO that covers outputs value, collateral and fee and use it exclusively for balancing
 * via `CompleteTxBuilder`
 * - send transaction via request message that notifies Pisa Fees service that transaction
 * was balanced and adjusted in known way
 *
 * After receiving such request, Pisa Fees balancer will do the following:
 * - remove dummy input used for balancing from inputs (if such input is missing, it will return an error)
 * - remove all outputs w/o scripts and Datums that are sent to change address, and recalculate change during balancing
 * - re-adjust inputs that were adjusted by adding minimum Ada value
 */
const completeWithDummyInput = (
  pws: PisaSocket,
  position: OutRef,
  swapAssets: Unit[],
  options: PisaCompleteOptions = {},
) =>
  Effect.gen(function* () {
    const { config } = yield* TxConfig;
    const wallet: Wallet = yield* getWallet(config);
    const walletAddress: string = yield* Effect.promise(() => wallet.address());

    const { changeAddress = walletAddress, collateral = undefined } = options;

    const valueRequiredToBalanceTx = yield* calculateRequiredValue(config);

    const artificialBalanceOptions = mkBalancingOptions(
      valueRequiredToBalanceTx,
      walletAddress,
      changeAddress,
    );
    const completed: TxSignBuilder.TxSignBuilder =
      (yield* CompleteTxBuilder.complete(artificialBalanceOptions))[2];

    const request = mkBalanceRequest(
      position,
      swapAssets,
      completed.toTransaction(),
      walletAddress,
      changeAddress,
      collateral,
    );

    const parsedResponse = yield* runWsRequest(pws, request);

    const sigBuilder = yield* Effect.promise(() =>
      TxSignBuilder.makeTxSignBuilder(
        wallet,
        CML.Transaction.from_cbor_hex(parsedResponse.balancedCbor),
      ).complete(),
    );
    const fixedTx = yield* fixHashes(sigBuilder.toTransaction());
    return TxSignBuilder.makeTxSignBuilder(wallet, fixedTx);
  }).pipe(Effect.catchAllDefect((cause) => new RunTimeError({ cause })));

const calculateRequiredValue = (config: TxBuilder.TxBuilderConfig) =>
  Effect.gen(function* () {
    // need to evaluate programs to get `config.totalOutputAssets`
    // but evaluating will cause `config` state mutation
    // to mitigate this, cloning config here and use it for evaluation,
    // so original config can be used later to `.complete()` with dummy balancing input
    const clonedConfig = cloneConfig(config);
    // need to evaluate programs to set `clonedConfig.totalOutputAssets`
    yield* Effect.provide(
      Effect.all(clonedConfig.programs),
      Layer.succeed(TxConfig, { config: clonedConfig }),
    );
    return clonedConfig.totalOutputAssets;
  });

const cloneConfig = (
  cfg: TxBuilder.TxBuilderConfig,
): TxBuilder.TxBuilderConfig => {
  const configClone = { ...cfg };
  configClone.txBuilder = CML.TransactionBuilder.new(
    configClone.lucidConfig.txbuilderconfig,
  );
  return configClone;
};

/**
 * Build dummy input for balancing with lucid-evolution.
 * Input should be big enough to cover outputs Value.
 */
const mkBalancingOptions = (
  requiredValue: Assets,
  walletAddress: Address,
  changeAddress: Address,
) => {
  const somethingToCoverFee = 4_000_000n;
  const collateralSize = 5_000_000n;
  requiredValue.lovelace =
    (requiredValue.lovelace ?? 0n) + collateralSize + somethingToCoverFee;

  const dummyInUtxo: UTxO = {
    txHash: "0000000000000000000000000000000000000000000000000000000000000000",
    outputIndex: 0,
    assets: requiredValue,
    address: walletAddress,
  };

  return {
    changeAddress: changeAddress,
    presetWalletInputs: [dummyInUtxo],
    setCollateral: collateralSize,
  };
};

// Utilities
const getWallet = (config: TxBuilder.TxBuilderConfig) =>
  pipe(
    Effect.fromNullable(config.lucidConfig.wallet),
    Effect.orElseFail(() => completeTxError(ERROR_MESSAGE.MISSING_WALLET)),
  );

const fixHashes = (tx: CML.Transaction) =>
  Effect.gen(function* () {
    const { config } = yield* TxConfig;
    const body = tx.body();
    const witnessSet = tx.witness_set();

    const redeemers = yield* pipe(
      Effect.fromNullable(witnessSet.redeemers()),
      Effect.orElseFail(() =>
        pisaBalanceError(
          `Impossible: no redeemers in transaction balanced by Pisa`,
        ),
      ),
    );

    const datums = witnessSet.plutus_datums() || CML.PlutusDataList.new();

    const calcIntegrityHash = () =>
      CML.calc_script_data_hash(
        redeemers,
        datums,
        config.lucidConfig.costModels,
        witnessSet.languages(),
      );

    // recalculate and set integrity hash
    const integrityHash = yield* pipe(
      Effect.fromNullable(calcIntegrityHash()),
      Effect.orElseFail(() =>
        pisaBalanceError(
          `Could not calculate integrity hash for tx balanced with Pisa`,
        ),
      ),
    );
    body.set_script_data_hash(integrityHash);

    // recalculate and set aux data hash
    const auxDat = tx.auxiliary_data();
    if (auxDat) {
      body.set_auxiliary_data_hash(CML.hash_auxiliary_data(auxDat));
    }

    return CML.Transaction.new(
      body,
      tx.witness_set(),
      tx.is_valid(),
      tx.auxiliary_data(),
    );
  });

const runWsRequest = (pws: PisaSocket, pisaRequest: PisaRequest) =>
  Effect.gen(function* () {
    const mkRequest = Effect.tryPromise({
      try: () => pws.runBalanceRequest(pisaRequest),
      catch: (someError) =>
        pisaBalanceError(
          `Failed get response for request ${pisaRequest.requestId}: ${someError}`,
        ),
    });

    const response = yield* Effect.flatMap(mkRequest, parseSuccessResponse);
    if (pisaRequest.requestId !== response.requestId) {
      yield* Effect.fail(
        pisaBalanceError(
          `Request id ${pisaRequest.requestId} does not match response id ${response.requestId}`,
        ),
      );
    }
    return response;
  });

/**
 * Wrapper for web socket that provides helper request-response function
 * and throws error if server disconnects unexpectedly.
 */
type PisaSocket = {
  runBalanceRequest: (pisaRequest: PisaRequest) => Promise<string>;
  shutDown: () => void;
};

const connect = async (url: string): Promise<PisaSocket> =>
  new Promise((resolve, _) => {
    const wss = new WebSocket(url);
    const throwSocketClose = () => {
      throw new Error("Pisa web socket connection was closed unexpectedly");
    };
    wss.onopen = (_) => {
      // after connection established, making on-close to throw exception
      // this prevents the situation when server disconnects unexpectedly
      // and application just stops execution w/o any result or error
      wss.onclose = (_) => throwSocketClose();
      resolve({
        runBalanceRequest: (pisaRequest: PisaRequest) =>
          new Promise((resolveInner, rejectInner) => {
            // during request-response on-close triggers reject so error can be handled by e.g. by `Effect.tryPromise`
            wss.onclose = (_) =>
              rejectInner("Pisa web socket connection was closed unexpectedly");
            wss.send(JSON.stringify(pisaRequest));
            wss.onmessage = (msg) => {
              resolveInner(msg.data.text());
              // after message received, set on-close back to throwing exception to (again) prevent execution
              // from stopping silently in case of server disconnects
              wss.onclose = (_) => throwSocketClose();
            };
          }),
        shutDown: () => {
          wss.onclose = (_) => {
            console.log("Closing Pisa web socket connection");
          };
          wss.close();
        },
      });
    };
  });
