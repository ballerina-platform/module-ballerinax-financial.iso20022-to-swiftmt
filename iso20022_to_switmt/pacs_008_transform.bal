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

# Transforms a PACS008 document to an MT102 message
#
# + document - The PACS008 document
# + messageType - The SWIFT message type
# + return - The MT102 message or an error if the transformation fails
isolated function transformPacs008DocumentToMT102(pacsIsoRecord:Pacs008Document document, string messageType) returns swiftmt:MT102Message|error => {
    block1: {
        logicalTerminal: getSenderOrReceiver(document.FIToFICstmrCdtTrf.GrpHdr.InstdAgt?.FinInstnId?.BICFI)
    },
    block2: {
        'type: "output",
        messageType: messageType,
        MIRLogicalTerminal: getSenderOrReceiver(document.FIToFICstmrCdtTrf.GrpHdr.InstgAgt?.FinInstnId?.BICFI),
        senderInputTime: {content: check convertToSwiftTimeFormat(document.FIToFICstmrCdtTrf.GrpHdr.CreDtTm.substring(11))},
        MIRDate: {content: convertToSWIFTStandardDate(document.FIToFICstmrCdtTrf.GrpHdr.CreDtTm.substring(0, 10))}
    },
    block3: createMtBlock3(document.FIToFICstmrCdtTrf.CdtTrfTxInf[0].PmtId?.UETR),
    block4: check generateMT102Block4(document, false).ensureType(swiftmt:MT102Block4),
    block5: check generateMtBlock5FromSupplementaryData(document.FIToFICstmrCdtTrf.SplmtryData)
};

# Transforms a PACS008 document to an MT102STP message
#
# + document - The PACS008 document
# + messageType - The SWIFT message type
# + return - The MT102STP message or an error if the transformation fails
isolated function transformPacs008DocumentToMT102STP(pacsIsoRecord:Pacs008Document document, string messageType) returns swiftmt:MT102STPMessage|error => {
    block1: {
        logicalTerminal: getSenderOrReceiver(document.FIToFICstmrCdtTrf.GrpHdr.InstdAgt?.FinInstnId?.BICFI)
    },
    block2: {
        'type: "output",
        messageType: messageType,
        MIRLogicalTerminal: getSenderOrReceiver(document.FIToFICstmrCdtTrf.GrpHdr.InstgAgt?.FinInstnId?.BICFI),
        senderInputTime: {content: check convertToSwiftTimeFormat(document.FIToFICstmrCdtTrf.GrpHdr.CreDtTm.substring(11))},
        MIRDate: {content: convertToSWIFTStandardDate(document.FIToFICstmrCdtTrf.GrpHdr.CreDtTm.substring(0, 10))}
    },
    block3: createMtBlock3(document.FIToFICstmrCdtTrf.CdtTrfTxInf[0].PmtId?.UETR, VALIDATION_FLAG_STP),
    block4: check generateMT102Block4(document, true).ensureType(swiftmt:MT102STPBlock4),
    block5: check generateMtBlock5FromSupplementaryData(document.FIToFICstmrCdtTrf.SplmtryData)
};

