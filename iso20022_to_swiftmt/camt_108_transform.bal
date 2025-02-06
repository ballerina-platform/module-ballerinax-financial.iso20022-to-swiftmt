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

# Transforms a camt.108 ISO 20022 document to its corresponding SWIFT MT111 format.
#
# + envelope - The camt.108 envelope containing the corresponding document to be transformed.
# + messageType - The SWIFT MT111 message type to be transformed.
# + return - The transformed SWIFT MT111 message or an error.
isolated function transformCamt108ToMt111(camtIsoRecord:Camt108Envelope envelope, string messageType) returns swiftmt:MT111Message|error => let
    camtIsoRecord:Cheque20 cheque = envelope.Document.ChqCxlOrStopReq.Chq[0],
    swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52D? field52a = check getField52(cheque.DrwrAgt?.FinInstnId, cheque.DrwrAgtAcct?.Id, isOptionBPresent = true) in {
        block1: generateBlock1(getSenderOrReceiver(envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)),
        block2: generateBlock2(messageType, getSenderOrReceiver(envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI),
                envelope.Document.ChqCxlOrStopReq.GrpHdr.CreDtTm),
        block4: {
            MT20: {name: MT20_NAME, msgId: {content: getMxToMTReference(envelope.Document.ChqCxlOrStopReq.GrpHdr.MsgId), number: NUMBER1}},
            MT21: {name: MT21_NAME, Ref: {content: cheque.ChqNb, number: NUMBER1}},
            MT30: {name: MT30_NAME, Dt: {content: convertToSWIFTStandardDate(cheque.IsseDt), number: NUMBER1}},
            MT32A: cheque.FctvDt?.Dt is string ? {
                    name: MT32A_NAME,
                    Dt: {content: convertToSWIFTStandardDate(cheque.FctvDt?.Dt), number: NUMBER1},
                    Ccy: {content: cheque.Amt.Ccy, number: NUMBER2},
                    Amnt: {content: convertDecimalNumberToSwiftDecimal(cheque.Amt.content), number: NUMBER3}
                } : (),
            MT32B: cheque.FctvDt?.Dt !is string ? {
                    name: MT32B_NAME,
                    Ccy: {content: cheque.Amt.Ccy, number: NUMBER1},
                    Amnt: {content: convertDecimalNumberToSwiftDecimal(cheque.Amt.content), number: NUMBER2}
                } : (),
            MT52A: field52a is swiftmt:MT52A ? field52a : (),
            MT52B: field52a is swiftmt:MT52B ? field52a : (),
            MT52D: field52a is swiftmt:MT52D ? field52a : (),
            MT59: getField59aForCamt108Or109(cheque.Pyee, cheque.PyeeAcct?.Id),
            MT75: getField75ForCamt108(cheque.ChqCxlOrStopRsn)
        }
    };

isolated function getField59aForCamt108Or109(camtIsoRecord:PartyIdentification272? creditor, camtIsoRecord:AccountIdentification4Choice? account) returns swiftmt:MT59? {
    [string?, camtIsoRecord:Max70Text[]?, string?, string?, string?, string?]
        [name, address, iban, bban, townName, countryCode] = [
        creditor?.Nm,
        creditor?.PstlAdr?.AdrLine,
        account?.IBAN,
        account?.Othr?.Id,
        creditor?.PstlAdr?.TwnNm,
        creditor?.PstlAdr?.Ctry
    ];
    if countryCode is string {
        swiftmt:MT59 fieldMt59 = {
            name: MT59_NAME,
            Acc: getAccount(getAccountId(iban, bban)),
            Nm: [{content: "1/" + getMandatoryField(name), number: NUMBER2}],
            AdrsLine: getAddressLine(address, 3, true, townName, countryCode, creditor?.PstlAdr, false, true)
        };
        return fieldMt59;
    }
    if name is string || address is camtIsoRecord:Max70Text[] || !(getAccountId(iban, bban).equalsIgnoreCaseAscii("")) {
        swiftmt:MT59 fieldMt59 = {
            name: MT59_NAME,
            Acc: getAccount(getAccountId(iban, bban)),
            Nm: [{content: getMandatoryField(name), number: NUMBER2}],
            // AdrsLine: getAddressLine(address)
            AdrsLine: getAddressLine(address, 3, true, townName, countryCode, creditor?.PstlAdr, false, true)

        };
        return fieldMt59;
    }
    return ();
}

isolated function getField75ForCamt108(camtIsoRecord:ChequeCancellationReason1? cancelReason) returns swiftmt:MT75? {
    if cancelReason is camtIsoRecord:ChequeCancellationReason1 {
        string? reason = chequeCancelReasonCode[cancelReason.Rsn.Cd.toString()];
        string narration = "";
        if reason is string {
            narration = "/" + reason + "/";
            if cancelReason.AddtlInf is string {
                narration = getNarration(cancelReason.AddtlInf.toString(), narration, 0)[0];
            }
            return {name: MT75_NAME, Nrtv: {content: narration, number: NUMBER1}};
        }
    }
    return ();
}
