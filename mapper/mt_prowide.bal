import ballerina/xmldata;

# Convert the MT record xml to Prowide XML
# 
# + input - The MT record xml
# + return - The Prowide XML or an error if the conversion fails
isolated function convertToProwideXML(xml input) returns xml | error {
    // TODO : Implement the function
    return input;
}

# Convert the Prowide XML to Fin message
# 
# + input - The Prowide XML
# + return - The Fin message or an error if the conversion fails
isolated function convertToFinMessageFromProwideXML(xml input) returns string | error {
    // TODO : Implement the function
    return input.toString();
}

# Create the Fin message from the MT message
# 
# + mtMessage - The MT message
# + return - The Fin message or an error if the conversion fails
isolated function createFinMessageFromMtMessage(MtMessage mtMessage) returns string | error {

    xml mtMessageXML = check xmldata:toXml(mtMessage.mtData);

    xml prowideXML = check convertToProwideXML(mtMessageXML);

    return convertToFinMessageFromProwideXML(prowideXML);
}