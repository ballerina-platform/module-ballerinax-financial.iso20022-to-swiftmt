import ballerina/xmldata;

isolated function convertToProwideXML(xml input) returns xml | error {
    // TODO : Implement the function
    return input;
}

isolated function convertToFinMessageFromProwideXML(xml input) returns string | error {
    // TODO : Implement the function
    return input.toString();
}

isolated function createFinMessageFromMtMessage(MtMessage mtMessage) returns string | error {

    xml mtMessageXML = check xmldata:toXml(mtMessage.mtData);

    xml prowideXML = check convertToProwideXML(mtMessageXML);

    return convertToFinMessageFromProwideXML(prowideXML);
}