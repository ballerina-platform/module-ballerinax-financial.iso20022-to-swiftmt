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
    groups: ["toSwiftMtMessage", "c58_1_2"],
    dataProvider: dataGen5812
}
isolated function testC5812(xml mx, string mt) returns error? {
    record{} rec = check toSwiftMtMessage(mx);
    test:assertEquals((check swiftmt:toFinMessage(rec)).toString(), mt, msg = "Use case c.58.1.2 result incorrect");
}

function dataGen5812() returns map<[xml, string]>|error {
    map<[xml, string]> dataSet = {
        "c58": [check io:fileReadXml("./tests/c_58_1_2/CBPR+ c.58.1.2 camt.058 CdtrtoC.xml"), finMessage_5812_c58_Cdtr_C],
        "c57": [check io:fileReadXml("./tests/c_58_1_2/CBPR+ c.58.1.2 camt.057-CdtrtoC.xml"), finMessage_5812_c57_Cdtr_C]
    };
    return dataSet;
}

string finMessage_5812_c58_Cdtr_C = "{1:F01NDEAFIHHXXXX0000000000}{2:O2920735221020OKOYFIHHXXXX00000000002210200735N}{4:\r\n" +
    ":20:cmt058bizmsgidr1\r\n" +
    ":21:ITM-021\r\n" +
    ":11S:210\r\n" +
    "221020\r\n" +
    ":79:/NOLE/\r\n" +
    ":32B:EUR125650,\r\n" +
    "-}";

string finMessage_5812_c57_Cdtr_C = "{1:F01NDEAFIHHXXXX0000000000}{2:O2100725221020OKOYFIHHXXXX00000000002210200725N}{4:\r\n" +
    ":20:cmt057bizmsgidr+\r\n" +
    ":25:25698745\r\n" +
    ":30:221025\r\n" +
    ":21:ITM-021\r\n" +
    ":32B:EUR125650,\r\n" +
    ":52A:CNORGB22\r\n" +
    "-}";
