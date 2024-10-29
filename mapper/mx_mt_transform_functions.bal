import ballerinax/iso20022records as SwiftMxRecords;

isolated map<isolated function (record {}) returns MtMessage | error> mxToMtTransformFunctionMap = {
    PAIN001 : transformPain001Message,
    PACS008 : transformPacs008Message,
    PAIN008 : transformPain008Message

    // ... Add more functions here
};

isolated function transformPain001Message(record {} mxMessage) returns MtMessage | error {
    SwiftMxRecords:Pain001Document pain001Document = <SwiftMxRecords:Pain001Document>mxMessage;
    MtMessage mtMessage = {mtTypeName: MT101, mtData: check transformPain001DocumentToMT101(pain001Document)};
    return mtMessage;
}

isolated function transformPacs008Message(record {} mxMessage) returns MtMessage | error {
    SwiftMxRecords:Pacs008Document pacs008Document = <SwiftMxRecords:Pacs008Document>mxMessage;

    match getPac008TransformType(pacs008Document) {
        MT103 => {
            return {mtTypeName: MT103, mtData: check transformPacs008DocumentToMT103(pacs008Document)};
        }
        MT103_STP => {
            return {mtTypeName: MT103_STP, mtData: check transformPacs008DocumentToMT103STP(pacs008Document)};
        }
        MT103_REMIT => {
            return {mtTypeName: MT103_REMIT, mtData: check transformPacs008DocumentToMT103REMIT(pacs008Document)};
        }
        MT102 => {
            return {mtTypeName: MT102, mtData: check transformPacs008DocumentToMT102(pacs008Document)};
        }
        MT102_STP => {
            return {mtTypeName: MT102_STP, mtData: check transformPacs008DocumentToMT102STP(pacs008Document)};
        }
    }

    return error("Unsupported PACS008 message type");
}


isolated function transformPain008Message(record {} mxMessage) returns MtMessage | error {
    SwiftMxRecords:Pain008Document pain008Document = <SwiftMxRecords:Pain008Document>mxMessage;
    MtMessage mtMessage = {mtTypeName: MT104, mtData: check transformPain008DocumentToMT104(pain008Document)};
    return mtMessage;
}
