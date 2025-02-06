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

# Transforms a camt.109 ISO 20022 document to its corresponding SWIFT MT112 format.
#
# + envelope - The camt.109 envelope containing the corresponding document to be transformed.
# + messageType - The SWIFT MT112 message type to be transformed.
# + return - The transformed SWIFT MT112 message or an error.
isolated function transformCamt109ToMt112(camtIsoRecord:Camt109Envelope envelope, string messageType) returns swiftmt:MT112Message|error => let
    camtIsoRecord:Cheque18 cheque = envelope.Document.ChqCxlOrStopRpt.Chq[0],
    swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52D? field52a = check getField52(cheque.DrwrAgt?.FinInstnId, cheque.DrwrAgtAcct?.Id, isOptionBPresent = true) in {
        block1: generateBlock1(getSenderOrReceiver(envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)),
        block2: generateBlock2(messageType, getSenderOrReceiver(envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI),
                envelope.Document.ChqCxlOrStopRpt.GrpHdr.CreDtTm),
        block4: {
            MT20: {name: MT20_NAME, msgId: {content: getMxToMTReference(envelope.Document.ChqCxlOrStopRpt.GrpHdr.MsgId), number: NUMBER1}},
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
            MT76: getField76ForCamt109(cheque.ChqCxlOrStopSts)
        }
    };

# Get field 59 for camt 108 or 109.
#
# + cancelStatus - The cheque cancellation status.
# + return - return the transformed SWIFT MT76 message or an error.
isolated function getField76ForCamt109(camtIsoRecord:ChequeCancellationStatus1? cancelStatus) returns swiftmt:MT76 {
    if cancelStatus is camtIsoRecord:ChequeCancellationStatus1 {
        // string? code = chequeCancelReasonCode[cancelStatus.Sts.Cd.toString()];
        // string answers = "/" + code "/" + cancelStatus.AddtlInf.toString();
        // return {name: MT76_NAME, Nrtv: {content: appendSubFieldToTextField(cancelStatus), number: NUMBER1}};
        string? code = chequeCancelStatusCode[cancelStatus.Sts.Cd.toString()];
        string narration = "";
        if code is string {
            narration = "/" + code + "/";
            if cancelStatus.AddtlInf is string {
                narration = narration + cancelStatus.AddtlInf.toString();
            }
            return {name: MT76_NAME, Nrtv: {content: appendSubFieldToTextField(narration), number: NUMBER1}};
        }
    }
    return {name: MT76_NAME, Nrtv: {content: "/NOTPROVIDED/", number: NUMBER1}};
}
