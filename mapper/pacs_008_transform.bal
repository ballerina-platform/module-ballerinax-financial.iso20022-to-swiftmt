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

// import ballerina/io;
import ballerinax/financial.iso20022.payments_clearing_and_settlement as SwiftMxRecords;
import ballerinax/financial.swift.mt as swiftmt;

# Gets the mt message type the PACS008 document should be transformed to
#
# + document - The PACS008 document
# + return - The mt message type as a string
isolated function getPac008TransformType(SwiftMxRecords:Pacs008Document document) returns string {
    return MT103;
}

# Transforms a PACS008 document to an MT102 message
#
# + document - The PACS008 document
# + return - The MT102 message or an error if the transformation fails
function transformPacs008DocumentToMT102(SwiftMxRecords:Pacs008Document document) returns swiftmt:MT102Message|error => {

    block1: (),
    block2: {
        messageType: MT102
    },
    block3: (),
    block4: <swiftmt:MT102Block4>check createMT102Block4(document, false),
    block5: ()
};

# Transforms a PACS008 document to an MT102STP message
#
# + document - The PACS008 document
# + return - The MT102STP message or an error if the transformation fails
isolated function transformPacs008DocumentToMT102STP(SwiftMxRecords:Pacs008Document document) returns swiftmt:MT102STPMessage|error {
    SwiftMxRecords:FIToFICustomerCreditTransferV12 fiToFiCstmrCdtTrf = document.FIToFICstmrCdtTrf;

    swiftmt:Block1? block1 = check createMtBlock1FromSupplementaryData(fiToFiCstmrCdtTrf.SplmtryData);
    swiftmt:Block2 block2 = check createMtBlock2FromSupplementaryData("102STP", fiToFiCstmrCdtTrf.SplmtryData);
    swiftmt:Block3? block3 = check createMtBlock3FromSupplementaryData(fiToFiCstmrCdtTrf.SplmtryData);
    swiftmt:Block5? block5 = check createMtBlock5FromSupplementaryData(fiToFiCstmrCdtTrf.SplmtryData);

    swiftmt:MT102STPBlock4 block4 = <swiftmt:MT102STPBlock4>check createMT102Block4(document, true);

    swiftmt:MT102STPMessage mtMessage = {
        block1: block1,
        block2: block2,
        block3: block3,
        block4: block4,
        block5: block5
    };

    return mtMessage;
}

