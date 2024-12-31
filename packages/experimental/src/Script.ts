import * as Types from "./Core/types.js";
import * as CML from "@anastasia-labs/cardano-multiplatform-lib-nodejs";
import * as Network from "./Network.js";
import { applyDoubleCborEncoding } from "./cbor.js";
import { Data } from "@lucid-evolution/plutus";
import {
  Application,
  encodeUPLC,
  parseUPLC,
  UPLCConst,
  UPLCProgram,
} from "@harmoniclabs/uplc";
import { fromHex, toHex } from "@lucid-evolution/core-utils";
import { decode } from "cbor-x";
import { dataFromCbor } from "@harmoniclabs/plutus-data";

export type Minting = Script;
export type Spending = Script;
export type Certificate = Script;
export type Withdrawal = Script;
export type Vote = Script;
export type Propose = Script;

export type Script = { type: ScriptType; script: string };
export type ScriptType = "Native" | PlutusVersion;
export type PlutusVersion = "PlutusV1" | "PlutusV2" | "PlutusV3";

export function toCMLScript(script: Script): CML.Script {
  switch (script.type) {
    case "Native":
      return CML.Script.new_native(
        CML.NativeScript.from_cbor_hex(script.script),
      );
    case "PlutusV1":
      return CML.Script.new_plutus_v1(
        CML.PlutusV1Script.from_cbor_hex(
          applyDoubleCborEncoding(script.script),
        ),
      );
    case "PlutusV2":
      return CML.Script.new_plutus_v2(
        CML.PlutusV2Script.from_cbor_hex(
          applyDoubleCborEncoding(script.script),
        ),
      );
    case "PlutusV3":
      return CML.Script.new_plutus_v3(
        CML.PlutusV3Script.from_cbor_hex(
          applyDoubleCborEncoding(script.script),
        ),
      );
    default:
      throw new Error("No variant matched.");
  }
}

export function fromCMLScript(scriptRef: CML.Script): Script {
  const kind = scriptRef.kind();
  switch (kind) {
    case 0:
      return {
        type: "Native",
        script: scriptRef.as_native()!.to_cbor_hex(),
      };
    case 1:
      return {
        type: "PlutusV1",
        script: scriptRef.as_plutus_v1()!.to_cbor_hex(),
      };
    case 2:
      return {
        type: "PlutusV2",
        script: scriptRef.as_plutus_v2()!.to_cbor_hex(),
      };
    case 3:
      return {
        type: "PlutusV3",
        script: scriptRef.as_plutus_v3()!.to_cbor_hex(),
      };
    default:
      throw new Error("No variant matched.");
  }
}

export function mintingPolicyToId(mintingPolicy: MintingPolicy): PolicyId {
  return validatorToScriptHash(mintingPolicy);
}

/**
 * Applies a list of parameters, in the form of the `Data` type, to a CBOR encoded script.
 *
 * The `plutusScript` must be double CBOR encoded(bytes). Ensure to use the `applyDoubleCborEncoding` function.
 */
export function applyParamsToScript<T extends unknown[] = Data[]>(
  plutusScript: string,
  params: Exact<[...T]>,
  type?: T,
): string {
  const program = parseUPLC(
    decode(decode(fromHex(applyDoubleCborEncoding(plutusScript)))),
    "flat",
  );
  const parameters = (type ? Data.castTo<T>(params, type) : params) as Data[];
  const appliedProgram = parameters.reduce((body, currentParameter) => {
    const data = UPLCConst.data(dataFromCbor(Data.to(currentParameter)));
    const appliedParameter = new Application(body, data);
    return appliedParameter;
  }, program.body);

  return applyDoubleCborEncoding(
    toHex(
      encodeUPLC(new UPLCProgram(program.version, appliedProgram)).toBuffer()
        .buffer,
    ),
  );
}
