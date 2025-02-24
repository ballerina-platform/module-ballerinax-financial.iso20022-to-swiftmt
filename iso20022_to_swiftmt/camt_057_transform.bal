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

isolated function transformCamt057ToMt210(camtIsoRecord:Camt057Envelope envelope, string messageType) returns swiftmt:MT210Message|error => let
    camtIsoRecord:NotificationItem9 notificationItem = envelope.Document.NtfctnToRcv.Ntfctn.Itm[0],
    swiftmt:MT50?|swiftmt:MT50C?|swiftmt:MT50F? field50 = getField50(envelope.Document.NtfctnToRcv.Ntfctn.Dbtr, notificationItem.Dbtr, true),
    swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT52D? field52 = check getField52(notificationItem.DbtrAgt?.FinInstnId),
    swiftmt:MT56A?|swiftmt:MT56C?|swiftmt:MT56D? field56 = check getField56(notificationItem.IntrmyAgt?.FinInstnId)
    in {
        block1: generateBlock1(getSenderOrReceiver(envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)),
        block2: check generateBlock2(messageType, getSenderOrReceiver(envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI),
                envelope.Document.NtfctnToRcv.GrpHdr.CreDtTm),
        block3: createMtBlock3(envelope.Document.NtfctnToRcv.Ntfctn.Itm[0].UETR),
        block4: {
            MT20: {
                name: MT20_NAME,
                msgId: {content: getField20Content(envelope.Document.NtfctnToRcv.GrpHdr.MsgId), number: NUMBER1}
            },
            MT21: {
                name: MT21_NAME,
                Ref: {content: notificationItem.EndToEndId is string ? truncate(notificationItem.EndToEndId, 16) : truncate(notificationItem.Id, 16), number: NUMBER1}
            },
            MT32B: {
                name: MT32B_NAME,
                Ccy: {content: notificationItem.Amt.Ccy, number: NUMBER1},
                Amnt: {content: convertDecimalToSwiftDecimal(notificationItem.Amt.content), number: NUMBER2}
            },
            MT30: {
                name: MT30_NAME,
                Dt: {content: convertToSWIFTStandardDate(notificationItem.XpctdValDt), number: NUMBER1}
            },
            MT25: getField25(envelope.Document.NtfctnToRcv.Ntfctn.Acct?.Id, notificationItem.Acct?.Id),
            MT52A: field52 is swiftmt:MT52A ? field52 : (),
            MT52D: field52 is swiftmt:MT52D ? field52 : (),
            MT56A: field56 is swiftmt:MT56A ? field56 : (),
            MT56D: field56 is swiftmt:MT56D ? field56 : (),
            MT50: field50 is swiftmt:MT50 ? field50 : (),
            MT50C: field50 is swiftmt:MT50C ? field50 : (),
            MT50F: field50 is swiftmt:MT50F ? field50 : ()
        }
    };