# Creates the block 4 of an MT102 message from a PACS008 document
#
# + document - The PACS008 document
# + isSTP - A boolean indicating whether the message is an STP message
# + return - The block 4 of the MT102 message or an error if the transformation fails
isolated function generateMT102Block4(pacsIsoRecord:Pacs008Document document, boolean isSTP) returns swiftmt:MT102Block4|swiftmt:MT102STPBlock4|error {
    pacsIsoRecord:GroupHeader113 grpHdr = document.FIToFICstmrCdtTrf.GrpHdr;
    pacsIsoRecord:CreditTransferTransaction64[] transactions = document.FIToFICstmrCdtTrf.CdtTrfTxInf;
    pacsIsoRecord:CreditTransferTransaction64 firstTransaction = transactions[0];

    swiftmt:MT20 MT20 = {
        name: MT20_NAME,
        msgId: {
            content: grpHdr.MsgId,
            number: NUMBER1
        }
    };

    swiftmt:MT23 MT23 = {
        name: MT23_NAME,
        Cd: {content: firstTransaction.PmtTpInf?.CtgyPurp?.Cd.toString(), number: NUMBER1}
    };

    swiftmt:MT51A? MT51A = getField51A(grpHdr.InstgAgt?.FinInstnId?.BICFI, grpHdr.InstgAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd);

    swiftmt:MT50A? MT50A = (check getOrderingCustomerFromPacs008Document(document.FIToFICstmrCdtTrf.CdtTrfTxInf))[0];
    swiftmt:MT50F? MT50F = (check getOrderingCustomerFromPacs008Document(document.FIToFICstmrCdtTrf.CdtTrfTxInf))[4];
    swiftmt:MT50K? MT50K = (check getOrderingCustomerFromPacs008Document(document.FIToFICstmrCdtTrf.CdtTrfTxInf))[2];

    swiftmt:MT52A? MT52A = (check getMT102OrderingInstitutionFromPacs008Document(document.FIToFICstmrCdtTrf.CdtTrfTxInf))[0];
    swiftmt:MT52B? MT52B = (check getMT102OrderingInstitutionFromPacs008Document(document.FIToFICstmrCdtTrf.CdtTrfTxInf))[1];
    swiftmt:MT52C? MT52C = (check getMT102OrderingInstitutionFromPacs008Document(document.FIToFICstmrCdtTrf.CdtTrfTxInf))[2];

    swiftmt:MT26T? MT26T = getRepeatingField26TForPacs008(document.FIToFICstmrCdtTrf.CdtTrfTxInf);

    swiftmt:MT71A? MT71A = getRepeatingField71AForPacs008(document.FIToFICstmrCdtTrf.CdtTrfTxInf);

    swiftmt:MT36? MT36 = check getRepeatingField36(document.FIToFICstmrCdtTrf.CdtTrfTxInf);

    swiftmt:MT32A MT32A = {
        name: MT32A_NAME,
        Dt: {content: convertToSWIFTStandardDate(firstTransaction.IntrBkSttlmDt)},
        Ccy: {content: getMandatoryField(grpHdr.TtlIntrBkSttlmAmt?.ActiveCurrencyAndAmount_SimpleType?.Ccy)},
        Amnt: {content: check convertToString(grpHdr.TtlIntrBkSttlmAmt?.ActiveCurrencyAndAmount_SimpleType?.ActiveCurrencyAndAmount_SimpleType)}
    };

    swiftmt:MT19? MT19 = check getField19(grpHdr.CtrlSum);

    swiftmt:MT71G? MT71G = check convertCharges16toMT71G(firstTransaction.ChrgsInf, firstTransaction.ChrgBr);
    swiftmt:MT13C? MT13C = check convertTimeToMT13C(firstTransaction.SttlmTmIndctn, firstTransaction.SttlmTmReq);
    swiftmt:MT53A? MT53A = getField53(grpHdr.SttlmInf.InstgRmbrsmntAgt?.FinInstnId?.BICFI, grpHdr.SttlmInf.InstgRmbrsmntAgt?.FinInstnId?.Nm, grpHdr.SttlmInf.InstgRmbrsmntAgt?.FinInstnId?.PstlAdr?.AdrLine, grpHdr.SttlmInf.InstgRmbrsmntAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, grpHdr.SttlmInf.InstgRmbrsmntAgtAcct?.Id?.IBAN, grpHdr.SttlmInf.InstgRmbrsmntAgtAcct?.Id?.Othr?.Id, isOptionCPresent = true)[0];
    swiftmt:MT53C? MT53C = getField53(grpHdr.SttlmInf.InstgRmbrsmntAgt?.FinInstnId?.BICFI, grpHdr.SttlmInf.InstgRmbrsmntAgt?.FinInstnId?.Nm, grpHdr.SttlmInf.InstgRmbrsmntAgt?.FinInstnId?.PstlAdr?.AdrLine, grpHdr.SttlmInf.InstgRmbrsmntAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, grpHdr.SttlmInf.InstgRmbrsmntAgtAcct?.Id?.IBAN, grpHdr.SttlmInf.InstgRmbrsmntAgtAcct?.Id?.Othr?.Id, isOptionCPresent = true)[2];
    swiftmt:MT54A? MT54A = getField54(grpHdr.SttlmInf.InstdRmbrsmntAgt?.FinInstnId?.BICFI, grpHdr.SttlmInf.InstdRmbrsmntAgt?.FinInstnId?.Nm, grpHdr.SttlmInf.InstdRmbrsmntAgt?.FinInstnId?.PstlAdr?.AdrLine, grpHdr.SttlmInf.InstdRmbrsmntAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, grpHdr.SttlmInf.InstdRmbrsmntAgtAcct?.Id?.IBAN, grpHdr.SttlmInf.InstdRmbrsmntAgtAcct?.Id?.Othr?.Id)[0];
    swiftmt:MT72? MT72 = getField72(firstTransaction.InstrForCdtrAgt, firstTransaction.InstrForNxtAgt, firstTransaction.IntrmyAgt1, firstTransaction.IntrmyAgt2, firstTransaction.PmtTpInf?.SvcLvl, firstTransaction.PmtTpInf?.CtgyPurp, firstTransaction.PmtTpInf?.LclInstrm);
    swiftmt:MT77B? MT77B = getRepeatingField77BForPacs008(document.FIToFICstmrCdtTrf.CdtTrfTxInf);

    swiftmt:MT102STPTransaction[]|swiftmt:MT102Transaction[] Transactions = check generateMT102Transactions(
            document.FIToFICstmrCdtTrf.CdtTrfTxInf,
            isSTP,
            document
    );

    if isSTP {
        swiftmt:MT102STPBlock4 MT102STPBlock4 = {
            MT20,
            MT23,
            MT50A,
            MT50F,
            MT50K,
            MT52A,
            MT26T,
            MT32A,
            MT19,
            MT71A,
            MT71G,
            MT13C,
            MT53A,
            MT53C,
            MT54A,
            MT72,
            MT77B,
            Transaction: <swiftmt:MT102STPTransaction[]>Transactions
        };
        return MT102STPBlock4;
    }
    swiftmt:MT102Block4 MT102Block4 = {
        MT20,
        MT23,
        MT51A,
        MT50A,
        MT50F,
        MT50K,
        MT52A,
        MT52C,
        MT26T,
        MT71A,
        MT36,
        MT77B,
        Transaction: <swiftmt:MT102Transaction[]>Transactions,
        MT32A,
        MT19,
        MT71G,
        MT13C,
        MT53A,
        MT53C,
        MT54A,
        MT52B,
        MT72
    };

    return MT102Block4;
}

