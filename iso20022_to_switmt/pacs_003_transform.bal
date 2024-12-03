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
        block1: generateMtBlock1FromInstgAgtAndInstdAgt((), document.FIToFICstmrDrctDbt.GrpHdr.InstdAgt),
        block2: check generateMtBlock2WithDateTime(MESSAGETYPE_104, document.FIToFICstmrDrctDbt.GrpHdr.CreDtTm),
        block3: check generateMtBlock3(document.FIToFICstmrDrctDbt.SplmtryData, document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].PmtId.UETR, ""),
        block4: {
            MT19: {
                name: MT19_NAME,
                Amnt: {
                    content: document.FIToFICstmrDrctDbt.GrpHdr.TtlIntrBkSttlmAmt?.ActiveCurrencyAndAmount_SimpleType.toString(),
                    number: NUMBER1
                }
            },
            MT20: {
                name: MT20_NAME,
                msgId: {
                    content: getEmptyStrIfNull(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].PmtId?.InstrId),
                    number: NUMBER1
                }
            },
            MT21E: {
                name: MT23E_NAME,
                Ref: {content: document.FIToFICstmrDrctDbt.GrpHdr.MsgId, number: NUMBER1}
            },
            MT21R: {
                name: MT21R_NAME,
                Ref: {
                    content: getEmptyStrIfNull(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].PmtId?.EndToEndId),
                    number: NUMBER1
                }
            },
            MT23E: document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].PmtTpInf?.CtgyPurp?.Cd is () ? () : {
                    name: MT23E_NAME,
                    InstrnCd: {content: document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].PmtTpInf?.CtgyPurp?.Cd.toString(), number: NUMBER1}
                },
            MT26T: document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].Purp?.Cd is () ? () : {
                    name: MT26T_NAME,
                    Typ: {content: document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].Purp?.Cd.toString(), number: NUMBER1}
                },
            MT30: {
                name: MT30_NAME,
                Dt: check convertISODateStringToSwiftMtDate(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].IntrBkSttlmDt.toString())
            },
            MT32B: {
                name: MT32B_NAME,
                Ccy: {content: document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].IntrBkSttlmAmt?.ActiveCurrencyAndAmount_SimpleType.Ccy, number: NUMBER1},
                Amnt: {content: document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].IntrBkSttlmAmt?.ActiveCurrencyAndAmount_SimpleType.toString(), number: NUMBER2}
            },
            MT50C: instructingParty is swiftmt:MT50C ? instructingParty : (),
            MT50L: instructingParty is swiftmt:MT50L ? instructingParty : (),
            MT50A: creditor is swiftmt:MT50A ? creditor : (),
            MT50K: creditor is swiftmt:MT50K ? creditor : (),
            MT51A: document.FIToFICstmrDrctDbt.GrpHdr.InstgAgt is () ? () : {
                    name: MT51A_NAME,
                    IdnCd: {content: document.FIToFICstmrDrctDbt.GrpHdr.InstgAgt?.FinInstnId?.BICFI.toString(), number: NUMBER1}
                },
            MT52A: creditorsBank is swiftmt:MT52A ? creditorsBank : (),
            MT52C: creditorsBank is swiftmt:MT52C ? creditorsBank : (),
            MT52D: creditorsBank is swiftmt:MT52D ? creditorsBank : (),
            MT53A: sendersCorrespondent is swiftmt:MT53A ? sendersCorrespondent : (),
            MT53B: sendersCorrespondent is swiftmt:MT53B ? sendersCorrespondent : (),
            MT71A: {
                name: MT71A_NAME,
                Cd: {
                    content: getMT71AChargesCode(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].ChrgBr.toString()),
                    number: NUMBER1
                }
            },
            MT71F: document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].ChrgsInf is () ? () : {
                    name: MT71F_NAME,
                    Ccy: {content: (<pacsIsoRecord:Charges16?>getFirstElementFromArray(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].ChrgsInf))?.Amt?.ActiveOrHistoricCurrencyAndAmount_SimpleType?.Ccy.toString(), number: NUMBER1},
                    Amnt: {content: (<pacsIsoRecord:Charges16?>getFirstElementFromArray(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].ChrgsInf))?.Amt?.ActiveOrHistoricCurrencyAndAmount_SimpleType.toString(), number: NUMBER2}
                },
            MT71G: document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].ChrgsInf is () ? () : {
                    name: MT71G_NAME,
                    Ccy: {content: (<pacsIsoRecord:Charges16?>getFirstElementFromArray(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].ChrgsInf))?.Amt?.ActiveOrHistoricCurrencyAndAmount_SimpleType?.Ccy.toString(), number: NUMBER1},
                    Amnt: {content: (<pacsIsoRecord:Charges16?>getFirstElementFromArray(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].ChrgsInf))?.Amt?.ActiveOrHistoricCurrencyAndAmount_SimpleType.toString(), number: NUMBER2}
                },
            MT72: document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].RmtInf?.Ustrd is () ? () : getMT72Narrative(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0]),
            MT77B: document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].RgltryRptg is () ? () :
                getMT77BRegulatoryReporting(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].RgltryRptg),
            Transaction: transactions
        },
        block5: check generateMtBlock5FromSupplementaryData(document.FIToFICstmrDrctDbt.SplmtryData)
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
            name: MT21_NAME,
            Ref: {
                content: getEmptyStrIfNull(tx.PmtId?.InstrId),
                number: NUMBER1
            }
        };

        swiftmt:MT23E MT23E = {
            name: MT23E_NAME,
            InstrnCd: {content: getEmptyStrIfNull(tx.PmtTpInf?.CtgyPurp?.Cd), number: NUMBER1}
        };

        swiftmt:MT32B MT32B = {
            name: MT23B_NAME,
            Ccy: {content: tx.IntrBkSttlmAmt.ActiveCurrencyAndAmount_SimpleType.Ccy, number: NUMBER1},
            Amnt: {content: tx.IntrBkSttlmAmt?.ActiveCurrencyAndAmount_SimpleType.toString(), number: NUMBER2}
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

# Tranform the given ISO 20022 Pacs.003 document to its corresponding SWIFT MT107 format.
# + document - The Pacs003Document as an input
# + return - The transformed SWIFT MT107 message or an error if the transformation fails
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
        block1: generateMtBlock1FromInstgAgtAndInstdAgt((), document.FIToFICstmrDrctDbt.GrpHdr.InstdAgt),
        block2: check generateMtBlock2WithDateTime(MESSAGETYPE_107, document.FIToFICstmrDrctDbt.GrpHdr.CreDtTm),
        block3: check generateMtBlock3(document.FIToFICstmrDrctDbt.SplmtryData, document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].PmtId.UETR, ""),
        block4: {
            MT19: document.FIToFICstmrDrctDbt.GrpHdr.CtrlSum is () ? () : {
                    name: MT19_NAME,
                    Amnt: {
                        content: document.FIToFICstmrDrctDbt.GrpHdr.CtrlSum.toString(),
                        number: NUMBER1
                    }
                },
            MT20: {
                name: MT20_NAME,
                msgId: {
                    content: document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].PmtId?.InstrId ?: "",
                    number: NUMBER1
                }
            },
            MT21E: {
                name: MT23E_NAME,
                Ref: {
                    content: document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].PmtId?.EndToEndId,
                    number: NUMBER1
                }
            },
            MT23E: document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].PmtTpInf?.CtgyPurp?.Cd is () ? () : {
                    name: MT23E_NAME,
                    InstrnCd: {
                        content: document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].PmtTpInf?.CtgyPurp?.Cd.toString(),
                        number: NUMBER1
                    }
                },
            MT30: {
                name: MT30_NAME,
                Dt: check convertISODateStringToSwiftMtDate(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].IntrBkSttlmDt.toString())
            },
            MT32B: {
                name: MT32B_NAME,
                Ccy: {
                    content: document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].IntrBkSttlmAmt.ActiveCurrencyAndAmount_SimpleType.Ccy,
                    number: NUMBER1
                },
                Amnt: {
                    content: document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].IntrBkSttlmAmt.ActiveCurrencyAndAmount_SimpleType.toString(),
                    number: NUMBER2
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
                name: MT71A_NAME,
                Cd: {
                    content: getMT71AChargesCode(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].ChrgBr.toString()),
                    number: NUMBER1
                }
            },
            MT71F: document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].ChrgsInf is () ? () : {
                    name: MT71F_NAME,
                    Ccy: {
                        content: (<pacsIsoRecord:Charges16?>getFirstElementFromArray(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].ChrgsInf))?.Amt?.ActiveOrHistoricCurrencyAndAmount_SimpleType?.Ccy.toString(),
                        number: NUMBER1
                    },
                    Amnt: {
                        content: (<pacsIsoRecord:Charges16?>getFirstElementFromArray(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].ChrgsInf))?.Amt?.ActiveOrHistoricCurrencyAndAmount_SimpleType.toString(),
                        number: NUMBER2
                    }
                },
            MT71G: document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].ChrgsInf is () ? () : {
                    name: MT71G_NAME,
                    Ccy: {
                        content: (<pacsIsoRecord:Charges16?>getLastElementFromArray(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].ChrgsInf))?.Amt?.ActiveOrHistoricCurrencyAndAmount_SimpleType?.Ccy.toString(),
                        number: NUMBER1
                    },
                    Amnt: {
                        content: (<pacsIsoRecord:Charges16?>getLastElementFromArray(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].ChrgsInf))?.Amt?.ActiveOrHistoricCurrencyAndAmount_SimpleType.toString(),
                        number: NUMBER2
                    }
                },
            MT72: document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].RmtInf?.Ustrd is () ? () : getMT72Narrative(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0]),
            MT77B: document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].RgltryRptg is () ? () : getMT77BRegulatoryReporting(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].RgltryRptg),
            Transaction: transactions
        },
        block5: check generateMtBlock5FromSupplementaryData(document.FIToFICstmrDrctDbt.SplmtryData)
    };

