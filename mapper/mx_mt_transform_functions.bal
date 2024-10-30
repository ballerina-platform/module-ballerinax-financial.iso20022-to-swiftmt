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

import ballerinax/iso20022records as SwiftMxRecords;

# This map contains the functions pointers to transform functions for each MX message type
final readonly & map<isolated function (record {}) returns MtMessage | error> mxToMtTransformFunctionMap = {
    PAIN001 : transformPain001Message,
    PACS008 : transformPacs008Message,
    PAIN008 : transformPain008Message

    // ... Add more functions here
};

# Transform the Pain001 message to Swift MT message
# 
# + mxMessage - The MX message record
# + return - The MT message or an error if the transformation fails
isolated function transformPain001Message(record {} mxMessage) returns MtMessage | error {
    SwiftMxRecords:Pain001Document pain001Document = <SwiftMxRecords:Pain001Document>mxMessage;
    MtMessage mtMessage = {mtTypeName: MT101, mtData: check transformPain001DocumentToMT101(pain001Document)};
    return mtMessage;
}

# Transform the Pacs008 message to Swift MT message
# 
# + mxMessage - The MX message record
# + return - The MT message or an error if the transformation fails
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

# Transform the Pain008 message to Swift MT message
# 
# + mxMessage - The MX message record
# + return - The MT message or an error if the transformation fails
isolated function transformPain008Message(record {} mxMessage) returns MtMessage | error {
    SwiftMxRecords:Pain008Document pain008Document = <SwiftMxRecords:Pain008Document>mxMessage;
    MtMessage mtMessage = {mtTypeName: MT104, mtData: check transformPain008DocumentToMT104(pain008Document)};
    return mtMessage;
}
