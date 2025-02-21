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

# generate the MT104 message from the Pain008 document
#
# + envelope - The Pain008 envelope containing the corresponding document to be transformed.
# + messageType - The SWIFT message type
# + return - The MT104 message or an error if the transformation fails
isolated function transformPain008DocumentToMT104(painIsoRecord:Pain008Envelope envelope, string messageType) returns swiftmt:MT104Message|error => let
    swiftmt:MT50C?|swiftmt:MT50L? instructingParty = getMT104InstructionPartyFromPain008Document(envelope.Document.CstmrDrctDbtInitn.GrpHdr.InitgPty),
    swiftmt:MT50A?|swiftmt:MT50K? creditor = getMT104CreditorFromPain008Document(envelope.Document),
    swiftmt:MT52A?|swiftmt:MT52C?|swiftmt:MT52D? creditorsBank = getMT104CreditorsBankFromPain008Document(envelope.Document),
    swiftmt:MT53A?|swiftmt:MT53B? sendersCorrespondent = getMT104SendersCorrespondentFromPain008Document(envelope.Document),
    swiftmt:MT104Transaction[] transactions = check generateMT104Transactions(envelope.Document.CstmrDrctDbtInitn.PmtInf, instructingParty, creditor, creditorsBank)
    in {
        block1: generateBlock1(getSenderOrReceiver(envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)),
        block2: generateBlock2(messageType, getSenderOrReceiver(envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI),
                envelope.Document.CstmrDrctDbtInitn.GrpHdr.CreDtTm),
        block3: createMtBlock3(envelope.Document.CstmrDrctDbtInitn.PmtInf[0].DrctDbtTxInf[0].PmtId?.UETR),
        block4: {
            MT19: {
                name: MT19_NAME,
                Amnt: {
                    content: convertDecimalToSwiftDecimal(envelope.Document.CstmrDrctDbtInitn.GrpHdr.CtrlSum),
                    number: NUMBER1
                }
            },
            MT20: {
                name: MT20_NAME,
                msgId: {
                    content: getEmptyStrIfNull(envelope.Document.CstmrDrctDbtInitn.PmtInf[0].DrctDbtTxInf[0].PmtId.InstrId),
                    number: NUMBER1
                }
            },
            MT21R: {
                name: MT21R_NAME,
                Ref: {
                    content: EMPTY_STRING,
                    number: NUMBER1
                }
            },
            MT23E: {
                name: MT23E_NAME,
                InstrnCd: {
                    content: getEmptyStrIfNull(envelope.Document.CstmrDrctDbtInitn.PmtInf[0].PmtTpInf?.CtgyPurp?.Cd),
                    number: NUMBER1
                }
            },
            MT21E: {
                name: MT21E_NAME,
                Ref: {
                    content: getEmptyStrIfNull(envelope.Document.CstmrDrctDbtInitn.GrpHdr.MsgId),
                    number: NUMBER1
                }
            },
            MT30: {
                name: MT30_NAME,
                Dt: check convertISODateStringToSwiftMtDate(envelope.Document.CstmrDrctDbtInitn.PmtInf[0].ReqdColltnDt, NUMBER1)
            },
            MT51A: {
                name: MT51A_NAME,
                IdnCd: {
                    content: getEmptyStrIfNull(envelope.Document.CstmrDrctDbtInitn.GrpHdr.FwdgAgt?.FinInstnId?.BICFI),
                    number: NUMBER1
                },
                PrtyIdn: {
                    content: getEmptyStrIfNull(envelope.Document.CstmrDrctDbtInitn.GrpHdr.FwdgAgt?.FinInstnId?.LEI),
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
            MT26T: {
                name: MT26T_NAME,
                Typ: {content: getEmptyStrIfNull(envelope.Document.CstmrDrctDbtInitn.PmtInf[0].DrctDbtTxInf[0].Purp?.Cd), number: NUMBER1}
            },
            MT77B: {
                name: MT77B_NAME,
                Nrtv: {content: EMPTY_STRING, number: EMPTY_STRING}
            },
            MT71A: {
                name: MT71A_NAME,
                Cd: getDetailsOfChargesFromChargeBearerType1Code(envelope.Document.CstmrDrctDbtInitn.PmtInf[0].ChrgBr)
            },
            MT72: {
                name: MT72_NAME,
                Cd: {content: EMPTY_STRING, number: NUMBER1}
            },
            MT32B: {
                name: MT32B_NAME,
                Ccy: {content: envelope.Document.CstmrDrctDbtInitn.PmtInf[0].DrctDbtTxInf[0].InstdAmt?.Ccy, number: NUMBER1},
                Amnt: {content: convertDecimalToSwiftDecimal(envelope.Document.CstmrDrctDbtInitn.PmtInf[0].DrctDbtTxInf[0].InstdAmt?.content), number: NUMBER2}
            },
            MT71F: {
                name: MT71F_NAME,
                Ccy: {content: EMPTY_STRING, number: NUMBER1},
                Amnt: {content: EMPTY_STRING, number: NUMBER2}
            },
            MT71G: {
                name: MT71G_NAME,
                Ccy: {content: EMPTY_STRING, number: NUMBER1},
                Amnt: {content: EMPTY_STRING, number: NUMBER2}
            },
            MT53A: sendersCorrespondent is swiftmt:MT53A ? sendersCorrespondent : (),
            MT53B: sendersCorrespondent is swiftmt:MT53B ? sendersCorrespondent : (),
            Transaction: transactions
        },
        block5: check generateMtBlock5FromSupplementaryData(envelope.Document.CstmrDrctDbtInitn.SplmtryData)
    };

# generate the MT104 transactions from the Pain008 envelope.Document
#
# + mxTransactions - The Pain008 transactions
# + instrutingParty - The instructing party
# + creditor - The creditor
# + creditorsBank - The creditor's bank
# + return - The MT104 transactions
isolated function generateMT104Transactions(
        painIsoRecord:PaymentInstruction45[] mxTransactions,
        swiftmt:MT50C?|swiftmt:MT50L? instrutingParty,
        swiftmt:MT50A?|swiftmt:MT50K? creditor,
        swiftmt:MT52A?|swiftmt:MT52C?|swiftmt:MT52D? creditorsBank
) returns swiftmt:MT104Transaction[]|error {
    swiftmt:MT104Transaction[] transactions = [];
    foreach painIsoRecord:PaymentInstruction45 mxTransaction in mxTransactions {
        swiftmt:MT21 MT21 = {
            name: MT21_NAME,
            Ref: {
                content: getEmptyStrIfNull(mxTransaction.PmtInfId),
                number: NUMBER1
            }
        };

        swiftmt:MT23E MT23E = {
            name: MT23E_NAME,
            InstrnCd: {content: getEmptyStrIfNull(mxTransaction.PmtTpInf?.CtgyPurp?.Cd), number: NUMBER1}
        };

        swiftmt:MT21C MT21C = {
            name: MT21_NAME,
            Ref: {
                content: getEmptyStrIfNull(mxTransaction.DrctDbtTxInf[0].DrctDbtTx?.MndtRltdInf?.MndtId),
                number: NUMBER1
            }
        };

        swiftmt:MT32B MT32B = {
            name: MT32B_NAME,
            Ccy: {content: mxTransaction.DrctDbtTxInf[0].InstdAmt?.Ccy, number: NUMBER1},
            Amnt: {content: convertDecimalToSwiftDecimal(mxTransaction.DrctDbtTxInf[0].InstdAmt?.content), number: NUMBER2}
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

        swiftmt:MT26T MT26T = {
            name: MT26T_NAME,
            Typ: {content: getEmptyStrIfNull(mxTransaction.DrctDbtTxInf[0].Purp?.Cd), number: NUMBER1}
        };

        swiftmt:MT33B MT33B = {
            name: MT33B_NAME,
            Ccy: {content: mxTransaction.DrctDbtTxInf[0].InstdAmt?.Ccy, number: NUMBER1},
            Amnt: {content: convertDecimalToSwiftDecimal(mxTransaction.DrctDbtTxInf[0].InstdAmt?.content), number: NUMBER2}
        };

        swiftmt:MT71A MT71A = {
            name: MT71A_NAME,
            Cd: getDetailsOfChargesFromChargeBearerType1Code(mxTransaction.ChrgBr)
        };

        transactions.push({
            MT21,
            MT23E,
            MT21C,
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
            MT26T,
            MT33B,
            MT71A
        });

    }
    return transactions;
}

# Get the instructing party from the Pain008 document.
#
# + instructingParty - The instructing party
# + return - The instructing party or an empty record
isolated function getMT104InstructionPartyFromPain008Document(painIsoRecord:PartyIdentification272? instructingParty)
    returns swiftmt:MT50C?|swiftmt:MT50L? {

    if instructingParty is () {
        return ();
    }

    painIsoRecord:GenericPersonIdentification2[]? otherIds = instructingParty.Id?.PrvtId?.Othr;
    if instructingParty.Id?.OrgId?.AnyBIC != () {
        return <swiftmt:MT50C>{
            name: MT50C_NAME,
            IdnCd: {
                content: instructingParty.Id?.OrgId?.AnyBIC.toString(),
                number: NUMBER1
            }
        };
    }
    if !(otherIds is ()) && otherIds.length() > 0 {
        return <swiftmt:MT50L>{
            name: MT50L_NAME,
            PrtyIdn: {
                content: otherIds[0].Id.toString(),
                number: NUMBER1
            }
        };
    }

    return ();
}

# Get the ordering customer from the Pain008 document.
#
# + document - The Pain008 document
# + return - The ordering customer or an empty record
isolated function getMT104CreditorFromPain008Document(painIsoRecord:Pain008Document document)
returns swiftmt:MT50A?|swiftmt:MT50K? {
    painIsoRecord:PartyIdentification272? creditor = document.CstmrDrctDbtInitn.PmtInf[0].Cdtr;

    if creditor is () {
        return ();
    }

    painIsoRecord:Max70Text[]? AdrLine = creditor.PstlAdr?.AdrLine;
    if creditor.Id?.OrgId?.AnyBIC != () {
        return <swiftmt:MT50A>{
            name: MT50A_NAME,
            IdnCd: {
                content: creditor.Id?.OrgId?.AnyBIC.toString(),
                number: NUMBER1
            }
        };
    }
    if creditor.Nm != () || (!(AdrLine is ()) && AdrLine.length() > 0) {
        return <swiftmt:MT50K>{
            name: MT50K_NAME,
            Nm: getNamesArrayFromNameString(creditor.Nm.toString()),
            AdrsLine: getAddressLine(creditor.PstlAdr?.AdrLine)
        };
    }

    return ();
}

# Get the account servicing institution from the Pain008 document.
#
# + document - The Pain008 document
# + return - The account servicing institution or an empty record
isolated function getMT104CreditorsBankFromPain008Document(painIsoRecord:Pain008Document document)
returns swiftmt:MT52A?|swiftmt:MT52C?|swiftmt:MT52D? {
    painIsoRecord:BranchAndFinancialInstitutionIdentification8? creditorsBank = document.CstmrDrctDbtInitn.PmtInf[0].CdtrAgt;

    if creditorsBank is () {
        return ();
    }

    if creditorsBank.FinInstnId?.BICFI != () {
        return <swiftmt:MT52A>{
            name: MT52A_NAME,
            IdnCd: {
                content: creditorsBank.FinInstnId?.BICFI.toString(),
                number: NUMBER1
            }
        };
    }
    if creditorsBank.FinInstnId?.ClrSysMmbId?.MmbId != () {
        return <swiftmt:MT52C>{
            name: MT52C_NAME,
            PrtyIdn: {
                content: creditorsBank.FinInstnId?.ClrSysMmbId?.MmbId.toString(),
                number: NUMBER1
            }
        };
    }
    if creditorsBank.FinInstnId?.Nm != () || creditorsBank.FinInstnId?.PstlAdr?.AdrLine != () {
        return <swiftmt:MT52D>{
            name: MT52D_NAME,
            Nm: getNamesArrayFromNameString(creditorsBank.FinInstnId?.Nm.toString()),
            AdrsLine: getAddressLine(creditorsBank.FinInstnId?.PstlAdr?.AdrLine)
        };
    }

    return ();
}

# Get the document debtor's bank from the Pain008 document.
#
# + mxTransaction - The MX document
# + return - The document debtor's bank or an empty record
isolated function getMT104TransactionDebtorsBankFromPain008Document(painIsoRecord:PaymentInstruction45 mxTransaction)
returns swiftmt:MT57A?|swiftmt:MT57C?|swiftmt:MT57D? {
    painIsoRecord:BranchAndFinancialInstitutionIdentification8? dbtrAgt = mxTransaction.DrctDbtTxInf[0].DbtrAgt;

    if dbtrAgt is () {
        return ();
    }
    if dbtrAgt.FinInstnId?.BICFI != () {
        return <swiftmt:MT57A>{
            name: MT57A_NAME,
            IdnCd: {
                content: dbtrAgt.FinInstnId.BICFI.toString(),
                number: NUMBER1
            }
        };
    }
    if dbtrAgt.FinInstnId?.ClrSysMmbId?.MmbId != () {
        return <swiftmt:MT57C>{
            name: MT57C_NAME,
            PrtyIdn: {
                content: dbtrAgt.FinInstnId.ClrSysMmbId?.MmbId.toString(),
                number: NUMBER1
            }
        };
    }
    if dbtrAgt.FinInstnId?.Othr?.Id != () {
        return <swiftmt:MT57D>{
            name: MT57D_NAME,
            PrtyIdn: {
                content: dbtrAgt.FinInstnId.Othr?.Id.toString(),
                number: NUMBER1
            },
            Nm: getNamesArrayFromNameString(dbtrAgt.FinInstnId.Nm.toString()),
            AdrsLine: getAddressLine(dbtrAgt.FinInstnId.PstlAdr?.AdrLine)
        };
    }

    return ();
}

# Get the document debtor from the Pain008 document.
#
# + mxTransaction - The MX document
# + return - The document debtor or an empty record
isolated function getMT104TransactionDebtorFromPain008Document(painIsoRecord:PaymentInstruction45 mxTransaction)
returns swiftmt:MT59?|swiftmt:MT59A? {
    painIsoRecord:PartyIdentification272? debtor = mxTransaction.DrctDbtTxInf[0].Dbtr;

    if debtor is () {
        return ();
    }
    if debtor.Id?.OrgId?.AnyBIC != () {
        return <swiftmt:MT59A>{
            name: MT56A_NAME,
            IdnCd: {
                content: debtor.Id?.OrgId?.AnyBIC.toString(),
                number: NUMBER1
            }
        };
    }
    if debtor.Nm != () || debtor.PstlAdr?.AdrLine != () {
        return <swiftmt:MT59>{
            name: MT59_NAME,
            Nm: getNamesArrayFromNameString(debtor.Nm.toString()),
            AdrsLine: getAddressLine(debtor.PstlAdr?.AdrLine)
        };
    }

    return ();
}

# Get the senders correspondent from the Pain008 document.
#
# + document - The Pain008 document
# + return - The senders correspondent or an empty record
isolated function getMT104SendersCorrespondentFromPain008Document(painIsoRecord:Pain008Document document)
returns swiftmt:MT53A?|swiftmt:MT53B? {
    painIsoRecord:BranchAndFinancialInstitutionIdentification8? sendersCorrespondent = document.CstmrDrctDbtInitn.GrpHdr.FwdgAgt;

    if sendersCorrespondent is () {
        return ();
    }

    if sendersCorrespondent.FinInstnId?.BICFI != () {
        return <swiftmt:MT53A>{
            name: MT53A_NAME,
            IdnCd: {
                content: sendersCorrespondent.FinInstnId.BICFI.toString(),
                number: NUMBER1
            }
        };
    }
    if sendersCorrespondent.FinInstnId?.PstlAdr?.TwnNm != () {
        return <swiftmt:MT53B>{
            name: MT53B_NAME,
            Lctn: {
                content: sendersCorrespondent.FinInstnId.PstlAdr?.TwnNm.toString(),
                number: NUMBER1
            }
        };
    }

    return ();
}