# Creates the transactions of an MT102 message from a PACS008 document
#
# + mxTransactions - The credit transfer transactions
# + isSTP - A boolean indicating whether the message is an STP message
# + document - The PACS008 document
# + return - The transactions of the MT102 message or an error if the transformation fails
isolated function generateMT102Transactions(
        pacsIsoRecord:CreditTransferTransaction64[] mxTransactions,
        boolean isSTP,
        pacsIsoRecord:Pacs008Document document)
returns swiftmt:MT102Transaction[]|swiftmt:MT102STPTransaction[]|error {
    swiftmt:MT102Transaction[] transactions = [];
    swiftmt:MT102STPTransaction[] transactionsSTP = [];
    foreach pacsIsoRecord:CreditTransferTransaction64 transaxion in mxTransactions {
        swiftmt:MT21 MT21 = {
            name: MT21_NAME,
            Ref: {
                content: transaxion.PmtId.EndToEndId,
                number: NUMBER1
            }
        };

        swiftmt:MT32B MT32B = {
            name: MT32B_NAME,
            Ccy: {
                content: getActiveOrHistoricCurrencyAndAmountCcy(transaxion.InstdAmt),
                number: NUMBER1
            },
            Amnt: {
                content: getActiveOrHistoricCurrencyAndAmountValue(transaxion.InstdAmt),
                number: NUMBER2
            }
        };

        swiftmt:MT50A? MT50A = (check getOrderingCustomerFromPacs008Document(mxTransactions, transaxion))[0];
        swiftmt:MT50F? MT50F = (check getOrderingCustomerFromPacs008Document(mxTransactions, transaxion))[4];
        swiftmt:MT50K? MT50K = (check getOrderingCustomerFromPacs008Document(mxTransactions, transaxion))[2];

        swiftmt:MT52A? MT52A = (check getMT102OrderingInstitutionFromPacs008Document(mxTransactions, transaxion))[0];
        swiftmt:MT52B? MT52B = (check getMT102OrderingInstitutionFromPacs008Document(mxTransactions, transaxion))[1];
        swiftmt:MT52C? MT52C = (check getMT102OrderingInstitutionFromPacs008Document(mxTransactions, transaxion))[2];

        swiftmt:MT57A? MT57A = (check getField57Alt(transaxion.CdtrAgt?.FinInstnId?.BICFI, transaxion.CdtrAgt?.FinInstnId?.Nm, transaxion.CdtrAgt?.FinInstnId?.PstlAdr?.AdrLine, transaxion.CdtrAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, transaxion.CdtrAgtAcct?.Id?.IBAN, transaxion.CdtrAgtAcct?.Id?.Othr?.Id, isOptionCPresent = true))[0];
        swiftmt:MT57C? MT57C = (check getField57Alt(transaxion.CdtrAgt?.FinInstnId?.BICFI, transaxion.CdtrAgt?.FinInstnId?.Nm, transaxion.CdtrAgt?.FinInstnId?.PstlAdr?.AdrLine, transaxion.CdtrAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, transaxion.CdtrAgtAcct?.Id?.IBAN, transaxion.CdtrAgtAcct?.Id?.Othr?.Id, isOptionCPresent = true))[2];

        swiftmt:MT59? MT59 = getField59a(transaxion.Cdtr.Id?.OrgId?.AnyBIC, transaxion.Cdtr?.Nm, transaxion.Cdtr.PstlAdr?.AdrLine, transaxion.CdtrAcct?.Id?.IBAN, transaxion.CdtrAcct?.Id?.Othr?.Id)[0];
        swiftmt:MT59A? MT59A = getField59a(transaxion.Cdtr.Id?.OrgId?.AnyBIC, transaxion.Cdtr?.Nm, transaxion.Cdtr.PstlAdr?.AdrLine, transaxion.CdtrAcct?.Id?.IBAN, transaxion.CdtrAcct?.Id?.Othr?.Id)[1];
        swiftmt:MT59F? MT59F = getField59a(transaxion.Cdtr.Id?.OrgId?.AnyBIC, transaxion.Cdtr?.Nm, transaxion.Cdtr.PstlAdr?.AdrLine, transaxion.CdtrAcct?.Id?.IBAN, transaxion.CdtrAcct?.Id?.Othr?.Id, townName = transaxion.Cdtr?.PstlAdr?.TwnNm, countryCode = transaxion.Cdtr?.PstlAdr?.Ctry)[2];

        swiftmt:MT70 MT70 = getRemittanceInformation(transaxion.PmtId, transaxion.RmtInf, transaxion.Purp);

        swiftmt:MT26T? MT26T = getRepeatingField26TForPacs008(mxTransactions, transaxion.Purp);

        swiftmt:MT33B? MT33B = check getField33B(transaxion.InstdAmt, transaxion.IntrBkSttlmAmt);

        swiftmt:MT71A? MT71A = getRepeatingField71AForPacs008(mxTransactions, transaxion.ChrgBr);

        swiftmt:MT71F? MT71F = check convertCharges16toMT71F(transaxion.ChrgsInf, transaxion.ChrgBr);
        swiftmt:MT71G? MT71G = check convertCharges16toMT71G(transaxion.ChrgsInf, transaxion.ChrgBr);

        swiftmt:MT36? MT36 = check getRepeatingField36(mxTransactions, transaxion.XchgRate);
        swiftmt:MT77B? MT77B = getRepeatingField77BForPacs008(document.FIToFICstmrCdtTrf.CdtTrfTxInf, transaxion);

        if isSTP {
            transactionsSTP.push({MT21, MT32B, MT50A, MT50F, MT50K, MT52A, MT57A, MT59, MT59A, MT59F, MT70, MT26T, MT33B, MT77B, MT71A, MT71F, MT71G, MT36});
        } else {
            transactions.push({MT21, MT32B, MT50A, MT50F, MT50K, MT52A, MT52B, MT52C, MT57A, MT57C, MT59, MT59A, MT59F, MT70, MT26T, MT33B, MT77B, MT71A, MT71F, MT71G, MT36});
        }
    }

    if isSTP {
        return transactionsSTP;
    } else {
        return transactions;
    }
}

