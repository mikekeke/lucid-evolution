import { Effect, Array as _Array, BigInt as _BigInt } from "effect";
import { Address, OutRef, Unit } from "@lucid-evolution/core-types";
import { TxBuilderError } from "../../Errors.js";
import { CML } from "../../core.js";
import * as S from "@effect/schema/Schema";
import { v4 as uuidv4 } from "uuid";
import { ParseError } from "@effect/schema/ParseResult";

export type PisaRequest = {
  requestId: string;
  requestType: string;
  payload: {
    positionRef: string;
    swapAssets: string[];
    unbalancedTxCbor: string;
    userAddresses: string[];
    userChangeAddress: string;
    userCollateral: string | null;
  };
};

const renderOutRef = (outRef: OutRef): string => {
  return outRef.txHash + "#" + outRef.outputIndex;
};

const toPiaAssetRepr = (unit: Unit): string => {
  const index = 28 * 2;
  return unit.substring(0, index) + "." + unit.substring(index);
};

export type PisaBalanceMethod = "reBalanceCbor" | "balanceWithFakeInCbor";

export const mkRequest = (
  balanceMethod: PisaBalanceMethod,
  position: OutRef,
  swapAssets: Unit[],
  transaction: CML.Transaction,
  walletAddress: Address,
  changeAddress: Address,
  collateral?: OutRef,
): PisaRequest => {
  return {
    requestId: uuidv4(),
    requestType: balanceMethod,
    payload: {
      positionRef: renderOutRef(position),
      swapAssets: swapAssets.map(toPiaAssetRepr),
      unbalancedTxCbor: transaction.to_cbor_hex(),
      userAddresses: [walletAddress],
      userChangeAddress: changeAddress,
      userCollateral: collateral ? renderOutRef(collateral) : null,
    },
  };
};

export const mkFakeInBalanceRequest = (
  position: OutRef,
  swapAssets: Unit[],
  transaction: CML.Transaction,
  walletAddress: Address,
  changeAddress: Address,
  collateral?: OutRef,
): PisaRequest => {
  return mkRequest(
    "balanceWithFakeInCbor",
    position,
    swapAssets,
    transaction,
    walletAddress,
    changeAddress,
    collateral,
  );
};

export const mkReBalanceRequest = (
  position: OutRef,
  swapAssets: Unit[],
  transaction: CML.Transaction,
  walletAddress: Address,
  changeAddress: Address,
  collateral?: OutRef,
): PisaRequest => {
  return mkRequest(
    "reBalanceCbor",
    position,
    swapAssets,
    transaction,
    walletAddress,
    changeAddress,
    collateral,
  );
};

// Response - success
const PisaSuccessResponseSchema = S.Struct({
  status: S.Literal("success"),
  data: S.Struct({
    balancedCbor: S.String,
    requestId: S.UUID,
  }),
});

// Response - fail
const PisaFailResponseSchema = S.Struct({
  status: S.Literal("fail"),
  data: S.Union(
    S.Struct({ error: S.String, failedRequest: S.String }),
    S.Struct({ error: S.String, requestId: S.UUID }),
  ),
});

// Response - error
const PisaErrorResponseSchema = S.Struct({
  status: S.Literal("error"),
  data: S.Struct({ error: S.String, requestId: S.UUID }),
});

export interface PisaErrorResponse
  extends S.Schema.Type<typeof PisaErrorResponseSchema> {}

const PisaResponseSchema = S.Union(
  PisaSuccessResponseSchema,
  PisaFailResponseSchema,
  PisaErrorResponseSchema,
);

export type PisaResponse = S.Schema.Type<typeof PisaResponseSchema>;

export const parseResponse = (
  rawResponse: string,
): Effect.Effect<PisaResponse, ParseError, never> => {
  return S.decodeUnknown(PisaResponseSchema)(JSON.parse(rawResponse));
};

export const parseSuccessResponse = (
  rawResponse: string,
): Effect.Effect<
  { readonly requestId: string; readonly balancedCbor: string },
  TxBuilderError,
  never
> => {
  const checkResponse = (r: PisaResponse) => {
    switch (r.status) {
      case "success":
        return Effect.succeed(r.data);
      case "fail":
        return Effect.fail(pisaBalanceError(JSON.stringify(r.data)));
      case "error":
        return Effect.fail(pisaBalanceError(JSON.stringify(r.data)));
      default:
        const _exhaustiveCheck: never = r;
        return _exhaustiveCheck;
    }
  };

  return Effect.matchEffect(parseResponse(rawResponse), {
    onFailure: (error) => Effect.fail(pisaBalanceError(error)),
    onSuccess: (resp) => checkResponse(resp),
  });
};

export const pisaBalanceError = (error: unknown) =>
  new TxBuilderError({ cause: `{ Pisa balance: ${error} }` });

export const completeTxError = (cause: unknown) =>
  new TxBuilderError({ cause: `{ Complete: ${cause} }` });
