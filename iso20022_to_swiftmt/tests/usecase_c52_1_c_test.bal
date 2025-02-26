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
    groups: ["toSwiftMtMessage", "c52_1_c"],
    dataProvider: dataGen521c
}
isolated function testC521c(xml mx, string mt) returns error? {
    record{} rec = check toSwiftMtMessage(mx);
    test:assertEquals((check swiftmt:toFinMessage(rec)).toString(), mt, msg = "Use case c.52.1.c result incorrect");
}

function dataGen521c() returns map<[xml, string]>|error {
    map<[xml, string]> dataSet = {
        "C_D": [check io:fileReadXml("./tests/c_52_1_c/CBPR+ c.52.1.c camt.052-CtoD.xml"), finMessage_521c_C_D]
    };
    return dataSet;
}

string finMessage_521c_C_D = "{1:F01VEBHIT2MXXXX0000000000}{2:O9421100201215MEDBITMMXXXX00000000002012151100N}{4:\r\n" +
    ":20:100-01\r\n" +
    ":25:48751258\r\n" +
    ":28C:50010/1\r\n" +
    ":34F:EUR0,\r\n" +
    ":13D:2012151100+0000\r\n" +
    ":61:201215C1000000,NTRFpacs008EndToEnd+\r\n" +
    "-}";