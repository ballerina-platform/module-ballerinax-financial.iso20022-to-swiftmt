import ballerinax/financial.iso20022.payments_clearing_and_settlement as pacsIsoRecord;
import ballerinax/financial.swift.mt as swiftmt;

# Transforms the given ISO 20022 Pacs.003 document to its corresponding SWIFT MT104 format.
#
# + document - The Pacs003Document as an input
# + return - The transformed SWIFT MT104 message or an error if the transformation fails
function transformPacs003DocumentToMT104(pacsIsoRecord:Pacs003Document document) returns swiftmt:MT104Message|error => let
    swiftmt:MT50C?|swiftmt:MT50L? instructingParty = getMT104InstructionPartyFromPacs003Document(document),
    swiftmt:MT50A?|swiftmt:MT50K? creditor = getMT104CreditorFromPacs003Document(document),
    swiftmt:MT52A?|swiftmt:MT52C?|swiftmt:MT52D? creditorsBank = getMT104CreditorsBankFromPacs003Document(document),
    swiftmt:MT53A?|swiftmt:MT53B? sendersCorrespondent = getMT104SendersCorrespondentFromPacs003Document(document),
    swiftmt:MT104Transaction[] transactions = check createMT104TransactionsFromPacs003(document.FIToFICstmrDrctDbt.DrctDbtTxInf, instructingParty, creditor, creditorsBank)
    in {
        block1: check createBlock1FromInstgAgtAndInstdAgt((), document.FIToFICstmrDrctDbt.GrpHdr.InstdAgt),
        block2: check createMtBlock2("104", document.FIToFICstmrDrctDbt.SplmtryData, document.FIToFICstmrDrctDbt.GrpHdr.CreDtTm),
        block3: check createMtBlock3FromSupplementaryData(document.FIToFICstmrDrctDbt.SplmtryData),
        block4: {
            MT19: {
                name: "19",
                Amnt: {
                    content: document.FIToFICstmrDrctDbt.GrpHdr.TtlIntrBkSttlmAmt?.ActiveCurrencyAndAmount_SimpleType.toString(),
                    number: "1"
                }
            },
            MT20: {
                name: "20",
                msgId: {
                    content: getEmptyStrIfNull(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].PmtId?.InstrId),
                    number: "1"
                }
            },
            MT21E: {
                name: "21E",
                Ref: {content: document.FIToFICstmrDrctDbt.GrpHdr.MsgId, number: "1"}
            },
            MT21R: {
                name: "21R",
                Ref: {
                    content: getEmptyStrIfNull(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].PmtId?.EndToEndId),
                    number: "1"
                }
            },
            MT23E: !(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].PmtTpInf?.CtgyPurp?.Cd is ()) ? {
                    name: "23E",
                    InstrnCd: {content: document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].PmtTpInf?.CtgyPurp?.Cd.toString(), number: "1"}
                } : (),
            MT26T: !(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].Purp?.Cd is ()) ? {
                    name: "26T",
                    Typ: {content: document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].Purp?.Cd.toString(), number: "1"}
                } : (),
            MT30: {
                name: "30",
                Dt: check convertISODateStringToSwiftMtDate(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].IntrBkSttlmDt.toString())
            },
            MT32B: {
                name: "32B",
                Ccy: {content: document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].IntrBkSttlmAmt?.ActiveCurrencyAndAmount_SimpleType.Ccy, number: "1"},
                Amnt: {content: document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].IntrBkSttlmAmt?.ActiveCurrencyAndAmount_SimpleType.toString(), number: "2"}
            },
            MT50C: instructingParty is swiftmt:MT50C ? instructingParty : (),
            MT50L: instructingParty is swiftmt:MT50L ? instructingParty : (),
            MT50A: creditor is swiftmt:MT50A ? creditor : (),
            MT50K: creditor is swiftmt:MT50K ? creditor : (),
            MT51A: !(document.FIToFICstmrDrctDbt.GrpHdr.InstgAgt is ()) ? {
                    name: "51A",
                    IdnCd: {content: document.FIToFICstmrDrctDbt.GrpHdr.InstgAgt?.FinInstnId?.BICFI.toString(), number: "1"}
                } : (),
            MT52A: creditorsBank is swiftmt:MT52A ? creditorsBank : (),
            MT52C: creditorsBank is swiftmt:MT52C ? creditorsBank : (),
            MT52D: creditorsBank is swiftmt:MT52D ? creditorsBank : (),
            MT53A: sendersCorrespondent is swiftmt:MT53A ? sendersCorrespondent : (),
            MT53B: sendersCorrespondent is swiftmt:MT53B ? sendersCorrespondent : (),
            MT71A: {
                name: "71A",
                Cd: {
                    content: getMT71AChargesCode(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].ChrgBr.toString()),
                    number: "1"
                }
            },
            MT71F: !(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].ChrgsInf is ()) ? {
                    name: "71F",
                    Ccy: {content: (<pacsIsoRecord:Charges16?>getFirstElementFromArray(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].ChrgsInf))?.Amt?.ActiveOrHistoricCurrencyAndAmount_SimpleType?.Ccy.toString(), number: "1"},
                    Amnt: {content: (<pacsIsoRecord:Charges16?>getFirstElementFromArray(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].ChrgsInf))?.Amt?.ActiveOrHistoricCurrencyAndAmount_SimpleType.toString(), number: "2"}
                } : (),
            MT71G: !(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].ChrgsInf is ()) ? {
                    name: "71G",
                    Ccy: {content: (<pacsIsoRecord:Charges16?>getFirstElementFromArray(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].ChrgsInf))?.Amt?.ActiveOrHistoricCurrencyAndAmount_SimpleType?.Ccy.toString(), number: "1"},
                    Amnt: {content: (<pacsIsoRecord:Charges16?>getFirstElementFromArray(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].ChrgsInf))?.Amt?.ActiveOrHistoricCurrencyAndAmount_SimpleType.toString(), number: "2"}
                } : (),
            MT72: !(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].RmtInf?.Ustrd is ()) ?
                getMT72Narrative(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0])
                : (),
            MT77B: !(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].RgltryRptg is ()) ?
                getMT77BRegulatoryReporting(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0])
                : (),
            Transaction: transactions
        },
        block5: check createMtBlock5FromSupplementaryData(document.FIToFICstmrDrctDbt.SplmtryData)
    };

