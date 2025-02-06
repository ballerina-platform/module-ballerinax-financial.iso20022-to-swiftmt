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

# This function transforms a camt.029 ISO 20022 message into an MTn96 SWIFT format message.
#
# + envelope - The camt.029 envelope containing the corresponding document to be transformed.
# + messageType - The SWIFT MTn96 message type to be transformed.
# + return - Returns an MTn96 message in the `swiftmt:MTn96Message` format if successful, otherwise returns an error.
isolated function transformCamt029ToMtn96(camtIsoRecord:Camt029Envelope envelope, string messageType) returns swiftmt:MTn96Message|error => let
    camtIsoRecord:PaymentTransaction152 cancellationDtls = check getTransactionInfoAndStsFromCamt029(check getCancellationDetailsFromCamt029(envelope.Document.RsltnOfInvstgtn.CxlDtls)),
    string status = generateStatus(envelope.Document.RsltnOfInvstgtn),
    var field76 = getCamtField76(status),
    var field77A = getCamtField77A(status, envelope.Document.RsltnOfInvstgtn)
    in {
        block1: generateBlock1(getSenderOrReceiver(envelope.Document.RsltnOfInvstgtn.Assgnmt.Assgne.Agt?.FinInstnId?.BICFI,
                        envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)),
        block2: generateBlock2(messageType, getSenderOrReceiver(envelope.Document.RsltnOfInvstgtn.Assgnmt.Assgnr.Agt?.FinInstnId?.BICFI,
                        envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI), envelope.Document.RsltnOfInvstgtn.Assgnmt.CreDtTm),
        block3: createMtBlock3(cancellationDtls.OrgnlUETR),
        block4: {
            MT20: {name: MT20_NAME, msgId: {content: getField20Content(cancellationDtls.CxlStsId), number: NUMBER1}},
            MT21: {name: MT21_NAME, Ref: {content: truncate(cancellationDtls.RslvdCase?.Id, 16), number: NUMBER1}},
            MT11R: {
                name: MT11R_NAME,
                Dt: {content: convertToSWIFTStandardDate(cancellationDtls.OrgnlGrpInf?.OrgnlCreDtTm), number: NUMBER2},
                MtNum: {content: getCamt029MtNumber(getMandatoryField(cancellationDtls.OrgnlGrpInf?.OrgnlMsgNmId)), number: NUMBER1}
            },
            MT76: field76,
            MT77A: field77A
        }
    };

# Get cancellation details from camt.029.
#
# + cxlDtls - camt.029 cancellation details array
# + return - return cancellation details or error
isolated function getCancellationDetailsFromCamt029(camtIsoRecord:UnderlyingTransaction32[]? cxlDtls) returns camtIsoRecord:PaymentTransaction152[]?|error {
    if cxlDtls is camtIsoRecord:UnderlyingTransaction32[] {
        if cxlDtls[0].TxInfAndSts is camtIsoRecord:PaymentTransaction152[] {
            return cxlDtls[0].TxInfAndSts;
        }
    }
    return error("Transaction Information is required to transform this ISO 20022 message to SWIFT message.");
}

# Get transaction information and status from camt.029.
#
# + txInfAndSts - camt.029 transaction information and status array
# + return - return transaction information and status or error
isolated function getTransactionInfoAndStsFromCamt029(camtIsoRecord:PaymentTransaction152[]? txInfAndSts) returns camtIsoRecord:PaymentTransaction152|error {
    if txInfAndSts is camtIsoRecord:PaymentTransaction152[] {
        return txInfAndSts[0];
    }
    return error("Transaction Information is required to transform this ISO 20022 message to SWIFT message.");
}

# Get mt number from camt.029 original message name.
#
# + orgnlMsgNmId - original message name
# + return - return mt number
isolated function getCamt029MtNumber(string orgnlMsgNmId) returns string {
    if orgnlMsgNmId.includes(PACS008) {
        return "103";
    } else if orgnlMsgNmId.includes(PACS003) {
        return "104";
    } else if orgnlMsgNmId.includes(PACS009) {
        return "202";
    } else if orgnlMsgNmId.includes(PACS010) {
        return "204";
    } else if orgnlMsgNmId.includes(PACS003) {
        return "104";
    } else {
        return orgnlMsgNmId.substring(3);
    }
}
