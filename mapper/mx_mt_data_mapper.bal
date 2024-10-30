// Copyright (c) 2023, WSO2 LLC. (https://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

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