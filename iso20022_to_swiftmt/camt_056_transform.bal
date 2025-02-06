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

# This function transforms a camt.056 ISO 20022 message into an MTn92 SWIFT format message.
#
# + envelope - The camt.056 envelope containing the corresponding document to be transformed.
# + messageType - The SWIFT MTn92 message type to be transformed.
# + return - Returns an MTn92 message in the `swiftmt:MTn92Message` format if successful, otherwise returns an error.
isolated function transformCamt056ToMtn92(camtIsoRecord:Camt056Envelope envelope, string messageType)
    returns swiftmt:MTn92Message|error =>
    
    let camtIsoRecord:PaymentTransaction155[] transactionInfo =
        check getTransactionInfo(envelope.Document.FIToFIPmtCxlReq.Undrlyg[0].TxInf)
    in {
        block1: generateBlock1(getSenderOrReceiver(envelope.Document.FIToFIPmtCxlReq.Assgnmt.Assgne.Agt?.FinInstnId?.BICFI,
                        envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)),
        block2: generateBlock2(messageType, getSenderOrReceiver(envelope.Document.FIToFIPmtCxlReq.Assgnmt.Assgnr.Agt?.FinInstnId?.BICFI,
                        envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI), envelope.Document.FIToFIPmtCxlReq.Assgnmt.CreDtTm),
        block3: createMtBlock3(transactionInfo[0].OrgnlUETR),
        block4: {
            MT20: {
                name: MT20_NAME,
                msgId: {content: getField20Content(transactionInfo[0].Case?.Id), number: NUMBER1}
            },
            MT21: {
                name: MT21_NAME,
                Ref: {content: getField21Content(transactionInfo[0].OrgnlInstrId), number: NUMBER1}
            },
            MT11S: {
                name: MT11S_NAME,
                Dt: {content: convertToSWIFTStandardDate(transactionInfo[0].OrgnlGrpInf?.OrgnlCreDtTm), number: NUMBER2},
                MtNum: {content: getOrignalMessageName(transactionInfo[0].OrgnlGrpInf?.OrgnlMsgNmId), number: NUMBER1}
            },
            MT79: getField79(transactionInfo[0]),
            MessageCopy: check getMessageCopyForCamt056(transactionInfo[0].OrgnlGrpInf?.OrgnlCreDtTm, transactionInfo[0].OrgnlIntrBkSttlmAmt)
        }
    };

# Get message copy field.
#
# + dateTime - iso date time
# + amount - amount
# + return - return message copy field
isolated function getMessageCopyForCamt056(camtIsoRecord:ISODateTime? dateTime, camtIsoRecord:ActiveOrHistoricCurrencyAndAmount? amount) returns swiftmt:MessageCopy|error {

    if (dateTime is camtIsoRecord:ISODateTime && amount is camtIsoRecord:ActiveOrHistoricCurrencyAndAmount) {
        return {
            MT32A: {
                name: MT32A_NAME,
                Dt: {content: convertToSWIFTStandardDate(dateTime), number: NUMBER1},
                Ccy: {content: amount.Ccy, number: NUMBER2},
                Amnt: {content: check convertToString(amount.content), number: NUMBER3}
            }
        };
    }
    return {};
};
