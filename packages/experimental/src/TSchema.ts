import { Schema, SchemaAST } from "effect";
import { NonEmptyReadonlyArray } from "effect/Array";
import * as Data from "../src/Data.js";
import * as CBOR from "./CBOR.js";

/**
 * Schema transformations between TypeScript types and Plutus Data
 *
 * This module provides bidirectional transformations:
 * 1. TypeScript types => Plutus Data type => CBOR hex
 * 2. CBOR hex => Plutus Data type => TypeScript types
 *
 * @since 1.0.0
 */

interface Literal<
  Literals extends NonEmptyReadonlyArray<SchemaAST.LiteralValue>,
> extends Schema.transform<typeof Data.Constr, Schema.Literal<[...Literals]>> {}

/**
 * Creates a schema for literal types with Plutus Data Constructor transformation
 *
 * @example
 * import { TSchema } from "@lucid-evolution/experimental";
 *
 * const RedeemAction = TSchema.Literal("spend", "mint", "withdraw");
 * const encoded = TSchema.unsafeEncode(RedeemAction, "spend"); // { index: 0n, fields: [] }
 * const decoded = TSchema.unsafeDecode(RedeemAction, encoded); // "spend"
 *
 * @since 1.0.0
 */
export const Literal = <
  Literals extends NonEmptyReadonlyArray<
    Exclude<SchemaAST.LiteralValue, null | bigint>
  >,
>(
  ...self: Literals
): Literal<Literals> =>
  Schema.transform(Data.Constr, Schema.Literal(...self), {
    strict: true,
    encode: (value: [...Literals][number]) => ({
      index: BigInt(self.indexOf(value)),
      fields: [],
    }),
    decode: (value: {
      readonly index: bigint;
      readonly fields: readonly any[];
    }) => self[Number(value.index)],
  });

interface Array<S extends Schema.Schema.Any> extends Schema.Array$<S> {}

/**
 * Creates a schema for arrays with Plutus list type annotation
 *
 * @example
 * import { TSchema } from "@lucid-evolution/experimental";
 *
 * const TokenList = TSchema.Array(TSchema.ByteArray);
 * const result = TSchema.unsafeDecode(TokenList, ["deadbeef", "cafe"]);
 *
 * @since 1.0.0
 */
export const Array = <S extends Schema.Schema.Any>(items: S): Array<S> =>
  Schema.Array(items).annotations({ identifier: "Array" });

interface Nullable<S extends Schema.Schema.All>
  extends Schema.transform<typeof Data.Constr, Schema.NullOr<S>> {}

/**
 * Creates a schema for nullable types that transforms to/from Plutus Data Constructor
 * Represents optional values as:
 * - Just(value) with index 0
 * - Nothing with index 1
 *
 * @example
 * import { TSchema } from "@lucid-evolution/experimental";
 *
 * const MaybeDeadline = TSchema.Nullable(TSchema.Integer);
 * const just = TSchema.unsafeEncode(MaybeDeadline, 1000n); // { index: 0n, fields: [1000n] }
 * const nothing = TSchema.unsafeEncode(MaybeDeadline, null); // { index: 1n, fields: [] }
 *
 * @since 1.0.0
 */
export const Nullable = <S extends Schema.Schema.All>(self: S): Nullable<S> =>
  Schema.transform(Data.Constr, Schema.NullOr(self), {
    strict: true,
    encode: (value) =>
      value ? { index: 0n, fields: [value] } : { index: 1n, fields: [] },
    decode: (value) =>
      value.index === 0n ? (value.fields[0] as Schema.Schema.Type<S>) : null,
  });

interface Boolean
  extends Schema.transform<
    typeof Data.Constr,
    Schema.SchemaClass<boolean, boolean, never>
  > {}

/**
 * Schema for boolean values using Plutus Data Constructor
 * - False with index 0
 * - True with index 1
 *
 * @example
 * import { TSchema } from "@lucid-evolution/experimental";
 *
 * const isLocked = TSchema.unsafeEncode(TSchema.Boolean, true); // { index: 1n, fields: [] }
 * const decoded = TSchema.unsafeDecode(TSchema.Boolean, isLocked); // true
 *
 * @since 1.0.0
 */
