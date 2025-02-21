// Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com).
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

import ballerina/data.xmldata;

# Converts an ISO 20022 XML message to its corresponding SWIFT MT message format.
#
# The function uses a map of transformation functions for different ISO 20022 message types
# and applies the appropriate transformation based on the provided XML content and target SWIFT MT message type.
#
# + xmlContent - The ISO 20022 XML content that needs to be converted.
# + return - Returns the transformed SWIFT MT message as a record value or an error if the conversion fails.
public isolated function toSwiftMtMessage(xml xmlContent) returns record {}|error {
    xml:Element document = xml `<Empty/>`;
    foreach xml:Element element in xmlContent.elementChildren() {
        if element.getName().includes("Document") {
            document = element;
        }
    }
    map<string> attributeMap = (document).getAttributes();
    if attributeMap.length() == 0 {
        return error("Invalid xml: Cannot be converted to SWIFT MT message.");
    }
    string isoRecordType = "";
    typedesc<record {}>? isoEnvelope = ();
    boolean isNameSpacePresent = false;
    foreach string attributeKey in attributeMap.keys() {
        if attributeKey.includes("xmlns") {
            isNameSpacePresent = true;
            foreach string recordKey in isoMessageTypes.keys() {
                string? nameSpace = attributeMap[attributeKey];
                if nameSpace is string && nameSpace.includes(recordKey) {
                    isoEnvelope = isoMessageTypes[recordKey];
                    isoRecordType = recordKey;
                    break;
                }
            }
        }
    }
    if !isNameSpacePresent {
        return error("Invalid xml: Cannot be converted to SWIFT MT message.");
    }
    if isoEnvelope is () {
        return error("ISO 20022 message type is not supported.");
    }

    return getTransformFunction(isoRecordType, check xmldata:parseAsType(xmlContent, {textFieldName: "content"}, isoEnvelope)).ensureType();
}
