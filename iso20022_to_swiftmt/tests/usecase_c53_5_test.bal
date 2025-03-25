// Copyright (c) 2025, WSO2 LLC. (https://www.wso2.com).
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

import ballerina/io;
import ballerina/test;
import ballerinax/financial.swift.mt as swiftmt;

@test:Config {
    groups: ["toSwiftMtMessage", "c53_5"],
    dataProvider: dataGen535
}
isolated function testC535(xml mx, string mt) returns error? {
    record{} rec = check toSwiftMtMessage(mx);
    test:assertEquals((check swiftmt:toFinMessage(rec)).toString(), mt, msg = "Use case c.53.5 result incorrect");
}

function dataGen535() returns map<[xml, string]>|error {
    map<[xml, string]> dataSet = {
        "A_B_nonEU": [check io:fileReadXml("./tests/c_53_5/CBPR+ c.53.5 pacs.008 AtoB.xml"), finMessage_535A_B]
    };
    return dataSet;
}

string finMessage_535A_B = "{1:F01DBSSSGSGXXXX0000000000}{2:O1030905200805WPACAU2SXXXX00000000002008050905N}{3:{121:174c245f-2682-4291-ad67-2a41e530cd27}}{4:\r\n" +
    ":20:pacs8bizmsgidr01\r\n" +
    ":23B:CRED\r\n" +
    ":32A:200805SGD500000,\r\n" +
    ":50F:/458756241\r\n" +
    "1/Australian Submarine\r\n" +
    "2/694 Mersey Rd\r\n" +
    "3/AU/Adelaide\r\n" +
    ":52A:WPACAU2S\r\n" +
    ":56A:DBSSSGSG\r\n" +
    ":57A:UOVBSGSG\r\n" +
    ":59F:/985412687\r\n" +
    "1/Agoda Company\r\n" +
    "2/30 Cecil Street\r\n" +
    "3/SG/Singapore\r\n" +
    ":70:/ROC/E2E04044506271305\r\n" +
    ":71A:OUR\r\n" +
    "-}";
