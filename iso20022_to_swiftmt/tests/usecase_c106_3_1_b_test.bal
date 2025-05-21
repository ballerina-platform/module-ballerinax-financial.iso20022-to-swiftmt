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
    groups: ["toSwiftMtMessage", "c106_3_1_b"],
    dataProvider: dataGen10631b
}
isolated function testC10631b(xml mx, string mt) returns error? {
    record{} rec = check toSwiftMtMessage(mx);
    test:assertEquals((check swiftmt:toFinMessage(rec)).toString(), mt, msg = "Use case c.106.3.1.b result incorrect");
}

function dataGen10631b() returns map<[xml, string]>|error {
    map<[xml, string]> dataSet = {
        "c106_B_A": [check io:fileReadXml("./tests/c_106_3_1_b/CBPR+ c.106.3.1.b camt.106-BtoA.xml"), finMessage_10631b_c106_B_A],
        "c106_C_B": [check io:fileReadXml("./tests/c_106_3_1_b/CBPR+ c.106.3.1.b camt.106-CtoB.xml"), finMessage_10631b_c106_C_B],
        "c106_D_C": [check io:fileReadXml("./tests/c_106_3_1_b/CBPR+ c.106.3.1.b camt.106-DtoC.xml"), finMessage_10631b_c106_D_C]
    };
    return dataSet;
}

string finMessage_10631b_c106_B_A = "{1:F01MYMBGB2LXXXX0000000000}{2:O1911020221020INGBROBUXXXX00000000002210201020N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:camt106chrgid1\r\n" +
    ":21:pacs008bzmsgid-1\r\n" +
    ":32B:RON15,\r\n" +
    ":52A:MYMBGB2LXXX\r\n" +
    ":71B:/OURC/RON15,/D\r\n" +
    ":72:/CHRQ/GEBABEBBXXX\r\n" +
    "-}";

string finMessage_10631b_c106_C_B = "{1:F01INGBROBUXXXX0000000000}{2:O1911020221020RZBRROBUXXXX00000000002210201020N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:camt106chrgid1\r\n" +
    ":21:pcs008bzmsgid-2\r\n" +
    ":32B:RON15,\r\n" +
    ":52A:MYMBGB2LXXX\r\n" +
    ":71B:/OURC/RON15,/D\r\n" +
    ":72:/CHRQ/GEBABEBBXXX\r\n" +
    "-}";

string finMessage_10631b_c106_D_C = "{1:F01RZBRROBUXXXX0000000000}{2:O1911020221020GEBABEBBXXXX00000000002210201020N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:camt106chrgid1\r\n" +
    ":21:pcs008bzmsgid-3\r\n" +
    ":32B:RON15,\r\n" +
    ":52A:MYMBGB2LXXX\r\n" +
    ":71B:/OURC/RON15,/D\r\n" +
    ":72:/CHRQ/GEBABEBBXXX\r\n" +
    "-}";
