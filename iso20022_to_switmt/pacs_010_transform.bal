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

isolated function transformPacs010ToMt204(pacsIsoRecord:Pacs010Document document, string messageType) returns swiftmt:MT204Message|error => let
    pacsIsoRecord:CreditTransferTransaction66 debitTransfer = document.FIDrctDbt.CdtInstr[0],
    swiftmt:MT57A?|swiftmt:MT57B?|swiftmt:MT57C?|swiftmt:MT57D? field57 = check getField57(debitTransfer.CdtrAgt?.FinInstnId?.BICFI, debitTransfer.CdtrAgt?.FinInstnId?.Nm, debitTransfer.CdtrAgt?.FinInstnId?.PstlAdr?.AdrLine, debitTransfer.CdtrAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, debitTransfer.CdtrAgtAcct?.Id?.IBAN, debitTransfer.CdtrAgtAcct?.Id?.Othr?.Id, true) in {
        block1: {
            logicalTerminal: getSenderOrReceiver(document.FIDrctDbt.GrpHdr.InstdAgt?.FinInstnId?.BICFI)
        },
        block2: {
            'type: "output",
            messageType: messageType,
            MIRLogicalTerminal: getSenderOrReceiver(document.FIDrctDbt.GrpHdr.InstgAgt?.FinInstnId?.BICFI),
            senderInputTime: {content: check convertToSwiftTimeFormat(document.FIDrctDbt.GrpHdr.CreDtTm.substring(11))},
            MIRDate: {content: convertToSWIFTStandardDate(document.FIDrctDbt.GrpHdr.CreDtTm.substring(0, 10))}
        },
        block3: createMtBlock3(document.FIDrctDbt.CdtInstr[0].DrctDbtTxInf[0].PmtId?.UETR),
        block4: {
            MT19: {
                name: MT19_NAME,
                Amnt: {content: check convertToString(document.FIDrctDbt.GrpHdr.CtrlSum), number: NUMBER1}
            },
            MT20: {
                name: MT20_NAME,
                msgId: {content: debitTransfer.CdtId, number: NUMBER1}
            },
            MT30: {
                name: MT30_NAME,
                Dt: {content: convertToSWIFTStandardDate(debitTransfer.IntrBkSttlmDt), number: NUMBER1}
            },
            MT57A: field57 is swiftmt:MT57A ? field57 : (),
            MT57B: field57 is swiftmt:MT57B ? field57 : (),
            MT57D: field57 is swiftmt:MT57D ? field57 : (),
            MT58A: getField58(debitTransfer.Cdtr?.FinInstnId?.BICFI, debitTransfer.Cdtr?.FinInstnId?.Nm, debitTransfer.Cdtr?.FinInstnId?.PstlAdr?.AdrLine, debitTransfer.Cdtr?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, debitTransfer.CdtrAcct?.Id?.IBAN, debitTransfer.CdtrAcct?.Id?.Othr?.Id)[0],
            MT58D: getField58(debitTransfer.Cdtr?.FinInstnId?.BICFI, debitTransfer.Cdtr?.FinInstnId?.Nm, debitTransfer.Cdtr?.FinInstnId?.PstlAdr?.AdrLine, debitTransfer.Cdtr?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, debitTransfer.CdtrAcct?.Id?.IBAN, debitTransfer.CdtrAcct?.Id?.Othr?.Id)[1],
            Transaction: check getMT204Transaction(debitTransfer.DrctDbtTxInf)
        }
    };

isolated function getMT204Transaction(pacsIsoRecord:DirectDebitTransactionInformation33[] debitTransaction) returns swiftmt:MT204Transaction[]|error {
    swiftmt:MT204Transaction[] transactionArray = [];
    foreach pacsIsoRecord:DirectDebitTransactionInformation33 transaxion in debitTransaction {
        transactionArray.push({
            MT20: {
                name: MT20_NAME,
                msgId: {
                    content: getMandatoryField(transaxion.PmtId.InstrId),
                    number: NUMBER1
                }
            },
            MT21: {name: MT21_NAME, Ref: {content: transaxion.PmtId.EndToEndId, number: NUMBER1}},
            MT32B: {
                name: MT32B_NAME,
                Ccy: {
                    content: transaxion.IntrBkSttlmAmt?.ActiveCurrencyAndAmount_SimpleType?.Ccy,
                    number: NUMBER1
                },
                Amnt: {
                    content: check convertToString(transaxion.IntrBkSttlmAmt?.ActiveCurrencyAndAmount_SimpleType?.ActiveCurrencyAndAmount_SimpleType),
                    number: NUMBER2
                }
            },
            MT53A: getField53(transaxion.Dbtr?.FinInstnId?.BICFI, transaxion.Dbtr?.FinInstnId?.Nm, transaxion.Dbtr?.FinInstnId?.PstlAdr?.AdrLine, transaxion.Dbtr?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, transaxion.DbtrAcct?.Id?.IBAN, transaxion.DbtrAcct?.Id?.Othr?.Id)[0],
            MT53B: getField53(transaxion.Dbtr?.FinInstnId?.BICFI, transaxion.Dbtr?.FinInstnId?.Nm, transaxion.Dbtr?.FinInstnId?.PstlAdr?.AdrLine, transaxion.Dbtr?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, transaxion.DbtrAcct?.Id?.IBAN, transaxion.DbtrAcct?.Id?.Othr?.Id)[1],
            MT53D: getField53(transaxion.Dbtr?.FinInstnId?.BICFI, transaxion.Dbtr?.FinInstnId?.Nm, transaxion.Dbtr?.FinInstnId?.PstlAdr?.AdrLine, transaxion.Dbtr?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, transaxion.DbtrAcct?.Id?.IBAN, transaxion.DbtrAcct?.Id?.Othr?.Id)[3]
        });
    }
    return transactionArray;
}