# Creates the MT104 transactions from the Pacs003 document's direct debit transaction information.
#
# + drctDbtTxInf - Array of DirectDebitTransactionInformation31 from Pacs003 document
# + instructingParty - The instructing party information
# + creditor - The creditor information
# + creditorsBank - The creditor's bank information
# + return - Array of MT104 transactions or an error
isolated function createMT104TransactionsFromPacs003(
        pacsIsoRecord:DirectDebitTransactionInformation31[] drctDbtTxInf,
        swiftmt:MT50C?|swiftmt:MT50L? instructingParty,
        swiftmt:MT50A?|swiftmt:MT50K? creditor,
        swiftmt:MT52A?|swiftmt:MT52C?|swiftmt:MT52D? creditorsBank
) returns swiftmt:MT104Transaction[]|error {
    swiftmt:MT104Transaction[] transactions = [];

    foreach pacsIsoRecord:DirectDebitTransactionInformation31 tx in drctDbtTxInf {
        swiftmt:MT21 MT21 = {
            name: "21",
            Ref: {
                content: getEmptyStrIfNull(tx.PmtId?.InstrId),
                number: "1"
            }
        };

        swiftmt:MT23E MT23E = {
            name: "23E",
            InstrnCd: {content: getEmptyStrIfNull(tx.PmtTpInf?.CtgyPurp?.Cd), number: "1"}
        };

        swiftmt:MT32B MT32B = {
            name: "32B",
            Ccy: {content: tx.IntrBkSttlmAmt.ActiveCurrencyAndAmount_SimpleType.Ccy, number: "1"},
            Amnt: {content: tx.IntrBkSttlmAmt?.ActiveCurrencyAndAmount_SimpleType.toString(), number: "2"}
        };

        swiftmt:MT50C? MT50C = instructingParty is swiftmt:MT50C ? instructingParty : ();
        swiftmt:MT50L? MT50L = instructingParty is swiftmt:MT50L ? instructingParty : ();

        swiftmt:MT50A? MT50A = creditor is swiftmt:MT50A ? creditor : ();
        swiftmt:MT50K? MT50K = creditor is swiftmt:MT50K ? creditor : ();

        swiftmt:MT52A? MT52A = creditorsBank is swiftmt:MT52A ? creditorsBank : ();
        swiftmt:MT52C? MT52C = creditorsBank is swiftmt:MT52C ? creditorsBank : ();
        swiftmt:MT52D? MT52D = creditorsBank is swiftmt:MT52D ? creditorsBank : ();

        swiftmt:MT57A?|swiftmt:MT57C?|swiftmt:MT57D? debtorsBank = getMT104TransactionDebtorsBankFromPacs003Document(tx);
        swiftmt:MT57A? MT57A = debtorsBank is swiftmt:MT57A ? debtorsBank : ();
        swiftmt:MT57C? MT57C = debtorsBank is swiftmt:MT57C ? debtorsBank : ();
        swiftmt:MT57D? MT57D = debtorsBank is swiftmt:MT57D ? debtorsBank : ();

        transactions.push({
            MT21,
            MT23E,
            MT32B,
            MT50C,
            MT50L,
            MT50A,
            MT50K,
            MT52A,
            MT52C,
            MT52D,
            MT57A,
            MT57C,
            MT57D
        });
    }

    return transactions;
}