# Creates the block 4 of an MT102 message from a PACS008 document
#
# + document - The PACS008 document
# + isSTP - A boolean indicating whether the message is an STP message
# + return - The block 4 of the MT102 message or an error if the transformation fails
isolated function createMT102Block4(SwiftMxRecords:Pacs008Document document, boolean isSTP) returns swiftmt:MT102Block4|swiftmt:MT102STPBlock4|error {

    SwiftMxRecords:GroupHeader113 grpHdr = document.FIToFICstmrCdtTrf.GrpHdr;
    SwiftMxRecords:CreditTransferTransaction64[] transactions = document.FIToFICstmrCdtTrf.CdtTrfTxInf;

    SwiftMxRecords:CreditTransferTransaction64 firstTransaction = transactions[0];

    swiftmt:MT20 MT20 = {
        name: "20",
        msgId: {
            content: getEmptyStrIfNull(firstTransaction.PmtId.InstrId),
            number: "1"
        }
    };

    // Leave the content empty as the value is not available in the input
    swiftmt:MT23 MT23 = {
        name: "23",
        Cd: {content: "", number: ""}
    };

    swiftmt:MT51A MT51A = {
        name: "51A",
        IdnCd: {
            content: getEmptyStrIfNull(document.FIToFICstmrCdtTrf.GrpHdr.InstdAgt?.FinInstnId?.BICFI),
            number: "1"
        },
        PrtyIdn: {
            content: getEmptyStrIfNull(document.FIToFICstmrCdtTrf.GrpHdr.InstdAgt?.FinInstnId?.LEI),
            number: "2"
        }
    };

    swiftmt:MT50A?|swiftmt:MT50F?|swiftmt:MT50K? orderingCustomer = getMT102OrderingCustomerFromPacs008Document(document);
    swiftmt:MT50A? MT50A = orderingCustomer is swiftmt:MT50A ? check orderingCustomer.ensureType(swiftmt:MT50A) : ();
    swiftmt:MT50F? MT50F = orderingCustomer is swiftmt:MT50F ? check orderingCustomer.ensureType(swiftmt:MT50F) : ();
    swiftmt:MT50K? MT50K = orderingCustomer is swiftmt:MT50K ? check orderingCustomer.ensureType(swiftmt:MT50K) : ();

    swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C? orderingInstitution = getMT102OrderingInstitutionFromPacs008Document(document, isSTP);
    swiftmt:MT52A? MT52A = orderingInstitution is swiftmt:MT52A ? check orderingInstitution.ensureType(swiftmt:MT52A) : ();
    swiftmt:MT52B? MT52B = orderingInstitution is swiftmt:MT52B ? check orderingInstitution.ensureType(swiftmt:MT52B) : ();
    swiftmt:MT52C? MT52C = orderingInstitution is swiftmt:MT52C ? check orderingInstitution.ensureType(swiftmt:MT52C) : ();

    swiftmt:MT26T MT26T = {
        name: "26T",
        Typ: {
            content: getEmptyStrIfNull(firstTransaction.Purp?.Cd),
            number: "1"
        }
    };

    swiftmt:MT77B MT77B = {
        name: "77B",
        Nrtv: {
            content: "",
            number: "1"
        }
    };

    swiftmt:MT71A MT71A = {
        name: "71A",
        Cd: getDetailsOfChargesFromChargeBearerType1Code(firstTransaction.ChrgBr)
    };

    swiftmt:MT36 MT36 = {
        name: "36",
        Rt: {
            content: convertDecimalNumberToSwiftDecimal(firstTransaction.XchgRate),
            number: "1"
        }
    };

    swiftmt:MT32A MT32A = {
        name: "32A",
        Ccy: {content: firstTransaction.IntrBkSttlmAmt.ActiveCurrencyAndAmount_SimpleType?.Ccy, number: "1"},
        Dt: check convertISODateStringToSwiftMtDate(firstTransaction.IntrBkSttlmDt.toString(), "2"),
        Amnt: {content: convertDecimalNumberToSwiftDecimal(firstTransaction.IntrBkSttlmAmt.ActiveCurrencyAndAmount_SimpleType?.ActiveCurrencyAndAmount_SimpleType), number: "3"}
    };

    swiftmt:MT19 MT19 = {
        name: "19",
        Amnt: {content: convertDecimalNumberToSwiftDecimal(grpHdr.CtrlSum), number: "1"}
    };

    swiftmt:MT71G MT71G = check convertCharges16toMT71G(firstTransaction.ChrgsInf);

    swiftmt:MT13C? MT13C = check convertTimeToMT13C(firstTransaction.SttlmTmIndctn, firstTransaction.SttlmTmReq);

    swiftmt:MT53A?|swiftmt:MT53C? sendersCorrespondent = getMT102SendersCorrespondentFromPacs008Document(document);
    swiftmt:MT53A? MT53A = sendersCorrespondent is swiftmt:MT53A ? check sendersCorrespondent.ensureType(swiftmt:MT53A) : ();
    swiftmt:MT53C? MT53C = sendersCorrespondent is swiftmt:MT53C ? check sendersCorrespondent.ensureType(swiftmt:MT53C) : ();

    swiftmt:MT54A MT54A = {name: "54A", IdnCd: {content: "", number: "1"}};

    swiftmt:MT72 MT72 = {name: "72", Cd: {content: "", number: "1"}};

    swiftmt:MT102STPTransaction[]|swiftmt:MT102Transaction[] Transactions = check createMT102Transactions(
            document.FIToFICstmrCdtTrf.CdtTrfTxInf,
            orderingCustomer,
            orderingInstitution,
            isSTP
    );

    if (isSTP) {
        return <swiftmt:MT102STPBlock4>{
            MT20,
            MT23,
            MT50A,
            MT50F,
            MT50K,
            MT52A,
            MT26T,
            MT77B,
            MT71A,
            MT36,
            MT32A,
            MT19,
            MT71G,
            MT13C,
            MT53A,
            MT53C,
            MT54A,
            MT72,
            Transaction: <swiftmt:MT102STPTransaction[]>Transactions
        };
    } else {
        return <swiftmt:MT102Block4>{
            MT20,
            MT23,
            MT51A,
            MT50A,
            MT50F,
            MT50K,
            MT52A,
            MT52B,
            MT52C,
            MT26T,
            MT77B,
            MT71A,
            MT36,
            MT32A,
            MT19,
            MT71G,
            MT13C,
            MT53A,
            MT53C,
            MT54A,
            MT72,
            Transaction: <swiftmt:MT102Transaction[]>Transactions
        };
    }
}

