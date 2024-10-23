import ballerinax/swiftmt as SwiftMtRecords;
import ballerinax/iso20022records as SwiftMxRecords;

isolated function getMT104InstructionPartyFromPain008Document(SwiftMxRecords:Pain008Document document) 
returns SwiftMtRecords:MT50C? | SwiftMtRecords:MT50L? {
    return ();
}

isolated function getMT104CreditorFromPain008Document(SwiftMxRecords:Pain008Document document) 
returns SwiftMtRecords:MT50A? | SwiftMtRecords:MT50K? {
    return ();
}

isolated function getMT104CreditorsBankFromPain008Document(SwiftMxRecords:Pain008Document document) 
returns SwiftMtRecords:MT52A? | SwiftMtRecords:MT52C? | SwiftMtRecords:MT52D? {
    return ();
}

isolated function getMT104TransactionDebtorsBankFromPain008Document(SwiftMxRecords:PaymentInstruction45 mxTransaction) 
returns SwiftMtRecords:MT57A? | SwiftMtRecords:MT57C? | SwiftMtRecords:MT57D? {
    return ();
}

isolated function getMT104TransactionDebtorFromPain008Document(SwiftMxRecords:PaymentInstruction45 mxTransaction) 
returns SwiftMtRecords:MT59? | SwiftMtRecords:MT59A? {
    return ();
}

isolated function getMT104SendersCorrespondentFromPain008Document(SwiftMxRecords:Pain008Document document)
returns SwiftMtRecords:MT53A? | SwiftMtRecords:MT53B? {
    return ();
}