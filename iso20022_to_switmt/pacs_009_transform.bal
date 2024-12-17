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

isolated function transformPacs009ToMt200(pacsIsoRecord:Pacs009Document document, string messageType) returns swiftmt:MT200Message|error => let
    pacsIsoRecord:CreditTransferTransaction62 creditTransfer = document.FICdtTrf.CdtTrfTxInf[0],
    pacsIsoRecord:SettlementInstruction15 settlementInfo = document.FICdtTrf.GrpHdr.SttlmInf,
    swiftmt:MT56A?|swiftmt:MT56C?|swiftmt:MT56D? field56 = check getField56(creditTransfer.IntrmyAgt1?.FinInstnId?.BICFI, creditTransfer.IntrmyAgt1?.FinInstnId?.Nm, creditTransfer.IntrmyAgt1?.FinInstnId?.PstlAdr?.AdrLine, creditTransfer.IntrmyAgt1?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, creditTransfer.IntrmyAgt1Acct?.Id?.IBAN, creditTransfer.IntrmyAgt1Acct?.Id?.Othr?.Id),
    swiftmt:MT57A?|swiftmt:MT57B?|swiftmt:MT57C?|swiftmt:MT57D? field57 = check getField57(creditTransfer.CdtrAgt?.FinInstnId?.BICFI, creditTransfer.CdtrAgt?.FinInstnId?.Nm, creditTransfer.CdtrAgt?.FinInstnId?.PstlAdr?.AdrLine, creditTransfer.CdtrAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, creditTransfer.CdtrAgtAcct?.Id?.IBAN, creditTransfer.CdtrAgtAcct?.Id?.Othr?.Id, true)
    in {
        block1: {
            logicalTerminal: getSenderOrReceiver(document.FICdtTrf.GrpHdr.InstdAgt?.FinInstnId?.BICFI)
        },
        block2: {
            'type: "output",
            messageType: messageType,
            MIRLogicalTerminal: getSenderOrReceiver(document.FICdtTrf.GrpHdr.InstgAgt?.FinInstnId?.BICFI),
            senderInputTime: {content: check convertToSwiftTimeFormat(document.FICdtTrf.GrpHdr.CreDtTm.substring(11))},
            MIRDate: {content: convertToSWIFTStandardDate(document.FICdtTrf.GrpHdr.CreDtTm.substring(0, 10))}
        },
        block3: createMtBlock3(document.FICdtTrf.CdtTrfTxInf[0].PmtId?.UETR),
        block4: {
            MT20: {
                name: MT20_NAME,
                msgId: {
                    content: getMandatoryField(creditTransfer.PmtId.InstrId),
                    number: NUMBER1
                }
            },
            MT32A: {
                name: "32A",
                Dt: {
                    content: convertToSWIFTStandardDate(creditTransfer.IntrBkSttlmDt),
                    number: NUMBER1
                },
                Ccy: {
                    content: getMandatoryField(creditTransfer.IntrBkSttlmAmt.ActiveCurrencyAndAmount_SimpleType.Ccy),
                    number: NUMBER2
                },
                Amnt: {
                    content: check convertToString(creditTransfer.IntrBkSttlmAmt.ActiveCurrencyAndAmount_SimpleType.ActiveCurrencyAndAmount_SimpleType),
                    number: NUMBER2
                }
            },
            MT53B: getField53((), (), settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.PstlAdr?.AdrLine, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, settlementInfo.InstgRmbrsmntAgtAcct?.Id?.IBAN, settlementInfo.InstgRmbrsmntAgtAcct?.Id?.Othr?.Id, true)[1],
            MT56A: field56 is swiftmt:MT56A ? field56 : (),
            MT56D: field56 is swiftmt:MT56D ? field56 : (),
            MT57A: field57 is swiftmt:MT57A ? field57 : (),
            MT57B: field57 is swiftmt:MT57B ? field57 : (),
            MT57D: field57 is swiftmt:MT57D ? field57 : (),
            MT72: getField72(creditTransfer.InstrForCdtrAgt, creditTransfer.InstrForNxtAgt)
        }
    };

isolated function transformPacs009ToMt201(pacsIsoRecord:Pacs009Document document, string messageType) returns swiftmt:MT201Message|error => let
    pacsIsoRecord:CreditTransferTransaction62 creditTransfer = document.FICdtTrf.CdtTrfTxInf[0],
    pacsIsoRecord:SettlementInstruction15 settlementInfo = document.FICdtTrf.GrpHdr.SttlmInf in {
        block1: {
            logicalTerminal: getSenderOrReceiver(document.FICdtTrf.GrpHdr.InstdAgt?.FinInstnId?.BICFI)
        },
        block2: {
            'type: "output",
            messageType: messageType,
            MIRLogicalTerminal: getSenderOrReceiver(document.FICdtTrf.GrpHdr.InstgAgt?.FinInstnId?.BICFI),
            senderInputTime: {content: check convertToSwiftTimeFormat(document.FICdtTrf.GrpHdr.CreDtTm.substring(11))},
            MIRDate: {content: convertToSWIFTStandardDate(document.FICdtTrf.GrpHdr.CreDtTm.substring(0, 10))}
        },
        block3: createMtBlock3(document.FICdtTrf.CdtTrfTxInf[0].PmtId?.UETR),
        block4: {
            MT30: {name: MT30_NAME, Dt: {content: convertToSWIFTStandardDate(creditTransfer.IntrBkSttlmDt), number: NUMBER1}},
            MT53B: getField53((), (), settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.PstlAdr?.AdrLine, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, settlementInfo.InstgRmbrsmntAgtAcct?.Id?.IBAN, settlementInfo.InstgRmbrsmntAgtAcct?.Id?.Othr?.Id, true)[1],
            MT72: getRepeatingField72(document.FICdtTrf.CdtTrfTxInf),
            Transaction: check getMT201Transaction(document.FICdtTrf.CdtTrfTxInf),
            MT19: {name: MT19_NAME, Amnt: {content: check convertToString(document.FICdtTrf.GrpHdr.CtrlSum), number: NUMBER1}}
        }
    };

isolated function getMT201Transaction(pacsIsoRecord:CreditTransferTransaction62[] creditTransaction) returns swiftmt:MT201Transaction[]|error {
    swiftmt:MT201Transaction[] transactionArray = [];
    foreach pacsIsoRecord:CreditTransferTransaction62 transaxion in creditTransaction {
        swiftmt:MT56A?|swiftmt:MT56C?|swiftmt:MT56D? field56 = check getField56(transaxion.IntrmyAgt1?.FinInstnId?.BICFI, transaxion.IntrmyAgt1?.FinInstnId?.Nm, transaxion.IntrmyAgt1?.FinInstnId?.PstlAdr?.AdrLine, transaxion.IntrmyAgt1?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, transaxion.IntrmyAgt1Acct?.Id?.IBAN, transaxion.IntrmyAgt1Acct?.Id?.Othr?.Id);
        swiftmt:MT57A?|swiftmt:MT57B?|swiftmt:MT57C?|swiftmt:MT57D? field57 = check getField57(transaxion.CdtrAgt?.FinInstnId?.BICFI, transaxion.CdtrAgt?.FinInstnId?.Nm, transaxion.CdtrAgt?.FinInstnId?.PstlAdr?.AdrLine, transaxion.CdtrAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, transaxion.CdtrAgtAcct?.Id?.IBAN, transaxion.CdtrAgtAcct?.Id?.Othr?.Id, true);
        transactionArray.push({
            MT20: {
                name: MT20_NAME,
                msgId: {
                    content: getMandatoryField(transaxion.PmtId.InstrId),
                    number: NUMBER1
                }
            },
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
            MT56A: field56 is swiftmt:MT56A ? field56 : (),
            MT56D: field56 is swiftmt:MT56D ? field56 : (),
            MT57A: field57 is swiftmt:MT57A ? field57 : (),
            MT57B: field57 is swiftmt:MT57B ? field57 : (),
            MT57D: field57 is swiftmt:MT57D ? field57 : (),
            MT72: getRepeatingField72(creditTransaction, transaxion)
        });
    }
    return transactionArray;
}

