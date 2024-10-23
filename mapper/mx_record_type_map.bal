import ballerina/regex;
import ballerinax/iso20022records as SwiftMxRecords;
import ballerina/data.xmldata;

final readonly & map<typedesc<record {}>> mxRecordTypeMap = {
    PAIN001 : SwiftMxRecords:Pain001Document,
    PACS008 : SwiftMxRecords:Pacs008Document,
    PAIN008 : SwiftMxRecords:Pain008Document,
    PACS003 : SwiftMxRecords:Pacs003Document,
    CAMT050 : SwiftMxRecords:Camt050Document,
    PACS009 : SwiftMxRecords:Pacs009Document,
    PACS010 : SwiftMxRecords:Pacs010Document,
    CAMT057 : SwiftMxRecords:Camt057Document,
    CAMT054 : SwiftMxRecords:Camt054Document,
    CAMT060 : SwiftMxRecords:Camt060Document,
    CAMT053 : SwiftMxRecords:Camt053Document,
    CAMT052 : SwiftMxRecords:Camt052Document
};

final string namespaceAttributeKey = "{http://www.w3.org/2000/xmlns/}xmlns";


# Get the record type name from the MX namespace. The namespace is in the format of urn:iso:std:iso:20022:tech:xsd:<MessageType>.<Variant>.<Version>
# We are considering `<MessageType>.<Variant>` as the record type name.
# 
# + mxNamespace - The MX namespace
# + return - The record type name or an error if the namespace is not in the expected format
isolated function getMxRecordTypeNameFromMxNs(string mxNamespace) returns string | error {
    // Let's split the namespace by ':' and get the last part
    string[] namespaceParts = regex:split(mxNamespace, ":");
    string mxMessageId = namespaceParts[namespaceParts.length() - 1];

    // Message Id is made of 4 parts separated by '.'
    // <BusinessArea>.<MessageType>.<Variant>.<Version>

    string[] mxMessageIdParts = regex:split(mxMessageId, "\\.");

    // In our case <BusinessArea>.<MessageType> makes up the record type
    return mxMessageIdParts[0] + "." + mxMessageIdParts[1];
}

# Get the bal record type from the MX type name.
# 
# + mxRecordTypeName - The MX record type name
# + return - The record type or an error if the record type is not supported
isolated function getMxRecordTypeFromTypeName(string mxRecordTypeName) returns typedesc<record {}> | error {
    typedesc<record {}>? result = ();
    
    result = mxRecordTypeMap[mxRecordTypeName];
    
    if (result is typedesc<record {}>) {
        return result;
    }

    return error("Unsupported MX message type: " + mxRecordTypeName);
}




# Get the MX record from the MX message.
# 
# + mxMessage - The MX message
# + return - The MX record or an error if the MX message does not contain a namespace attribute
isolated function getMxRecordFromMessage(xml mxMessage) returns MxMessage | error {
    // Extract the document tag
    xml:Element documentTag = check mxMessage.strip().get(0).ensureType();

    if (documentTag.getAttributes().hasKey(namespaceAttributeKey)) {
        // Extract the namespace attribute
        string mxMessageNamespace = documentTag.getAttributes().get(namespaceAttributeKey).toString();
        
        string mxRecordTypeName = check getMxRecordTypeNameFromMxNs(mxMessageNamespace);
        typedesc<record {}> recordType = check getMxRecordTypeFromTypeName(mxRecordTypeName);

        record{} data = check xmldata:parseAsType(mxMessage, t = recordType);
        return { mxTypeName : mxRecordTypeName, mxData : data };
    }

    return error("MX message does not contain a namespace attribute");
}
