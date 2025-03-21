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
    groups: ["toSwiftMtMessage", "c106_1_2"],
    dataProvider: dataGen10612
}
isolated function testC10612(xml mx, string mt) returns error? {
    record{} rec = check toSwiftMtMessage(mx);
    test:assertEquals((check swiftmt:toFinMessage(rec)).toString(), mt, msg = "Use case c.106.1.2 result incorrect");
}

function dataGen10612() returns map<[xml, string]>|error {
    map<[xml, string]> dataSet = {
        "c106_D_A": [check io:fileReadXml("./tests/c_106_1_2/CBPR+ c.106.1.2 camt.106-DtoA.xml"), finMessage_10612_c106_D_A],
        "c106_D_Aalt": [check io:fileReadXml("./tests/c_106_1_2/CBPR+ c.106.1.2 camt.106Altered-DtoA.xml"), finMessage_10612_c106_D_Aalt]
    };
    return dataSet;
}

string finMessage_10612_c106_D_A = "{1:F01MYMBGB2LXXXX0000000000}{2:O1911020221020GEBABEBBXXXX00000000002210201020N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:camt106chrgid1\r\n" +
    ":21:pacs008bzmsgid-1\r\n" +
    ":32B:RON15,\r\n" +
    ":52A:MYMBGB2LXXX\r\n" +
    ":71B:/OURC/RON15,/D\r\n" +
    ":72:/CHRQ/GEBABEBBXXX\r\n" +
    "-}";

string finMessage_10612_c106_D_Aalt = "{1:F01MYMBGB2LXXXX0000000000}{2:O2911020221020GEBABEBBXXXX00000000002210201020N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:camt106chrgid1\r\n" +
    ":21:pacs008bzmsgid-1\r\n" +
    ":32B:RON15,\r\n" +
    ":52A:MYMBGB2LXXX\r\n" +
    ":71B:/OURC/RON15,/D\r\n" +
    ":72:/CHRQ/GEBABEBBXXX\r\n" +
    "-}";