export const Boolean: Boolean = Schema.transform(Data.Constr, Schema.Boolean, {
  strict: true,
  encode: (boolean) =>
    boolean ? { index: 1n, fields: [] } : { index: 0n, fields: [] },
  decode: ({ index }) => index === 1n,
});

interface Struct<Fields extends Schema.Struct.Fields>
  extends Schema.transform<typeof Data.Constr, Schema.Struct<Fields>> {}

/**
 * Creates a schema for struct types using Plutus Data Constructor
 * Objects are represented as a constructor with index 0 and fields as an array
 *
 * @example
 * import { TSchema } from "@lucid-evolution/experimental";
 *
 * const Token = TSchema.Struct({
 *   policyId: TSchema.ByteArray,
 *   assetName: TSchema.ByteArray,
 *   amount: TSchema.Integer
 * });
 *
 * const encoded = TSchema.unsafeEncode(Token, {
 *   policyId: "deadbeef",
 *   assetName: "cafe",
 *   amount: 1000n
 * }); // { index: 0n, fields: ["deadbeef", "cafe", 1000n] }
 *
 * @since 1.0.0
 */
export const Struct = <Fields extends Schema.Struct.Fields>(
  fields: Fields
): Struct<Fields> =>
  Schema.transform(Data.Constr, Schema.Struct(fields), {
    strict: false,
    encode: (obj) => ({
      index: 0n,
      fields: Object.values(obj),
    }),
    decode: (constr: {
      readonly index: bigint;
      readonly fields: readonly any[];
    }) => {
      const keys = Object.keys(fields);
      return Object.fromEntries(
        keys.map((key, index) => [key, constr.fields[index]])
      );
    },
  });

interface Integer extends Schema.SchemaClass<bigint, bigint, never> {}

/**
 * Schema for Plutus Integer type
 * @since 1.0.0
 */
export const Integer: Integer = Schema.BigIntFromSelf.annotations({
  identifier: "Integer",
});

interface ByteArray extends Schema.SchemaClass<string, string, never> {}
/**
 * Schema for Plutus byte array represented as a hexadecimal string
 *
 * Byte arrays must be encoded as hexadecimal strings (e.g. "deadbeef")
 * where each byte is represented by two hexadecimal digits.
 *
 * @since 1.0.0
 */
export const ByteArray: ByteArray = Schema.String.annotations({
  identifier: "ByteArray",
});

/**
 * Decodes a value from Plutus Data Constructor to TypeScript type without error handling
 *
 * @example
 * import { TSchema } from "@lucid-evolution/experimental";
 *
 * const data = { index: 0n, fields: ["deadbeef", "cafe", 1000n] };
 * const token = TSchema.unsafeDecode(Token, data);
 * // { policyId: "deadbeef", assetName: "cafe", amount: 1000n }
 *
 * @throws {Error} If decoding fails
 * @since 1.0.0
 */
export const unsafeDecode = <A, I>(
  schema: Schema.Schema<A, I, never>,
  input: unknown,
  options?: SchemaAST.ParseOptions
) => Schema.decodeUnknownSync(schema, options)(input);

/**
 * Encodes a TypeScript value to Plutus Data Constructor without error handling
 *
 * @example
 * import { TSchema } from "@lucid-evolution/experimental";
 *
 * const token = {
 *   policyId: "deadbeef",
 *   assetName: "cafe",
 *   amount: 1000n
 * };
 * const data = TSchema.unsafeEncode(Token, token);
 * // { index: 0n, fields: ["deadbeef", "cafe", 1000n] }
 *
 * @throws {Error} If encoding fails
 * @since 1.0.0
 */
export const unsafeEncode = <A, I>(
  schema: Schema.Schema<A, I, never>,
  input: unknown,
  options?: SchemaAST.ParseOptions
) => Schema.encodeUnknownSync(schema, options)(input);

export const unsafeEncodeCBOR = <A, D extends Data.Data>(
  schema: Schema.Schema<A, D, never>,
  input: unknown
) => {
  const data = unsafeEncode(schema, input);
  return CBOR.toCBOR(data);
};

export const unsafeDecodeCBOR = <A, D extends Data.Data>(
  schema: Schema.Schema<A, D, never>,
  input: string
) => {
  const data = CBOR.fromCBOR(input);
  return unsafeDecode(schema, data);
};
