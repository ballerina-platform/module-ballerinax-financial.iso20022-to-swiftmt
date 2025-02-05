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
    groups: ["toSwiftMtMessage", "p3_1_2"],
    dataProvider: dataGen312
}
isolated function testP312(xml mx, string mt) returns error? {
    record{} rec = check toSwiftMtMessage(mx);
    test:assertEquals((check swiftmt:getFinMessage(rec)).toString(), mt, msg = "Use case p.3.1.2 result incorrect");
}

function dataGen312() returns map<[xml, string]>|error {
    map<[xml, string]> dataSet = {
        // pacs.003 and pain mappings N/A, A_B, A_Cdtr, Cdtr_A ignored
        "B_A": [check io:fileReadXml("./tests/p_3_1_2/CBPR+ p.3.1.2 pacs.002 BtoA.xml"), finMessage_312_B_A]
    };
    return dataSet;
}

string finMessage_312_B_A = "{1:F01NDEAFIHHXXXX0000000000}{2:O1991135221020RBOSGB2LXXXX00000000002210201135N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:pacs002bizmsgid+\r\n" +
    ":21:pc003bzmsgidr01\r\n" +
    ":79:/REJT/99\r\n" +
    "/XT99/AC05/\r\n" +
    "/MREF/pc003bzmsgidr01\r\n" +
    "/TREF/pain008EndToEnd+\r\n" +
    "/TEXT//UETR/7a562c67-ca16-48ba-b074-65581be6f001\r\n" +
    "-}";
