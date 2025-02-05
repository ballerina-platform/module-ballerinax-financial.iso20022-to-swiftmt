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

import ballerinax/financial.iso20022.payments_clearing_and_settlement as pacsIsoRecord;
import ballerinax/financial.swift.mt as swiftmt;

# Transforms a camt.026 ISO 20022 document to its corresponding SWIFT MTn95 format.
#
# + envelope - The camt.026 envelope containing the corresponding document to be transformed.
# + messageType - The SWIFT MTn95 message type to be transformed.
# + return - The transformed SWIFT MTn95 message or an error.
isolated function transformPacs002DocumentToMTn99(pacsIsoRecord:Pacs002Envelope envelope, string messageType) returns swiftmt:MTn99Message|error => let
    pacsIsoRecord:PaymentTransaction161 transactionInfo = check getTransactionInfoForPacs002(envelope.Document.FIToFIPmtStsRpt.TxInfAndSts)
    in {
        block1: generateBlock1(getSenderOrReceiver(envelope.Document.FIToFIPmtStsRpt.GrpHdr.InstdAgt?.FinInstnId?.BICFI,
                        envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)),
        block2: generateBlock2(messageType, getSenderOrReceiver(envelope.Document.FIToFIPmtStsRpt.GrpHdr.InstgAgt?.FinInstnId?.BICFI,
                        envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI), envelope.Document.FIToFIPmtStsRpt.GrpHdr.CreDtTm),
        block3: createMtBlock3(transactionInfo.OrgnlUETR),
        block4: {
            MT20: {
                name: MT20_NAME,
                msgId: {content: getField20Content(envelope.Document.FIToFIPmtStsRpt.GrpHdr.MsgId), number: NUMBER1}
            },
            MT21: {
                name: MT21_NAME,
                Ref: {
                    content: getField21Content(transactionInfo.OrgnlInstrId),
                    number: NUMBER1
                }
            },
            MT79: {
                name: MT79_NAME,
                // Nrtv: [{content: getPacs002Field79(transactionInfo), number: NUMBER1}]
                Nrtv: getField79ForPacs002(transactionInfo.OrgnlGrpInf?.OrgnlMsgId, transactionInfo.OrgnlEndToEndId,
                        transactionInfo.OrgnlUETR, transactionInfo.StsRsnInf)
            }
        }
    };
