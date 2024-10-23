import ballerinax/swiftmt as SwiftMtRecords;
import ballerinax/iso20022records as SwiftMxRecords;

isolated function getPac008TransformType(SwiftMxRecords:Pacs008Document document) returns string {
    return MT103;
}

isolated function transformPacs008DocumentToMT102(SwiftMxRecords:Pacs008Document document) returns SwiftMtRecords:MT102Message | error {
    SwiftMxRecords:FIToFICustomerCreditTransferV12 fiToFiCstmrCdtTrf = document.FIToFICstmrCdtTrf;

    SwiftMtRecords:Block1? block1 = check createMtBlock1FromSupplementaryData(fiToFiCstmrCdtTrf.SplmtryData);
    SwiftMtRecords:Block2 block2 = check createMtBlock2FromSupplementaryData("102", fiToFiCstmrCdtTrf.SplmtryData);
    SwiftMtRecords:Block3? block3 = check createMtBlock3FromSupplementaryData(fiToFiCstmrCdtTrf.SplmtryData);
    SwiftMtRecords:Block5? block5 = check createMtBlock5FromSupplementaryData(fiToFiCstmrCdtTrf.SplmtryData);

    SwiftMtRecords:MT102Block4 block4 = <SwiftMtRecords:MT102Block4> check createMT102Block4(document, false);

    SwiftMtRecords:MT102Message mtMessage = {
        block1: block1,
        block2: block2,
        block3: block3,
        block4: block4,
        block5: block5
    };

    return mtMessage;
}

isolated function transformPacs008DocumentToMT102STP(SwiftMxRecords:Pacs008Document document) returns SwiftMtRecords:MT102STPMessage | error {
    SwiftMxRecords:FIToFICustomerCreditTransferV12 fiToFiCstmrCdtTrf = document.FIToFICstmrCdtTrf;

    SwiftMtRecords:Block1? block1 = check createMtBlock1FromSupplementaryData(fiToFiCstmrCdtTrf.SplmtryData);
    SwiftMtRecords:Block2 block2 = check createMtBlock2FromSupplementaryData("102STP", fiToFiCstmrCdtTrf.SplmtryData);
    SwiftMtRecords:Block3? block3 = check createMtBlock3FromSupplementaryData(fiToFiCstmrCdtTrf.SplmtryData);
    SwiftMtRecords:Block5? block5 = check createMtBlock5FromSupplementaryData(fiToFiCstmrCdtTrf.SplmtryData);

    SwiftMtRecords:MT102STPBlock4 block4 = <SwiftMtRecords:MT102STPBlock4> check createMT102Block4(document, true);

    SwiftMtRecords:MT102STPMessage mtMessage = {
        block1: block1,
        block2: block2,
        block3: block3,
        block4: block4,
        block5: block5
    };

    return mtMessage;
}

