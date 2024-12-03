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
import ballerinax/financial.iso20022.payments_clearing_and_settlement as pacsIsoRecord;
import ballerinax/financial.swift.mt as swiftmt;

# Get the instructing party from the Pain008 document.
#
# + document - The Pain008 document
# + return - The instructing party or an empty record
isolated function getMT104InstructionPartyFromPain008Document(painIsoRecord:Pain008Document document)
returns swiftmt:MT50C?|swiftmt:MT50L? {
    painIsoRecord:PartyIdentification272? instructingParty = document.CstmrDrctDbtInitn.GrpHdr.InitgPty;

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
    } else if !(otherIds is ()) && otherIds.length() > 0 {
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
    } else if creditor.Nm != () || (!(AdrLine is ()) && AdrLine.length() > 0) {
        return <swiftmt:MT50K>{
            name: MT50K_NAME,
            Nm: getNamesArrayFromNameString(creditor.Nm.toString()),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>creditor.PstlAdr?.AdrLine)
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
    else if creditorsBank.FinInstnId?.ClrSysMmbId?.MmbId != () {
        return <swiftmt:MT52C>{
            name: MT52C_NAME,
            PrtyIdn: {
                content: creditorsBank.FinInstnId?.ClrSysMmbId?.MmbId.toString(),
                number: NUMBER1
            }
        };
    }
    else if creditorsBank.FinInstnId?.Nm != () || creditorsBank.FinInstnId?.PstlAdr?.AdrLine != () {
        return <swiftmt:MT52D>{
            name: MT52D_NAME,
            Nm: getNamesArrayFromNameString(creditorsBank.FinInstnId?.Nm.toString()),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>creditorsBank.FinInstnId?.PstlAdr?.AdrLine)
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
    } else if dbtrAgt.FinInstnId?.ClrSysMmbId?.MmbId != () {
        return <swiftmt:MT57C>{
            name: MT57C_NAME,
            PrtyIdn: {
                content: dbtrAgt.FinInstnId.ClrSysMmbId?.MmbId.toString(),
                number: NUMBER1
            }
        };
    } else if dbtrAgt.FinInstnId?.Othr?.Id != () {
        return <swiftmt:MT57D>{
            name: MT57D_NAME,
            PrtyIdn: {
                content: dbtrAgt.FinInstnId.Othr?.Id.toString(),
                number: NUMBER1
            },
            Nm: getNamesArrayFromNameString(dbtrAgt.FinInstnId.Nm.toString()),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>dbtrAgt.FinInstnId.PstlAdr?.AdrLine)
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
    else if debtor.Nm != () || debtor.PstlAdr?.AdrLine != () {
        return <swiftmt:MT59>{
            name: MT59_NAME,
            Nm: getNamesArrayFromNameString(debtor.Nm.toString()),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>debtor.PstlAdr?.AdrLine)
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
    else if sendersCorrespondent.FinInstnId?.PstlAdr?.TwnNm != () {
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

# Maps the ISO 20022 charge bearer type to the equivalent SWIFT MT104 code for field MT71A.
#
# + chargeBearer - The charge bearer type from ISO 20022.
# + return - Returns the mapped SWIFT MT104 charge code (BEN, OUR, SHA) or an empty string for unmapped values.
function getMT71AChargesCode(string chargeBearer) returns string {
    string mappedCode = "";
    if chargeBearer == "CRED" {
        mappedCode = "BEN";
    } else if chargeBearer == "DEBT" {
        mappedCode = "OUR";
    } else if chargeBearer == "SHAR" {
        mappedCode = "SHA";
    }
    return mappedCode;
}

# Creates the MT72 field based on ISO 20022 Remittance Information.
#
# + document - A single document from the Pacs.003 document.
# + return - The transformed MT72 field or an empty record if no narrative is present.
function getMT72Narrative(pacsIsoRecord:DirectDebitTransactionInformation31 document) returns swiftmt:MT72? {
    string[]? unstructuredInfo = document.RmtInf?.Ustrd;

    if unstructuredInfo is () || unstructuredInfo.length() == 0 {
        return ();
    }

    string code = "/RETN/";
    if unstructuredInfo[0].startsWith("/REJT/") {
        code = "/REJT/";
        unstructuredInfo[0] = unstructuredInfo[0].substring(6);
    }
    string narrative = code + joinStringArray(unstructuredInfo, "\n//");

    return {
        name: MT72_NAME,
        Cd: {
            content: narrative,
            number: NUMBER1
        }
    };
}

# Processes regulatory reporting details and joins them with newline characters.
#
# + regulatoryReports - The array of regulatory reporting details.
# + return - The concatenated string with newline-separated reporting details.
isolated function processRegulatoryReportsInLoop(pacsIsoRecord:RegulatoryReporting3[] regulatoryReports) returns string {
    string[] narrativeParts = [];
    foreach pacsIsoRecord:RegulatoryReporting3 report in regulatoryReports {
        pacsIsoRecord:StructuredRegulatoryReporting3[]? Dtls = report.Dtls;

        if Dtls is () {
            continue;
        }

        foreach pacsIsoRecord:StructuredRegulatoryReporting3 detail in Dtls {
            string part = "";
            part += detail.Tp ?: "";
            part += detail.Dt is () ? "" : " " + detail.Dt.toString();
            part += detail.Ctry is () ? "" : " " + detail.Ctry.toString();
            part += detail.Cd is () ? "" : " " + detail.Cd.toString();
            part += detail.Amt is () ? "" : " " + detail.Amt.toString();
            part += detail.Inf is () ? "" : " " + joinStringArray(<string[]>detail.Inf, " ");
            narrativeParts.push(part.trim());
        }
    }
    return joinStringArray(narrativeParts, "\n");
}

isolated function getMT77BRegulatoryReporting(pacsIsoRecord:RegulatoryReporting3[]? regulatoryReports) returns swiftmt:MT77B? {

    if regulatoryReports is () || regulatoryReports.length() == 0 {
        return ();
    }
    string narrative = processRegulatoryReportsInLoop(regulatoryReports);

    if narrative == "" {
        return ();
    }

    return {
        name: MT77B_NAME,
        Nrtv: {
            content: narrative,
            number: NUMBER1
        }
    };
}

# Get the instructing party from the Pacs003 document.
#
# + document - The Pacs003 document
# + return - The instructing party or an empty record
isolated function getMT104InstructionPartyFromPacs003Document(pacsIsoRecord:Pacs003Document document)
returns swiftmt:MT50C?|swiftmt:MT50L? {
    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? instructingParty = document.FIToFICstmrDrctDbt.GrpHdr.InstgAgt;

    if instructingParty is () {
        return ();
    }

    pacsIsoRecord:FinancialInstitutionIdentification23? finInstId = instructingParty.FinInstnId;
    if finInstId is () {
        return ();
    }
    if finInstId.BICFI != () {
        return <swiftmt:MT50C>{
            name: MT50C_NAME,
            IdnCd: {
                content: finInstId.BICFI.toString(),
                number: NUMBER1
            }
        };
    }
    else if finInstId.Othr != () {
        return <swiftmt:MT50L>{
            name: MT50L_NAME,
            PrtyIdn: {
                content: finInstId.Othr?.Id.toString(),
                number: NUMBER1
            }
        };
    }

    return ();
}

# Get the ordering customer from the Pacs003 document.
#
# + document - The Pacs003 document
# + return - The ordering customer or an empty record
isolated function getMT104CreditorFromPacs003Document(pacsIsoRecord:Pacs003Document document)
returns swiftmt:MT50A?|swiftmt:MT50K? {
    pacsIsoRecord:PartyIdentification272? creditor = document.FIToFICstmrDrctDbt.DrctDbtTxInf[0]?.Cdtr;

    if creditor is () {
        return ();
    }

    pacsIsoRecord:Max70Text[]? AdrLine = creditor.PstlAdr?.AdrLine;
    if creditor.Id?.OrgId?.AnyBIC != () {
        return <swiftmt:MT50A>{
            name: MT50A_NAME,
            IdnCd: {
                content: creditor.Id?.OrgId?.AnyBIC.toString(),
                number: NUMBER1
            }
        };
    } else if creditor.Nm != () || (!(AdrLine is ()) && AdrLine.length() > 0) {
        return <swiftmt:MT50K>{
            name: MT50K_NAME,
            Nm: getNamesArrayFromNameString(creditor.Nm.toString()),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>creditor.PstlAdr?.AdrLine)
        };
    }

    return ();
}

# Get the account servicing institution from the Pacs003 document.
#
# + document - The Pacs003 document
# + return - The account servicing institution or an empty record
isolated function getMT104CreditorsBankFromPacs003Document(pacsIsoRecord:Pacs003Document document)
returns swiftmt:MT52A?|swiftmt:MT52C?|swiftmt:MT52D? {
    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? creditorsBank = document.FIToFICstmrDrctDbt.DrctDbtTxInf[0]?.CdtrAgt;

    if creditorsBank is () {
        return ();
    }

    pacsIsoRecord:FinancialInstitutionIdentification23? finInstId = creditorsBank.FinInstnId;
    if finInstId is () {
        return ();
    }
    if finInstId.BICFI != () {
        return <swiftmt:MT52A>{
            name: MT52A_NAME,
            IdnCd: {
                content: finInstId.BICFI.toString(),
                number: NUMBER1
            }
        };
    } else if finInstId.ClrSysMmbId?.MmbId != () {
        return <swiftmt:MT52C>{
            name: MT52C_NAME,
            PrtyIdn: {
                content: finInstId.ClrSysMmbId?.MmbId.toString(),
                number: NUMBER1
            }
        };
    } else if finInstId.Othr?.Id != () {
        return <swiftmt:MT52D>{
            name: MT52D_NAME,
            PrtyIdn: {
                content: finInstId.Othr?.Id.toString(),
                number: NUMBER1
            },
            Nm: getNamesArrayFromNameString(finInstId.Nm.toString()),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>finInstId.PstlAdr?.AdrLine)
        };
    }

    return ();
}

# Get the document debtor's bank from the Pacs003 document.
#
# + document - The Pacs003 document
# + return - The document debtor's bank or an empty record
isolated function getMT104TransactionDebtorsBankFromPacs003Document(pacsIsoRecord:DirectDebitTransactionInformation31 document)
returns swiftmt:MT57A?|swiftmt:MT57C?|swiftmt:MT57D? {
    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? dbtrAgt = document.DbtrAgt;

    if dbtrAgt is () {
        return ();
    }

    pacsIsoRecord:FinancialInstitutionIdentification23? finInstId = dbtrAgt.FinInstnId;
    if finInstId is () {
        return ();
    }
    if finInstId.BICFI != () {
        return <swiftmt:MT57A>{
            name: MT57A_NAME,
            IdnCd: {
                content: finInstId.BICFI.toString(),
                number: NUMBER1
            }
        };
    } else if finInstId.ClrSysMmbId?.MmbId != () {
        return <swiftmt:MT57C>{
            name: MT57C_NAME,
            PrtyIdn: {
                content: finInstId.ClrSysMmbId?.MmbId.toString(),
                number: NUMBER1
            }
        };
    } else if finInstId.Othr?.Id != () {
        return <swiftmt:MT57D>{
            name: MT57D_NAME,
            PrtyIdn: {
                content: finInstId.Othr?.Id.toString(),
                number: NUMBER1
            },
            Nm: getNamesArrayFromNameString(finInstId.Nm.toString()),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>finInstId.PstlAdr?.AdrLine)
        };
    }

    return ();
}

# Get the document debtor from the Pacs003 document.
#
# + document - The Pacs003 document
# + return - The document debtor or an empty record
isolated function getMT104TransactionDebtorFromPacs003Document(pacsIsoRecord:DirectDebitTransactionInformation31 document)
returns swiftmt:MT59?|swiftmt:MT59A? {
    pacsIsoRecord:PartyIdentification272? debtor = document.Dbtr;

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

    else if debtor.Nm != () || debtor.PstlAdr?.AdrLine != () {
        return <swiftmt:MT59>{
            name: MT59_NAME,
            Nm: getNamesArrayFromNameString(debtor.Nm.toString()),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>debtor.PstlAdr?.AdrLine)
        };
    }

    return ();
}

# Get the sender's correspondent from the Pacs003 document.
#
# + document - The Pacs003 document
# + return - The sender's correspondent or an empty record
isolated function getMT104SendersCorrespondentFromPacs003Document(pacsIsoRecord:Pacs003Document document)
returns swiftmt:MT53A?|swiftmt:MT53B? {
    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? sendersCorrespondent = document.FIToFICstmrDrctDbt.GrpHdr.InstgAgt;

    if sendersCorrespondent is () {
        return ();
    }

    pacsIsoRecord:FinancialInstitutionIdentification23? finInstId = sendersCorrespondent.FinInstnId;
    if finInstId is () {
        return ();
    }
    if finInstId.BICFI != () {
        return <swiftmt:MT53A>{
            name: MT53A_NAME,
            IdnCd: {
                content: finInstId.BICFI.toString(),
                number: NUMBER1
            }
        };
    }

    if finInstId.PstlAdr?.TwnNm != () {
        return <swiftmt:MT53B>{
            name: MT53B_NAME,
            Lctn: {
                content: finInstId.PstlAdr?.TwnNm.toString(),
                number: NUMBER1
            }
        };
    }

    return ();
}

