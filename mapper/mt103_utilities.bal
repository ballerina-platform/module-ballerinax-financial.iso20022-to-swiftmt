import ballerinax/swiftmt as SwiftMtRecords;
import ballerinax/iso20022records as SwiftMxRecords;

isolated function getMT103OrderingCustomerFromPacs008Document(SwiftMxRecords:Pacs008Document document) 
returns SwiftMtRecords:MT50A? | SwiftMtRecords:MT50F? | SwiftMtRecords:MT50K? {
    return ();
}

isolated function getMT103OrderingInstitutionFromPacs008Document(SwiftMxRecords:Pacs008Document document, boolean isSTP) 
returns SwiftMtRecords:MT52A? | SwiftMtRecords:MT52D? {
    return ();
}

isolated function getMT103SendersCorrespondentFromPacs008Document(SwiftMxRecords:Pacs008Document document)
returns SwiftMtRecords:MT53A? | SwiftMtRecords:MT53B? | SwiftMtRecords:MT53D? {
    return ();
}

isolated function getMT103ReceiversCorrespondentFromPacs008Document(SwiftMxRecords:Pacs008Document document, boolean isSTP)
returns SwiftMtRecords:MT54A? | SwiftMtRecords:MT54B? | SwiftMtRecords:MT54D? {
    return ();
}

isolated function getMT103ThirdReimbursementInstitutionFromPacs008Document(SwiftMxRecords:Pacs008Document document, boolean isSTP)
returns SwiftMtRecords:MT55A? | SwiftMtRecords:MT55B? | SwiftMtRecords:MT55D? {
    return ();
}

isolated function getMT103IntermediaryInstitutionFromPacs008Document(SwiftMxRecords:Pacs008Document document, boolean isSTP)
returns SwiftMtRecords:MT56A? | SwiftMtRecords:MT56C? | SwiftMtRecords:MT56D? {
    return ();
}

isolated function getMT103AccountWithInstitutionFromPacs008Document(SwiftMxRecords:Pacs008Document document, boolean isSTP)
returns SwiftMtRecords:MT57A? | SwiftMtRecords:MT57B? | SwiftMtRecords:MT57C? | SwiftMtRecords:MT57D? {
    return ();
}


isolated function getMT103BeneficiaryCustomerFromPacs008Document(SwiftMxRecords:Pacs008Document document)
returns SwiftMtRecords:MT59? | SwiftMtRecords:MT59A? | SwiftMtRecords:MT59F? {
    return ();
}
