import {
  Effect,
  pipe,
  Array as _Array,
  BigInt as _BigInt,
  Layer,
} from "effect";
import {
  Address,
  OutRef,
  Unit,
  UTxO,
  Wallet,
} from "@lucid-evolution/core-types";
import {
  ERROR_MESSAGE,
  RunTimeError,
  TransactionError,
  TxBuilderError,
} from "../../Errors.js";
import { CML, makeReturn } from "../../core.js";
import * as TxBuilder from "../TxBuilder.js";
import * as TxSignBuilder from "../../tx-sign-builder/TxSignBuilder.js";
import { TxConfig } from "./Service.js";
import * as CompleteTxBuilder from "./CompleteTxBuilder.js";
import {
  completeTxError,
  mkFakeInBalanceRequest,
  mkReBalanceRequest,
  parseSuccessResponse,
  pisaBalanceError,
  PisaBalanceMethod,
  PisaRequest,
} from "./PisaCompleteTxTypes.js";
import { Either } from "effect/Either";

export type PisaCompleteOptions = {
  changeAddress?: Address;
  collateral?: OutRef;
  mode?: PisaBalanceMethod;
};

export type Pisa = {
  completeWithPisaSafe: (
    builder: TxBuilder.TxBuilder,
    position: OutRef,
    swapAssets: Unit[],
    options?: PisaCompleteOptions,
  ) => Promise<Either<TxSignBuilder.TxSignBuilder, TransactionError>>;
  completeWithPisa: (
    builder: TxBuilder.TxBuilder,
    position: OutRef,
    swapAssets: Unit[],
    options?: PisaCompleteOptions,
  ) => Promise<TxSignBuilder.TxSignBuilder>;
  finalize: () => void;
};

// TODO: add to export lists properly
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
      pickBalancer(options.mode)(pws, position, swapAssets, options),
      Effect.provide(configLayer),
      Effect.map((result) => result),
    );
  };

  return {
    completeWithPisaSafe: (
      builder: TxBuilder.TxBuilder,

      position: OutRef,
      swapAssets: Unit[],
      options: PisaCompleteOptions = {},
    ) => {
      return makeReturn(
        mkProgram(builder, position, swapAssets, options),
      ).safeRun();
    },

    completeWithPisa: (
      builder: TxBuilder.TxBuilder,
      position: OutRef,
      swapAssets: Unit[],
      options: PisaCompleteOptions = {},
    ) => {
      return makeReturn(
        mkProgram(builder, position, swapAssets, options),
      ).unsafeRun();
    },

    finalize: () => {
      console.log("Closing Pisa WS connection");
      pws.shutDown();
    },
  };
};

export const completeSingle = (
  pisaUrl: string,
  position: OutRef,
  swapAssets: Unit[],
  options: PisaCompleteOptions = {},
) => {
  console.log("Complete single");
  const acquireWs = Effect.tryPromise({
    try: () => connect(pisaUrl),
    catch: () => pisaBalanceError("Pisa WS connection error"),
  });

  const releaseWs = (res: PisaSocket) =>
    Effect.gen(function* () {
      console.log("Release:Closing pisa WS");
      res.shutDown();
    });

  const wsResource = Effect.acquireRelease(acquireWs, releaseWs);

  return Effect.scoped(
    Effect.gen(function* () {
      const pws = yield* wsResource;
      return yield* pickBalancer(options.mode)(
        pws,
        position,
        swapAssets,
        options,
      );
    }),
  );
};

// TODO: better to decide on a single balancing mode before wrapping up integration

const completeWithRebalance = (
  pws: PisaSocket,
  position: OutRef,
  swapAssets: Unit[],
  options: PisaCompleteOptions = {},
) =>
  Effect.gen(function* () {
    console.log("Completing with Pisa by rebalancing");
    const { config } = yield* TxConfig;
    const wallet: Wallet = yield* getWallet(config);
    const walletAddress: string = yield* Effect.promise(() => wallet.address());

    const { changeAddress = walletAddress, collateral = undefined } = options;

    const compOptions = {
      coinSelection: false,
      changeAddress: changeAddress,
      localUPLCEval: false,
      setCollateral: 5_000_000n,
      canonical: false,
      includeLeftoverLovelaceAsFee: false,
      presetWalletInputs: [],
    };
    const completed = (yield* CompleteTxBuilder.complete(compOptions))[2];

    const reBalanceRequest = mkReBalanceRequest(
      position,
      swapAssets,
      completed.toTransaction(),
      walletAddress,
      changeAddress,
      collateral,
    );
    const pisaResponse = yield* runWsRequest(pws, reBalanceRequest);
    const unfixedTx = CML.Transaction.from_cbor_hex(pisaResponse.balancedCbor);

    const sigBuilder = yield* Effect.promise(() =>
      TxSignBuilder.makeTxSignBuilder(wallet, unfixedTx).complete(),
    );

    const fixedTx = yield* fixHashes(sigBuilder.toTransaction());
    return TxSignBuilder.makeTxSignBuilder(wallet, fixedTx);
  }).pipe(Effect.catchAllDefect((cause) => new RunTimeError({ cause })));

