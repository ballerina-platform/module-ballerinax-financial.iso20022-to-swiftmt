# This Ballerina program demonstrates how to map an MX message to an MT message using a transform function.
# The transform function is selected based on the MX message type.
# 
# + mxXmlMessage - The MX message in XML format.
# + return - The MT message in string format.
public isolated function convertToMTFinMessage(xml mxXmlMessage) returns string | error {
    // Get the MX record type name and the MX record from the MX message
    MxMessage mxMessage = check getMxRecordFromMessage(mxXmlMessage);

    // Get the transform function for the MX record type
    any transformFunction =  ();
    
    transformFunction = mxToMtTransformFunctionMap[mxMessage.mxTypeName];
    
    if (transformFunction is isolated function (record {}) returns MtMessage | error) {
        // Invoke the transform function
        MtMessage mtMessage = check transformFunction(mxMessage.mxData);

        return createFinMessageFromMtMessage(mtMessage);
    }

    return error("Unsupported MX message type: " + mxMessage.mxTypeName);

}