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

import ballerina/io;
import ballerina/test;
import ballerinax/financial.swift.mt as swiftmt;


@test:Config {
    groups: ["toSwiftMtMessage", "p2_4_2"],
    dataProvider: dataGen242
}
isolated function testP242(xml mx, string mt) returns error? {
    record{} rec = check toSwiftMtMessage(mx);
    test:assertEquals((check swiftmt:getFinMessage(rec)).toString(), mt, msg = "Use case p.2.4.2 result incorrect");
}

function dataGen242() returns map<[xml, string]>|error {
    // no mapping for pacs.010, E_B ignored
    map<[xml, string]> dataSet = {
        "B_E": [check io:fileReadXml("./tests/p_2_4_2/CBPR+ p.2.4.2 pacs.002 BtoE.xml"), finMessage_242_B_E]
    };
    return dataSet;
}

string finMessage_242_B_E = "{1:F01NDEADKK2XXXX0000000000}{2:O2990935221020BOFSGB2LXXXX00000000002210200935N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:pacs002bizmsgid+\r\n" +
    ":21:pcs010bizmsgidr1\r\n" +
    ":79:/REJT/99\r\n" +
    "/XT99/MD01/\r\n" +
    "/MREF/pcs010bizmsgidr1\r\n" +
    "/TREF/MANDATE123456\r\n" +
    "/TEXT//UETR/7a562c67-ca16-48ba-b074-65581be6f001\r\n" +
    "-}";

