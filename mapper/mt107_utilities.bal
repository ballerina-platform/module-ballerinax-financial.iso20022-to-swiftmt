import ballerinax/financial.iso20022.payments_clearing_and_settlement as pacsIsoRecord;
import ballerinax/financial.swift.mt as swiftmt;

# Get MT107 message from Pacs003Document
# + document - The Pacs003 document.
# + return - The corresponding MT107 message.
isolated function getMT107InstructionPartyFromPacs003Document(
        pacsIsoRecord:Pacs003Document document
) returns swiftmt:MT50C?|swiftmt:MT50L? {
    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? instructingParty = document.FIToFICstmrDrctDbt.GrpHdr.InstgAgt;

    if instructingParty is () {
        return ();
    }

    if instructingParty.FinInstnId.BICFI is string {
        return <swiftmt:MT50C>{
            name: "50C",
            IdnCd: {
                content: instructingParty.FinInstnId.BICFI.toString(),
                number: "1"
            }
        };
    } else if instructingParty.FinInstnId.Othr?.Id is string {
        return <swiftmt:MT50L>{
            name: "50L",
            PrtyIdn: {
                content: instructingParty.FinInstnId.Othr?.Id.toString(),
                number: "1"
            }
        };
    }

    return ();
}

# Extracts the creditor's information from a Pacs003Document.
# + document - The Pacs003 document.
# + return - The corresponding MT50A or MT50K record, or null if no matching data is found.
isolated function getMT107CreditorFromPacs003Document(
        pacsIsoRecord:Pacs003Document document
) returns swiftmt:MT50A?|swiftmt:MT50K? {
    pacsIsoRecord:PartyIdentification272 creditor = document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].Cdtr;

    if creditor.Id?.OrgId?.AnyBIC is string {
        return <swiftmt:MT50A>{
            name: "50A",
            IdnCd: {
                content: creditor.Id?.OrgId?.AnyBIC.toString(),
                number: "1"
            }
        };
    } else if creditor.Nm is string || creditor.PstlAdr?.AdrLine is string[] {
        return <swiftmt:MT50K>{
            name: "50K",
            Acc: {
                content: (<pacsIsoRecord:GenericOrganisationIdentification3>getFirstElementFromArray(creditor.Id?.PrvtId?.Othr))?.Id.toString(),
                number: "1"
            },
            Nm: getNamesArrayFromNameString(creditor.Nm.toString()),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>creditor.PstlAdr?.AdrLine)
        }
;
    }

    return ();

}

# Extracts the creditor's bank information from a Pacs003Document.
#
# + document - The Pacs003 document.
# + return - The corresponding MT52A, MT52C, or MT52D record, or null if no matching data is found.
isolated function getMT107CreditorsBankFromPacs003Document(
        pacsIsoRecord:Pacs003Document document
) returns swiftmt:MT52A?|swiftmt:MT52C?|swiftmt:MT52D? {
    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8 creditorsBank = document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].CdtrAgt;

    if creditorsBank.FinInstnId?.BICFI is string {
        return <swiftmt:MT52A>{
            name: "52A",
            IdnCd: {
                content: creditorsBank.FinInstnId.BICFI.toString(),
                number: "1"
            },
            PrtyIdnTyp: {
                content: creditorsBank.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd.toString(),
                number: "1"
            },
            PrtyIdn: {
                content: creditorsBank.FinInstnId?.ClrSysMmbId?.MmbId.toString(),
                number: "1"
            }
        };
    }
    else if creditorsBank.FinInstnId?.ClrSysMmbId?.MmbId is string {
        return <swiftmt:MT52C>{
            name: "52C",
            PrtyIdn: {
                content: creditorsBank.FinInstnId.ClrSysMmbId?.MmbId.toString(),
                number: "1"
            }
        };
    }
    else if creditorsBank.FinInstnId?.Nm is string {
        return <swiftmt:MT52D>{
            name: "52D",
            PrtyIdn: {
                content: creditorsBank.FinInstnId?.Othr?.Id.toString(),
                number: "1"
            },
            PrtyIdnTyp: {
                content: creditorsBank.FinInstnId?.Othr?.SchmeNm?.Cd.toString(),
                number: "1"
            },
            Nm: getNamesArrayFromNameString(creditorsBank.FinInstnId.Nm.toString()),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>creditorsBank.FinInstnId.PstlAdr?.AdrLine)
        };
    }

    return ();
}

# Extracts the sender's correspondent information from a Pacs003Document.
#
# + document - The Pacs003 document.
# + return - The corresponding MT53A or MT53B record, or null if no matching data is found.
isolated function getMT107SendersCorrespondentFromPacs003Document(
        pacsIsoRecord:Pacs003Document document
) returns swiftmt:MT53A?|swiftmt:MT53B? {
    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? sendersCorrespondent =
        document.FIToFICstmrDrctDbt.GrpHdr.InstgAgt;

    if sendersCorrespondent is () {
        return ();
    }

    if sendersCorrespondent.FinInstnId?.BICFI is string {
        return <swiftmt:MT53A>{
            name: "53A",
            IdnCd: {
                content: sendersCorrespondent.FinInstnId.BICFI.toString(),
                number: "1"
            },
            PrtyIdnTyp: sendersCorrespondent.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd is string ? {
                    content: sendersCorrespondent.FinInstnId.ClrSysMmbId?.ClrSysId?.Cd.toString(),
                    number: "1"
                } : (),
            PrtyIdn: sendersCorrespondent.FinInstnId?.ClrSysMmbId?.MmbId is string ? {
                    content: sendersCorrespondent.FinInstnId.ClrSysMmbId?.MmbId.toString(),
                    number: "1"
                } : ()
        };
    }
    else if sendersCorrespondent.FinInstnId?.Nm is string {
        return <swiftmt:MT53B>{
            name: "53B",
            PrtyIdn: sendersCorrespondent.FinInstnId?.ClrSysMmbId?.MmbId is string ? {
                    content: sendersCorrespondent.FinInstnId.ClrSysMmbId?.MmbId.toString(),
                    number: "1"
                } : (),
            PrtyIdnTyp: sendersCorrespondent.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd is string ? {
                    content: sendersCorrespondent.FinInstnId.ClrSysMmbId?.ClrSysId?.Cd.toString(),
                    number: "1"
                } : (),
            Lctn: {
                content: sendersCorrespondent.FinInstnId.Nm.toString(),
                number: "1"
            }
        };
    }

    return ();
}

