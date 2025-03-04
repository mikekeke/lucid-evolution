import {
  Effect,
  pipe,
  Record,
  Array as _Array,
  BigInt as _BigInt,
  Tuple,
  Option,
  Layer,
  Schema,
} from "effect";
import {
  Address,
  Assets,
  EvalRedeemer,
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
import {
  assetsToValue,
  coreToTxOutput,
  isEqualUTxO,
  selectUTxOs,
  sortUTxOs,
  stringify,
  utxoToCore,
  utxoToTransactionInput,
  utxoToTransactionOutput,
  toCMLRedeemerTag,
  valueToAssets,
} from "@lucid-evolution/utils";
import { SLOT_CONFIG_NETWORK } from "@lucid-evolution/plutus";
import { collectFromUTxO } from "./Collect.js";
import { TxConfig } from "./Service.js";
import { isError } from "effect/Predicate";
import { makeSubmit, TxSigned } from "../../tx-submit/TxSubmit.js";
import { sum } from "effect/BigInt";
import * as CompleteTxBuilder from "./CompleteTxBuilder.js";
import { completePartialPrograms } from "./CompleteTxBuilder.js";
import { v4 as uuidv4 } from 'uuid';
import { mkFakeInBalanceRequest } from "./PisaCompleteTxTypes.js";


const connect = async (url: string): Promise<WebSocket> => {
  return new Promise((resolve) => {
    const wss = new WebSocket(url);
    wss.onclose = (_) => {
      console.log("ONCLOSE");
    };
    wss.onopen = (ev) => {
      console.log("Connected to Pisa Server");
      resolve(wss);
    };
  });
};

export type Pisa = {
  completeWithPisaUnsafe: (
    position: OutRef,
    swapAssets: Unit[],
    options?: PisaCompleteOptions,
  ) => Promise<TxSignBuilder.TxSignBuilder>;
  finalize: () => void;
};

// TODO: add to export lists properly
export const Pisa = async (
  pisaUrl: string,
  builderConf: TxBuilder.TxBuilderConfig,
): Promise<Pisa> => {
  const ws: WebSocket = await connect(pisaUrl);

  return {
    completeWithPisaUnsafe: (
      position: OutRef,
      swapAssets: Unit[],
      options: PisaCompleteOptions = {},
    ) => {
      const configLayer = Layer.succeed(TxConfig, { config: builderConf });
      return makeReturn(
        pipe(
          pickBalancer(options.mode)(ws, position, swapAssets, options),
          Effect.provide(configLayer),
          Effect.map((result) => result),
        ),
      ).unsafeRun();
    },

    finalize: () => {
      console.log("Closing Pisa WS connection");
      ws.close();
    },
  };
};

export const completeSingle = (
  pisaUrl: string,
  position: OutRef,
  swapAssets: Unit[],
  options: PisaCompleteOptions = {},
) =>
  Effect.gen(function* () {
    const ws = yield* Effect.promise(() => connect(pisaUrl));
    const completeAndBalance = pickBalancer(options.mode)
    const res = yield* completeAndBalance(ws, position, swapAssets.map(toPisaRepr), options); //TODO: debugging rebalancing
    ws.close();
    return res;
  });

const pickBalancer = (mode?: PisaBalancingMode) => {
  if (!mode) return completeCoreFakeInput;
  switch (mode) {
    case "ReBalance":
      return completeCoreRebalance
    case "FakeInBalance":
      return completeCoreFakeInput
    default:
      throw new Error("pickBalancer: Should not happen") //TODO: better way to handle this
  }
}


// TODO: proper type for pisa request
// TODO: verify that response id matches request id
const wsRequestResponse = (ws: WebSocket, pisaRequest: any) => Effect.gen(function* () {
  ws.send(JSON.stringify(pisaRequest));
  const waitReceiveEff: Effect.Effect<string, never, never> = Effect.promise(
    () =>
      new Promise((resolve) => {
        ws.onmessage = (msg) => {
          resolve(msg.data.text());
        };
      }),
  );
  const rawResponse: string = yield* waitReceiveEff;
  return JSON.parse(rawResponse) // TODO: add schema and parse with validation
})

const toPisaRepr = (unit: Unit): string => {
  const index = 28 * 2;
  return unit.substring(0, index) + "." + unit.substring(index);
}

export const completeCoreRebalance = (
  ws: WebSocket,
  position: OutRef,
  swapAssets: Unit[],
  options: PisaCompleteOptions = {},
) =>
  Effect.gen(function* () {
    console.log("Completing with Pisa by rebalancing");
    const { config } = yield* TxConfig;
    const wallet: Wallet = yield* pipe(
      Effect.fromNullable(config.lucidConfig.wallet),
      Effect.orElseFail(() => completeTxError(ERROR_MESSAGE.MISSING_WALLET)),
    );
    const walletAddress: string = yield* Effect.promise(() => wallet.address());


    const { changeAddress = walletAddress, collateral = null } = options;

    const compOptions = {
      coinSelection: false,
      changeAddress: changeAddress,
      localUPLCEval: false,
      setCollateral: 5_000_000n,
      canonical: false,
      includeLeftoverLovelaceAsFee: false,
      presetWalletInputs: [],
    }
    const completed = (yield* CompleteTxBuilder.complete(compOptions))[2]


    const reBalanceRequest = {
      requestId: "6fb8473d-807c-40b6-b4ca-478664b96ef4", // TODO: generate UUID
      requestType: "reBalanceCbor",
      payload: {
        positionRef: position,
        swapAssets: swapAssets,
        unbalancedTxCbor: completed.toTransaction().to_cbor_hex(),
        userAddresses: [walletAddress],
        userChangeAddress: changeAddress,
        userCollateral: collateral,
      },
    };

    const parsedResponse = yield* wsRequestResponse(ws, reBalanceRequest);
    const unfixedTx = CML.Transaction.from_cbor_hex(parsedResponse.data.balancedCbor)
    console.log("unfixedTx", unfixedTx.to_js_value())

    const sigBuilderComplete = TxSignBuilder.makeTxSignBuilder(
      wallet,
      unfixedTx,
    ).complete()

    const sigBuilder = yield* Effect.promise(() => sigBuilderComplete);

    const costModels = config.lucidConfig.costModels
    const fixedTx = yield* Effect.promise(() => fixHashes(sigBuilder.toTransaction(), costModels));

    const fixedSigBuilder = TxSignBuilder.makeTxSignBuilder(
      wallet,
      fixedTx
    )
    return fixedSigBuilder;

  }).pipe(Effect.catchAllDefect((cause) => new RunTimeError({ cause })));

type PisaBalancingMode = "ReBalance" | "FakeInBalance"

export type PisaCompleteOptions = {
  changeAddress?: Address;

  collateral?: OutRef;

  mode?: PisaBalancingMode

  // TODO: should tie it to Atlas ability to select UTxO with exactly 5 Ada for collateral?
  // TODO: add hashes fix
  // /**
  //  * Amount to set as collateral
  //  * @default 5_000_000n
  //  */
  // setCollateral?: bigint;
};


const cloneConfig = (cfg: TxBuilder.TxBuilderConfig): TxBuilder.TxBuilderConfig => {
  const copyConfig = { ...cfg }
  copyConfig.txBuilder = CML.TransactionBuilder.new(copyConfig.lucidConfig.txbuilderconfig)
  return copyConfig

}

const completeWithFakeIn = (fakeIns: UTxO[], changeAddress: string) => Effect.gen(function* () {

  const collateralSize = 5_000_000n
  const compOptions = {
    changeAddress: changeAddress,
    presetWalletInputs: fakeIns,
    setCollateral: collateralSize,
  }
  return (yield* CompleteTxBuilder.complete(compOptions))[2]
});

export const completeCoreFakeInput = (
  ws: WebSocket,
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
    const clonedLayer = Layer.succeed(TxConfig, { config: cloneConfig(config) });

    const wallet: Wallet = yield* pipe(
      Effect.fromNullable(config.lucidConfig.wallet),
      Effect.orElseFail(() => completeTxError(ERROR_MESSAGE.MISSING_WALLET)),
    );
    const walletAddress: string = yield* Effect.promise(() => wallet.address());


    const { changeAddress = walletAddress, collateral = undefined } = options;

    const compOptions = {
      changeAddress: changeAddress,
    }
    const _preCompleted: TxSignBuilder.TxSignBuilder = (yield* CompleteTxBuilder.complete(compOptions))[2]
    console.dir({ preCompleted: _preCompleted.toTransaction().to_js_value() }, { depth: null })


    const collateralSize = 5000000n //TODO: need to be set somewhere hard for Pisa or propagated here from ops
    const requiredOutValue = config.totalOutputAssets;
    const lovelaceInTx = requiredOutValue.lovelace ?? 0n
    const withCollateralCovered =
      (collateralSize - lovelaceInTx < 0n) ? lovelaceInTx : lovelaceInTx + (collateralSize - lovelaceInTx)

    const somethingToCoverFee = 2000000n

    requiredOutValue.lovelace = withCollateralCovered + somethingToCoverFee

    const fakeInUtxo: UTxO = {
      txHash:
        "0000000000000000000000000000000000000000000000000000000000000000",
      outputIndex: 0,
      assets: requiredOutValue,
      address: walletAddress,
    };
    const fakeBalancingUtxos = [fakeInUtxo]

    const completed = yield* Effect.provide(completeWithFakeIn(fakeBalancingUtxos, changeAddress), clonedLayer)

    const reBalanceRequest = mkFakeInBalanceRequest(
      position,
      swapAssets,
      completed.toTransaction(),
      walletAddress,
      changeAddress,
      collateral
    );

    const parsedResponse = yield* wsRequestResponse(ws, reBalanceRequest);

    const sigBuilder = yield* Effect.promise(() =>
      TxSignBuilder.makeTxSignBuilder(
        wallet,
        CML.Transaction.from_cbor_hex(parsedResponse.data.balancedCbor),
      ).complete());

    const costModels = config.lucidConfig.costModels
    const fixedTx = yield* Effect.promise(() => fixHashes(sigBuilder.toTransaction(), costModels));

    const fixedSigBuilder = TxSignBuilder.makeTxSignBuilder(
      wallet,
      fixedTx
    )
    return fixedSigBuilder;

  }).pipe(Effect.catchAllDefect((cause) => new RunTimeError({ cause })));


export const completeTxError = (cause: unknown) =>
  new TxBuilderError({ cause: `{ Complete: ${cause} }` });

export const fixHashes = async (tx: CML.Transaction, costModels: CML.CostModels) => {
  const body = tx.body();
  const witnessSet = tx.witness_set();

  const redeemers = witnessSet.redeemers();
  const datums = witnessSet.plutus_datums() || CML.PlutusDataList.new();


  if (!redeemers) {
    throw new Error("Error: Tx balanced with Pisa missing redeemers")
  }
  const integrityHash = CML.calc_script_data_hash(
    redeemers,
    datums,
    costModels,
    witnessSet.languages()
  )
  if (!integrityHash) {
    throw new Error("Error: Could not calculate integrity hash for tx balanced with Pisa")
  }

  body.set_script_data_hash(integrityHash)

  const auxDat = tx.auxiliary_data();
  if (auxDat) {
    body.set_auxiliary_data_hash(CML.hash_auxiliary_data(auxDat))
  }

  const newCmlTx = CML.Transaction.new(
    body,
    tx.witness_set(),
    tx.is_valid(),
    tx.auxiliary_data(),
  )
  return newCmlTx

}
