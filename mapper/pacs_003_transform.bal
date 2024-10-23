import ballerinax/swiftmt as SwiftMtRecords;
import ballerinax/iso20022records as SwiftMxRecords;

isolated function getPacs003TransformType(SwiftMxRecords:Pacs003Document document) returns string {
    return MT104;
}

isolated function transformPacs003DocumentToMT104(SwiftMxRecords:Pacs003Document document) returns SwiftMtRecords:MT104Message | error {
    return error("Not implemented");
}

isolated function transformPacs003DocumentToMT107(SwiftMxRecords:Pacs003Document document) returns SwiftMtRecords:MT107Message | error {
    return error("Not implemented");
}