isolated function transformPacs009ToMt202(pacsIsoRecord:Pacs009Document document, string messageType) returns swiftmt:MT202Message|error => let
    pacsIsoRecord:CreditTransferTransaction62 creditTransfer = document.FICdtTrf.CdtTrfTxInf[0],
    pacsIsoRecord:SettlementInstruction15 settlementInfo = document.FICdtTrf.GrpHdr.SttlmInf,
    swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT52D? field52 = check getField52(creditTransfer.Dbtr?.FinInstnId?.BICFI, creditTransfer.Dbtr?.FinInstnId?.Nm, creditTransfer.Dbtr?.FinInstnId?.PstlAdr?.AdrLine, creditTransfer.Dbtr?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, creditTransfer.DbtrAcct?.Id?.IBAN, creditTransfer.DbtrAcct?.Id?.Othr?.Id),
    swiftmt:MT56A?|swiftmt:MT56C?|swiftmt:MT56D? field56 = check getField56(creditTransfer.IntrmyAgt1?.FinInstnId?.BICFI, creditTransfer.IntrmyAgt1?.FinInstnId?.Nm, creditTransfer.IntrmyAgt1?.FinInstnId?.PstlAdr?.AdrLine, creditTransfer.IntrmyAgt1?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, creditTransfer.IntrmyAgt1Acct?.Id?.IBAN, creditTransfer.IntrmyAgt1Acct?.Id?.Othr?.Id),
    swiftmt:MT57A?|swiftmt:MT57B?|swiftmt:MT57C?|swiftmt:MT57D? field57 = check getField57(creditTransfer.CdtrAgt?.FinInstnId?.BICFI, creditTransfer.CdtrAgt?.FinInstnId?.Nm, creditTransfer.CdtrAgt?.FinInstnId?.PstlAdr?.AdrLine, creditTransfer.CdtrAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, creditTransfer.CdtrAgtAcct?.Id?.IBAN, creditTransfer.CdtrAgtAcct?.Id?.Othr?.Id, true) in {
        block1: {
            logicalTerminal: getSenderOrReceiver(document.FICdtTrf.GrpHdr.InstdAgt?.FinInstnId?.BICFI)
        },
        block2: {
            'type: "output",
            messageType: messageType,
            MIRLogicalTerminal: getSenderOrReceiver(document.FICdtTrf.GrpHdr.InstgAgt?.FinInstnId?.BICFI),
            senderInputTime: {content: check convertToSwiftTimeFormat(document.FICdtTrf.GrpHdr.CreDtTm.substring(11))},
            MIRDate: {content: convertToSWIFTStandardDate(document.FICdtTrf.GrpHdr.CreDtTm.substring(0, 10))}
        },
        block3: createMtBlock3(document.FICdtTrf.CdtTrfTxInf[0].PmtId?.UETR),
        block4: {
            MT13C: getFieldMt13C(creditTransfer.SttlmTmReq?.CLSTm, creditTransfer.SttlmTmIndctn?.CdtDtTm, creditTransfer.SttlmTmIndctn?.DbtDtTm),
            MT20: {
                name: MT20_NAME,
                msgId: {
                    content: getMandatoryField(creditTransfer.PmtId.InstrId),
                    number: NUMBER1
                }
            },
            MT21: {
                name: MT21_NAME,
                Ref: {
                    content: creditTransfer.PmtId.EndToEndId,
                    number: NUMBER1
                }
            },
            MT32A: {
                name: MT32A_NAME,
                Dt: {
                    content: convertToSWIFTStandardDate(creditTransfer.IntrBkSttlmDt),
                    number: NUMBER1
                },
                Ccy: {
                    content: getMandatoryField(creditTransfer.IntrBkSttlmAmt.ActiveCurrencyAndAmount_SimpleType.Ccy),
                    number: NUMBER2
                },
                Amnt: {
                    content: check convertToString(creditTransfer.IntrBkSttlmAmt.ActiveCurrencyAndAmount_SimpleType.ActiveCurrencyAndAmount_SimpleType),
                    number: NUMBER2
                }
            },
            MT52A: field52 is swiftmt:MT52A ? field52 : (),
            MT52D: field52 is swiftmt:MT52D ? field52 : (),
            MT56A: field56 is swiftmt:MT56A ? field56 : (),
            MT56D: field56 is swiftmt:MT56D ? field56 : (),
            MT53A: getField53(settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.BICFI, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.Nm, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.PstlAdr?.AdrLine, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, settlementInfo.InstgRmbrsmntAgtAcct?.Id?.IBAN, settlementInfo.InstgRmbrsmntAgtAcct?.Id?.Othr?.Id, true)[0],
            MT53B: getField53(settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.BICFI, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.Nm, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.PstlAdr?.AdrLine, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, settlementInfo.InstgRmbrsmntAgtAcct?.Id?.IBAN, settlementInfo.InstgRmbrsmntAgtAcct?.Id?.Othr?.Id, true)[1],
            MT53D: getField53(settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.BICFI, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.Nm, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.PstlAdr?.AdrLine, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, settlementInfo.InstgRmbrsmntAgtAcct?.Id?.IBAN, settlementInfo.InstgRmbrsmntAgtAcct?.Id?.Othr?.Id, true)[3],
            MT54A: getField54(settlementInfo.InstdRmbrsmntAgt?.FinInstnId?.BICFI, settlementInfo.InstdRmbrsmntAgt?.FinInstnId?.Nm, settlementInfo.InstdRmbrsmntAgt?.FinInstnId?.PstlAdr?.AdrLine, settlementInfo.InstdRmbrsmntAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, settlementInfo.InstdRmbrsmntAgtAcct?.Id?.IBAN, settlementInfo.InstdRmbrsmntAgtAcct?.Id?.Othr?.Id, true)[0],
            MT54B: getField54(settlementInfo.InstdRmbrsmntAgt?.FinInstnId?.BICFI, settlementInfo.InstdRmbrsmntAgt?.FinInstnId?.Nm, settlementInfo.InstdRmbrsmntAgt?.FinInstnId?.PstlAdr?.AdrLine, settlementInfo.InstdRmbrsmntAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, settlementInfo.InstdRmbrsmntAgtAcct?.Id?.IBAN, settlementInfo.InstdRmbrsmntAgtAcct?.Id?.Othr?.Id, true)[1],
            MT54D: getField54(settlementInfo.InstdRmbrsmntAgt?.FinInstnId?.BICFI, settlementInfo.InstdRmbrsmntAgt?.FinInstnId?.Nm, settlementInfo.InstdRmbrsmntAgt?.FinInstnId?.PstlAdr?.AdrLine, settlementInfo.InstdRmbrsmntAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, settlementInfo.InstdRmbrsmntAgtAcct?.Id?.IBAN, settlementInfo.InstdRmbrsmntAgtAcct?.Id?.Othr?.Id, true)[2],
            MT57A: field57 is swiftmt:MT57A ? field57 : (),
            MT57B: field57 is swiftmt:MT57B ? field57 : (),
            MT57D: field57 is swiftmt:MT57D ? field57 : (),
            MT58A: getField58(creditTransfer.Cdtr?.FinInstnId?.BICFI, creditTransfer.Cdtr?.FinInstnId?.Nm, creditTransfer.Cdtr?.FinInstnId?.PstlAdr?.AdrLine, creditTransfer.Cdtr?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, creditTransfer.CdtrAcct?.Id?.IBAN, creditTransfer.CdtrAcct?.Id?.Othr?.Id)[0],
            MT58D: getField58(creditTransfer.Cdtr?.FinInstnId?.BICFI, creditTransfer.Cdtr?.FinInstnId?.Nm, creditTransfer.Cdtr?.FinInstnId?.PstlAdr?.AdrLine, creditTransfer.Cdtr?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, creditTransfer.CdtrAcct?.Id?.IBAN, creditTransfer.CdtrAcct?.Id?.Othr?.Id)[1],
            MT72: getField72(creditTransfer.InstrForCdtrAgt, creditTransfer.InstrForNxtAgt)
        }
    };

