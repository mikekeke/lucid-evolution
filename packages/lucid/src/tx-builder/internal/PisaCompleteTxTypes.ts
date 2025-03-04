import {
  Effect,
  pipe,
  Record,
  Array as _Array,
  BigInt as _BigInt,
  Tuple,
  Option,
  Layer,
  // Schema,
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
import * as S from "@effect/schema/Schema";
import { v4 as uuidv4 } from 'uuid';

type PisaRequest = {
  requestId: string,
  requestType: string,
  payload: {
    positionRef: string,
    swapAssets: string[],
    unbalancedTxCbor: string,
    userAddresses: string[],
    userChangeAddress: string,
    userCollateral: string | null,
  }
}

// const mkReBalanceRequest = (): PisaRequest => {

// }

const renderOutRef = (outRef: OutRef): string => {
  return outRef.txHash + "#" + outRef.outputIndex
}

export const mkFakeInBalanceRequest = (
  position: OutRef,
  swapAssets: Unit[],
  transaction: CML.Transaction,
  walletAddress: Address,
  changeAddress: Address,
  collateral?: OutRef
): PisaRequest => {
  return {
    requestId: uuidv4(),
    requestType: "balanceWithFakeInCbor",
    payload: {
      positionRef: renderOutRef(position),
      swapAssets: swapAssets,
      unbalancedTxCbor: transaction.to_cbor_hex(),
      userAddresses: [walletAddress],
      userChangeAddress: changeAddress,
      userCollateral: collateral ? renderOutRef(collateral) : null,
    },
  }
}

// Response - success
const PisaSuccessResponseSchema = S.Struct({
  status: S.Literal("success"),
  data: S.Struct({
    balancedCbor: S.String,
    requestId: S.UUID
  })
})

type PisaSuccessResponseT = S.Schema.Type<typeof PisaSuccessResponseSchema>
interface PisaSuccessResponse extends S.Schema.Type<typeof PisaSuccessResponseSchema> { }

// Response - fail
const PisaFailResponseSchema = S.Struct({
  status: S.Literal("fail"),
  data: S.Union(
    S.Struct({ error: S.String, failedRequest: S.String }),
    S.Struct({ error: S.String, requestId: S.UUID }),
  )
})

type PisaFailResponseT = S.Schema.Type<typeof PisaFailResponseSchema>
interface PisaFailResponse extends S.Schema.Type<typeof PisaFailResponseSchema> { }

// Response - error
const PisaErrorResponseSchema = S.Struct({
  status: S.Literal("error"),
  data: S.Struct({ error: S.String, requestId: S.UUID }),
})

type PisaErrorResponseT = S.Schema.Type<typeof PisaErrorResponseSchema>
export interface PisaErrorResponse extends S.Schema.Type<typeof PisaErrorResponseSchema> { }


const PisaResponseSchema =
  S.Union(
    PisaSuccessResponseSchema,
    PisaFailResponseSchema,
    PisaErrorResponseSchema
  )

type PisaResponseT = S.Schema.Type<typeof PisaResponseSchema>