function transformPacs003DocumentToMT107(pacsIsoRecord:Pacs003Document document) returns swiftmt:MT107Message|error => let
    swiftmt:MT50C?|swiftmt:MT50L? instructingParty = getMT107InstructionPartyFromPacs003Document(document),
    swiftmt:MT50A?|swiftmt:MT50K? creditor = getMT107CreditorFromPacs003Document(document),
    swiftmt:MT52A?|swiftmt:MT52C?|swiftmt:MT52D? creditorsBank = getMT107CreditorsBankFromPacs003Document(document),
    swiftmt:MT53A?|swiftmt:MT53B? sendersCorrespondent = getMT107SendersCorrespondentFromPacs003Document(document),
    swiftmt:MT107Transaction[] transactions = check createMT107TransactionsFromPacs003(
            document.FIToFICstmrDrctDbt.DrctDbtTxInf,
            instructingParty,
            creditor,
            creditorsBank
    )
    in {
        block1: check createBlock1FromInstgAgtAndInstdAgt((), document.FIToFICstmrDrctDbt.GrpHdr.InstdAgt),
        block2: check createMtBlock2("107", document.FIToFICstmrDrctDbt.SplmtryData, document.FIToFICstmrDrctDbt.GrpHdr.CreDtTm),
        block3: check createMtBlock3FromSupplementaryData(document.FIToFICstmrDrctDbt.SplmtryData),
        block4: {
            MT19: !(document.FIToFICstmrDrctDbt.GrpHdr.CtrlSum is ()) ? {
                    name: "19",
                    Amnt: {
                        content: document.FIToFICstmrDrctDbt.GrpHdr.CtrlSum.toString(),
                        number: "1"
                    }
                } : (),
            MT20: {
                name: "20",
                msgId: {
                    content: document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].PmtId?.InstrId ?: "",
                    number: "1"
                }
            },
            MT21E: {
                name: "21E",
                Ref: {
                    content: document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].PmtId?.EndToEndId,
                    number: "1"
                }
            },
            MT23E: !(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].PmtTpInf?.CtgyPurp?.Cd is ()) ? {
                    name: "23E",
                    InstrnCd: {
                        content: document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].PmtTpInf?.CtgyPurp?.Cd.toString(),
                        number: "1"
                    }
                } : (),
            MT30: {
                name: "30",
                Dt: check convertISODateStringToSwiftMtDate(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].IntrBkSttlmDt.toString())
            },
            MT32B: {
                name: "32B",
                Ccy: {
                    content: document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].IntrBkSttlmAmt.ActiveCurrencyAndAmount_SimpleType.Ccy,
                    number: "1"
                },
                Amnt: {
                    content: document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].IntrBkSttlmAmt.ActiveCurrencyAndAmount_SimpleType.toString(),
                    number: "2"
                }
            },
            MT50C: instructingParty is swiftmt:MT50C ? instructingParty : (),
            MT50L: instructingParty is swiftmt:MT50L ? instructingParty : (),
            MT50A: creditor is swiftmt:MT50A ? creditor : (),
            MT50K: creditor is swiftmt:MT50K ? creditor : (),
            MT52A: creditorsBank is swiftmt:MT52A ? creditorsBank : (),
            MT52C: creditorsBank is swiftmt:MT52C ? creditorsBank : (),
            MT52D: creditorsBank is swiftmt:MT52D ? creditorsBank : (),
            MT53A: sendersCorrespondent is swiftmt:MT53A ? sendersCorrespondent : (),
            MT53B: sendersCorrespondent is swiftmt:MT53B ? sendersCorrespondent : (),
            MT71A: {
                name: "71A",
                Cd: {
                    content: getMT71AChargesCode(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].ChrgBr.toString()),
                    number: "1"
                }
            },
            MT71F: !(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].ChrgsInf is ()) ? {
                    name: "71F",
                    Ccy: {
                        content: (<pacsIsoRecord:Charges16?>getFirstElementFromArray(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].ChrgsInf))?.Amt?.ActiveOrHistoricCurrencyAndAmount_SimpleType?.Ccy.toString(),
                        number: "1"
                    },
                    Amnt: {
                        content: (<pacsIsoRecord:Charges16?>getFirstElementFromArray(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].ChrgsInf))?.Amt?.ActiveOrHistoricCurrencyAndAmount_SimpleType.toString(),
                        number: "2"
                    }
                } : (),
            MT71G: !(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].ChrgsInf is ()) ? {
                    name: "71G",
                    Ccy: {
                        content: (<pacsIsoRecord:Charges16?>getLastElementFromArray(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].ChrgsInf))?.Amt?.ActiveOrHistoricCurrencyAndAmount_SimpleType?.Ccy.toString(),
                        number: "1"
                    },
                    Amnt: {
                        content: (<pacsIsoRecord:Charges16?>getLastElementFromArray(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].ChrgsInf))?.Amt?.ActiveOrHistoricCurrencyAndAmount_SimpleType.toString(),
                        number: "2"
                    }
                } : (),
            MT72: !(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].RmtInf?.Ustrd is ()) ?
                getMT72Narrative(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0])
                : (),
            MT77B: !(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].RgltryRptg is ()) ?
                getMT77BRegulatoryReporting(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0])
                : (),
            Transaction: transactions
        },
        block5: check createMtBlock5FromSupplementaryData(document.FIToFICstmrDrctDbt.SplmtryData)
    };

