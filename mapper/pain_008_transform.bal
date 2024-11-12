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

import ballerinax/financial.iso20022.payment_initiation as painIsoRecord;
import ballerinax/financial.swift.mt as swiftmt;

# Create the MT104 message from the Pain008 document
#
# + document - The Pain008 document
# + return - The MT104 message or an error if the transformation fails
function transformPain008DocumentToMT104(painIsoRecord:Pain008Document document) returns swiftmt:MT104Message|error => let
    swiftmt:MT50C?|swiftmt:MT50L? instructingParty = getMT104InstructionPartyFromPain008Document(document),
    swiftmt:MT50A?|swiftmt:MT50K? creditor = getMT104CreditorFromPain008Document(document),
    swiftmt:MT52A?|swiftmt:MT52C?|swiftmt:MT52D? creditorsBank = getMT104CreditorsBankFromPain008Document(document),
    swiftmt:MT53A?|swiftmt:MT53B? sendersCorrespondent = getMT104SendersCorrespondentFromPain008Document(document),
    swiftmt:MT104Transaction[] transactions = check createMT104Transactions(document.CstmrDrctDbtInitn.PmtInf, instructingParty, creditor, creditorsBank)
    in {
        block1: check createMtBlock1FromSupplementaryData(document.CstmrDrctDbtInitn.SplmtryData),
        block2: {
            messageType: "104"
        },
        block3: check createMtBlock3FromSupplementaryData(document.CstmrDrctDbtInitn.SplmtryData),
        block4: {
            MT20: {
                name: "20",
                msgId: {
                    content: getEmptyStrIfNull(document.CstmrDrctDbtInitn.PmtInf[0].DrctDbtTxInf[0].PmtId.InstrId),
                    number: "1"
                }
            },
            MT21R: {
                name: "21R",
                Ref: {
                    content: "",
                    number: "1"
                }
            },
            MT23E: {
                name: "23E",
                InstrnCd: {
                    content: getEmptyStrIfNull(document.CstmrDrctDbtInitn.PmtInf[0].PmtTpInf?.CtgyPurp?.Cd),
                    number: "1"
                }
            },
            MT21E: {
                name: "21E",
                Ref: {
                    content: getEmptyStrIfNull(document.CstmrDrctDbtInitn.GrpHdr.MsgId),
                    number: "1"
                }
            },
            MT30: {
                name: "30",
                Dt: check convertISODateStringToSwiftMtDate(document.CstmrDrctDbtInitn.PmtInf[0].ReqdColltnDt, "1")
            },
            MT51A: {
                name: "51A",
                IdnCd: {
                    content: getEmptyStrIfNull(document.CstmrDrctDbtInitn.GrpHdr.FwdgAgt?.FinInstnId?.BICFI),
                    number: "1"
                },
                PrtyIdn: {
                    content: getEmptyStrIfNull(document.CstmrDrctDbtInitn.GrpHdr.FwdgAgt?.FinInstnId?.LEI),
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
            MT26T: {
                name: "26T",
                Typ: {content: getEmptyStrIfNull(document.CstmrDrctDbtInitn.PmtInf[0].DrctDbtTxInf[0].Purp?.Cd), number: "1"}
            },
            MT77B: {
                name: "77B",
                Nrtv: {content: "", number: ""}
            },
            MT71A: {
                name: "71A",
                Cd: getDetailsOfChargesFromChargeBearerType1Code(document.CstmrDrctDbtInitn.PmtInf[0].ChrgBr)
            },
            MT72: {
                name: "72",
                Cd: {content: "", number: "1"}
            },
            MT32B: {
                name: "32B",
                Ccy: {content: getActiveOrHistoricCurrencyAndAmountCcy(document.CstmrDrctDbtInitn.PmtInf[0].DrctDbtTxInf[0].InstdAmt), number: "1"},
                Amnt: {content: getActiveOrHistoricCurrencyAndAmountValue(document.CstmrDrctDbtInitn.PmtInf[0].DrctDbtTxInf[0].InstdAmt), number: "2"}
            },
            MT19: {
                name: "19",
                Amnt: {content: "", number: "1"}
            },
            MT71F: {
                name: "71F",
                Ccy: {content: "", number: "1"},
                Amnt: {content: "", number: "2"}
            },
            MT71G: {
                name: "71G",
                Ccy: {content: "", number: "1"},
                Amnt: {content: "", number: "2"}
            },
            MT53A: sendersCorrespondent is swiftmt:MT53A ? sendersCorrespondent : (),
            MT53B: sendersCorrespondent is swiftmt:MT53B ? sendersCorrespondent : (),
            Transaction: transactions
        },
        block5: check createMtBlock5FromSupplementaryData(document.CstmrDrctDbtInitn.SplmtryData)
    };

# Create the MT104 transactions from the Pain008 document
#
# + mxTransactions - The Pain008 transactions
# + instrutingParty - The instructing party
# + creditor - The creditor
# + creditorsBank - The creditor's bank
# + return - The MT104 transactions
isolated function createMT104Transactions(
        painIsoRecord:PaymentInstruction45[] mxTransactions,
        swiftmt:MT50C?|swiftmt:MT50L? instrutingParty,
        swiftmt:MT50A?|swiftmt:MT50K? creditor,
        swiftmt:MT52A?|swiftmt:MT52C?|swiftmt:MT52D? creditorsBank
) returns swiftmt:MT104Transaction[]|error {
    swiftmt:MT104Transaction[] transactions = [];

    foreach painIsoRecord:PaymentInstruction45 mxTransaction in mxTransactions {
        swiftmt:MT21 MT21 = {
            name: "21",
            Ref: {
                content: getEmptyStrIfNull(mxTransaction.PmtInfId),
                number: "1"
            }
        };

        swiftmt:MT23E MT23E = {
            name: "23E",
            InstrnCd: {content: getEmptyStrIfNull(mxTransaction.PmtTpInf?.CtgyPurp?.Cd), number: "1"}
        };

        swiftmt:MT21C MT21C = {
            name: "21C",
            Ref: {
                content: getEmptyStrIfNull(mxTransaction.DrctDbtTxInf[0].DrctDbtTx?.MndtRltdInf?.MndtId),
                number: "1"
            }
        };

        swiftmt:MT21D MT21D = {
            name: "21D",
            Ref: {
                content: "",
                number: "1"
            }
        };

        swiftmt:MT21E MT21E = {
            name: "21E",
            Ref: {
                content: "",
                number: "1"
            }
        };

        swiftmt:MT32B MT32B = {
            name: "32B",
            Ccy: {content: getActiveOrHistoricCurrencyAndAmountCcy(mxTransaction.DrctDbtTxInf[0].InstdAmt), number: "1"},
            Amnt: {content: getActiveOrHistoricCurrencyAndAmountValue(mxTransaction.DrctDbtTxInf[0].InstdAmt), number: "2"}
        };

        swiftmt:MT50C? MT50C = instrutingParty is swiftmt:MT50C ? instrutingParty : ();
        swiftmt:MT50L? MT50L = instrutingParty is swiftmt:MT50L ? instrutingParty : ();

        swiftmt:MT50A? MT50A = creditor is swiftmt:MT50A ? creditor : ();
        swiftmt:MT50K? MT50K = creditor is swiftmt:MT50K ? creditor : ();

        swiftmt:MT52A? MT52A = creditorsBank is swiftmt:MT52A ? creditorsBank : ();
        swiftmt:MT52C? MT52C = creditorsBank is swiftmt:MT52C ? creditorsBank : ();
        swiftmt:MT52D? MT52D = creditorsBank is swiftmt:MT52D ? creditorsBank : ();

        swiftmt:MT57A?|swiftmt:MT57C?|swiftmt:MT57D? debtorsBank = getMT104TransactionDebtorsBankFromPain008Document(mxTransaction);
        swiftmt:MT57A? MT57A = debtorsBank is swiftmt:MT57A ? debtorsBank : ();
        swiftmt:MT57C? MT57C = debtorsBank is swiftmt:MT57C ? debtorsBank : ();
        swiftmt:MT57D? MT57D = debtorsBank is swiftmt:MT57D ? debtorsBank : ();

        swiftmt:MT59?|swiftmt:MT59A? debtor = getMT104TransactionDebtorFromPain008Document(mxTransaction);
        swiftmt:MT59? MT59 = debtor is swiftmt:MT59 ? debtor : ();
        swiftmt:MT59A? MT59A = debtor is swiftmt:MT59A ? debtor : ();

        swiftmt:MT70 MT70 = {
            name: "70",
            Nrtv: {content: "", number: "1"}
        };

        swiftmt:MT26T MT26T = {
            name: "26T",
            Typ: {content: getEmptyStrIfNull(mxTransaction.DrctDbtTxInf[0].Purp?.Cd), number: "1"}
        };

        swiftmt:MT77B MT77B = {
            name: "77B",
            Nrtv: {content: "", number: "1"}
        };

        swiftmt:MT33B MT33B = {
            name: "33B",
            Ccy: {content: getActiveOrHistoricCurrencyAndAmountCcy(mxTransaction.DrctDbtTxInf[0].InstdAmt), number: "1"},
            Amnt: {content: getActiveOrHistoricCurrencyAndAmountValue(mxTransaction.DrctDbtTxInf[0].InstdAmt), number: "2"}
        };

        swiftmt:MT71A MT71A = {
            name: "71A",
            Cd: getDetailsOfChargesFromChargeBearerType1Code(mxTransaction.ChrgBr)
        };

        swiftmt:MT71F MT71F = {
            name: "71F",
            Ccy: {content: "", number: "1"},
            Amnt: {content: "", number: "2"}
        };

        swiftmt:MT71G MT71G = {
            name: "71G",
            Ccy: {content: "", number: "1"},
            Amnt: {content: "", number: "2"}
        };

        swiftmt:MT36 MT36 = {
            name: "36",
            Rt: {content: "", number: "1"}
        };

        transactions.push({
            MT21,
            MT23E,
            MT21C,
            MT21D,
            MT21E,
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
            MT57D,
            MT59,
            MT59A,
            MT70,
            MT26T,
            MT77B,
            MT33B,
            MT71A,
            MT71F,
            MT71G,
            MT36
        });

    }

    return transactions;
}

