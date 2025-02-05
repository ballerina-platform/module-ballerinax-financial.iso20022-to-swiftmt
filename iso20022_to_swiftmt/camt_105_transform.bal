// Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com).
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

# Transforms a camt.105 ISO 20022 document to its corresponding SWIFT MTn90 format.
#
# + envelope - The camt.105 envelope containing the corresponding document to be transformed.
# + messageType - The SWIFT MTn90 message type to be transformed.
# + return - The transformed SWIFT MTn90 message or an error.
isolated function transformCamt105ToMtn90(camtIsoRecord:Camt105Envelope envelope, string messageType) returns swiftmt:MTn90Message|error => let
    camtIsoRecord:ChargesPerTransaction4? charges = envelope.Document.ChrgsPmtNtfctn.Chrgs.PerTx,
    swiftmt:MT32A? field32a = getField32aForCamt105(charges?.Rcrd),
    swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52D? field52a = check getDebtorAgtDtlsForCamt105(charges?.Rcrd) in {
        block1: generateBlock1(getSenderOrReceiver(envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)),
        block2: generateBlock2(messageType, getSenderOrReceiver(envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI),
                envelope.Document.ChrgsPmtNtfctn.GrpHdr.CreDtTm),
        block3: createMtBlock3(getBlock3ContentForCamt(charges?.Rcrd)),
        block4: {
            MT20: {name: MT20_NAME, msgId: {content: getMxToMTReference(charges?.ChrgsId.toString()), number: NUMBER1}},
            MT21: {name: MT21_NAME, Ref: {content: getField21Content(getField21ForCamt105(charges?.Rcrd)), number: NUMBER1}},
            MT25: {
                name: MT25_NAME,
                Acc: {
                    content: getAccountId(envelope.Document.ChrgsPmtNtfctn.GrpHdr?.ChrgsAcct?.Id?.IBAN,
                            envelope.Document.ChrgsPmtNtfctn.GrpHdr?.ChrgsAcct?.Id?.Othr?.Id),
                    number: NUMBER1
                }
            },
            MT32C: field32a?.name == "32C" ? field32a : (),
            MT32D: field32a?.name == "32D" ? field32a : (),
            MT52A: field52a is swiftmt:MT52A ? field52a : (),
            MT52D: field52a is swiftmt:MT52D ? field52a : (),
            MT71B: getField71B(getChargesBreakdown(charges?.Rcrd)),
            MT72: getField72ForCamt105(envelope.Document.ChrgsPmtNtfctn.GrpHdr.ChrgsRqstr?.FinInstnId?.BICFI)
        }
    };

isolated function getChargesBreakdown(camtIsoRecord:ChargesPerTransactionRecord3[]|camtIsoRecord:ChargesPerTransactionRecord4[]? rec) returns camtIsoRecord:ChargesBreakdown1[]? {
    if rec is camtIsoRecord:ChargesPerTransactionRecord3[]|camtIsoRecord:ChargesPerTransactionRecord4[] {
        return rec[0].ChrgsBrkdwn;
    }
    return ();
}

isolated function getField21ForCamt105(camtIsoRecord:ChargesPerTransactionRecord4[]? recordsArray) returns string {
    if recordsArray is camtIsoRecord:ChargesPerTransactionRecord4[] {
        [string?, string?, string?, string?] [instrId, endToEndId, msgId, acctSvcrRef] = [
            recordsArray[0].UndrlygTx?.InstrId,
            recordsArray[0].UndrlygTx?.EndToEndId,
            recordsArray[0].UndrlygTx?.MsgId,
            recordsArray[0].UndrlygTx?.AcctSvcrRef
        ];
        if instrId is string {
            return instrId;
        }
        if endToEndId is string {
            return endToEndId;
        }
        if msgId is string {
            return msgId;
        }
        if acctSvcrRef is string {
            return acctSvcrRef;
        }
    }
    return "NOTPROVIDED";
}

isolated function getDebtorAgtDtlsForCamt105(camtIsoRecord:ChargesPerTransactionRecord4[]? recordsArray)
    returns swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT52D?|error {
    if recordsArray is camtIsoRecord:ChargesPerTransactionRecord4[] {
        return getField52(recordsArray[0].DbtrAgt?.FinInstnId, recordsArray[0].DbtrAgtAcct?.Id);
    }
    return ();
}

isolated function getField32aForCamt105(camtIsoRecord:ChargesPerTransactionRecord4[]? recordsArray) returns swiftmt:MT32A? {
    if recordsArray is camtIsoRecord:ChargesPerTransactionRecord4[] {
        if recordsArray[0].TtlChrgsPerRcrd?.CdtDbtInd.toString() == "CRDT" {
            return {
                name: MT32C_NAME,
                Dt: {content: convertToSWIFTStandardDate(recordsArray[0].ValDt?.Dt), number: NUMBER1},
                Ccy: {content: recordsArray[0].TtlChrgsPerRcrd?.TtlChrgsAmt?.Ccy.toString(), number: NUMBER2},
                Amnt: {
                    content: convertDecimalNumberToSwiftDecimal(recordsArray[0].TtlChrgsPerRcrd?.TtlChrgsAmt?.content),
                    number: NUMBER3
                }
            };
        }
        if recordsArray[0].TtlChrgsPerRcrd?.CdtDbtInd.toString() == "DBIT" {
            return {
                name: MT32D_NAME,
                Dt: {content: convertToSWIFTStandardDate(recordsArray[0].ValDt?.Dt), number: NUMBER1},
                Ccy: {content: recordsArray[0].TtlChrgsPerRcrd?.TtlChrgsAmt?.Ccy.toString(), number: NUMBER2},
                Amnt: {
                    content: convertDecimalNumberToSwiftDecimal(recordsArray[0].TtlChrgsPerRcrd?.TtlChrgsAmt?.content),
                    number: NUMBER3
                }
            };
        }

    }
    return ();
}

isolated function getField72ForCamt105(string? bic) returns swiftmt:MT72? {
    if bic is string {
        return {name: MT72_NAME, Cd: {content: "/CHRQ/" + bic, number: NUMBER1}};
    }
    return ();
}