isolated function transformPacs009ToMt202COV(pacsIsoRecord:Pacs009Document document, string messageType) returns swiftmt:MT202COVMessage|error => let
    pacsIsoRecord:CreditTransferTransaction62 creditTransfer = document.FICdtTrf.CdtTrfTxInf[0],
    pacsIsoRecord:SettlementInstruction15 settlementInfo = document.FICdtTrf.GrpHdr.SttlmInf,
    swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT52D? field52 = check getField52(creditTransfer.Dbtr?.FinInstnId?.BICFI, creditTransfer.Dbtr?.FinInstnId?.Nm, creditTransfer.Dbtr?.FinInstnId?.PstlAdr?.AdrLine, creditTransfer.Dbtr?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, creditTransfer.DbtrAcct?.Id?.IBAN, creditTransfer.DbtrAcct?.Id?.Othr?.Id),
    swiftmt:MT56A?|swiftmt:MT56C?|swiftmt:MT56D? field56 = check getField56(creditTransfer.IntrmyAgt1?.FinInstnId?.BICFI, creditTransfer.IntrmyAgt1?.FinInstnId?.Nm, creditTransfer.IntrmyAgt1?.FinInstnId?.PstlAdr?.AdrLine, creditTransfer.IntrmyAgt1?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, creditTransfer.IntrmyAgt1Acct?.Id?.IBAN, creditTransfer.IntrmyAgt1Acct?.Id?.Othr?.Id),
    swiftmt:MT57A?|swiftmt:MT57B?|swiftmt:MT57C?|swiftmt:MT57D? field57 = check getField57(creditTransfer.CdtrAgt?.FinInstnId?.BICFI, creditTransfer.CdtrAgt?.FinInstnId?.Nm, creditTransfer.CdtrAgt?.FinInstnId?.PstlAdr?.AdrLine, creditTransfer.CdtrAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, creditTransfer.CdtrAgtAcct?.Id?.IBAN, creditTransfer.CdtrAgtAcct?.Id?.Othr?.Id, true) in {
        block1: {
            logicalTerminal: getSenderOrReceiver(document.FICdtTrf.GrpHdr.InstdAgt?.FinInstnId?.BICFI)
        },
        block2: {
            'type: "output",
            messageType: messageType,
            MIRLogicalTerminal: getSenderOrReceiver(document.FICdtTrf.GrpHdr.InstgAgt?.FinInstnId?.BICFI),
            senderInputTime: {content: check convertToSwiftTimeFormat(document.FICdtTrf.GrpHdr.CreDtTm.substring(11))},
            MIRDate: {content: convertToSWIFTStandardDate(document.FICdtTrf.GrpHdr.CreDtTm.substring(0, 10))}
        },
        block3: createMtBlock3(document.FICdtTrf.CdtTrfTxInf[0].PmtId?.UETR, VALIDATION_FLAG_COV),
        block4: {
            MT13C: getFieldMt13C(creditTransfer.SttlmTmReq?.CLSTm, creditTransfer.SttlmTmIndctn?.CdtDtTm, creditTransfer.SttlmTmIndctn?.DbtDtTm),
            MT20: {
                name: MT20_NAME,
                msgId: {
                    content: getMandatoryField(creditTransfer.PmtId.InstrId),
                    number: NUMBER1
                }
            },
            MT21: {
                name: MT21_NAME,
                Ref: {
                    content: creditTransfer.PmtId.EndToEndId,
                    number: NUMBER1
                }
            },
            MT32A: {
                name: MT32A_NAME,
                Dt: {
                    content: convertToSWIFTStandardDate(creditTransfer.IntrBkSttlmDt),
                    number: NUMBER1
                },
                Ccy: {
                    content: getMandatoryField(creditTransfer.IntrBkSttlmAmt.ActiveCurrencyAndAmount_SimpleType.Ccy),
                    number: NUMBER2
                },
                Amnt: {
                    content: check convertToString(creditTransfer.IntrBkSttlmAmt.ActiveCurrencyAndAmount_SimpleType.ActiveCurrencyAndAmount_SimpleType),
                    number: NUMBER2
                }
            },
            MT52A: field52 is swiftmt:MT52A ? field52 : (),
            MT52D: field52 is swiftmt:MT52D ? field52 : (),
            MT56A: field56 is swiftmt:MT56A ? field56 : (),
            MT56D: field56 is swiftmt:MT56D ? field56 : (),
            MT53A: getField53(settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.BICFI, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.Nm, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.PstlAdr?.AdrLine, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, settlementInfo.InstgRmbrsmntAgtAcct?.Id?.IBAN, settlementInfo.InstgRmbrsmntAgtAcct?.Id?.Othr?.Id, true)[0],
            MT53B: getField53(settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.BICFI, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.Nm, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.PstlAdr?.AdrLine, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, settlementInfo.InstgRmbrsmntAgtAcct?.Id?.IBAN, settlementInfo.InstgRmbrsmntAgtAcct?.Id?.Othr?.Id, true)[1],
            MT53D: getField53(settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.BICFI, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.Nm, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.PstlAdr?.AdrLine, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, settlementInfo.InstgRmbrsmntAgtAcct?.Id?.IBAN, settlementInfo.InstgRmbrsmntAgtAcct?.Id?.Othr?.Id, true)[3],
            MT54A: getField54(settlementInfo.InstdRmbrsmntAgt?.FinInstnId?.BICFI, settlementInfo.InstdRmbrsmntAgt?.FinInstnId?.Nm, settlementInfo.InstdRmbrsmntAgt?.FinInstnId?.PstlAdr?.AdrLine, settlementInfo.InstdRmbrsmntAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, settlementInfo.InstdRmbrsmntAgtAcct?.Id?.IBAN, settlementInfo.InstdRmbrsmntAgtAcct?.Id?.Othr?.Id, true)[0],
            MT54B: getField54(settlementInfo.InstdRmbrsmntAgt?.FinInstnId?.BICFI, settlementInfo.InstdRmbrsmntAgt?.FinInstnId?.Nm, settlementInfo.InstdRmbrsmntAgt?.FinInstnId?.PstlAdr?.AdrLine, settlementInfo.InstdRmbrsmntAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, settlementInfo.InstdRmbrsmntAgtAcct?.Id?.IBAN, settlementInfo.InstdRmbrsmntAgtAcct?.Id?.Othr?.Id, true)[1],
            MT54D: getField54(settlementInfo.InstdRmbrsmntAgt?.FinInstnId?.BICFI, settlementInfo.InstdRmbrsmntAgt?.FinInstnId?.Nm, settlementInfo.InstdRmbrsmntAgt?.FinInstnId?.PstlAdr?.AdrLine, settlementInfo.InstdRmbrsmntAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, settlementInfo.InstdRmbrsmntAgtAcct?.Id?.IBAN, settlementInfo.InstdRmbrsmntAgtAcct?.Id?.Othr?.Id, true)[2],
            MT57A: field57 is swiftmt:MT57A ? field57 : (),
            MT57B: field57 is swiftmt:MT57B ? field57 : (),
            MT57D: field57 is swiftmt:MT57D ? field57 : (),
            MT58A: getField58(creditTransfer.Cdtr?.FinInstnId?.BICFI, creditTransfer.Cdtr?.FinInstnId?.Nm, creditTransfer.Cdtr?.FinInstnId?.PstlAdr?.AdrLine, creditTransfer.Cdtr?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, creditTransfer.CdtrAcct?.Id?.IBAN, creditTransfer.CdtrAcct?.Id?.Othr?.Id)[0],
            MT58D: getField58(creditTransfer.Cdtr?.FinInstnId?.BICFI, creditTransfer.Cdtr?.FinInstnId?.Nm, creditTransfer.Cdtr?.FinInstnId?.PstlAdr?.AdrLine, creditTransfer.Cdtr?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, creditTransfer.CdtrAcct?.Id?.IBAN, creditTransfer.CdtrAcct?.Id?.Othr?.Id)[1],
            MT72: getField72(creditTransfer.InstrForCdtrAgt, creditTransfer.InstrForNxtAgt),
            UndrlygCstmrCdtTrf: check getUnderlyingCustomerTransaction(creditTransfer)
        }
    };