isolated function createMT102Block4(SwiftMxRecords:Pacs008Document document, boolean isSTP) returns SwiftMtRecords:MT102Block4 | SwiftMtRecords:MT102STPBlock4 | error {
    
    SwiftMxRecords:CreditTransferTransaction64[] transactions = document.FIToFICstmrCdtTrf.CdtTrfTxInf;

    if (transactions.length() == 0) {
        return error("");
    }

    SwiftMxRecords:CreditTransferTransaction64 firstTransaction = transactions[0];
    
    SwiftMtRecords:MT20 MT20 = {
        name: "20",
        msgId: {
            \#content: getEmptyStrIfNull(firstTransaction.PmtId.InstrId),
            number: "1"
        }
    };

    // Leave the content empty as the value is not available in the input
    SwiftMtRecords:MT23 MT23 = {
        name: "23",
        Cd: {\#content: "", number: ""}
    };

    SwiftMtRecords:MT51A MT51A = {
        name: "51A",
        IdnCd: {
            \#content: getEmptyStrIfNull(document.FIToFICstmrCdtTrf.GrpHdr.InstdAgt?.FinInstnId?.BICFI),
            number: "1"
        },
        PrtyIdn: {
            \#content: getEmptyStrIfNull(document.FIToFICstmrCdtTrf.GrpHdr.InstdAgt?.FinInstnId?.LEI), 
            number: "2"
        }
    };

    SwiftMtRecords:MT50A? | SwiftMtRecords:MT50F? | SwiftMtRecords:MT50K? orderingCustomer = getMT102OrderingCustomerFromPacs008Document(document);
    SwiftMtRecords:MT52A? | SwiftMtRecords:MT52B? | SwiftMtRecords:MT52C? orderingInstitution = getMT102OrderingInstitutionFromPacs008Document(document, isSTP);

    SwiftMtRecords:MT26T MT26T = {
        name: "26T",
        Typ: {
            \#content: getEmptyStrIfNull(firstTransaction.Purp?.Cd), 
            number: "1"
        }
    };

    SwiftMtRecords:MT77B MT77B = {
        name: "77B",
        Nrtv:{
            \#content: "", 
            number: "1"
        }
    };

    SwiftMtRecords:MT71A MT71A = {
        name: "71A",
        Cd: getDetailsOfChargesFromChargeBearerType1Code(firstTransaction.ChrgBr)
    };

    SwiftMtRecords:MT36 MT36 = {
        name: "36",
        Rt : {
            \#content: convertDecimalNumberToSwiftDecimal(firstTransaction.XchgRate), 
            number: "1"
        }
    };


    SwiftMtRecords:MT32A MT32A = {
        name: "32A",
        Ccy: {\#content: firstTransaction.IntrBkSttlmAmt.ActiveCurrencyAndAmount_SimpleType?.Ccy, number: "1"},
        Dt: check convertISODateStringToSwiftMtDate(firstTransaction.IntrBkSttlmDt.toString(), "2"),
        Amnt: {\#content: convertDecimalNumberToSwiftDecimal(firstTransaction.IntrBkSttlmAmt.ActiveCurrencyAndAmount_SimpleType?.ActiveCurrencyAndAmount_SimpleType), number: "3"}
    };

    SwiftMtRecords:MT19 MT19 = {
        name: "19",
        Amnt: {\#content: "", number: "1"}
    };

    SwiftMtRecords:MT71G MT71G = {
        name: "71G",
        Ccy: {\#content: "", number: "1"},
        Amnt: {\#content: "", number: "2"}
    };

    SwiftMtRecords:MT13C MT13C = {
        name: "13C",
        Cd: {
            \#content: "",
            number: "1"
        },
        Sgn: {
            \#content: "",
            number: "1"
        },
        Tm: {
            \#content: "",
            number: "1"
        },
        TmOfst: {
            \#content: "",
            number: "1"
        }
    };

    SwiftMtRecords:MT53A MT53A = {
        name: "53A",
        IdnCd: {
            \#content: "",
            number: "1"
        }
    };

    SwiftMtRecords:MT54A MT54A = {
        name: "54A",
        IdnCd: {
            \#content: "",
            number: "1"
        }
    };

    SwiftMtRecords:MT72 MT72 = {
        name: "72",
        Cd: {
            \#content: "",
            number: "1"
        }
    };


    if (STP) {
        return <SwiftMtRecords:MT102STPBlock4>{
            MT20: MT20,
            MT23: MT23,
            MT50A: MT50A,
            MT52A: MT52A,
            MT26T: MT26T,
            MT77B: MT77B,
            MT71A: MT71A,
            MT36: MT36,
            MT32A: MT32A,
            MT19: MT19,
            MT71G: MT71G,
            MT13C: MT13C,
            MT53A: MT53A,
            MT54A: MT54A,
            MT72: MT72,
            Transaction: <SwiftMtRecords:MT102STPTransaction[]> check createMT102Transactions(document.FIToFICstmrCdtTrf.CdtTrfTxInf, STP)
        };
    } else {
        return <SwiftMtRecords:MT102Block4>{
            MT20: MT20,
            MT23: MT23,
            MT51A: MT51A,
            MT50A: MT50A,
            MT52A: MT52A,
            MT26T: MT26T,
            MT77B: MT77B,
            MT71A: MT71A,
            MT36: MT36,
            MT32A: MT32A,
            MT19: MT19,
            MT71G: MT71G,
            MT13C: MT13C,
            MT53A: MT53A,
            MT54A: MT54A,
            MT72: MT72,
            Transaction: <SwiftMtRecords:MT102Transaction[]> check createMT102Transactions(document.FIToFICstmrCdtTrf.CdtTrfTxInf, STP)
        };
    }
}

isolated function createMT102Transactions(SwiftMxRecords:CreditTransferTransaction64[] mxTransactions, boolean STP) returns SwiftMtRecords:MT102Transaction[] | SwiftMtRecords:MT102STPTransaction[] | error {
    SwiftMtRecords:MT102Transaction[] transactions = [];
    SwiftMtRecords:MT102STPTransaction[] transactionsSTP = [];

    foreach SwiftMxRecords:CreditTransferTransaction64 item in mxTransactions {

        SwiftMtRecords:MT21 MT21 = {
            name: "21",
            Ref: {
                \#content: getEmptyStrIfNull(item.PmtId.InstrId),
                number: "1"
            }
        };

        SwiftMtRecords:MT32B MT32B = {
            name: "32B",
            Ccy: {
                \#content: "",
                number: "1"
            },
            Amnt: {
                \#content: "",
                number: "2"
            }
        };

        SwiftMtRecords:MT50A MT50A = {
            name: "50A",
            IdnCd: {
                \#content: "",
                number: "1"
            }
        };

        SwiftMtRecords:MT52A MT52A = {
            name: "52A",
            IdnCd: {
                \#content: "",
                number: "1"
            }
        };

        SwiftMtRecords:MT57A MT57A = {
            name: "57A",
            IdnCd: {
                \#content: "",
                number: "1"
            }
        };

        SwiftMtRecords:MT59 MT59 = {
            name: "59",
            AdrsLine: [],
            Nm: []
        };

        SwiftMtRecords:MT70 MT70 = {
            name: "70",
            Nrtv: {\#content: "", number: "1"}
        };

        SwiftMtRecords:MT26T MT26T = {
            name: "26T",
            Typ: {\#content: "", number: "1"}
        };

        SwiftMtRecords:MT77B MT77B = {
            name: "77B",
            Nrtv: {\#content: "", number: "1"}
        };

        SwiftMtRecords:MT33B MT33B = {
            name: "33B",
            Ccy: {\#content: "", number: "1"},
            Amnt: {\#content: "", number: "2"}
        };

        SwiftMtRecords:MT71A MT71A = {
            name: "71A",
            Cd: {
                \#content: "",
                number: "1"
            }
        };

        SwiftMtRecords:MT71F MT71F = {
            name: "71F",
            Ccy: {\#content: "", number: "1"},
            Amnt: {\#content: "", number: "2"}
        };

        SwiftMtRecords:MT71G MT71G = {
            name: "71G",
            Ccy: {\#content: "", number: "1"},
            Amnt: {\#content: "", number: "2"}
        };

        SwiftMtRecords:MT36 MT36 = {
            name: "36",
            Rt: {\#content: "", number: "1"}
        };

        if (STP) {
            transactionsSTP.push({
                MT21: MT21,
                MT32B: MT32B,
                MT50A: MT50A,
                MT52A: MT52A,
                MT57A: MT57A,
                MT59: MT59,
                MT70: MT70,
                MT26T: MT26T,
                MT77B: MT77B,
                MT33B: MT33B,
                MT71A: MT71A,
                MT71F: MT71F,
                MT71G: MT71G,
                MT36: MT36
            });
        } else {
            transactions.push({
                MT21: MT21,
                MT32B: MT32B,
                MT50A: MT50A,
                MT52A: MT52A,
                MT57A: MT57A,
                MT59: MT59,
                MT70: MT70,
                MT26T: MT26T,
                MT77B: MT77B,
                MT33B: MT33B,
                MT71A: MT71A,
                MT71F: MT71F,
                MT71G: MT71G,
                MT36: MT36
            });
        }
    }

    if (STP) {
        return transactionsSTP;
    } else {
        return transactions;
    }
}
enum MT103Type {
    MT103,
    MT103_STP,
    MT103_REMIT
}
isolated function transformPacs008DocumentToMT103(SwiftMxRecords:Pacs008Document document) returns SwiftMtRecords:MT103Message | error {
    SwiftMxRecords:FIToFICustomerCreditTransferV12 fiToFiCstmrCdtTrf = document.FIToFICstmrCdtTrf;

    SwiftMtRecords:Block1? block1 = check createMtBlock1FromSupplementaryData(fiToFiCstmrCdtTrf.SplmtryData);
    SwiftMtRecords:Block2 block2 = check createMtBlock2FromSupplementaryData("103", fiToFiCstmrCdtTrf.SplmtryData);
    SwiftMtRecords:Block3? block3 = check createMtBlock3FromSupplementaryData(fiToFiCstmrCdtTrf.SplmtryData);
    SwiftMtRecords:Block5? block5 = check createMtBlock5FromSupplementaryData(fiToFiCstmrCdtTrf.SplmtryData);

    SwiftMtRecords:MT103Block4 block4 = <SwiftMtRecords:MT103Block4> check createMT103Block4(document, MT103);

    SwiftMtRecords:MT103Message mtMessage = {
        block1: block1,
        block2: block2,
        block3: block3,
        block4: block4,
        block5: block5
    };

    return mtMessage;
}

isolated function transformPacs008DocumentToMT103STP(SwiftMxRecords:Pacs008Document document) returns SwiftMtRecords:MT103STPMessage | error {
    SwiftMxRecords:FIToFICustomerCreditTransferV12 fiToFiCstmrCdtTrf = document.FIToFICstmrCdtTrf;

    SwiftMtRecords:Block1? block1 = check createMtBlock1FromSupplementaryData(fiToFiCstmrCdtTrf.SplmtryData);
    SwiftMtRecords:Block2 block2 = check createMtBlock2FromSupplementaryData("103STP", fiToFiCstmrCdtTrf.SplmtryData);
    SwiftMtRecords:Block3? block3 = check createMtBlock3FromSupplementaryData(fiToFiCstmrCdtTrf.SplmtryData);
    SwiftMtRecords:Block5? block5 = check createMtBlock5FromSupplementaryData(fiToFiCstmrCdtTrf.SplmtryData);

    SwiftMtRecords:MT103STPBlock4 block4 = <SwiftMtRecords:MT103STPBlock4> check createMT103Block4(document, MT103_STP);

    SwiftMtRecords:MT103STPMessage mtMessage = {
        block1: block1,
        block2: block2,
        block3: block3,
        block4: block4,
        block5: block5
    };

    return mtMessage;
}

isolated function transformPacs008DocumentToMT103REMIT(SwiftMxRecords:Pacs008Document document) returns SwiftMtRecords:MT103REMITMessage | error {
    SwiftMxRecords:FIToFICustomerCreditTransferV12 fiToFiCstmrCdtTrf = document.FIToFICstmrCdtTrf;

    SwiftMtRecords:Block1? block1 = check createMtBlock1FromSupplementaryData(fiToFiCstmrCdtTrf.SplmtryData);
    SwiftMtRecords:Block2 block2 = check createMtBlock2FromSupplementaryData("103REMIT", fiToFiCstmrCdtTrf.SplmtryData);
    SwiftMtRecords:Block3? block3 = check createMtBlock3FromSupplementaryData(fiToFiCstmrCdtTrf.SplmtryData);
    SwiftMtRecords:Block5? block5 = check createMtBlock5FromSupplementaryData(fiToFiCstmrCdtTrf.SplmtryData);

    SwiftMtRecords:MT103REMITBlock4 block4 = <SwiftMtRecords:MT103REMITBlock4> check createMT103Block4(document, MT103_REMIT);

    SwiftMtRecords:MT103REMITMessage mtMessage = {
        block1: block1,
        block2: block2,
        block3: block3,
        block4: block4,
        block5: block5
    };

    return mtMessage;
}

isolated function createMT103Block4(SwiftMxRecords:Pacs008Document document, MT103Type messageType) returns SwiftMtRecords:MT103Block4 | SwiftMtRecords:MT103STPBlock4 | SwiftMtRecords:MT103REMITBlock4 | error {
    return error("Not implemented");
}