export const completeWithFakeInput = (
  pws: PisaSocket,
  position: OutRef,
  swapAssets: Unit[],
  options: PisaCompleteOptions = {},
) =>
  Effect.gen(function* () {
    console.log("Completing with Pisa via fake input");
    const { config } = yield* TxConfig;

    // TODO: revisit and make sure it is how it works
    // clone config before mutable state of TxBuilderConfig  will be further changed during lucid balancing
    // internal CML.TransactionBuilder should have initial state at this moment
    // This approach assumes that nothing yet happened with the state of CML.TransactionBuilder
    // before CompleteTxBuilder.complete(...) is called
    const clonedLayer = Layer.succeed(TxConfig, {
      config: cloneConfig(config),
    });

    const wallet: Wallet = yield* getWallet(config);
    const walletAddress: string = yield* Effect.promise(() => wallet.address());

    const { changeAddress = walletAddress, collateral = undefined } = options;

    const compOptions = {
      changeAddress: changeAddress,
    };
    const _preCompleted: TxSignBuilder.TxSignBuilder =
      (yield* CompleteTxBuilder.complete(compOptions))[2];

    const collateralSize = 5000000n; //TODO: need to be set somewhere hard for Pisa or propagated here from ops
    const requiredOutValue = config.totalOutputAssets;
    const lovelaceInTx = requiredOutValue.lovelace ?? 0n;
    const withCollateralCovered =
      collateralSize - lovelaceInTx < 0n
        ? lovelaceInTx
        : lovelaceInTx + (collateralSize - lovelaceInTx);

    const somethingToCoverFee = 2000000n;

    requiredOutValue.lovelace = withCollateralCovered + somethingToCoverFee;

    const fakeInUtxo: UTxO = {
      txHash:
        "0000000000000000000000000000000000000000000000000000000000000000",
      outputIndex: 0,
      assets: requiredOutValue,
      address: walletAddress,
    };
    const fakeBalancingUtxos = [fakeInUtxo];

    const completed = yield* Effect.provide(
      mkBuilderWithFakeIn(fakeBalancingUtxos, changeAddress),
      clonedLayer,
    );

    const request = mkFakeInBalanceRequest(
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

    const fixedSigBuilder = TxSignBuilder.makeTxSignBuilder(wallet, fixedTx);
    return fixedSigBuilder;
  }).pipe(Effect.catchAllDefect((cause) => new RunTimeError({ cause })));

const mkBuilderWithFakeIn = (fakeIns: UTxO[], changeAddress: string) =>
  Effect.gen(function* () {
    const collateralSize = 5_000_000n;
    const compOptions = {
      changeAddress: changeAddress,
      presetWalletInputs: fakeIns,
      setCollateral: collateralSize,
    };
    return (yield* CompleteTxBuilder.complete(compOptions))[2];
  });

// Utilities
const cloneConfig = (
  cfg: TxBuilder.TxBuilderConfig,
): TxBuilder.TxBuilderConfig => {
  const copyConfig = { ...cfg };
  copyConfig.txBuilder = CML.TransactionBuilder.new(
    copyConfig.lucidConfig.txbuilderconfig,
  );
  return copyConfig;
};

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

const pickBalancer = (mode?: PisaBalanceMethod) => {
  if (!mode) return completeWithFakeInput;
  switch (mode) {
    case "reBalanceCbor":
      return completeWithRebalance;
    case "balanceWithFakeInCbor":
      return completeWithFakeInput;
    default:
      const _exhaustiveCheck: never = mode;
      return _exhaustiveCheck;
  }
};

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