isolated function getUnderlyingCustomerTransaction(pacsIsoRecord:CreditTransferTransaction62 creditTransfer) returns swiftmt:UndrlygCstmrCdtTrf|error {
    //swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT52D? field52 = check getField52(creditTransfer.UndrlygCstmrCdtTrf?.DbtrAgt?.FinInstnId?.BICFI, creditTransfer.UndrlygCstmrCdtTrf?.DbtrAgt?.FinInstnId?.Nm, creditTransfer.UndrlygCstmrCdtTrf?.DbtrAgt?.FinInstnId?.PstlAdr?.AdrLine, creditTransfer.UndrlygCstmrCdtTrf?.DbtrAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, creditTransfer.UndrlygCstmrCdtTrf?.DbtrAgtAcct?.Id?.IBAN, creditTransfer.UndrlygCstmrCdtTrf?.DbtrAgtAcct?.Id?.Othr?.Id);
    //swiftmt:MT56A?|swiftmt:MT56C?|swiftmt:MT56D? field56 = check getField56(creditTransfer.UndrlygCstmrCdtTrf?.IntrmyAgt1?.FinInstnId?.BICFI, creditTransfer.UndrlygCstmrCdtTrf?.IntrmyAgt1?.FinInstnId?.Nm, creditTransfer.UndrlygCstmrCdtTrf?.IntrmyAgt1?.FinInstnId?.PstlAdr?.AdrLine, creditTransfer.UndrlygCstmrCdtTrf?.IntrmyAgt1?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, creditTransfer.UndrlygCstmrCdtTrf?.IntrmyAgt1Acct?.Id?.IBAN, creditTransfer.UndrlygCstmrCdtTrf?.IntrmyAgt1Acct?.Id?.Othr?.Id);
    //swiftmt:MT57A?|swiftmt:MT57B?|swiftmt:MT57C?|swiftmt:MT57D? field57 = check getField57(creditTransfer.UndrlygCstmrCdtTrf?.CdtrAgt?.FinInstnId?.BICFI, creditTransfer.UndrlygCstmrCdtTrf?.CdtrAgt?.FinInstnId?.Nm, creditTransfer.UndrlygCstmrCdtTrf?.CdtrAgt?.FinInstnId?.PstlAdr?.AdrLine, creditTransfer.UndrlygCstmrCdtTrf?.CdtrAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, creditTransfer.UndrlygCstmrCdtTrf?.CdtrAgtAcct?.Id?.IBAN, creditTransfer.UndrlygCstmrCdtTrf?.CdtrAgtAcct?.Id?.Othr?.Id, true);
    return {
        MT33B: check getField33B(creditTransfer.UndrlygCstmrCdtTrf?.InstdAmt, ()),
        MT50A: (check getField50a(creditTransfer.UndrlygCstmrCdtTrf?.Dbtr?.Id?.OrgId?.AnyBIC, creditTransfer.UndrlygCstmrCdtTrf?.Dbtr?.Nm, creditTransfer.UndrlygCstmrCdtTrf?.Dbtr?.PstlAdr?.AdrLine, creditTransfer.UndrlygCstmrCdtTrf?.DbtrAcct?.Id?.IBAN, creditTransfer.UndrlygCstmrCdtTrf?.DbtrAcct?.Id?.Othr?.Id, creditTransfer.UndrlygCstmrCdtTrf?.Dbtr?.Id?.PrvtId?.Othr, townName = creditTransfer.UndrlygCstmrCdtTrf?.Dbtr?.PstlAdr?.TwnNm, countryCode = creditTransfer.UndrlygCstmrCdtTrf?.Dbtr?.PstlAdr?.Ctry))[0],
        MT50F: (check getField50a(creditTransfer.UndrlygCstmrCdtTrf?.Dbtr?.Id?.OrgId?.AnyBIC, creditTransfer.UndrlygCstmrCdtTrf?.Dbtr?.Nm, creditTransfer.UndrlygCstmrCdtTrf?.Dbtr?.PstlAdr?.AdrLine, creditTransfer.UndrlygCstmrCdtTrf?.DbtrAcct?.Id?.IBAN, creditTransfer.UndrlygCstmrCdtTrf?.DbtrAcct?.Id?.Othr?.Id, creditTransfer.UndrlygCstmrCdtTrf?.Dbtr?.Id?.PrvtId?.Othr, townName = creditTransfer.UndrlygCstmrCdtTrf?.Dbtr?.PstlAdr?.TwnNm, countryCode = creditTransfer.UndrlygCstmrCdtTrf?.Dbtr?.PstlAdr?.Ctry))[4],
        MT50K: (check getField50a(creditTransfer.UndrlygCstmrCdtTrf?.Dbtr?.Id?.OrgId?.AnyBIC, creditTransfer.UndrlygCstmrCdtTrf?.Dbtr?.Nm, creditTransfer.UndrlygCstmrCdtTrf?.Dbtr?.PstlAdr?.AdrLine, creditTransfer.UndrlygCstmrCdtTrf?.DbtrAcct?.Id?.IBAN, creditTransfer.UndrlygCstmrCdtTrf?.DbtrAcct?.Id?.Othr?.Id, creditTransfer.UndrlygCstmrCdtTrf?.Dbtr?.Id?.PrvtId?.Othr, townName = creditTransfer.UndrlygCstmrCdtTrf?.Dbtr?.PstlAdr?.TwnNm, countryCode = creditTransfer.UndrlygCstmrCdtTrf?.Dbtr?.PstlAdr?.Ctry))[2],
        MT52A: (check getField52Alt(creditTransfer.UndrlygCstmrCdtTrf?.DbtrAgt?.FinInstnId?.BICFI, creditTransfer.UndrlygCstmrCdtTrf?.DbtrAgt?.FinInstnId?.Nm, creditTransfer.UndrlygCstmrCdtTrf?.DbtrAgt?.FinInstnId?.PstlAdr?.AdrLine, creditTransfer.UndrlygCstmrCdtTrf?.DbtrAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, creditTransfer.UndrlygCstmrCdtTrf?.DbtrAgtAcct?.Id?.IBAN, creditTransfer.UndrlygCstmrCdtTrf?.DbtrAgtAcct?.Id?.Othr?.Id))[0],
        MT52D: (check getField52Alt(creditTransfer.UndrlygCstmrCdtTrf?.DbtrAgt?.FinInstnId?.BICFI, creditTransfer.UndrlygCstmrCdtTrf?.DbtrAgt?.FinInstnId?.Nm, creditTransfer.UndrlygCstmrCdtTrf?.DbtrAgt?.FinInstnId?.PstlAdr?.AdrLine, creditTransfer.UndrlygCstmrCdtTrf?.DbtrAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, creditTransfer.UndrlygCstmrCdtTrf?.DbtrAgtAcct?.Id?.IBAN, creditTransfer.UndrlygCstmrCdtTrf?.DbtrAgtAcct?.Id?.Othr?.Id))[3],
        MT56A: (check getField56Alt(creditTransfer.UndrlygCstmrCdtTrf?.IntrmyAgt1?.FinInstnId?.BICFI, creditTransfer.UndrlygCstmrCdtTrf?.IntrmyAgt1?.FinInstnId?.Nm, creditTransfer.UndrlygCstmrCdtTrf?.IntrmyAgt1?.FinInstnId?.PstlAdr?.AdrLine, creditTransfer.UndrlygCstmrCdtTrf?.IntrmyAgt1?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, creditTransfer.UndrlygCstmrCdtTrf?.IntrmyAgt1Acct?.Id?.IBAN, creditTransfer.UndrlygCstmrCdtTrf?.IntrmyAgt1Acct?.Id?.Othr?.Id))[0],
        MT56D: (check getField56Alt(creditTransfer.UndrlygCstmrCdtTrf?.IntrmyAgt1?.FinInstnId?.BICFI, creditTransfer.UndrlygCstmrCdtTrf?.IntrmyAgt1?.FinInstnId?.Nm, creditTransfer.UndrlygCstmrCdtTrf?.IntrmyAgt1?.FinInstnId?.PstlAdr?.AdrLine, creditTransfer.UndrlygCstmrCdtTrf?.IntrmyAgt1?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, creditTransfer.UndrlygCstmrCdtTrf?.IntrmyAgt1Acct?.Id?.IBAN, creditTransfer.UndrlygCstmrCdtTrf?.IntrmyAgt1Acct?.Id?.Othr?.Id))[2],
        MT57A: (check getField57Alt(creditTransfer.UndrlygCstmrCdtTrf?.CdtrAgt?.FinInstnId?.BICFI, creditTransfer.UndrlygCstmrCdtTrf?.CdtrAgt?.FinInstnId?.Nm, creditTransfer.UndrlygCstmrCdtTrf?.CdtrAgt?.FinInstnId?.PstlAdr?.AdrLine, creditTransfer.UndrlygCstmrCdtTrf?.CdtrAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, creditTransfer.UndrlygCstmrCdtTrf?.CdtrAgtAcct?.Id?.IBAN, creditTransfer.UndrlygCstmrCdtTrf?.CdtrAgtAcct?.Id?.Othr?.Id, true))[0],
        MT57B: (check getField57Alt(creditTransfer.UndrlygCstmrCdtTrf?.CdtrAgt?.FinInstnId?.BICFI, creditTransfer.UndrlygCstmrCdtTrf?.CdtrAgt?.FinInstnId?.Nm, creditTransfer.UndrlygCstmrCdtTrf?.CdtrAgt?.FinInstnId?.PstlAdr?.AdrLine, creditTransfer.UndrlygCstmrCdtTrf?.CdtrAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, creditTransfer.UndrlygCstmrCdtTrf?.CdtrAgtAcct?.Id?.IBAN, creditTransfer.UndrlygCstmrCdtTrf?.CdtrAgtAcct?.Id?.Othr?.Id, true))[1],
        MT57D: (check getField57Alt(creditTransfer.UndrlygCstmrCdtTrf?.CdtrAgt?.FinInstnId?.BICFI, creditTransfer.UndrlygCstmrCdtTrf?.CdtrAgt?.FinInstnId?.Nm, creditTransfer.UndrlygCstmrCdtTrf?.CdtrAgt?.FinInstnId?.PstlAdr?.AdrLine, creditTransfer.UndrlygCstmrCdtTrf?.CdtrAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, creditTransfer.UndrlygCstmrCdtTrf?.CdtrAgtAcct?.Id?.IBAN, creditTransfer.UndrlygCstmrCdtTrf?.CdtrAgtAcct?.Id?.Othr?.Id, true))[3],
        MT59: getField59a(creditTransfer.UndrlygCstmrCdtTrf?.Cdtr?.Id?.OrgId?.AnyBIC, creditTransfer.UndrlygCstmrCdtTrf?.Cdtr?.Nm, creditTransfer.UndrlygCstmrCdtTrf?.Cdtr?.PstlAdr?.AdrLine, creditTransfer.UndrlygCstmrCdtTrf?.CdtrAcct?.Id?.IBAN, creditTransfer.UndrlygCstmrCdtTrf?.CdtrAcct?.Id?.Othr?.Id)[0],
        MT59A: getField59a(creditTransfer.UndrlygCstmrCdtTrf?.Cdtr?.Id?.OrgId?.AnyBIC, creditTransfer.UndrlygCstmrCdtTrf?.Cdtr?.Nm, creditTransfer.UndrlygCstmrCdtTrf?.Cdtr?.PstlAdr?.AdrLine, creditTransfer.UndrlygCstmrCdtTrf?.CdtrAcct?.Id?.IBAN, creditTransfer.UndrlygCstmrCdtTrf?.CdtrAcct?.Id?.Othr?.Id)[1],
        MT59F: getField59a(creditTransfer.UndrlygCstmrCdtTrf?.Cdtr?.Id?.OrgId?.AnyBIC, creditTransfer.UndrlygCstmrCdtTrf?.Cdtr?.Nm, creditTransfer.UndrlygCstmrCdtTrf?.Cdtr?.PstlAdr?.AdrLine, creditTransfer.UndrlygCstmrCdtTrf?.CdtrAcct?.Id?.IBAN, creditTransfer.UndrlygCstmrCdtTrf?.CdtrAcct?.Id?.Othr?.Id, townName = creditTransfer.UndrlygCstmrCdtTrf?.Cdtr?.PstlAdr?.TwnNm, countryCode = creditTransfer.UndrlygCstmrCdtTrf?.Cdtr?.PstlAdr?.Ctry)[2],
        MT70: getField70(creditTransfer.UndrlygCstmrCdtTrf?.RmtInf?.Ustrd),
        MT72: getField72(creditTransfer.UndrlygCstmrCdtTrf?.InstrForCdtrAgt, creditTransfer.UndrlygCstmrCdtTrf?.InstrForNxtAgt)
    };
}

