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

    // Extract the instructing party information from the Pain008 document.
    painIsoRecord:PartyIdentification272? instructingParty = document.CstmrDrctDbtInitn.GrpHdr.InitgPty;

    if instructingParty is () {
        // Return empty if no instructing party is found.
        return ();
    }

    painIsoRecord:GenericPersonIdentification2[]? otherIds = instructingParty.Id?.PrvtId?.Othr;

    // Determine whether to return MT50C or MT50L based on the presence of identifiers.
    if instructingParty.Id?.OrgId?.AnyBIC != () {
        // MT50C format: If BIC is present, create MT50C with OrgId.
        return <swiftmt:MT50C>{
            name: "50C",
            IdnCd: {
                content: instructingParty.Id?.OrgId?.AnyBIC.toString(),
                number: "1"
            }
        };
    } else if !(otherIds is ()) && otherIds.length() > 0 {
        // MT50L format: If other identifiers are present in PrvtId, create MT50L.
        return <swiftmt:MT50L>{
            name: "50L",
            PrtyIdn: {
                content: otherIds[0].Id.toString(),
                number: "1"
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

    // Extract the creditor information from the Pain008 document.
    painIsoRecord:PartyIdentification272? creditor = document.CstmrDrctDbtInitn.PmtInf[0].Cdtr;

    if creditor is () {
        // Return empty if no creditor is found.
        return ();
    }

    painIsoRecord:Max70Text[]? AdrLine = creditor.PstlAdr?.AdrLine;

    // Determine whether to return MT50A or MT50K based on the presence of identifiers.
    if creditor.Id?.OrgId?.AnyBIC != () {
        // MT50A format: If BIC is present, create MT50A with OrgId.
        return <swiftmt:MT50A>{
            name: "50A",
            IdnCd: {
                content: creditor.Id?.OrgId?.AnyBIC.toString(),
                number: "1"
            }
        };
    } else if creditor.Nm != () || (!(AdrLine is ()) && AdrLine.length() > 0) {
        // MT50K format: If name or address is present, create MT50K.
        return <swiftmt:MT50K>{
            name: "50K",
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

    // Extract the creditor's bank information from the Pain008 document.
    painIsoRecord:BranchAndFinancialInstitutionIdentification8? creditorsBank = document.CstmrDrctDbtInitn.PmtInf[0].CdtrAgt;

    if creditorsBank is () {
        // Return empty if no creditor's bank is found.
        return ();
    }

    // Check for MT52A format: If BICFI is available, return MT52A with BICFI.
    if creditorsBank.FinInstnId?.BICFI != () {
        return <swiftmt:MT52A>{
            name: "52A",
            IdnCd: {
                content: creditorsBank.FinInstnId?.BICFI.toString(),
                number: "1"
            }
        };
    }

    // Check for MT52C format: If clearing system member ID is available, return MT52C.
    else if creditorsBank.FinInstnId?.ClrSysMmbId?.MmbId != () {
        return <swiftmt:MT52C>{
            name: "52C",
            PrtyIdn: {
                content: creditorsBank.FinInstnId?.ClrSysMmbId?.MmbId.toString(),
                number: "1"
            }
        };
    }

    // Check for MT52D format: If name or address is available, return MT52D.
    else if creditorsBank.FinInstnId?.Nm != () || creditorsBank.FinInstnId?.PstlAdr?.AdrLine != () {
        return <swiftmt:MT52D>{
            name: "52D",
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

    // Extract the debtor agent (debtor's bank) information from the Pain008 document.
    painIsoRecord:BranchAndFinancialInstitutionIdentification8? dbtrAgt = mxTransaction.DrctDbtTxInf[0].DbtrAgt;

    if dbtrAgt is () {
        // Return empty if no debtor agent is found.
        return ();
    }

    // Determine which MT57 format to use based on available identifiers in the debtor agent information.
    if dbtrAgt.FinInstnId?.BICFI != () {
        // MT57A format: If BIC code is available, return MT57A with BICFI as the identification code.
        return <swiftmt:MT57A>{
            name: "57A",
            IdnCd: {
                content: dbtrAgt.FinInstnId.BICFI.toString(),
                number: "1"
            }
        };
    } else if dbtrAgt.FinInstnId?.ClrSysMmbId?.MmbId != () {
        // MT57C format: If clearing system member ID is available, return MT57C with that ID.
        return <swiftmt:MT57C>{
            name: "57C",
            PrtyIdn: {
                content: dbtrAgt.FinInstnId.ClrSysMmbId?.MmbId.toString(),
                number: "1"
            }
        };
    } else if dbtrAgt.FinInstnId?.Othr?.Id != () {
        // MT57D format: If other identifier is available, return MT57D with additional name and address details.
        return <swiftmt:MT57D>{
            name: "57D",
            PrtyIdn: {
                content: dbtrAgt.FinInstnId.Othr?.Id.toString(),
                number: "1"
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

    // Extract debtor information from the Pain008 document.
    painIsoRecord:PartyIdentification272? debtor = mxTransaction.DrctDbtTxInf[0].Dbtr;

    if debtor is () {
        // Return empty if no debtor information is found.
        return ();
    }

    // Check if debtor has a BIC available for MT59A mapping.
    if debtor.Id?.OrgId?.AnyBIC != () {
        // Map to MT59A with BIC.
        return <swiftmt:MT59A>{
            name: "59A",
            IdnCd: {
                content: debtor.Id?.OrgId?.AnyBIC.toString(),
                number: "1"
            }
        };
    }

    // Otherwise, map to MT59 with debtor's name and address if available.
    else if debtor.Nm != () || debtor.PstlAdr?.AdrLine != () {
        return <swiftmt:MT59>{
            name: "59",
            Nm: getNamesArrayFromNameString(debtor.Nm.toString()),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>debtor.PstlAdr?.AdrLine)
        };
    }

    // Return empty if neither condition is met.
    return ();
}

# Get the senders correspondent from the Pain008 document.
#
# + document - The Pain008 document
# + return - The senders correspondent or an empty record
isolated function getMT104SendersCorrespondentFromPain008Document(painIsoRecord:Pain008Document document)
returns swiftmt:MT53A?|swiftmt:MT53B? {

    // Extract forwarding agent information from the Pain008 document.
    painIsoRecord:BranchAndFinancialInstitutionIdentification8? sendersCorrespondent = document.CstmrDrctDbtInitn.GrpHdr.FwdgAgt;

    if sendersCorrespondent is () {
        // Return empty if no sender's correspondent is found.
        return ();
    }

    // Check if BICFI is available for MT53A format mapping.
    if sendersCorrespondent.FinInstnId?.BICFI != () {
        // Map to MT53A with BIC code.
        return <swiftmt:MT53A>{
            name: "53A",
            IdnCd: {
                content: sendersCorrespondent.FinInstnId.BICFI.toString(),
                number: "1"
            }
        };
    }

    // Map to MT53B if only location details are available.
    else if sendersCorrespondent.FinInstnId?.PstlAdr?.TwnNm != () {
        return <swiftmt:MT53B>{
            name: "53B",
            Lctn: {
                content: sendersCorrespondent.FinInstnId.PstlAdr?.TwnNm.toString(),
                number: "1"
            }
        };
    }

    // Return empty if neither MT53A nor MT53B mapping is possible.
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

    // Default to "RETN" as the reason for return if not specified.
    string code = "/RETN/";
    // Check for other possible codes in the unstructured narrative.
    if unstructuredInfo[0].startsWith("/REJT/") {
        code = "/REJT/";
        unstructuredInfo[0] = unstructuredInfo[0].substring(6); // Remove the code from the first line.
    }

    // Build the narrative with structured lines.
    string narrative = code + joinStringArray(unstructuredInfo, "\n//");

    return {
        name: "72",
        Cd: {
            content: narrative,
            number: "1"
        }
    };
}

# Processes regulatory reporting details and joins them with newline characters.
#
# + regulatoryReports - The array of regulatory reporting details.
# + return - The concatenated string with newline-separated reporting details.
function processRegulatoryReportsInLoop(pacsIsoRecord:RegulatoryReporting3[] regulatoryReports) returns string {
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

function getMT77BRegulatoryReporting(pacsIsoRecord:DirectDebitTransactionInformation31 document) returns swiftmt:MT77B? {
    pacsIsoRecord:RegulatoryReporting3[]? regulatoryReports = document.RgltryRptg;

    if regulatoryReports is () || regulatoryReports.length() == 0 {
        return ();
    }

    // Use the loop-based processing function for structured details.
    string narrative = processRegulatoryReportsInLoop(regulatoryReports);

    if narrative == "" {
        return ();
    }

    return {
        name: "77B",
        Nrtv: {
            content: narrative,
            number: "1"
        }
    };
}

# Get the instructing party from the Pacs003 document.
#
# + document - The Pacs003 document
# + return - The instructing party or an empty record
isolated function getMT104InstructionPartyFromPacs003Document(pacsIsoRecord:Pacs003Document document)
returns swiftmt:MT50C?|swiftmt:MT50L? {

    // Extract the instructing agent (InstgAgt) from the Group Header (GrpHdr).
    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? instructingParty = document.FIToFICstmrDrctDbt.GrpHdr.InstgAgt;

    if instructingParty is () {
        // Return empty if no instructing party is found.
        return ();
    }

    pacsIsoRecord:FinancialInstitutionIdentification23? finInstId = instructingParty.FinInstnId;
    if finInstId is () {
        // Return empty if no financial institution information is found.
        return ();
    }

    // Check if the instructing party has a BICFI (BIC Code).
    if finInstId.BICFI != () {
        // Create MT50C if BICFI is present.
        return <swiftmt:MT50C>{
            name: "50C",
            IdnCd: {
                content: finInstId.BICFI.toString(),
                number: "1"
            }
        };
    }

    // Check if the instructing party has Other identification.
    else if finInstId.Othr != () {
        // Create MT50L if Other identification is present.
        return <swiftmt:MT50L>{
            name: "50L",
            PrtyIdn: {
                content: finInstId.Othr?.Id.toString(),
                number: "1"
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

    // Extract the creditor information from the Pacs003 document.
    pacsIsoRecord:PartyIdentification272? creditor = document.FIToFICstmrDrctDbt.DrctDbtTxInf[0]?.Cdtr;

    if creditor is () {
        // Return empty if no creditor is found.
        return ();
    }

    pacsIsoRecord:Max70Text[]? AdrLine = creditor.PstlAdr?.AdrLine;

    // Determine whether to return MT50A or MT50K based on the presence of identifiers.
    if creditor.Id?.OrgId?.AnyBIC != () {
        // MT50A format: If BIC is present, create MT50A with OrgId.
        return <swiftmt:MT50A>{
            name: "50A",
            IdnCd: {
                content: creditor.Id?.OrgId?.AnyBIC.toString(),
                number: "1"
            }
        };
    } else if creditor.Nm != () || (!(AdrLine is ()) && AdrLine.length() > 0) {
        // MT50K format: If name or address is present, create MT50K.
        return <swiftmt:MT50K>{
            name: "50K",
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

    // Extract the creditor's bank information from the Pacs003 document.
    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? creditorsBank = document.FIToFICstmrDrctDbt.DrctDbtTxInf[0]?.CdtrAgt;

    if creditorsBank is () {
        // Return empty if no creditor's bank is found.
        return ();
    }

    pacsIsoRecord:FinancialInstitutionIdentification23? finInstId = creditorsBank.FinInstnId;
    if finInstId is () {
        // Return empty if no financial institution information is found.
        return ();
    }

    // Determine the MT52 format to use based on the presence of identifiers.
    if finInstId.BICFI != () {
        // MT52A format: If BIC code is available, return MT52A with BICFI as the identification code.
        return <swiftmt:MT52A>{
            name: "52A",
            IdnCd: {
                content: finInstId.BICFI.toString(),
                number: "1"
            }
        };
    } else if finInstId.ClrSysMmbId?.MmbId != () {
        // MT52C format: If clearing system member ID is available, return MT52C with that ID.
        return <swiftmt:MT52C>{
            name: "52C",
            PrtyIdn: {
                content: finInstId.ClrSysMmbId?.MmbId.toString(),
                number: "1"
            }
        };
    } else if finInstId.Othr?.Id != () {
        // MT52D format: If other identifier or name and address are available, return MT52D.
        return <swiftmt:MT52D>{
            name: "52D",
            PrtyIdn: {
                content: finInstId.Othr?.Id.toString(),
                number: "1"
            },
            Nm: getNamesArrayFromNameString(finInstId.Nm.toString()),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>finInstId.PstlAdr?.AdrLine)
        };
    }

    // Return empty if no applicable format can be derived.
    return ();
}

# Get the document debtor's bank from the Pacs003 document.
#
# + document - The Pacs003 document
# + return - The document debtor's bank or an empty record
isolated function getMT104TransactionDebtorsBankFromPacs003Document(pacsIsoRecord:DirectDebitTransactionInformation31 document)
returns swiftmt:MT57A?|swiftmt:MT57C?|swiftmt:MT57D? {

    // Extract the debtor agent (debtor's bank) from the Pacs003 document.
    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? dbtrAgt = document.DbtrAgt;

    if dbtrAgt is () {
        // Return empty if no debtor agent is found.
        return ();
    }

    pacsIsoRecord:FinancialInstitutionIdentification23? finInstId = dbtrAgt.FinInstnId;
    if finInstId is () {
        // Return empty if no financial institution information is found.
        return ();
    }

    // Determine the MT57 format based on the presence of identifiers.
    if finInstId.BICFI != () {
        // MT57A format: If BIC code is available, return MT57A with BICFI.
        return <swiftmt:MT57A>{
            name: "57A",
            IdnCd: {
                content: finInstId.BICFI.toString(),
                number: "1"
            }
        };
    } else if finInstId.ClrSysMmbId?.MmbId != () {
        // MT57C format: If clearing system member ID is available, return MT57C.
        return <swiftmt:MT57C>{
            name: "57C",
            PrtyIdn: {
                content: finInstId.ClrSysMmbId?.MmbId.toString(),
                number: "1"
            }
        };
    } else if finInstId.Othr?.Id != () {
        // MT57D format: If other identifier or name and address are available, return MT57D.
        return <swiftmt:MT57D>{
            name: "57D",
            PrtyIdn: {
                content: finInstId.Othr?.Id.toString(),
                number: "1"
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

    // Extract the debtor from the Pacs003 document.
    pacsIsoRecord:PartyIdentification272? debtor = document.Dbtr;

    if debtor is () {
        // Return empty if no debtor is found.
        return ();
    }

    // Check for BIC availability for MT59A mapping.
    if debtor.Id?.OrgId?.AnyBIC != () {
        // MT59A format: Map to MT59A with BIC.
        return <swiftmt:MT59A>{
            name: "59A",
            IdnCd: {
                content: debtor.Id?.OrgId?.AnyBIC.toString(),
                number: "1"
            }
        };
    }

    // Otherwise, map to MT59 with name and address if available.
    else if debtor.Nm != () || debtor.PstlAdr?.AdrLine != () {
        return <swiftmt:MT59>{
            name: "59",
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

    // Extract the forwarding agent (sender's correspondent) from the Pacs003 document.
    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? sendersCorrespondent = document.FIToFICstmrDrctDbt.GrpHdr.InstgAgt;

    if sendersCorrespondent is () {
        // Return empty if no sender's correspondent is found.
        return ();
    }

    pacsIsoRecord:FinancialInstitutionIdentification23? finInstId = sendersCorrespondent.FinInstnId;
    if finInstId is () {
        // Return empty if no financial institution information is found.
        return ();
    }

    // Check for BICFI for MT53A mapping.
    if finInstId.BICFI != () {
        // MT53A format: Map to MT53A with BICFI as the identifier code.
        return <swiftmt:MT53A>{
            name: "53A",
            IdnCd: {
                content: finInstId.BICFI.toString(),
                number: "1"
            }
        };
    }

    // Check for the presence of postal address location (Town Name) for MT53B mapping.
    if finInstId.PstlAdr?.TwnNm != () {
        // MT53B format: Map to MT53B with location details.
        return <swiftmt:MT53B>{
            name: "53B",
            Lctn: {
                content: finInstId.PstlAdr?.TwnNm.toString(),
                number: "1"
            }
        };
    }

    return ();
}