# This enum represents the different types of MT103 messages
enum MT103Type {
    MT103,
    MT103_STP,
    MT103_REMIT
}

# Transforms a PACS008 document to an MT103 message
#
# + document - The PACS008 document
# + messageType - The SWIFT message type
# + return - The MT103 message or an error if the transformation fails
isolated function transformPacs008DocumentToMT103(pacsIsoRecord:Pacs008Document document, string messageType) returns swiftmt:MT103Message|error => {
    block1: {
        logicalTerminal: getSenderOrReceiver(document.FIToFICstmrCdtTrf.GrpHdr.InstdAgt?.FinInstnId?.BICFI)
    },
    block2: {
        'type: "output",
        messageType: messageType,
        MIRLogicalTerminal: getSenderOrReceiver(document.FIToFICstmrCdtTrf.GrpHdr.InstgAgt?.FinInstnId?.BICFI),
        senderInputTime: {content: check convertToSwiftTimeFormat(document.FIToFICstmrCdtTrf.GrpHdr.CreDtTm.substring(11))},
        MIRDate: {content: convertToSWIFTStandardDate(document.FIToFICstmrCdtTrf.GrpHdr.CreDtTm.substring(0, 10))}
    },
    block3: createMtBlock3(document.FIToFICstmrCdtTrf.CdtTrfTxInf[0].PmtId?.UETR),
    block4: check generateMT103Block4(document, MT103).ensureType(swiftmt:MT103Block4),
    block5: check generateMtBlock5FromSupplementaryData(document.FIToFICstmrCdtTrf.SplmtryData)
};

# Transforms a PACS008 document to an MT103STP message
#
# + document - The PACS008 document
# + messageType - The SWIFT message type
# + return - The MT103STP message or an error if the transformation fails
isolated function transformPacs008DocumentToMT103STP(pacsIsoRecord:Pacs008Document document, string messageType) returns swiftmt:MT103STPMessage|error => {
    block1: {
        logicalTerminal: getSenderOrReceiver(document.FIToFICstmrCdtTrf.GrpHdr.InstdAgt?.FinInstnId?.BICFI)
    },
    block2: {
        'type: "output",
        messageType: messageType,
        MIRLogicalTerminal: getSenderOrReceiver(document.FIToFICstmrCdtTrf.GrpHdr.InstgAgt?.FinInstnId?.BICFI),
        senderInputTime: {content: check convertToSwiftTimeFormat(document.FIToFICstmrCdtTrf.GrpHdr.CreDtTm.substring(11))},
        MIRDate: {content: convertToSWIFTStandardDate(document.FIToFICstmrCdtTrf.GrpHdr.CreDtTm.substring(0, 10))}
    },
    block3: createMtBlock3(document.FIToFICstmrCdtTrf.CdtTrfTxInf[0].PmtId?.UETR, VALIDATION_FLAG_STP),
    block4: check generateMT103Block4(document, MT103_STP).ensureType(swiftmt:MT103STPBlock4),
    block5: check generateMtBlock5FromSupplementaryData(document.FIToFICstmrCdtTrf.SplmtryData)
};