isolated function transformPacs009ToMt203(pacsIsoRecord:Pacs009Document document, string messageType) returns swiftmt:MT203Message|error => let
    pacsIsoRecord:CreditTransferTransaction62 creditTransfer = document.FICdtTrf.CdtTrfTxInf[0],
    pacsIsoRecord:SettlementInstruction15 settlementInfo = document.FICdtTrf.GrpHdr.SttlmInf,
    swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT52D? field52 = check getField52(creditTransfer.Dbtr?.FinInstnId?.BICFI, creditTransfer.Dbtr?.FinInstnId?.Nm, creditTransfer.Dbtr?.FinInstnId?.PstlAdr?.AdrLine, creditTransfer.Dbtr?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, creditTransfer.DbtrAcct?.Id?.IBAN, creditTransfer.DbtrAcct?.Id?.Othr?.Id) in {
        block1: {
            logicalTerminal: getSenderOrReceiver(document.FICdtTrf.GrpHdr.InstdAgt?.FinInstnId?.BICFI)
        },
        block2: {
            'type: "output",
            messageType: messageType,
            MIRLogicalTerminal: getSenderOrReceiver(document.FICdtTrf.GrpHdr.InstgAgt?.FinInstnId?.BICFI),
            senderInputTime: {content: check convertToSwiftTimeFormat(document.FICdtTrf.GrpHdr.CreDtTm.substring(11))},
            MIRDate: {content: convertToSWIFTStandardDate(document.FICdtTrf.GrpHdr.CreDtTm.substring(0, 10))}
        },
        block3: createMtBlock3(document.FICdtTrf.CdtTrfTxInf[0].PmtId?.UETR),
        block4: {
            MT19: {name: MT19_NAME, Amnt: {content: check convertToString(document.FICdtTrf.GrpHdr.CtrlSum), number: NUMBER1}},
            MT30: {
                name: MT30_NAME,
                Dt: {content: convertToSWIFTStandardDate(creditTransfer.IntrBkSttlmDt), number: NUMBER1}
            },
            MT52A: field52 is swiftmt:MT52A ? field52 : (),
            MT52D: field52 is swiftmt:MT52D ? field52 : (),
            MT53A: getField53(settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.BICFI, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.Nm, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.PstlAdr?.AdrLine, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, settlementInfo.InstgRmbrsmntAgtAcct?.Id?.IBAN, settlementInfo.InstgRmbrsmntAgtAcct?.Id?.Othr?.Id, true)[0],
            MT53B: getField53(settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.BICFI, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.Nm, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.PstlAdr?.AdrLine, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, settlementInfo.InstgRmbrsmntAgtAcct?.Id?.IBAN, settlementInfo.InstgRmbrsmntAgtAcct?.Id?.Othr?.Id, true)[1],
            MT53D: getField53(settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.BICFI, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.Nm, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.PstlAdr?.AdrLine, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, settlementInfo.InstgRmbrsmntAgtAcct?.Id?.IBAN, settlementInfo.InstgRmbrsmntAgtAcct?.Id?.Othr?.Id, true)[3],
            MT54A: getField54(settlementInfo.InstdRmbrsmntAgt?.FinInstnId?.BICFI, settlementInfo.InstdRmbrsmntAgt?.FinInstnId?.Nm, settlementInfo.InstdRmbrsmntAgt?.FinInstnId?.PstlAdr?.AdrLine, settlementInfo.InstdRmbrsmntAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, settlementInfo.InstdRmbrsmntAgtAcct?.Id?.IBAN, settlementInfo.InstdRmbrsmntAgtAcct?.Id?.Othr?.Id, true)[0],
            MT54B: getField54(settlementInfo.InstdRmbrsmntAgt?.FinInstnId?.BICFI, settlementInfo.InstdRmbrsmntAgt?.FinInstnId?.Nm, settlementInfo.InstdRmbrsmntAgt?.FinInstnId?.PstlAdr?.AdrLine, settlementInfo.InstdRmbrsmntAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, settlementInfo.InstdRmbrsmntAgtAcct?.Id?.IBAN, settlementInfo.InstdRmbrsmntAgtAcct?.Id?.Othr?.Id, true)[1],
            MT54D: getField54(settlementInfo.InstdRmbrsmntAgt?.FinInstnId?.BICFI, settlementInfo.InstdRmbrsmntAgt?.FinInstnId?.Nm, settlementInfo.InstdRmbrsmntAgt?.FinInstnId?.PstlAdr?.AdrLine, settlementInfo.InstdRmbrsmntAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, settlementInfo.InstdRmbrsmntAgtAcct?.Id?.IBAN, settlementInfo.InstdRmbrsmntAgtAcct?.Id?.Othr?.Id, true)[2],
            MT72: getRepeatingField72(document.FICdtTrf.CdtTrfTxInf),
            Transaction: check getMT203Transaction(document.FICdtTrf.CdtTrfTxInf)
        }
    };

