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

# Transforms a camt.060 ISO 20022 document to its corresponding SWIFT MT920 format.
#
# + envelope - The camt.060 envelope containing the corresponding document to be transformed.
# + messageType - The SWIFT MT920 message type to be transformed.
# + return - The transformed SWIFT MT920 message or an error.
isolated function transformCamt060ToMt920(camtIsoRecord:Camt060Envelope envelope, string messageType) returns swiftmt:MT920Message|error => let
swiftmt:MT25A?|swiftmt:MT25P? field25a = getCashAccount(envelope.Document.AcctRptgReq.RptgReq[0].Acct?.Id, (), true) in {
        block1: generateBlock1(getSenderOrReceiver(envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)),
        block2: generateBlock2(messageType, getSenderOrReceiver(envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI),
                envelope.Document.AcctRptgReq.GrpHdr.CreDtTm),
        block4: {
            MT12: {name: MT12_NAME, Msg: {content: envelope.Document.AcctRptgReq.RptgReq[0].ReqdMsgNmId, number: NUMBER1}},
            MT20: {name: MT20_NAME, msgId: {content: getMxToMTReference(envelope.Document.AcctRptgReq.GrpHdr.MsgId), number: NUMBER1}},
            MT25: field25a is swiftmt:MT25A ? field25a : {name: MT25_NAME, Acc: {content: "NOTPROVIDED", number: NUMBER1}},
            MT34F: check getField34F(envelope.Document.AcctRptgReq.RptgReq[0].ReqdTxTp?.FlrLmt)
        }
    };

# Transforms a camt.060 ISO 20022 document to its corresponding SWIFT MT973 format.
#
# + envelope - The camt.060 envelope containing the corresponding document to be transformed.
# + messageType - The SWIFT MT973 message type to be transformed.
# + return - The transformed SWIFT MT973 message or an error.
isolated function transformCamt060ToMt973(camtIsoRecord:Camt060Envelope envelope, string messageType) returns swiftmt:MT973Message|error => let
swiftmt:MT25A?|swiftmt:MT25P? field25a = getCashAccount(envelope.Document.AcctRptgReq.RptgReq[0].Acct?.Id, (), true) in {
        block1: generateBlock1(getSenderOrReceiver(envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)),
        block2: generateBlock2(messageType, getSenderOrReceiver(envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI),
                envelope.Document.AcctRptgReq.GrpHdr.CreDtTm),
        block4: {
            MT12: {name: MT12_NAME, Msg: {content: envelope.Document.AcctRptgReq.RptgReq[0].ReqdMsgNmId, number: NUMBER1}},
            MT20: {name: MT20_NAME, msgId: {content: getMxToMTReference(envelope.Document.AcctRptgReq.GrpHdr.MsgId), number: NUMBER1}},
            MT25: field25a is swiftmt:MT25A ? field25a : {name: MT25_NAME, Acc: {content: "NOTPROVIDED", number: NUMBER1}}
        }
    };