# Create the MT107 transactions from the Pacs003 document's direct debit transaction information.
# + drctDbtTxInf - Array of DirectDebitTransactionInformation31 from Pacs003 document
# + instructingParty - The instructing party information
# + creditor - The creditor information
# + creditorsBank - The creditor's bank information
# + return - Array of MT107 transactions or an error
isolated function createMT107TransactionsFromPacs003(
        pacsIsoRecord:DirectDebitTransactionInformation31[] drctDbtTxInf,
        swiftmt:MT50C?|swiftmt:MT50L? instructingParty,
        swiftmt:MT50A?|swiftmt:MT50K? creditor,
        swiftmt:MT52A?|swiftmt:MT52C?|swiftmt:MT52D? creditorsBank
) returns swiftmt:MT107Transaction[]|error {
    swiftmt:MT107Transaction[] transactions = [];
    foreach pacsIsoRecord:DirectDebitTransactionInformation31 tx in drctDbtTxInf {
        swiftmt:MT21 MT21 = {
            name: MT21_NAME,
            Ref: {
                content: tx.PmtId?.InstrId ?: "", // TODO: Check if this is correct
                number: NUMBER1
            }
        };

        swiftmt:MT23E MT23E = {
            name: MT23E_NAME,
            InstrnCd: {
                content: tx.PmtTpInf?.CtgyPurp?.Cd ?: "", // TODO: Check if this is correct
                number: NUMBER1
            }
        };

        swiftmt:MT32B MT32B = {
            name: MT32B_NAME,
            Ccy: {
                content: tx.IntrBkSttlmAmt.ActiveCurrencyAndAmount_SimpleType.Ccy,
                number: NUMBER1
            },
            Amnt: {
                content: tx.IntrBkSttlmAmt.ActiveCurrencyAndAmount_SimpleType.toString(),
                number: NUMBER2
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