isolated function getMT203Transaction(pacsIsoRecord:CreditTransferTransaction62[] creditTransaction) returns swiftmt:MT203Transaction[]|error {
    swiftmt:MT203Transaction[] transactionArray = [];
    foreach pacsIsoRecord:CreditTransferTransaction62 transaxion in creditTransaction {
        swiftmt:MT56A?|swiftmt:MT56C?|swiftmt:MT56D? field56 = check getField56(transaxion.IntrmyAgt1?.FinInstnId?.BICFI, transaxion.IntrmyAgt1?.FinInstnId?.Nm, transaxion.IntrmyAgt1?.FinInstnId?.PstlAdr?.AdrLine, transaxion.IntrmyAgt1?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, transaxion.IntrmyAgt1Acct?.Id?.IBAN, transaxion.IntrmyAgt1Acct?.Id?.Othr?.Id);
        swiftmt:MT57A?|swiftmt:MT57B?|swiftmt:MT57C?|swiftmt:MT57D? field57 = check getField57(transaxion.CdtrAgt?.FinInstnId?.BICFI, transaxion.CdtrAgt?.FinInstnId?.Nm, transaxion.CdtrAgt?.FinInstnId?.PstlAdr?.AdrLine, transaxion.CdtrAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, transaxion.CdtrAgtAcct?.Id?.IBAN, transaxion.CdtrAgtAcct?.Id?.Othr?.Id, true);
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
            MT56A: field56 is swiftmt:MT56A ? field56 : (),
            MT56D: field56 is swiftmt:MT56D ? field56 : (),
            MT57A: field57 is swiftmt:MT57A ? field57 : (),
            MT57B: field57 is swiftmt:MT57B ? field57 : (),
            MT57D: field57 is swiftmt:MT57D ? field57 : (),
            MT58A: getField58(transaxion.Cdtr?.FinInstnId?.BICFI, transaxion.Cdtr?.FinInstnId?.Nm, transaxion.Cdtr?.FinInstnId?.PstlAdr?.AdrLine, transaxion.Cdtr?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, transaxion.CdtrAcct?.Id?.IBAN, transaxion.CdtrAcct?.Id?.Othr?.Id)[0],
            MT58D: getField58(transaxion.Cdtr?.FinInstnId?.BICFI, transaxion.Cdtr?.FinInstnId?.Nm, transaxion.Cdtr?.FinInstnId?.PstlAdr?.AdrLine, transaxion.Cdtr?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, transaxion.CdtrAcct?.Id?.IBAN, transaxion.CdtrAcct?.Id?.Othr?.Id)[1],
            MT72: getRepeatingField72(creditTransaction, transaxion)
        });
    }
    return transactionArray;
}

