import { Effect, pipe } from "effect";
import { StakeContract, User, MintContract } from "./services";
import { Constr, Data } from "@lucid-evolution/plutus";
import { fromText, RedeemerBuilder, UTxO } from "../../src";
import {
  handleSignSubmit,
  handleSignSubmitWithoutValidation,
  withLogNoRetry,
  withLogRetry,
} from "./utils";

export const depositFunds = Effect.gen(function* () {
  const { user } = yield* User;
  const datum = Data.void();
  const stakeContract = yield* StakeContract;
  const mintContract = yield* MintContract;

  let txBuilder = user.newTx();

  // Lock 10 UTxOs at Stake Contract to test input index generated by RedeemerBuilder
  // for every script input when it will be later spent 
  for (let i = 0; i < 10; i++) {
    txBuilder = txBuilder.pay.ToAddressWithData(
      stakeContract.contractAddress,
      {
        kind: "inline",
        value: datum,
      },
      { lovelace: 1_000_000n },
    );
  }

  // Lock 3 UTxOs at Mint Contract to test input index generated by RedeemerBuilder
  // for selected script inputs when it will be later spent
  for (let i = 0; i < 3; i++) {
    txBuilder = txBuilder.pay.ToAddressWithData(
      mintContract.contractAddress,
      {
        kind: "inline",
        value: datum,
      },
      { lovelace: 1_000_000n },
    );
  }

  const signBuilder = yield* txBuilder.completeProgram();

  return signBuilder;
}).pipe(Effect.flatMap(handleSignSubmit), withLogRetry);

export const collectFunds = Effect.gen(function* ($) {
  const { user } = yield* User;
  const stakeContract = yield* StakeContract;
  const mintContract = yield* MintContract;
  const addr = yield* Effect.tryPromise(() => user.wallet().address());

  const stakeUtxos = yield* Effect.tryPromise(() =>
    user.utxosAt(stakeContract.contractAddress),
  );
  const mintUtxos = yield* Effect.tryPromise(() =>
    user.utxosAt(mintContract.contractAddress),
  );
  // console.log("Total number of utxos: " + allUtxos.length);
  const selectedStakeUTxOs = stakeUtxos.slice(0, 10);
  const selectedMintUTxOs = mintUtxos.slice(0, 3);

  const rdmrBuilderSelfSpend: RedeemerBuilder = {
    kind: "self",
    makeRedeemer: (inputIndex: bigint) => {
      return Data.to(new Constr(1, [inputIndex]));
    },
  };

  const rdmrBuilderSelectedSpend: RedeemerBuilder = {
    kind: "selected",
    makeRedeemer: (inputIndices: bigint[]) => {
      return Data.to(new Constr(1, [new Constr(0, [inputIndices])]));
    },
    inputs: selectedMintUTxOs,
  };  

  let txBuilder = user
    .newTx()
    .collectFrom(selectedStakeUTxOs, rdmrBuilderSelfSpend)
    .collectFrom(selectedMintUTxOs, rdmrBuilderSelectedSpend)

  selectedStakeUTxOs.forEach((utxo: UTxO) => {
    txBuilder = txBuilder.pay.ToAddressWithData(
      stakeContract.contractAddress,
      {
        kind: "inline",
        value: Data.void(),
      },
      utxo.assets,
    );
  });

  selectedMintUTxOs.forEach((utxo: UTxO) => {
    txBuilder = txBuilder.pay.ToAddressWithData(
      mintContract.contractAddress,
      {
        kind: "inline",
        value: Data.void(),
      },
      utxo.assets,
    );
  });

  const rdmrBuilderWithdraw: RedeemerBuilder = {
    kind: "selected",
    makeRedeemer: (inputIndices: bigint[]) => {
      return Data.to(new Constr(0, [inputIndices]));
    },
    inputs: selectedStakeUTxOs,
  };

  const rdmrBuilderMint: RedeemerBuilder = {
    kind: "selected",
    makeRedeemer: (inputIndices: bigint[]) => {
      return Data.to(new Constr(0, [inputIndices]));
    },
    inputs: selectedMintUTxOs,
  };

  const signBuilder = yield* txBuilder
    .withdraw(stakeContract.rewardAddress, 0n, rdmrBuilderWithdraw)
    .attach.WithdrawalValidator(stakeContract.stake)
    .mintAssets({
      [mintContract.policyId + fromText("Test")]: 1n
    }, rdmrBuilderMint)
    .attach.MintingPolicy(mintContract.mint)
    .completeProgram();
  return signBuilder;
}).pipe(Effect.flatMap(handleSignSubmit), withLogRetry);

export const registerStake = Effect.gen(function* ($) {
  const { user } = yield* User;
  const { rewardAddress } = yield* StakeContract;
  const signBuilder = yield* user
    .newTx()
    .registerStake(rewardAddress)
    .completeProgram();
  return signBuilder;
}).pipe(
  Effect.flatMap(handleSignSubmit),
  Effect.catchTag("TxSubmitError", (error) =>
    error.message.includes("StakeKeyAlreadyRegisteredDELEG")
      ? Effect.void
      : Effect.fail(error),
  ),
  withLogRetry,
);
