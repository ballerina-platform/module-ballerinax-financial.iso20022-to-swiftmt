// Copyright (c) 2025, WSO2 LLC. (https://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerinax/financial.iso20022.cash_management as camtIsoRecord;
import ballerinax/financial.swift.mt as swiftmt;

# Transforms a camt.106 ISO 20022 document to its corresponding SWIFT MTn91 format.
#
# + envelope - The camt.106 envelope containing the corresponding document to be transformed.
# + messageType - The SWIFT MTn91 message type to be transformed.
# + return - The transformed SWIFT MTn91 message or an error.
isolated function transformCamt106ToMtn91(camtIsoRecord:Camt106Envelope envelope, string messageType) 
    returns swiftmt:MTn91Message|error => let 
        camtIsoRecord:ChargesPerTransaction3? charges = envelope.Document.ChrgsPmtReq.Chrgs.PerTx,
        camtIsoRecord:ChargesPerTransactionRecord3[]? chargesRecord = charges?.Rcrd,
        swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52D? field52a = check getDebtorAgtDtlsForCamt105Or106(charges?.Rcrd),
        swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52D? chrgsAcctAgt = check getField52(
            envelope.Document.ChrgsPmtReq.GrpHdr.ChrgsAcctAgt?.FinInstnId,
            envelope.Document.ChrgsPmtReq.GrpHdr.ChrgsAcctAgtAcct?.Id) in {
            block1: generateBlock1(getSenderOrReceiver(envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)),
            block2: generateBlock2(messageType, getSenderOrReceiver(envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI), 
                envelope.Document.ChrgsPmtReq.GrpHdr.CreDtTm),
            block3: createMtBlock3(getUETRfromUnderlyingTx(charges?.Rcrd)),
            block4: {
                MT20: {name: MT20_NAME, msgId: {content: getMxToMTReference(charges?.ChrgsId.toString()),
                    number: NUMBER1}},
                MT21: {name:MT21_NAME, Ref: {content: getField21ForCamt105Or106(charges?.Rcrd), number: NUMBER1}},
                MT52A: field52a is swiftmt:MT52A ? field52a : chrgsAcctAgt is swiftmt:MT52A ? chrgsAcctAgt : (),
                MT52D: field52a is swiftmt:MT52D? field52a : chrgsAcctAgt is swiftmt:MT52D ? chrgsAcctAgt : (),
                MT71B: getField71B(getChargesBreakdown(charges?.Rcrd)),
                MT72: getField72ForCamt106(chargesRecord,
                    envelope.Document.ChrgsPmtReq.GrpHdr.ChrgsRqstr?.FinInstnId?.BICFI),
                MT32B: chargesRecord is camtIsoRecord:ChargesPerTransactionRecord3[] ? {
                    Ccy: {content: chargesRecord[0].TtlChrgsPerRcrd?.TtlChrgsAmt?.Ccy.toString(), number: NUMBER1}, 
                    Amnt: {content: convertDecimalToSwiftDecimal(chargesRecord[0].TtlChrgsPerRcrd?.TtlChrgsAmt?.content),
                        number: NUMBER2}} : {Ccy: {content: "", number: NUMBER1}, 
                        Amnt: {content: "NOTPROVIDED", number: NUMBER2}}}
        };

# Creates MT72 field for CAMT.106 message
#
# + chargesRecord - Array of charge transaction records
# + bic - BIC code
# + return - MT72 field or null if no data
isolated function getField72ForCamt106(
    camtIsoRecord:ChargesPerTransactionRecord3[]? chargesRecord, 
    string? bic
) returns swiftmt:MT72? {
    if chargesRecord is () {
        return createMT72WithBIC(bic);
    }

    camtIsoRecord:InstructionForInstructedAgent1? instruction = chargesRecord[0].InstrForInstdAgt;
    if instruction is () {
        return createMT72WithBIC(bic);
    }

    return createMT72WithInstruction(instruction, bic);
}

# Creates MT72 with instruction information
#
# + instruction - Instruction for agent
# + bic - BIC code
# + return - MT72 field
isolated function createMT72WithInstruction(
    camtIsoRecord:InstructionForInstructedAgent1 instruction, 
    string? bic
) returns swiftmt:MT72 {
    string narration = "";
    
    if instruction.Cd is string {
        narration = formatInstructionCode(instruction);
        if bic is string {
            return {
                name: MT72_NAME, 
                Cd: {
                    content: narration + "\n" + CHARGE_REQUEST_PREFIX + bic, 
                    number: NUMBER1
                }
            };
        }
    }

    if bic is string {
        narration += CHARGE_REQUEST_PREFIX + bic;
    }

    string? instructionInfo = instruction.InstrInf;
    if instructionInfo is string {
        narration = formatInstructionInfo(narration, instructionInfo);
    }

    return {name: MT72_NAME, Cd: {content: narration, number: NUMBER1}};
}

# Formats instruction code
#
# + instruction - Instruction for agent
# + return - Formatted instruction code
isolated function formatInstructionCode(camtIsoRecord:InstructionForInstructedAgent1 instruction) returns string {
    string narration = INSTRUCTION_CODE_PREFIX + instruction.Cd.toString() + INSTRUCTION_CODE_PREFIX;
    
    string? instructionInfo = instruction.InstrInf;
    if instructionInfo is string {
        narration = formatInstructionInfo(narration, instructionInfo);
    }
    
    return narration;
}

# Formats instruction information with line breaks
#
# + baseText - Base text to append to
# + info - Instruction information
# + return - Formatted instruction information
isolated function formatInstructionInfo(string baseText, string info) returns string {
    string result = baseText;
    if !result.endsWith(INSTRUCTION_CODE_PREFIX) {
        result += "\n" + INSTRUCTION_CODE_PREFIX;
    }

    foreach int i in 0 ... info.length() - 1 {
        if result.length() % LINE_LENGTH == 0 {
            result += "\n";
        }
        result += info[i];
    }
    
    return result;
}

# Creates MT72 with only BIC
#
# + bic - BIC code
# + return - MT72 field or null if no BIC
isolated function createMT72WithBIC(string? bic) returns swiftmt:MT72? {
    if bic is string {
        return {
            name: MT72_NAME, 
            Cd: {
                content: CHARGE_REQUEST_PREFIX + bic, 
                number: NUMBER1
            }
        };
    }
    return ();
}
