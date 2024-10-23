import ballerinax/swiftmt as SwiftMtRecords;
import ballerinax/iso20022records as SwiftMxRecords;

isolated function getMT101InstructingPartyFromPain001Document(SwiftMxRecords:Pain001Document document) 
returns SwiftMtRecords:MT50C? | SwiftMtRecords:MT50L? {
    SwiftMxRecords:Party52Choice? id = document.CstmrCdtTrfInitn.GrpHdr.InitgPty.Id;

    if (id is ()) {
        return ();
    }

    SwiftMxRecords:OrganisationIdentification39? OrgId = id?.OrgId;

    if (OrgId != ()) {
        return {
            name: "50C",
            IdnCd: {
                \#content: getEmptyStrIfNull(OrgId?.AnyBIC),
                number: "1"
            }
        };
    }

    SwiftMxRecords:PersonIdentification18? PrvtId = id?.PrvtId;

    if (PrvtId != ()) {
        SwiftMxRecords:GenericPersonIdentification2[]? Othr = id?.PrvtId?.Othr;
        
        if (Othr != () && Othr.length() > 0) {
            return {
                name: "50L",
                PrtyIdn: {
                    \#content: getEmptyStrIfNull(Othr[0].Id),
                    number: "1"
                }
            };
        }
    }


    return ();
}

isolated function getMT101OrderingCustomerFromPain001Document(SwiftMxRecords:Pain001Document document) 
returns SwiftMtRecords:MT50F? | SwiftMtRecords:MT50G? | SwiftMtRecords:MT50H? {
    return ();
}

isolated function getMT101AccountServicingInstitutionFromPain001Document(SwiftMxRecords:Pain001Document document) 
returns SwiftMtRecords:MT52A? | SwiftMtRecords:MT52C? {
    return ();
}

isolated function getMT101TransactionIntermediaryFromPain001Document(SwiftMxRecords:PaymentInstruction44 mxTransaction) 
returns SwiftMtRecords:MT56A? | SwiftMtRecords:MT56C? | SwiftMtRecords:MT56D? {
    return ();
}


isolated function getMT101TransactionAcountWithInstitution(SwiftMxRecords:PaymentInstruction44 mxTransaction) 
returns SwiftMtRecords:MT57A? | SwiftMtRecords:MT57C? | SwiftMtRecords:MT57D? {
    return ();
}

isolated function getMT101TransactionBeneficiary(SwiftMxRecords:PaymentInstruction44 mxTransaction) 
returns SwiftMtRecords:MT59 | SwiftMtRecords:MT59A? | SwiftMtRecords:MT59F? {
    return ();
}