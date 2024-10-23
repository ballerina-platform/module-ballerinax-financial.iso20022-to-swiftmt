import ballerinax/swiftmt as SwiftMtRecords;
import ballerinax/iso20022records as SwiftMxRecords;

isolated function getMT102OrderingCustomerFromPacs008Document(SwiftMxRecords:Pacs008Document document) 
returns SwiftMtRecords:MT50A? | SwiftMtRecords:MT50F? | SwiftMtRecords:MT50K? {
    return ();
}

isolated function getMT102OrderingInstitutionFromPacs008Document(SwiftMxRecords:Pacs008Document document, boolean isSTP) 
returns SwiftMtRecords:MT52A? | SwiftMtRecords:MT52B? | SwiftMtRecords:MT52C? {
    return ();
}

isolated function getMT102TransactionAccountWithInstitutionFromPacs008Document(SwiftMxRecords:CreditTransferTransaction64 mxTransaction, boolean isSTP)
returns SwiftMtRecords:MT57A? | SwiftMtRecords:MT57C? {
    return ();
}


isolated function getMT102TransactionBeneficiaryCustomerFromPacs008Document(SwiftMxRecords:CreditTransferTransaction64 mxTransaction)
returns SwiftMtRecords:MT59? | SwiftMtRecords:MT59A? | SwiftMtRecords:MT59F? {
    return ();
}

isolated function getMT102SendersCorrespondentFromPacs008Document(SwiftMxRecords:Pacs008Document document)
returns SwiftMtRecords:MT53A? | SwiftMtRecords:MT53C? {
    return ();
}
