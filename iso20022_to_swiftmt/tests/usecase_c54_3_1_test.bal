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
    groups: ["toSwiftMtMessage", "c54_3_1"],
    dataProvider: dataGen5431
}
isolated function testC5431(xml mx, string mt) returns error? {
    record{} rec = check toSwiftMtMessage(mx);
    test:assertEquals((check swiftmt:getFinMessage(rec)).toString(), mt, msg = "Use case c.54.3.1 result incorrect");
}

function dataGen5431() returns map<[xml, string]>|error {
    map<[xml, string]> dataSet = {
        "B_A": [check io:fileReadXml("./tests/c_54_3_1/CBPR+ c.54.3.1 camt.054-BtoA.xml"), finMessage_5431_B_A]
    };
    return dataSet;
}

string finMessage_5431_B_A = "{1:F01SCBLSG22XXXX0000000000}{2:O9002000200806AWABJPJTXXXX00000000002008062000N}{4:\r\n" +
    ":20:cmt054bizmsgidr+\r\n" +
    ":21:pacs9bizmsgidr01\r\n" +
    ":25:AWA15457\r\n" +
    ":32A:200806JPY165486600,\r\n" +
    "-}";