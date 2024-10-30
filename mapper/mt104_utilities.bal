import ballerinax/swiftmt as SwiftMtRecords;
import ballerinax/iso20022records as SwiftMxRecords;

# Get the instructing party from the Pain008 document.
# 
# + document - The Pain008 document
# + return - The instructing party or an empty record
isolated function getMT104InstructionPartyFromPain008Document(SwiftMxRecords:Pain008Document document) 
returns SwiftMtRecords:MT50C? | SwiftMtRecords:MT50L? {
    return ();
}

# Get the ordering customer from the Pain008 document.
# 
# + document - The Pain008 document
# + return - The ordering customer or an empty record
isolated function getMT104CreditorFromPain008Document(SwiftMxRecords:Pain008Document document) 
returns SwiftMtRecords:MT50A? | SwiftMtRecords:MT50K? {
    return ();
}

# Get the account servicing institution from the Pain008 document.
# 
# + document - The Pain008 document
# + return - The account servicing institution or an empty record
isolated function getMT104CreditorsBankFromPain008Document(SwiftMxRecords:Pain008Document document) 
returns SwiftMtRecords:MT52A? | SwiftMtRecords:MT52C? | SwiftMtRecords:MT52D? {
    return ();
}

# Get the transaction debtor from the Pain008 document.
# 
# + mxTransaction - The MX transaction
# + return - The transaction debtor or an empty record
isolated function getMT104TransactionDebtorsBankFromPain008Document(SwiftMxRecords:PaymentInstruction45 mxTransaction) 
returns SwiftMtRecords:MT57A? | SwiftMtRecords:MT57C? | SwiftMtRecords:MT57D? {
    return ();
}

# Get the transaction debtor from the Pain008 document.
# 
# + mxTransaction - The MX transaction
# + return - The transaction debtor or an empty record
isolated function getMT104TransactionDebtorFromPain008Document(SwiftMxRecords:PaymentInstruction45 mxTransaction) 
returns SwiftMtRecords:MT59? | SwiftMtRecords:MT59A? {
    return ();
}

# Get the senders correspondent from the Pain008 document.
# 
# + document - The Pain008 document
# + return - The senders correspondent or an empty record
isolated function getMT104SendersCorrespondentFromPain008Document(SwiftMxRecords:Pain008Document document)
returns SwiftMtRecords:MT53A? | SwiftMtRecords:MT53B? {
    return ();
}