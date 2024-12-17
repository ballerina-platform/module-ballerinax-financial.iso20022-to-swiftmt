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

isolated function transformCamt057ToMt210(camtIsoRecord:Camt057Document document, string messageType) returns swiftmt:MT210Message|error => let
    camtIsoRecord:NotificationItem9 notificationItem = document.NtfctnToRcv.Ntfctn.Itm[0],
    swiftmt:MT50?|swiftmt:MT50C?|swiftmt:MT50L? field50 = getField50Or50COr50L(notificationItem.Dbtr?.Pty?.Id?.OrgId?.AnyBIC, notificationItem.Dbtr?.Pty?.Nm, notificationItem.Dbtr?.Pty?.PstlAdr?.AdrLine, notificationItem.Dbtr?.Pty?.Id?.PrvtId?.Othr),
    swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT52D? field52 = check getField52(notificationItem.DbtrAgt?.FinInstnId?.BICFI, notificationItem.DbtrAgt?.FinInstnId?.Nm, notificationItem.DbtrAgt?.FinInstnId?.PstlAdr?.AdrLine, notificationItem.DbtrAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd),
    swiftmt:MT56A?|swiftmt:MT56C?|swiftmt:MT56D? field56 = check getField56(notificationItem.IntrmyAgt?.FinInstnId?.BICFI, notificationItem.IntrmyAgt?.FinInstnId?.Nm, notificationItem.IntrmyAgt?.FinInstnId?.PstlAdr?.AdrLine, notificationItem.IntrmyAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd)
    in {
        block2: {
            'type: "output",
            messageType: messageType,
            senderInputTime: {content: check convertToSwiftTimeFormat(document.NtfctnToRcv.GrpHdr.CreDtTm.substring(11))},
            MIRDate: {content: convertToSWIFTStandardDate(document.NtfctnToRcv.GrpHdr.CreDtTm.substring(0, 10))}
        },
        block3: createMtBlock3(document.NtfctnToRcv.Ntfctn.Itm[0].UETR),
        block4: {
            MT20: {
                name: MT20_NAME,
                msgId: {content: document.NtfctnToRcv.Ntfctn.Id, number: NUMBER1}
            },
            MT21: {
                name: MT21_NAME,
                Ref: {content: getField21(notificationItem.EndToEndId, id = notificationItem.Id), number: NUMBER1}
            },
            MT32B: {
                name: MT32B_NAME,
                Ccy: {content: notificationItem.Amt.ActiveOrHistoricCurrencyAndAmount_SimpleType.Ccy, number: NUMBER1},
                Amnt: {content: check convertToString(notificationItem.Amt.ActiveOrHistoricCurrencyAndAmount_SimpleType.ActiveOrHistoricCurrencyAndAmount_SimpleType), number: NUMBER2}
            },
            MT30: {
                name: MT30_NAME,
                Dt: {content: convertToSWIFTStandardDate(notificationItem.XpctdValDt), number: NUMBER1}
            },
            MT25: getField25(notificationItem.Acct?.Id?.IBAN, notificationItem.Acct?.Id?.Othr?.Id),
            MT52A: field52 is swiftmt:MT52A ? field52 : (),
            MT52D: field52 is swiftmt:MT52D ? field52 : (),
            MT56A: field56 is swiftmt:MT56A ? field56 : (),
            MT56D: field56 is swiftmt:MT56D ? field56 : (),
            MT50: field50 is swiftmt:MT50 ? field50 : (),
            MT50C: field50 is swiftmt:MT50C ? field50 : (),
            MT50F: (check getField50a(notificationItem.Dbtr?.Pty?.Id?.OrgId?.AnyBIC, notificationItem.Dbtr?.Pty?.Nm, notificationItem.Dbtr?.Pty?.PstlAdr?.AdrLine, (), (), notificationItem.Dbtr?.Pty?.Id?.PrvtId?.Othr, townName = notificationItem.Dbtr?.Pty?.PstlAdr?.TwnNm, countryCode = notificationItem.Dbtr?.Pty?.PstlAdr?.Ctry))[4]
        }
    };
