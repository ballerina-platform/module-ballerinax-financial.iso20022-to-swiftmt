import ballerinax/swiftmt as SwiftMtRecords;
import ballerinax/iso20022records as SwiftMxRecords;

isolated function transformPain008DocumentToMT104(SwiftMxRecords:Pain008Document document) returns SwiftMtRecords:MT104Message | error {
    SwiftMxRecords:CustomerDirectDebitInitiationV11 cstmrDrctDbtInitn = document.CstmrDrctDbtInitn;

    SwiftMtRecords:Block1? block1 = check createMtBlock1FromSupplementaryData(cstmrDrctDbtInitn.SplmtryData);
    SwiftMtRecords:Block2 block2 = check createMtBlock2FromSupplementaryData("104", cstmrDrctDbtInitn.SplmtryData);
    SwiftMtRecords:Block3? block3 = check createMtBlock3FromSupplementaryData(cstmrDrctDbtInitn.SplmtryData);
    SwiftMtRecords:Block5? block5 = check createMtBlock5FromSupplementaryData(cstmrDrctDbtInitn.SplmtryData);

    SwiftMxRecords:PaymentInstruction45[] transactions = cstmrDrctDbtInitn.PmtInf;
    if (transactions.length() == 0) {
        return error("No transactions found in the document");
    }

    SwiftMxRecords:PaymentInstruction45 firstTransaction = transactions[0];


    SwiftMtRecords:MT20 MT20 = {
        name: "20", 
        msgId: {
            \#content: getEmptyStrIfNull(firstTransaction.DrctDbtTxInf[0].PmtId.InstrId),
            number: "1"
        }
    };

    // Leave the value empty as it is not available in the pain.008 document
    SwiftMtRecords:MT21R MT21R = {
        name: "21R", 
        Ref: {
            \#content: "",
            number: "1"
        }
    };

    

    SwiftMtRecords:MT23E MT23E = {
        name: "23E", 
        InstrnCd: {
            \#content: getEmptyStrIfNull(firstTransaction.PmtTpInf?.CtgyPurp?.Cd),
            number: "1"
        }
    };

    // Leave the value empty as it is not available in the pain.008 document
    SwiftMtRecords:MT21E MT21E = {
        name: "21E", 
        Ref: {
            \#content: getEmptyStrIfNull(cstmrDrctDbtInitn.GrpHdr.MsgId),
            number: "1"
        }
    };

    SwiftMtRecords:MT30 MT30 = {
        name: "30", 
        Dt: check convertISODateStringToSwiftMtDate(firstTransaction.ReqdColltnDt, "1")
    };

    SwiftMtRecords:MT51A MT51A = {
        name: "51A",
        IdnCd: {
            \#content: getEmptyStrIfNull(cstmrDrctDbtInitn.GrpHdr.FwdgAgt?.FinInstnId?.BICFI),
            number: "1"
        },
        PrtyIdn: {
            \#content: getEmptyStrIfNull(cstmrDrctDbtInitn.GrpHdr.FwdgAgt?.FinInstnId?.LEI), 
            number: "2"
        }
    };

    SwiftMtRecords:MT50C? | SwiftMtRecords:MT50L? instrutingParty = getMT104InstructionPartyFromPain008Document(document);
    SwiftMtRecords:MT50C? MT50C = instrutingParty is SwiftMtRecords:MT50C ? instrutingParty : ();
    SwiftMtRecords:MT50L? MT50L = instrutingParty is SwiftMtRecords:MT50L ? instrutingParty : ();

    SwiftMtRecords:MT50A? | SwiftMtRecords:MT50K? creditor = getMT104CreditorFromPain008Document(document);
    SwiftMtRecords:MT50A? MT50A = creditor is SwiftMtRecords:MT50A ? creditor : ();
    SwiftMtRecords:MT50K? MT50K = creditor is SwiftMtRecords:MT50K ? creditor : ();

    SwiftMtRecords:MT52A? | SwiftMtRecords:MT52C? | SwiftMtRecords:MT52D? creditorsBank = getMT104CreditorsBankFromPain008Document(document);
    SwiftMtRecords:MT52A? MT52A = creditorsBank is SwiftMtRecords:MT52A ? creditorsBank : ();
    SwiftMtRecords:MT52C? MT52C = creditorsBank is SwiftMtRecords:MT52C ? creditorsBank : ();
    SwiftMtRecords:MT52D? MT52D = creditorsBank is SwiftMtRecords:MT52D ? creditorsBank : ();

    SwiftMtRecords:MT26T MT26T = {
        name: "26T", 
        Typ: {\#content: getEmptyStrIfNull(firstTransaction.DrctDbtTxInf[0].Purp?.Cd), number: "1"}
    };

    SwiftMtRecords:MT77B MT77B = {
        name: "77B", 
        Nrtv: {\#content: "", number: ""}
    };

    SwiftMtRecords:MT71A MT71A = {
        name: "71A", 
        Cd: getDetailsOfChargesFromChargeBearerType1Code(firstTransaction.ChrgBr) 
    };

    SwiftMtRecords:MT72 MT72 = {
        name: "72", 
        Cd: {\#content: "", number: "1"}
    };

    SwiftMtRecords:MT32B MT32B = {
        name: "32B", 
        Ccy: {\#content: getActiveOrHistoricCurrencyAndAmountCcy(firstTransaction.DrctDbtTxInf[0].InstdAmt), number: "1"},
        Amnt: {\#content: getActiveOrHistoricCurrencyAndAmountValue(firstTransaction.DrctDbtTxInf[0].InstdAmt), number: "2"}
    };

    SwiftMtRecords:MT19 MT19 = {
        name: "19", 
        Amnt: {\#content: "", number: "1"}
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

    SwiftMtRecords:MT53A? | SwiftMtRecords:MT53B? sendersCorrespondent = getMT104SendersCorrespondentFromPain008Document(document);
    SwiftMtRecords:MT53A? MT53A = sendersCorrespondent is SwiftMtRecords:MT53A ? sendersCorrespondent : ();
    SwiftMtRecords:MT53B? MT53B = sendersCorrespondent is SwiftMtRecords:MT53B ? sendersCorrespondent : ();

    SwiftMtRecords:MT104Transaction[] Transaction = check createMT104Transactions(document.CstmrDrctDbtInitn.PmtInf, instrutingParty, creditor, creditorsBank);

    SwiftMtRecords:MT104Block4 block4 = {
        MT20, MT21R, MT23E, MT21E, MT30, MT51A, MT50C, MT50L, MT50A, MT50K, MT52A, MT52C, MT52D, MT26T, MT77B, MT71A, MT72, MT32B, MT19, MT71F, MT71G, MT53A, MT53B, Transaction
    };

    return {
        block1: block1,
        block2: block2,
        block3: block3,
        block4: block4,
        block5: block5
    };
}

isolated function createMT104Transactions(
    SwiftMxRecords:PaymentInstruction45[] mxTransactions,
    SwiftMtRecords:MT50C? | SwiftMtRecords:MT50L? instrutingParty,
    SwiftMtRecords:MT50A? | SwiftMtRecords:MT50K? creditor,
    SwiftMtRecords:MT52A? | SwiftMtRecords:MT52C? | SwiftMtRecords:MT52D? creditorsBank
) returns SwiftMtRecords:MT104Transaction[] | error {
    SwiftMtRecords:MT104Transaction[] transactions = [];

    foreach SwiftMxRecords:PaymentInstruction45 mxTransaction in mxTransactions {
        SwiftMtRecords:MT21 MT21 = {
            name: "21", 
            Ref: {
                \#content: getEmptyStrIfNull(mxTransaction.PmtInfId),
                number: "1"
            }
        };

        SwiftMtRecords:MT23E MT23E = {
            name: "23E", 
            InstrnCd: {\#content: getEmptyStrIfNull(mxTransaction.PmtTpInf?.CtgyPurp?.Cd), number: "1"}
        };

        SwiftMtRecords:MT21C MT21C = {
            name: "21C", 
            Ref: {
                \#content: getEmptyStrIfNull(mxTransaction.DrctDbtTxInf[0].DrctDbtTx?.MndtRltdInf?.MndtId),
                number: "1"
            }
        };

        SwiftMtRecords:MT21D MT21D = {
            name: "21D", 
            Ref: {
                \#content: "",
                number: "1"
            }
        };

        SwiftMtRecords:MT21E MT21E = {
            name: "21E", 
            Ref: {
                \#content: "",
                number: "1"
            }
        };

        SwiftMtRecords:MT32B MT32B = {
            name: "32B",
            Ccy: {\#content: getActiveOrHistoricCurrencyAndAmountCcy(mxTransaction.DrctDbtTxInf[0].InstdAmt), number: "1"},
            Amnt: {\#content: getActiveOrHistoricCurrencyAndAmountValue(mxTransaction.DrctDbtTxInf[0].InstdAmt), number: "2"}
        };

        SwiftMtRecords:MT50C? MT50C = instrutingParty is SwiftMtRecords:MT50C ? instrutingParty : ();
        SwiftMtRecords:MT50L? MT50L = instrutingParty is SwiftMtRecords:MT50L ? instrutingParty : ();

        SwiftMtRecords:MT50A? MT50A = creditor is SwiftMtRecords:MT50A ? creditor : ();
        SwiftMtRecords:MT50K? MT50K = creditor is SwiftMtRecords:MT50K ? creditor : ();

        SwiftMtRecords:MT52A? MT52A = creditorsBank is SwiftMtRecords:MT52A ? creditorsBank : ();
        SwiftMtRecords:MT52C? MT52C = creditorsBank is SwiftMtRecords:MT52C ? creditorsBank : ();
        SwiftMtRecords:MT52D? MT52D = creditorsBank is SwiftMtRecords:MT52D ? creditorsBank : ();

        SwiftMtRecords:MT57A? | SwiftMtRecords:MT57C? | SwiftMtRecords:MT57D? debtorsBank = getMT104TransactionDebtorsBankFromPain008Document(mxTransaction);
        SwiftMtRecords:MT57A? MT57A = debtorsBank is SwiftMtRecords:MT57A ? debtorsBank : ();
        SwiftMtRecords:MT57C? MT57C = debtorsBank is SwiftMtRecords:MT57C ? debtorsBank : ();
        SwiftMtRecords:MT57D? MT57D = debtorsBank is SwiftMtRecords:MT57D ? debtorsBank : ();

        SwiftMtRecords:MT59? | SwiftMtRecords:MT59A? debtor = getMT104TransactionDebtorFromPain008Document(mxTransaction);
        SwiftMtRecords:MT59? MT59 = debtor is SwiftMtRecords:MT59 ? debtor : ();
        SwiftMtRecords:MT59A? MT59A = debtor is SwiftMtRecords:MT59A ? debtor : ();

        SwiftMtRecords:MT70 MT70 = {
            name: "70", 
            Nrtv: {\#content: "", number: "1"}
        };

        SwiftMtRecords:MT26T MT26T = {
            name: "26T", 
            Typ: {\#content: getEmptyStrIfNull(mxTransaction.DrctDbtTxInf[0].Purp?.Cd), number: "1"}
        };

        SwiftMtRecords:MT77B MT77B = {
            name: "77B", 
            Nrtv: {\#content: "", number: "1"}
        };

        SwiftMtRecords:MT33B MT33B = {
            name: "33B",             
            Ccy: {\#content: getActiveOrHistoricCurrencyAndAmountCcy(mxTransaction.DrctDbtTxInf[0].InstdAmt), number: "1"},
            Amnt: {\#content: getActiveOrHistoricCurrencyAndAmountValue(mxTransaction.DrctDbtTxInf[0].InstdAmt), number: "2"}
        };

        SwiftMtRecords:MT71A MT71A = {
            name: "71A", 
            Cd: getDetailsOfChargesFromChargeBearerType1Code(mxTransaction.ChrgBr) 
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

        transactions.push({
            MT21, MT23E, MT21C, MT21D, MT21E, MT32B, MT50C, MT50L, MT50A, MT50K, MT52A, MT52C, MT52D, 
            MT57A, MT57C, MT57D, MT59, MT59A, MT70, MT26T, MT77B, MT33B, MT71A, MT71F, MT71G, MT36
        });

    }

    return transactions;
}