isolated function createMT107TransactionsFromPacs003(
        pacsIsoRecord:DirectDebitTransactionInformation31[] drctDbtTxInf,
        swiftmt:MT50C?|swiftmt:MT50L? instructingParty,
        swiftmt:MT50A?|swiftmt:MT50K? creditor,
        swiftmt:MT52A?|swiftmt:MT52C?|swiftmt:MT52D? creditorsBank
) returns swiftmt:MT107Transaction[]|error {
    swiftmt:MT107Transaction[] transactions = [];

    foreach pacsIsoRecord:DirectDebitTransactionInformation31 tx in drctDbtTxInf {
        swiftmt:MT21 MT21 = {
            name: "21",
            Ref: {
                content: tx.PmtId?.InstrId ?: "",
                number: "1"
            }
        };

        swiftmt:MT23E MT23E = {
            name: "23E",
            InstrnCd: {
                content: tx.PmtTpInf?.CtgyPurp?.Cd ?: "",
                number: "1"
            }
        };

        swiftmt:MT32B MT32B = {
            name: "32B",
            Ccy: {
                content: tx.IntrBkSttlmAmt.ActiveCurrencyAndAmount_SimpleType.Ccy,
                number: "1"
            },
            Amnt: {
                content: tx.IntrBkSttlmAmt.ActiveCurrencyAndAmount_SimpleType.toString(),
                number: "2"
            }
        };

        transactions.push({
            MT21,
            MT23E,
            MT32B,
            MT50C: instructingParty is swiftmt:MT50C ? instructingParty : (),
            MT50L: instructingParty is swiftmt:MT50L ? instructingParty : (),
            MT50A: creditor is swiftmt:MT50A ? creditor : (),
            MT50K: creditor is swiftmt:MT50K ? creditor : (),
            MT52A: creditorsBank is swiftmt:MT52A ? creditorsBank : (),
            MT52C: creditorsBank is swiftmt:MT52C ? creditorsBank : (),
            MT52D: creditorsBank is swiftmt:MT52D ? creditorsBank : ()
        });
    }

    return transactions;
}
