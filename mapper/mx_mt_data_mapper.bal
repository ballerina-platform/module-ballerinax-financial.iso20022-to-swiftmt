public isolated function convertToMTFinMessage(xml mxXmlMessage) returns string | error {
    // Get the MX record type name and the MX record from the MX message
    MxMessage mxMessage = check getMxRecordFromMessage(mxXmlMessage);

    // Get the transform function for the MX record type
    any transformFunction =  ();
    
    lock {
        transformFunction = mxToMtTransformFunctionMap[mxMessage.mxTypeName];
    }

    if (transformFunction is isolated function (record {}) returns MtMessage | error) {
        // Invoke the transform function
        MtMessage mtMessage = check transformFunction(mxMessage.mxData);

        return createFinMessageFromMtMessage(mtMessage);
    }

    return error("Unsupported MX message type: " + mxMessage.mxTypeName);

}