# Creates the transactions of an MT102 message from a PACS008 document
#
# + mxTransactions - The credit transfer transactions
# + orderingCustomer - The ordering customer
# + orderingInstitution - The ordering institution
# + isSTP - A boolean indicating whether the message is an STP message
# + return - The transactions of the MT102 message or an error if the transformation fails
isolated function createMT102Transactions(
        SwiftMxRecords:CreditTransferTransaction64[] mxTransactions,
        swiftmt:MT50A?|swiftmt:MT50F?|swiftmt:MT50K? orderingCustomer,
        swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C? orderingInstitution,
        boolean isSTP)
returns swiftmt:MT102Transaction[]|swiftmt:MT102STPTransaction[]|error {
    swiftmt:MT102Transaction[] transactions = [];
    swiftmt:MT102STPTransaction[] transactionsSTP = [];

    foreach SwiftMxRecords:CreditTransferTransaction64 transaxion in mxTransactions {

        swiftmt:MT21 MT21 = {
            name: "21",
            Ref: {
                content: getEmptyStrIfNull(transaxion.PmtId.TxId),
                number: "1"
            }
        };

        swiftmt:MT32B MT32B = {
            name: "32B",
            Ccy: {
                content: getActiveOrHistoricCurrencyAndAmountCcy(transaxion.InstdAmt),
                number: "1"
            },
            Amnt: {
                content: getActiveOrHistoricCurrencyAndAmountValue(transaxion.InstdAmt),
                number: "2"
            }
        };

        swiftmt:MT50A? MT50A = orderingCustomer is swiftmt:MT50A ? check orderingCustomer.ensureType(swiftmt:MT50A) : ();
        swiftmt:MT50F? MT50F = orderingCustomer is swiftmt:MT50F ? check orderingCustomer.ensureType(swiftmt:MT50F) : ();
        swiftmt:MT50K? MT50K = orderingCustomer is swiftmt:MT50K ? check orderingCustomer.ensureType(swiftmt:MT50K) : ();

        swiftmt:MT52A? MT52A = orderingInstitution is swiftmt:MT52A ? check orderingInstitution.ensureType(swiftmt:MT52A) : ();
        swiftmt:MT52B? MT52B = orderingInstitution is swiftmt:MT52B ? check orderingInstitution.ensureType(swiftmt:MT52B) : ();
        swiftmt:MT52C? MT52C = orderingInstitution is swiftmt:MT52C ? check orderingInstitution.ensureType(swiftmt:MT52C) : ();

        swiftmt:MT57A?|swiftmt:MT57C? accountWithInstitution = getMT102TransactionAccountWithInstitutionFromPacs008Document(transaxion, isSTP);
        swiftmt:MT57A? MT57A = accountWithInstitution is swiftmt:MT57A ? check accountWithInstitution.ensureType(swiftmt:MT57A) : ();
        swiftmt:MT57C? MT57C = accountWithInstitution is swiftmt:MT57C ? check accountWithInstitution.ensureType(swiftmt:MT57C) : ();

        swiftmt:MT59?|swiftmt:MT59A?|swiftmt:MT59F? beneficiaryCustomer = getMT102TransactionBeneficiaryCustomerFromPacs008Document(transaxion);
        swiftmt:MT59? MT59 = beneficiaryCustomer is swiftmt:MT59 ? check beneficiaryCustomer.ensureType(swiftmt:MT59) : ();
        swiftmt:MT59A? MT59A = beneficiaryCustomer is swiftmt:MT59A ? check beneficiaryCustomer.ensureType(swiftmt:MT59A) : ();
        swiftmt:MT59F? MT59F = beneficiaryCustomer is swiftmt:MT59F ? check beneficiaryCustomer.ensureType(swiftmt:MT59F) : ();

        swiftmt:MT70 MT70 = getRemitenceInformationFromPmtIdOrRmtInf(transaxion.PmtId, transaxion.RmtInf);

        swiftmt:MT26T MT26T = {
            name: "26T",
            Typ: {content: getEmptyStrIfNull(transaxion.Purp?.Cd), number: "1"}
        };

        swiftmt:MT77B MT77B = {
            name: "77B",
            Nrtv: {content: "", number: "1"}
        };

        swiftmt:MT33B MT33B = {
            name: "33B",
            Ccy: {
                content: getActiveOrHistoricCurrencyAndAmountCcy(transaxion.InstdAmt),
                number: "1"
            },
            Amnt: {
                content: getActiveOrHistoricCurrencyAndAmountValue(transaxion.InstdAmt),
                number: "2"
            }
        };

        swiftmt:MT71A MT71A = {
            name: "71A",
            Cd: getDetailsOfChargesFromChargeBearerType1Code(transaxion.ChrgBr, "1")
        };

        swiftmt:MT71F MT71F = check convertCharges16toMT71F(transaxion.ChrgsInf);

        swiftmt:MT71G MT71G = check convertCharges16toMT71G(transaxion.ChrgsInf);

        swiftmt:MT36 MT36 = {
            name: "36",
            Rt: {content: convertDecimalNumberToSwiftDecimal(transaxion.XchgRate), number: "1"}
        };

        if (isSTP) {
            transactionsSTP.push({MT21, MT32B, MT50A, MT50F, MT50K, MT52A, MT57A, MT59, MT59A, MT59F, MT70, MT26T, MT77B, MT33B, MT71A, MT71F, MT71G, MT36});
        } else {
            transactions.push({MT21, MT32B, MT50A, MT50F, MT50K, MT52A, MT52B, MT52C, MT57A, MT57C, MT59, MT59A, MT59F, MT70, MT26T, MT77B, MT33B, MT71A, MT71F, MT71G, MT36});
        }
    }

    if (isSTP) {
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
# + return - The MT103 message or an error if the transformation fails
isolated function transformPacs008DocumentToMT103(SwiftMxRecords:Pacs008Document document) returns swiftmt:MT103Message|error {
    SwiftMxRecords:FIToFICustomerCreditTransferV12 fiToFiCstmrCdtTrf = document.FIToFICstmrCdtTrf;

    swiftmt:Block1? block1 = check createMtBlock1FromSupplementaryData(fiToFiCstmrCdtTrf.SplmtryData);
    swiftmt:Block2 block2 = check createMtBlock2FromSupplementaryData("103", fiToFiCstmrCdtTrf.SplmtryData);
    swiftmt:Block3? block3 = check createMtBlock3FromSupplementaryData(fiToFiCstmrCdtTrf.SplmtryData);
    swiftmt:Block5? block5 = check createMtBlock5FromSupplementaryData(fiToFiCstmrCdtTrf.SplmtryData);

    swiftmt:MT103Block4 block4 = <swiftmt:MT103Block4>check createMT103Block4(document, MT103);

    swiftmt:MT103Message mtMessage = {
        block1: block1,
        block2: block2,
        block3: block3,
        block4: block4,
        block5: block5
    };

    return mtMessage;
}

# Transforms a PACS008 document to an MT103STP message
#
# + document - The PACS008 document
# + return - The MT103STP message or an error if the transformation fails
isolated function transformPacs008DocumentToMT103STP(SwiftMxRecords:Pacs008Document document) returns swiftmt:MT103STPMessage|error {
    SwiftMxRecords:FIToFICustomerCreditTransferV12 fiToFiCstmrCdtTrf = document.FIToFICstmrCdtTrf;

    swiftmt:Block1? block1 = check createMtBlock1FromSupplementaryData(fiToFiCstmrCdtTrf.SplmtryData);
    swiftmt:Block2 block2 = check createMtBlock2FromSupplementaryData("103STP", fiToFiCstmrCdtTrf.SplmtryData);
    swiftmt:Block3? block3 = check createMtBlock3FromSupplementaryData(fiToFiCstmrCdtTrf.SplmtryData);
    swiftmt:Block5? block5 = check createMtBlock5FromSupplementaryData(fiToFiCstmrCdtTrf.SplmtryData);

    swiftmt:MT103STPBlock4 block4 = <swiftmt:MT103STPBlock4>check createMT103Block4(document, MT103_STP);

    swiftmt:MT103STPMessage mtMessage = {
        block1: block1,
        block2: block2,
        block3: block3,
        block4: block4,
        block5: block5
    };

    return mtMessage;
}

# Transforms a PACS008 document to an MT103REMIT message
#
# + document - The PACS008 document
# + return - The MT103REMIT message or an error if the transformation fails
isolated function transformPacs008DocumentToMT103REMIT(SwiftMxRecords:Pacs008Document document) returns swiftmt:MT103REMITMessage|error {
    SwiftMxRecords:FIToFICustomerCreditTransferV12 fiToFiCstmrCdtTrf = document.FIToFICstmrCdtTrf;

    swiftmt:Block1? block1 = check createMtBlock1FromSupplementaryData(fiToFiCstmrCdtTrf.SplmtryData);
    swiftmt:Block2 block2 = check createMtBlock2FromSupplementaryData("103REMIT", fiToFiCstmrCdtTrf.SplmtryData);
    swiftmt:Block3? block3 = check createMtBlock3FromSupplementaryData(fiToFiCstmrCdtTrf.SplmtryData);
    swiftmt:Block5? block5 = check createMtBlock5FromSupplementaryData(fiToFiCstmrCdtTrf.SplmtryData);

    swiftmt:MT103REMITBlock4 block4 = <swiftmt:MT103REMITBlock4>check createMT103Block4(document, MT103_REMIT);

    swiftmt:MT103REMITMessage mtMessage = {
        block1: block1,
        block2: block2,
        block3: block3,
        block4: block4,
        block5: block5
    };

    return mtMessage;
}

# Creates the block 4 of an MT103 message from a PACS008 document
#
# + document - The PACS008 document
# + messageType - The type of the MT103 message
# + return - The block 4 of the MT103 message or an error if the transformation fails
isolated function createMT103Block4(SwiftMxRecords:Pacs008Document document, MT103Type messageType) returns swiftmt:MT103Block4|swiftmt:MT103STPBlock4|swiftmt:MT103REMITBlock4|error {
    SwiftMxRecords:FIToFICustomerCreditTransferV12 fiToFiCstmrCdtTrf = document.FIToFICstmrCdtTrf;
    SwiftMxRecords:CreditTransferTransaction64[] transactions = fiToFiCstmrCdtTrf.CdtTrfTxInf;

    if (transactions.length() == 0) {
        return error("");
    }

    SwiftMxRecords:CreditTransferTransaction64 firstTransaction = transactions[0];

    swiftmt:MT20 MT20 = {
        name: "20",
        msgId: {
            content: getEmptyStrIfNull(firstTransaction.PmtId.InstrId),
            number: "1"
        }
    };

    swiftmt:MT13C? MT13C = check convertTimeToMT13C(firstTransaction.SttlmTmIndctn, firstTransaction.SttlmTmReq);

    swiftmt:MT23B MT23B = {
        name: "23B",
        Typ: {
            content: getBankOperationCodeFromPaymentTypeInformation22(firstTransaction.PmtTpInf),
            number: "1"
        }
    };

    swiftmt:MT23E[]? MT23E = [];

    swiftmt:MT26T MT26T = {
        name: "26T",
        Typ: {
            content: getEmptyStrIfNull(firstTransaction.Purp?.Cd),
            number: "1"
        }
    };

    swiftmt:MT32A MT32A = {
        name: "32A",
        Ccy: {
            content: firstTransaction.IntrBkSttlmAmt.ActiveCurrencyAndAmount_SimpleType?.Ccy,
            number: "1"
        },
        Dt: check convertISODateStringToSwiftMtDate(firstTransaction.IntrBkSttlmDt.toString(), "2"),
        Amnt: {
            content: convertDecimalNumberToSwiftDecimal(firstTransaction.IntrBkSttlmAmt.ActiveCurrencyAndAmount_SimpleType?.ActiveCurrencyAndAmount_SimpleType),
            number: "3"
        }
    };

    swiftmt:MT33B MT33B = {
        name: "33B",
        Ccy: {
            content: getActiveOrHistoricCurrencyAndAmountCcy(firstTransaction.InstdAmt),
            number: "1"
        },
        Amnt: {
            content: getActiveOrHistoricCurrencyAndAmountValue(firstTransaction.InstdAmt),
            number: "2"
        }
    };

    swiftmt:MT36 MT36 = {
        name: "36",
        Rt: {
            content: convertDecimalNumberToSwiftDecimal(firstTransaction.XchgRate),
            number: "1"
        }
    };

    swiftmt:MT50A?|swiftmt:MT50F?|swiftmt:MT50K? orderingCustomer = getMT103OrderingCustomerFromPacs008Document(document);
    swiftmt:MT50A? MT50A = orderingCustomer is swiftmt:MT50A ? check orderingCustomer.ensureType(swiftmt:MT50A) : ();
    swiftmt:MT50F? MT50F = orderingCustomer is swiftmt:MT50F ? check orderingCustomer.ensureType(swiftmt:MT50F) : ();
    swiftmt:MT50K? MT50K = orderingCustomer is swiftmt:MT50K ? check orderingCustomer.ensureType(swiftmt:MT50K) : ();

    swiftmt:MT51A MT51A = {
        name: "51A",
        IdnCd: {
            content: getEmptyStrIfNull(fiToFiCstmrCdtTrf.GrpHdr.InstdAgt?.FinInstnId?.BICFI),
            number: "1"
        },
        PrtyIdn: {
            content: getEmptyStrIfNull(fiToFiCstmrCdtTrf.GrpHdr.InstdAgt?.FinInstnId?.LEI),
            number: "2"
        }
    };

    swiftmt:MT52A?|swiftmt:MT52D? orderingInstitution = getMT103OrderingInstitutionFromPacs008Document(document, messageType == MT103_STP);
    swiftmt:MT52A? MT52A = orderingInstitution is swiftmt:MT52A ? check orderingInstitution.ensureType(swiftmt:MT52A) : ();
    swiftmt:MT52D? MT52D = orderingInstitution is swiftmt:MT52D ? check orderingInstitution.ensureType(swiftmt:MT52D) : ();

    swiftmt:MT53A?|swiftmt:MT53B?|swiftmt:MT53D? sendersCorrespondent = getMT103SendersCorrespondentFromPacs008Document(document);
    swiftmt:MT53A? MT53A = sendersCorrespondent is swiftmt:MT53A ? check sendersCorrespondent.ensureType(swiftmt:MT53A) : ();
    swiftmt:MT53B? MT53B = sendersCorrespondent is swiftmt:MT53B ? check sendersCorrespondent.ensureType(swiftmt:MT53B) : ();

    swiftmt:MT54A?|swiftmt:MT54B?|swiftmt:MT54D? receiversCorrespondent = getMT103ReceiversCorrespondentFromPacs008Document(document, messageType == MT103_STP);
    swiftmt:MT54A? MT54A = receiversCorrespondent is swiftmt:MT54A ? check receiversCorrespondent.ensureType(swiftmt:MT54A) : ();
    swiftmt:MT54B? MT54B = receiversCorrespondent is swiftmt:MT54B ? check receiversCorrespondent.ensureType(swiftmt:MT54B) : ();
    swiftmt:MT54D? MT54D = receiversCorrespondent is swiftmt:MT54D ? check receiversCorrespondent.ensureType(swiftmt:MT54D) : ();

    swiftmt:MT55A?|swiftmt:MT55B?|swiftmt:MT55D? thirdReimbursementInstitution = getMT103ThirdReimbursementInstitutionFromPacs008Document(document, messageType == MT103_STP);
    swiftmt:MT55A? MT55A = thirdReimbursementInstitution is swiftmt:MT55A ? check thirdReimbursementInstitution.ensureType(swiftmt:MT55A) : ();
    swiftmt:MT55B? MT55B = thirdReimbursementInstitution is swiftmt:MT55B ? check thirdReimbursementInstitution.ensureType(swiftmt:MT55B) : ();
    swiftmt:MT55D? MT55D = thirdReimbursementInstitution is swiftmt:MT55D ? check thirdReimbursementInstitution.ensureType(swiftmt:MT55D) : ();

    swiftmt:MT56A?|swiftmt:MT56C?|swiftmt:MT56D? intermediaryInstitution = getMT103IntermediaryInstitutionFromPacs008Document(document, messageType == MT103_STP);
    swiftmt:MT56A? MT56A = intermediaryInstitution is swiftmt:MT56A ? check intermediaryInstitution.ensureType(swiftmt:MT56A) : ();
    swiftmt:MT56C? MT56C = intermediaryInstitution is swiftmt:MT56C ? check intermediaryInstitution.ensureType(swiftmt:MT56C) : ();
    swiftmt:MT56D? MT56D = intermediaryInstitution is swiftmt:MT56D ? check intermediaryInstitution.ensureType(swiftmt:MT56D) : ();

    swiftmt:MT57A?|swiftmt:MT57B?|swiftmt:MT57C?|swiftmt:MT57D? accountWithInstitution = getMT103AccountWithInstitutionFromPacs008Document(document, messageType == MT103_STP);
    swiftmt:MT57A? MT57A = accountWithInstitution is swiftmt:MT57A ? check accountWithInstitution.ensureType(swiftmt:MT57A) : ();
    swiftmt:MT57B? MT57B = accountWithInstitution is swiftmt:MT57B ? check accountWithInstitution.ensureType(swiftmt:MT57B) : ();
    swiftmt:MT57C? MT57C = accountWithInstitution is swiftmt:MT57C ? check accountWithInstitution.ensureType(swiftmt:MT57C) : ();

    swiftmt:MT59?|swiftmt:MT59A?|swiftmt:MT59F? beneficiaryCustomer = getMT103BeneficiaryCustomerFromPacs008Document(document);
    swiftmt:MT59? MT59 = beneficiaryCustomer is swiftmt:MT59 ? check beneficiaryCustomer.ensureType(swiftmt:MT59) : ();
    swiftmt:MT59A? MT59A = beneficiaryCustomer is swiftmt:MT59A ? check beneficiaryCustomer.ensureType(swiftmt:MT59A) : ();
    swiftmt:MT59F? MT59F = beneficiaryCustomer is swiftmt:MT59F ? check beneficiaryCustomer.ensureType(swiftmt:MT59F) : ();

    swiftmt:MT70 MT70 = getRemitenceInformationFromPmtIdOrRmtInf(firstTransaction.PmtId, firstTransaction.RmtInf);

    swiftmt:MT71A MT71A = {
        name: "71A",
        Cd: getDetailsOfChargesFromChargeBearerType1Code(firstTransaction.ChrgBr)
    };

    swiftmt:MT71F MT71F = check convertCharges16toMT71F(firstTransaction.ChrgsInf);

    swiftmt:MT71G MT71G = check convertCharges16toMT71G(firstTransaction.ChrgsInf);

    swiftmt:MT72 MT72 = {name: "72", Cd: {content: "", number: "1"}};

    swiftmt:MT77B MT77B = {
        name: "77B",
        Nrtv: {content: "", number: "1"}
    };

    swiftmt:MT77T MT77T = {
        name: "77T",
        EnvCntnt: {content: "", number: ""}
    };

    match messageType {
        MT103 => {
            return <swiftmt:MT103Block4>{
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
        }

        MT103_STP => {
            return <swiftmt:MT103STPBlock4>{
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
        }

        MT103_REMIT => {
            return <swiftmt:MT103REMITBlock4>{
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
        }
    }

    return error("Error occurred while creating MT103 block4");

}
