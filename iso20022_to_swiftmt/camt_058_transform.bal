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

# This function transforms a camt.058 ISO 20022 message into an MTn92 SWIFT format message.
#
# + envelope - The camt.058 envelope containing the corresponding document to be transformed.
# + messageType - The SWIFT MTn92 message type to be transformed.
# + return - Returns an MTn92 message in the `swiftmt:MTn92Message` format if successful, otherwise returns an error.
isolated function transformCamt058ToMtn92(camtIsoRecord:Camt058Envelope envelope, string messageType)
    returns swiftmt:MTn92Message|error =>
    let camtIsoRecord:OriginalNotificationReference14[]? orgnlNtfRef = envelope.Document.NtfctnToRcvCxlAdvc.OrgnlNtfctn
        .OrgnlNtfctnRef
    in
    {
        block1: generateBlock1(getSenderOrReceiver(envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)),
        block2: check generateBlock2(messageType, getSenderOrReceiver(envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI),
                envelope.Document.NtfctnToRcvCxlAdvc.GrpHdr.CreDtTm),
        block4: {
            MT20: {
                name: MT20_NAME,
                msgId: {content: getMxToMTReference(envelope.Document.NtfctnToRcvCxlAdvc.GrpHdr.MsgId), number: NUMBER1}
            },
            MT21: {
                name: MT21_NAME,
                Ref: {
                    content: truncate(getOriginalItmId(orgnlNtfRef), 16),
                    number: NUMBER1
                }
            },
            MT11S: {
                name: MT11S_NAME,
                MtNum: {
                    content: "210",
                    number: NUMBER1
                },
                Dt: check convertISODateStringToSwiftMtDate(envelope.Document.NtfctnToRcvCxlAdvc.OrgnlNtfctn
                        .OrgnlCreDtTm.toString(), NUMBER2)
            },
            MT79: {
                name: MT79_NAME,
                Nrtv: buildAdditionaInfo(envelope.Document.NtfctnToRcvCxlAdvc.CxlRsn)
            },
            MessageCopy: getMessageCopyForCamt058(orgnlNtfRef)
        }
    };

# Get original item id
#
# + orgnlNtfRef - original notification reference
# + return - original item id
isolated function getOriginalItmId(camtIsoRecord:OriginalNotificationReference14[]? orgnlNtfRef) returns string? {
    if orgnlNtfRef is camtIsoRecord:OriginalNotificationReference14[] {
        return orgnlNtfRef[0].OrgnlItm[0].OrgnlItmId;
    }
    return ();
}

# Get message copy field for camt058
#
# + orgnlNtfRef - original notification reference
# + return - message copy with field 30 and 32B
isolated function getMessageCopyForCamt058(camtIsoRecord:OriginalNotificationReference14[]? orgnlNtfRef)
    returns swiftmt:MessageCopy? {

    if orgnlNtfRef is camtIsoRecord:OriginalNotificationReference14[] {
        camtIsoRecord:OriginalItem8 orgnlItm = orgnlNtfRef[0].OrgnlItm[0];

        string? field30 = orgnlItm.XpctdValDt is camtIsoRecord:ISODate ?
            convertToSWIFTStandardDate(orgnlItm.XpctdValDt) : ();
        string field32b = convertDecimalToSwiftDecimal(orgnlItm.Amt.content);
        return {
            MT30: field30 is string ? {
                    name: MT30_NAME,
                    Dt: {content: field30, number: NUMBER1}
                } : (),
            MT32B: {
                name: MT32B_NAME,
                Ccy: {content: orgnlItm.Amt.Ccy, number: NUMBER1},
                Amnt: {content: field32b, number: NUMBER2}
            }
        };
    }
    return ();
};

# Build additional cancellation reason information
#
# + cxRsn - cancellation reason
# + return - narratives
isolated function buildAdditionaInfo(camtIsoRecord:NotificationCancellationReason2? cxRsn) returns swiftmt:Nrtv[] {
    swiftmt:Nrtv[] narratives = [];
    narratives[0] = {content: "/" + cxRsn?.Rsn?.Cd.toString() + "/", number: NUMBER1};
    return narratives;
}