isolated function transformPacs009ToMt205(pacsIsoRecord:Pacs009Document document, string messageType) returns swiftmt:MT205Message|error => let
    pacsIsoRecord:CreditTransferTransaction62 creditTransfer = document.FICdtTrf.CdtTrfTxInf[0],
    pacsIsoRecord:SettlementInstruction15 settlementInfo = document.FICdtTrf.GrpHdr.SttlmInf,
    swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT52D? field52 = check getField52(creditTransfer.Dbtr?.FinInstnId?.BICFI, creditTransfer.Dbtr?.FinInstnId?.Nm, creditTransfer.Dbtr?.FinInstnId?.PstlAdr?.AdrLine, creditTransfer.Dbtr?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, creditTransfer.DbtrAcct?.Id?.IBAN, creditTransfer.DbtrAcct?.Id?.Othr?.Id),
    swiftmt:MT56A?|swiftmt:MT56C?|swiftmt:MT56D? field56 = check getField56(creditTransfer.IntrmyAgt1?.FinInstnId?.BICFI, creditTransfer.IntrmyAgt1?.FinInstnId?.Nm, creditTransfer.IntrmyAgt1?.FinInstnId?.PstlAdr?.AdrLine, creditTransfer.IntrmyAgt1?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, creditTransfer.IntrmyAgt1Acct?.Id?.IBAN, creditTransfer.IntrmyAgt1Acct?.Id?.Othr?.Id),
    swiftmt:MT57A?|swiftmt:MT57B?|swiftmt:MT57C?|swiftmt:MT57D? field57 = check getField57(creditTransfer.CdtrAgt?.FinInstnId?.BICFI, creditTransfer.CdtrAgt?.FinInstnId?.Nm, creditTransfer.CdtrAgt?.FinInstnId?.PstlAdr?.AdrLine, creditTransfer.CdtrAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, creditTransfer.CdtrAgtAcct?.Id?.IBAN, creditTransfer.CdtrAgtAcct?.Id?.Othr?.Id, true) in {
        block1: {
            logicalTerminal: getSenderOrReceiver(document.FICdtTrf.GrpHdr.InstdAgt?.FinInstnId?.BICFI)
        },
        block2: {
            'type: "output",
            messageType: messageType,
            MIRLogicalTerminal: getSenderOrReceiver(document.FICdtTrf.GrpHdr.InstgAgt?.FinInstnId?.BICFI),
            senderInputTime: {content: check convertToSwiftTimeFormat(document.FICdtTrf.GrpHdr.CreDtTm.substring(11))},
            MIRDate: {content: convertToSWIFTStandardDate(document.FICdtTrf.GrpHdr.CreDtTm.substring(0, 10))}
        },
        block3: createMtBlock3(document.FICdtTrf.CdtTrfTxInf[0].PmtId?.UETR),
        block4: {
            MT13C: getFieldMt13C(creditTransfer.SttlmTmReq?.CLSTm, creditTransfer.SttlmTmIndctn?.CdtDtTm, creditTransfer.SttlmTmIndctn?.DbtDtTm),
            MT20: {
                name: MT20_NAME,
                msgId: {
                    content: getMandatoryField(creditTransfer.PmtId.InstrId),
                    number: NUMBER1
                }
            },
            MT21: {
                name: MT21_NAME,
                Ref: {
                    content: creditTransfer.PmtId.EndToEndId,
                    number: NUMBER1
                }
            },
            MT32A: {
                name: MT32A_NAME,
                Dt: {
                    content: convertToSWIFTStandardDate(creditTransfer.IntrBkSttlmDt),
                    number: NUMBER1
                },
                Ccy: {
                    content: getMandatoryField(creditTransfer.IntrBkSttlmAmt.ActiveCurrencyAndAmount_SimpleType.Ccy),
                    number: NUMBER2
                },
                Amnt: {
                    content: check convertToString(creditTransfer.IntrBkSttlmAmt.ActiveCurrencyAndAmount_SimpleType.ActiveCurrencyAndAmount_SimpleType),
                    number: NUMBER2
                }
            },
            MT52A: field52 is swiftmt:MT52A ? field52 : (),
            MT52D: field52 is swiftmt:MT52D ? field52 : (),
            MT56A: field56 is swiftmt:MT56A ? field56 : (),
            MT56D: field56 is swiftmt:MT56D ? field56 : (),
            MT53A: getField53(settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.BICFI, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.Nm, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.PstlAdr?.AdrLine, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, settlementInfo.InstgRmbrsmntAgtAcct?.Id?.IBAN, settlementInfo.InstgRmbrsmntAgtAcct?.Id?.Othr?.Id, true)[0],
            MT53B: getField53(settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.BICFI, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.Nm, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.PstlAdr?.AdrLine, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, settlementInfo.InstgRmbrsmntAgtAcct?.Id?.IBAN, settlementInfo.InstgRmbrsmntAgtAcct?.Id?.Othr?.Id, true)[1],
            MT53D: getField53(settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.BICFI, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.Nm, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.PstlAdr?.AdrLine, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, settlementInfo.InstgRmbrsmntAgtAcct?.Id?.IBAN, settlementInfo.InstgRmbrsmntAgtAcct?.Id?.Othr?.Id, true)[3],
            MT57B: field57 is swiftmt:MT57B ? field57 : (),
            MT57D: field57 is swiftmt:MT57D ? field57 : (),
            MT58A: getField58(creditTransfer.Cdtr?.FinInstnId?.BICFI, creditTransfer.Cdtr?.FinInstnId?.Nm, creditTransfer.Cdtr?.FinInstnId?.PstlAdr?.AdrLine, creditTransfer.Cdtr?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, creditTransfer.CdtrAcct?.Id?.IBAN, creditTransfer.CdtrAcct?.Id?.Othr?.Id)[0],
            MT58D: getField58(creditTransfer.Cdtr?.FinInstnId?.BICFI, creditTransfer.Cdtr?.FinInstnId?.Nm, creditTransfer.Cdtr?.FinInstnId?.PstlAdr?.AdrLine, creditTransfer.Cdtr?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, creditTransfer.CdtrAcct?.Id?.IBAN, creditTransfer.CdtrAcct?.Id?.Othr?.Id)[1],
            MT72: getField72(creditTransfer.InstrForCdtrAgt, creditTransfer.InstrForNxtAgt)
        }
    };

