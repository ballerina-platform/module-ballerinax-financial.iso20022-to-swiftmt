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

isolated function transformCamt029ToMtn96(camtIsoRecord:Camt029Document document, string messageType) returns swiftmt:MTn96Message|error => let
    camtIsoRecord:PaymentTransaction152 cancellationDtls = check getTransactionInfoAndSts(check getCancellationDetails(document.RsltnOfInvstgtn.CxlDtls)),
    var [field76, field77A] = getField76(cancellationDtls.CxlStsRsnInf, document.RsltnOfInvstgtn.Sts.Conf) in {
        block1: {
            logicalTerminal: getSenderOrReceiver(document.RsltnOfInvstgtn.Assgnmt.Assgne.Agt?.FinInstnId?.BICFI)
        },
        block2: {
            'type: "output",
            messageType: messageType,
            MIRLogicalTerminal: getSenderOrReceiver(document.RsltnOfInvstgtn.Assgnmt.Assgne.Agt?.FinInstnId?.BICFI),
            senderInputTime: {content: check convertToSwiftTimeFormat(document.RsltnOfInvstgtn.Assgnmt.CreDtTm.substring(11))},
            MIRDate: {content: convertToSWIFTStandardDate(document.RsltnOfInvstgtn.Assgnmt.CreDtTm.substring(0, 10))}
        },
        block3: createMtBlock3(cancellationDtls.OrgnlUETR),
        block4: {
            MT20: {name: MT20_NAME, msgId: {content: getMandatoryField(cancellationDtls.CxlStsId), number: NUMBER1}},
            MT21: {name: MT21_NAME, Ref: {content: getMandatoryField(cancellationDtls.RslvdCase?.Id), number: NUMBER1}},
            MT11R: {
                name: MT11R_NAME,
                Dt: {content: convertToSWIFTStandardDate(cancellationDtls.OrgnlGrpInf?.OrgnlCreDtTm), number: NUMBER2},
                MtNum: {content: getMandatoryField(cancellationDtls.OrgnlGrpInf?.OrgnlMsgNmId), number: NUMBER1}
            },
            MT76: field76,
            MT77A: field77A
        }
    };