# Transforms a PACS008 document to an MT103REMIT message
#
# + document - The PACS008 document
# + messageType - The SWIFT message type
# + return - The MT103REMIT message or an error if the transformation fails
isolated function transformPacs008DocumentToMT103REMIT(pacsIsoRecord:Pacs008Document document, string messageType) returns swiftmt:MT103REMITMessage|error => {
    block1: {
        logicalTerminal: getSenderOrReceiver(document.FIToFICstmrCdtTrf.GrpHdr.InstdAgt?.FinInstnId?.BICFI)
    },
    block2: {
        'type: "output",
        messageType: messageType,
        MIRLogicalTerminal: getSenderOrReceiver(document.FIToFICstmrCdtTrf.GrpHdr.InstgAgt?.FinInstnId?.BICFI),
        senderInputTime: {content: check convertToSwiftTimeFormat(document.FIToFICstmrCdtTrf.GrpHdr.CreDtTm.substring(11))},
        MIRDate: {content: convertToSWIFTStandardDate(document.FIToFICstmrCdtTrf.GrpHdr.CreDtTm.substring(0, 10))}
    },
    block3: createMtBlock3(document.FIToFICstmrCdtTrf.CdtTrfTxInf[0].PmtId?.UETR, VALIDATION_FLAG_REMIT),
    block4: check generateMT103Block4(document, MT103_REMIT).ensureType(swiftmt:MT103REMITBlock4),
    block5: check generateMtBlock5FromSupplementaryData(document.FIToFICstmrCdtTrf.SplmtryData)
};