isolated function transformPacs009ToMt205COV(pacsIsoRecord:Pacs009Document document, string messageType) returns swiftmt:MT205COVMessage|error => let
    pacsIsoRecord:CreditTransferTransaction62 creditTransfer = document.FICdtTrf.CdtTrfTxInf[0],
    pacsIsoRecord:SettlementInstruction15 settlementInfo = document.FICdtTrf.GrpHdr.SttlmInf,
    swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT52D? field52 = check getField52(creditTransfer.Dbtr?.FinInstnId?.BICFI, creditTransfer.Dbtr?.FinInstnId?.Nm, creditTransfer.Dbtr?.FinInstnId?.PstlAdr?.AdrLine, creditTransfer.Dbtr?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, creditTransfer.DbtrAcct?.Id?.IBAN, creditTransfer.DbtrAcct?.Id?.Othr?.Id),
    swiftmt:MT56A?|swiftmt:MT56C?|swiftmt:MT56D? field56 = check getField56(creditTransfer.IntrmyAgt1?.FinInstnId?.BICFI, creditTransfer.IntrmyAgt1?.FinInstnId?.Nm, creditTransfer.IntrmyAgt1?.FinInstnId?.PstlAdr?.AdrLine, creditTransfer.IntrmyAgt1?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, creditTransfer.IntrmyAgt1Acct?.Id?.IBAN, creditTransfer.IntrmyAgt1Acct?.Id?.Othr?.Id),
    swiftmt:MT57A?|swiftmt:MT57B?|swiftmt:MT57C?|swiftmt:MT57D? field57 = check getField57(creditTransfer.CdtrAgt?.FinInstnId?.BICFI, creditTransfer.CdtrAgt?.FinInstnId?.Nm, creditTransfer.CdtrAgt?.FinInstnId?.PstlAdr?.AdrLine, creditTransfer.CdtrAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, creditTransfer.CdtrAgtAcct?.Id?.IBAN, creditTransfer.CdtrAgtAcct?.Id?.Othr?.Id, true) in {
        block1: {
            logicalTerminal: getSenderOrReceiver(document.FICdtTrf.GrpHdr.InstdAgt?.FinInstnId?.BICFI)
        },
        block2: {
            'type: "output",
            messageType: messageType,
            MIRLogicalTerminal: getSenderOrReceiver(document.FICdtTrf.GrpHdr.InstgAgt?.FinInstnId?.BICFI),
            senderInputTime: {content: check convertToSwiftTimeFormat(document.FICdtTrf.GrpHdr.CreDtTm.substring(11))},
            MIRDate: {content: convertToSWIFTStandardDate(document.FICdtTrf.GrpHdr.CreDtTm.substring(0, 10))}
        },
        block3: createMtBlock3(document.FICdtTrf.CdtTrfTxInf[0].PmtId?.UETR, VALIDATION_FLAG_COV),
        block4: {
            MT13C: getFieldMt13C(creditTransfer.SttlmTmReq?.CLSTm, creditTransfer.SttlmTmIndctn?.CdtDtTm, creditTransfer.SttlmTmIndctn?.DbtDtTm),
            MT20: {
                name: MT20_NAME,
                msgId: {
                    content: getMandatoryField(creditTransfer.PmtId.InstrId),
                    number: NUMBER1
                }
            },
            MT21: {
                name: MT21_NAME,
                Ref: {
                    content: creditTransfer.PmtId.EndToEndId,
                    number: NUMBER1
                }
            },
            MT32A: {
                name: MT32A_NAME,
                Dt: {
                    content: convertToSWIFTStandardDate(creditTransfer.IntrBkSttlmDt),
                    number: NUMBER1
                },
                Ccy: {
                    content: getMandatoryField(creditTransfer.IntrBkSttlmAmt.ActiveCurrencyAndAmount_SimpleType.Ccy),
                    number: NUMBER2
                },
                Amnt: {
                    content: check convertToString(creditTransfer.IntrBkSttlmAmt.ActiveCurrencyAndAmount_SimpleType.ActiveCurrencyAndAmount_SimpleType),
                    number: NUMBER2
                }
            },
            MT52A: field52 is swiftmt:MT52A ? field52 : (),
            MT52D: field52 is swiftmt:MT52D ? field52 : (),
            MT56A: field56 is swiftmt:MT56A ? field56 : (),
            MT56D: field56 is swiftmt:MT56D ? field56 : (),
            MT53A: getField53(settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.BICFI, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.Nm, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.PstlAdr?.AdrLine, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, settlementInfo.InstgRmbrsmntAgtAcct?.Id?.IBAN, settlementInfo.InstgRmbrsmntAgtAcct?.Id?.Othr?.Id, true)[0],
            MT53B: getField53(settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.BICFI, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.Nm, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.PstlAdr?.AdrLine, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, settlementInfo.InstgRmbrsmntAgtAcct?.Id?.IBAN, settlementInfo.InstgRmbrsmntAgtAcct?.Id?.Othr?.Id, true)[1],
            MT53D: getField53(settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.BICFI, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.Nm, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.PstlAdr?.AdrLine, settlementInfo.InstgRmbrsmntAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, settlementInfo.InstgRmbrsmntAgtAcct?.Id?.IBAN, settlementInfo.InstgRmbrsmntAgtAcct?.Id?.Othr?.Id, true)[3],
            MT57A: field57 is swiftmt:MT57A ? field57 : (),
            MT57B: field57 is swiftmt:MT57B ? field57 : (),
            MT57D: field57 is swiftmt:MT57D ? field57 : (),
            MT58A: getField58(creditTransfer.Cdtr?.FinInstnId?.BICFI, creditTransfer.Cdtr?.FinInstnId?.Nm, creditTransfer.Cdtr?.FinInstnId?.PstlAdr?.AdrLine, creditTransfer.Cdtr?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, creditTransfer.CdtrAcct?.Id?.IBAN, creditTransfer.CdtrAcct?.Id?.Othr?.Id)[0],
            MT58D: getField58(creditTransfer.Cdtr?.FinInstnId?.BICFI, creditTransfer.Cdtr?.FinInstnId?.Nm, creditTransfer.Cdtr?.FinInstnId?.PstlAdr?.AdrLine, creditTransfer.Cdtr?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, creditTransfer.CdtrAcct?.Id?.IBAN, creditTransfer.CdtrAcct?.Id?.Othr?.Id)[1],
            MT72: getField72(creditTransfer.InstrForCdtrAgt, creditTransfer.InstrForNxtAgt),
            UndrlygCstmrCdtTrf: check getUnderlyingCustomerTransaction(creditTransfer)
        }
    };
