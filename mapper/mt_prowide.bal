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