# Creates the block 4 of an MT103 message from a PACS008 document
#
# + document - The PACS008 document
# + messageType - The type of the MT103 message
# + return - The block 4 of the MT103 message or an error if the transformation fails
isolated function generateMT103Block4(pacsIsoRecord:Pacs008Document document, MT103Type messageType) returns swiftmt:MT103Block4|swiftmt:MT103STPBlock4|swiftmt:MT103REMITBlock4|error {
    pacsIsoRecord:GroupHeader113 grpHdr = document.FIToFICstmrCdtTrf.GrpHdr;
    pacsIsoRecord:CreditTransferTransaction64[] transactions = document.FIToFICstmrCdtTrf.CdtTrfTxInf;

    pacsIsoRecord:CreditTransferTransaction64 firstTransaction = transactions[0];
    swiftmt:MT13C? MT13C = check convertTimeToMT13C(firstTransaction.SttlmTmIndctn, firstTransaction.SttlmTmReq);

    swiftmt:MT20 MT20 = {
        name: MT20_NAME,
        msgId: {
            content: document.FIToFICstmrCdtTrf.GrpHdr.MsgId,
            number: NUMBER1
        }
    };

    swiftmt:MT23B MT23B = {
        name: MT23_NAME,
        Typ: {
            content: getBankOperationCodeFromPaymentTypeInformation22(firstTransaction.PmtTpInf),
            number: NUMBER1
        }
    };

    swiftmt:MT23E[]? MT23E = mapCategoryPurposeToMT23E(firstTransaction.Purp);

    swiftmt:MT26T? MT26T = getField26T(firstTransaction.Purp?.Cd);

    swiftmt:MT32A MT32A = {
        name: MT32A_NAME,
        Dt: {content: convertToSWIFTStandardDate(firstTransaction.IntrBkSttlmDt), number: NUMBER1},
        Ccy: {content: getMandatoryField(firstTransaction.IntrBkSttlmAmt?.ActiveCurrencyAndAmount_SimpleType?.Ccy), number: NUMBER2},
        Amnt: {content: check convertToString(firstTransaction.IntrBkSttlmAmt?.ActiveCurrencyAndAmount_SimpleType?.ActiveCurrencyAndAmount_SimpleType), number: NUMBER3}
    };

    swiftmt:MT33B? MT33B = check getField33B(firstTransaction.InstdAmt, firstTransaction.IntrBkSttlmAmt);

    swiftmt:MT36? MT36 = check getField36(firstTransaction.XchgRate);

    swiftmt:MT50A? MT50A = (check getField50a(firstTransaction?.Dbtr?.Id?.OrgId?.AnyBIC, firstTransaction?.Dbtr?.Nm, firstTransaction?.Dbtr?.PstlAdr?.AdrLine, firstTransaction?.DbtrAcct?.Id?.IBAN, firstTransaction?.DbtrAcct?.Id?.Othr?.Id, firstTransaction?.Dbtr?.Id?.PrvtId?.Othr))[0];
    swiftmt:MT50F? MT50F = (check getField50a(firstTransaction?.Dbtr?.Id?.OrgId?.AnyBIC, firstTransaction?.Dbtr?.Nm, firstTransaction?.Dbtr?.PstlAdr?.AdrLine, firstTransaction?.DbtrAcct?.Id?.IBAN, firstTransaction?.DbtrAcct?.Id?.Othr?.Id, firstTransaction?.Dbtr?.Id?.PrvtId?.Othr, false, firstTransaction?.Dbtr?.PstlAdr?.TwnNm, firstTransaction?.Dbtr?.PstlAdr?.Ctry))[4];
    swiftmt:MT50K? MT50K = (check getField50a(firstTransaction?.Dbtr?.Id?.OrgId?.AnyBIC, firstTransaction?.Dbtr?.Nm, firstTransaction?.Dbtr?.PstlAdr?.AdrLine, firstTransaction?.DbtrAcct?.Id?.IBAN, firstTransaction?.DbtrAcct?.Id?.Othr?.Id, firstTransaction?.Dbtr?.Id?.PrvtId?.Othr))[2];

    swiftmt:MT51A? MT51A = getField51A(grpHdr.InstgAgt?.FinInstnId?.BICFI, grpHdr.InstgAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd);

    swiftmt:MT52A? MT52A = (check getField52Alt(firstTransaction.DbtrAgt?.FinInstnId?.BICFI, firstTransaction.DbtrAgt?.FinInstnId?.Nm, firstTransaction.DbtrAgt?.FinInstnId?.PstlAdr?.AdrLine, firstTransaction.DbtrAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, firstTransaction.DbtrAgtAcct?.Id?.IBAN, firstTransaction.DbtrAgtAcct?.Id?.Othr?.Id))[0];
    swiftmt:MT52D? MT52D = (check getField52Alt(firstTransaction.DbtrAgt?.FinInstnId?.BICFI, firstTransaction.DbtrAgt?.FinInstnId?.Nm, firstTransaction.DbtrAgt?.FinInstnId?.PstlAdr?.AdrLine, firstTransaction.DbtrAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, firstTransaction.DbtrAgtAcct?.Id?.IBAN, firstTransaction.DbtrAgtAcct?.Id?.Othr?.Id))[3];

    swiftmt:MT53A? MT53A = getField53(grpHdr.SttlmInf.InstgRmbrsmntAgt?.FinInstnId?.BICFI, grpHdr.SttlmInf.InstgRmbrsmntAgt?.FinInstnId?.Nm, grpHdr.SttlmInf.InstgRmbrsmntAgt?.FinInstnId?.PstlAdr?.AdrLine, grpHdr.SttlmInf.InstgRmbrsmntAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, grpHdr.SttlmInf.InstgRmbrsmntAgtAcct?.Id?.IBAN, grpHdr.SttlmInf.InstgRmbrsmntAgtAcct?.Id?.Othr?.Id, isOptionBPresent = true)[0];
    swiftmt:MT53B? MT53B = getField53(grpHdr.SttlmInf.InstgRmbrsmntAgt?.FinInstnId?.BICFI, grpHdr.SttlmInf.InstgRmbrsmntAgt?.FinInstnId?.Nm, grpHdr.SttlmInf.InstgRmbrsmntAgt?.FinInstnId?.PstlAdr?.AdrLine, grpHdr.SttlmInf.InstgRmbrsmntAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, grpHdr.SttlmInf.InstgRmbrsmntAgtAcct?.Id?.IBAN, grpHdr.SttlmInf.InstgRmbrsmntAgtAcct?.Id?.Othr?.Id, isOptionBPresent = true)[1];

    swiftmt:MT54A? MT54A = getField54(grpHdr.SttlmInf.InstdRmbrsmntAgt?.FinInstnId?.BICFI, grpHdr.SttlmInf.InstdRmbrsmntAgt?.FinInstnId?.Nm, grpHdr.SttlmInf.InstdRmbrsmntAgt?.FinInstnId?.PstlAdr?.AdrLine, grpHdr.SttlmInf.InstdRmbrsmntAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, grpHdr.SttlmInf.InstdRmbrsmntAgtAcct?.Id?.IBAN, grpHdr.SttlmInf.InstdRmbrsmntAgtAcct?.Id?.Othr?.Id, isOptionBPresent = true)[0];
    swiftmt:MT54B? MT54B = getField54(grpHdr.SttlmInf.InstdRmbrsmntAgt?.FinInstnId?.BICFI, grpHdr.SttlmInf.InstdRmbrsmntAgt?.FinInstnId?.Nm, grpHdr.SttlmInf.InstdRmbrsmntAgt?.FinInstnId?.PstlAdr?.AdrLine, grpHdr.SttlmInf.InstdRmbrsmntAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, grpHdr.SttlmInf.InstdRmbrsmntAgtAcct?.Id?.IBAN, grpHdr.SttlmInf.InstdRmbrsmntAgtAcct?.Id?.Othr?.Id, isOptionBPresent = true)[1];
    swiftmt:MT54D? MT54D = getField54(grpHdr.SttlmInf.InstdRmbrsmntAgt?.FinInstnId?.BICFI, grpHdr.SttlmInf.InstdRmbrsmntAgt?.FinInstnId?.Nm, grpHdr.SttlmInf.InstdRmbrsmntAgt?.FinInstnId?.PstlAdr?.AdrLine, grpHdr.SttlmInf.InstdRmbrsmntAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, grpHdr.SttlmInf.InstdRmbrsmntAgtAcct?.Id?.IBAN, grpHdr.SttlmInf.InstdRmbrsmntAgtAcct?.Id?.Othr?.Id, isOptionBPresent = true)[2];

    swiftmt:MT55A? MT55A = getField55(grpHdr.SttlmInf.ThrdRmbrsmntAgt?.FinInstnId?.BICFI, grpHdr.SttlmInf.ThrdRmbrsmntAgt?.FinInstnId?.Nm, grpHdr.SttlmInf.ThrdRmbrsmntAgt?.FinInstnId?.PstlAdr?.AdrLine, grpHdr.SttlmInf.ThrdRmbrsmntAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, grpHdr.SttlmInf.ThrdRmbrsmntAgtAcct?.Id?.IBAN, grpHdr.SttlmInf.ThrdRmbrsmntAgtAcct?.Id?.Othr?.Id, isOptionBPresent = true)[0];
    swiftmt:MT55B? MT55B = getField55(grpHdr.SttlmInf.ThrdRmbrsmntAgt?.FinInstnId?.BICFI, grpHdr.SttlmInf.ThrdRmbrsmntAgt?.FinInstnId?.Nm, grpHdr.SttlmInf.ThrdRmbrsmntAgt?.FinInstnId?.PstlAdr?.AdrLine, grpHdr.SttlmInf.ThrdRmbrsmntAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, grpHdr.SttlmInf.ThrdRmbrsmntAgtAcct?.Id?.IBAN, grpHdr.SttlmInf.ThrdRmbrsmntAgtAcct?.Id?.Othr?.Id, isOptionBPresent = true)[1];
    swiftmt:MT55D? MT55D = getField55(grpHdr.SttlmInf.ThrdRmbrsmntAgt?.FinInstnId?.BICFI, grpHdr.SttlmInf.ThrdRmbrsmntAgt?.FinInstnId?.Nm, grpHdr.SttlmInf.ThrdRmbrsmntAgt?.FinInstnId?.PstlAdr?.AdrLine, grpHdr.SttlmInf.ThrdRmbrsmntAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, grpHdr.SttlmInf.ThrdRmbrsmntAgtAcct?.Id?.IBAN, grpHdr.SttlmInf.ThrdRmbrsmntAgtAcct?.Id?.Othr?.Id, isOptionBPresent = true)[2];

    swiftmt:MT56A? MT56A = (check getField56Alt(firstTransaction.IntrmyAgt1?.FinInstnId?.BICFI, firstTransaction.IntrmyAgt1?.FinInstnId?.Nm, firstTransaction.IntrmyAgt1?.FinInstnId?.PstlAdr?.AdrLine, firstTransaction.IntrmyAgt1?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, firstTransaction.IntrmyAgt1Acct?.Id?.IBAN, firstTransaction.IntrmyAgt1Acct?.Id?.Othr?.Id, isOptionCPresent = true))[0];
    swiftmt:MT56C? MT56C = (check getField56Alt(firstTransaction.IntrmyAgt1?.FinInstnId?.BICFI, firstTransaction.IntrmyAgt1?.FinInstnId?.Nm, firstTransaction.IntrmyAgt1?.FinInstnId?.PstlAdr?.AdrLine, firstTransaction.IntrmyAgt1?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, firstTransaction.IntrmyAgt1Acct?.Id?.IBAN, firstTransaction.IntrmyAgt1Acct?.Id?.Othr?.Id, isOptionCPresent = true))[1];
    swiftmt:MT56D? MT56D = (check getField56Alt(firstTransaction.IntrmyAgt1?.FinInstnId?.BICFI, firstTransaction.IntrmyAgt1?.FinInstnId?.Nm, firstTransaction.IntrmyAgt1?.FinInstnId?.PstlAdr?.AdrLine, firstTransaction.IntrmyAgt1?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, firstTransaction.IntrmyAgt1Acct?.Id?.IBAN, firstTransaction.IntrmyAgt1Acct?.Id?.Othr?.Id, isOptionCPresent = true))[2];

    swiftmt:MT57A? MT57A = (check getField57Alt(firstTransaction.CdtrAgt?.FinInstnId?.BICFI, firstTransaction.CdtrAgt?.FinInstnId?.Nm, firstTransaction.CdtrAgt?.FinInstnId?.PstlAdr?.AdrLine, firstTransaction.CdtrAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, firstTransaction.CdtrAgtAcct?.Id?.IBAN, firstTransaction.CdtrAgtAcct?.Id?.Othr?.Id, true, true))[0];
    swiftmt:MT57B? MT57B = (check getField57Alt(firstTransaction.CdtrAgt?.FinInstnId?.BICFI, firstTransaction.CdtrAgt?.FinInstnId?.Nm, firstTransaction.CdtrAgt?.FinInstnId?.PstlAdr?.AdrLine, firstTransaction.CdtrAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, firstTransaction.CdtrAgtAcct?.Id?.IBAN, firstTransaction.CdtrAgtAcct?.Id?.Othr?.Id, true, true))[1];
    swiftmt:MT57C? MT57C = (check getField57Alt(firstTransaction.CdtrAgt?.FinInstnId?.BICFI, firstTransaction.CdtrAgt?.FinInstnId?.Nm, firstTransaction.CdtrAgt?.FinInstnId?.PstlAdr?.AdrLine, firstTransaction.CdtrAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, firstTransaction.CdtrAgtAcct?.Id?.IBAN, firstTransaction.CdtrAgtAcct?.Id?.Othr?.Id, true, true))[2];
    swiftmt:MT57D? MT57D = (check getField57Alt(firstTransaction.CdtrAgt?.FinInstnId?.BICFI, firstTransaction.CdtrAgt?.FinInstnId?.Nm, firstTransaction.CdtrAgt?.FinInstnId?.PstlAdr?.AdrLine, firstTransaction.CdtrAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, firstTransaction.CdtrAgtAcct?.Id?.IBAN, firstTransaction.CdtrAgtAcct?.Id?.Othr?.Id, true, true))[3];

    swiftmt:MT59? MT59 = getField59a(firstTransaction?.Cdtr?.Id?.OrgId?.AnyBIC, firstTransaction?.Cdtr?.Nm, firstTransaction?.Cdtr?.PstlAdr?.AdrLine, firstTransaction?.CdtrAcct?.Id?.IBAN, firstTransaction?.CdtrAcct?.Id?.Othr?.Id)[0];
    swiftmt:MT59A? MT59A = getField59a(firstTransaction?.Cdtr?.Id?.OrgId?.AnyBIC, firstTransaction?.Cdtr?.Nm, firstTransaction?.Cdtr?.PstlAdr?.AdrLine, firstTransaction?.CdtrAcct?.Id?.IBAN, firstTransaction?.CdtrAcct?.Id?.Othr?.Id)[1];
    swiftmt:MT59F? MT59F = getField59a(firstTransaction?.Cdtr?.Id?.OrgId?.AnyBIC, firstTransaction?.Cdtr?.Nm, firstTransaction?.Cdtr?.PstlAdr?.AdrLine, firstTransaction?.CdtrAcct?.Id?.IBAN, firstTransaction?.CdtrAcct?.Id?.Othr?.Id, townName = firstTransaction.Cdtr.PstlAdr?.TwnNm, countryCode = firstTransaction.Cdtr.PstlAdr?.Ctry)[2];

    swiftmt:MT70 MT70 = getRemittanceInformation(firstTransaction.PmtId, firstTransaction.RmtInf, firstTransaction.Purp);

    swiftmt:MT71A MT71A = {
        name: MT71A_NAME,
        Cd: getDetailsOfChargesFromChargeBearerType1Code(firstTransaction.ChrgBr)
    };
    swiftmt:MT71F? MT71F = check convertCharges16toMT71F(firstTransaction.ChrgsInf, firstTransaction.ChrgBr);
    swiftmt:MT71G? MT71G = check convertCharges16toMT71G(firstTransaction.ChrgsInf, firstTransaction.ChrgBr);

    swiftmt:MT72? MT72 = getField72(firstTransaction.InstrForCdtrAgt, firstTransaction.InstrForNxtAgt, firstTransaction.PrvsInstgAgt1, firstTransaction.IntrmyAgt2, firstTransaction.PmtTpInf?.SvcLvl, firstTransaction.PmtTpInf?.CtgyPurp, firstTransaction.PmtTpInf?.LclInstrm);
    swiftmt:MT77B? MT77B = getField77B(firstTransaction.RgltryRptg);
    swiftmt:MT77T MT77T = getField77T(document.FIToFICstmrCdtTrf.SplmtryData, firstTransaction.RmtInf?.Ustrd);

    match messageType {
        MT103 => {
            swiftmt:MT103Block4 MT103Block4 = {
                MT20,
                MT13C,
                MT23B,
                MT23E,
                MT26T,
                MT32A,
                MT33B,
                MT36,
                MT50A,
                MT50F,
                MT50K,
                MT51A,
                MT52A,
                MT52D,
                MT53A,
                MT53B,
                MT54A,
                MT54B,
                MT54D,
                MT55A,
                MT55B,
                MT55D,
                MT56A,
                MT56C,
                MT56D,
                MT57A,
                MT57B,
                MT57C,
                MT57D,
                MT59,
                MT59A,
                MT59F,
                MT70,
                MT71A,
                MT71F,
                MT71G,
                MT72,
                MT77B
            };

            return MT103Block4;
        }

        MT103_STP => {
            swiftmt:MT103STPBlock4 MT103STPBlock4 = {
                MT20,
                MT13C,
                MT23B,
                MT23E,
                MT26T,
                MT32A,
                MT33B,
                MT36,
                MT50A,
                MT50F,
                MT50K,
                MT52A,
                MT53A,
                MT53B,
                MT54A,
                MT55A,
                MT56A,
                MT57A,
                MT59,
                MT59A,
                MT59F,
                MT70,
                MT71A,
                MT71F,
                MT71G,
                MT72,
                MT77B
            };

            return MT103STPBlock4;
        }

        MT103_REMIT => {
            swiftmt:MT103REMITBlock4 MT103REMITBlock4 = {
                MT20,
                MT13C,
                MT23B,
                MT23E,
                MT26T,
                MT32A,
                MT33B,
                MT36,
                MT50A,
                MT50F,
                MT50K,
                MT51A,
                MT52A,
                MT52D,
                MT53A,
                MT53B,
                MT54A,
                MT54B,
                MT54D,
                MT55A,
                MT55B,
                MT55D,
                MT56A,
                MT56C,
                MT56D,
                MT57A,
                MT57B,
                MT57C,
                MT57D,
                MT59,
                MT59A,
                MT59F,
                MT71A,
                MT71F,
                MT71G,
                MT72,
                MT77B,
                MT77T
            };

            return MT103REMITBlock4;
        }
    }

    return error("Error occurred while creating MT103 block4");

}
