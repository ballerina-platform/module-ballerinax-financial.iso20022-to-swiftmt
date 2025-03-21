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
    groups: ["toSwiftMtMessage", "c106_2_1_1"],
    dataProvider: dataGen10621a
}
isolated function testC10621a(xml mx, string mt) returns error? {
    record{} rec = check toSwiftMtMessage(mx);
    test:assertEquals((check swiftmt:toFinMessage(rec)).toString(), mt, msg = "Use case c.106.2.1.a result incorrect");
}

function dataGen10621a() returns map<[xml, string]>|error {
    map<[xml, string]> dataSet = {
        "c106_C_B": [check io:fileReadXml("./tests/c_106_2_1_a/CBPR+ c.106.2.1.a camt.106-CtoB.xml"), finMessage_10621a_c106_C_B],
        "p008_A_B": [check io:fileReadXml("./tests/c_106_2_1_a/CBPR+ c.106.2.1.a pacs.008 AtoB.xml"), finMessage_10621a_p008_A_B],
        "p008_B_C": [check io:fileReadXml("./tests/c_106_2_1_a/CBPR+ c.106.2.1.a pacs.008 BtoC.xml"), finMessage_10621a_p008_B_C],
        "p008_C_D": [check io:fileReadXml("./tests/c_106_2_1_a/CBPR+ c.106.2.1.a pacs.008 CtoD.xml"), finMessage_10621a_p008_C_D],
        "p009_B_C": [check io:fileReadXml("./tests/c_106_2_1_a/CBPR+ c.106.2.1.a pacs.009 BtoC.xml"), finMessage_10621a_p009_B_C]
    };
    return dataSet;
}

string finMessage_10621a_c106_C_B = "{1:F01INGBROBUXXXX0000000000}{2:O1911020221020RZBRROBUXXXX00000000002210201020N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:camt106chrgid1\r\n" +
    ":21:pcs008bzmsgid-2\r\n" +
    ":32B:RON15,\r\n" +
    ":52A:MYMBGB2LXXX\r\n" +
    ":71B:/OURC/RON15,/D\r\n" +
    ":72:/CHRQ/RZBRROBUXXX\r\n" +
    "-}";

string finMessage_10621a_p008_A_B = "{1:F01INGBROBUXXXX0000000000}{2:O1030925221020MYMBGB2LXXXX00000000002210200925N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:pacs008bzmsgid-1\r\n" +
    ":23B:CRED\r\n" +
    ":32A:221020RON65784,32\r\n" +
    ":33B:RON65784,32\r\n" +
    ":50F:/25698745\r\n" +
    "1/S Baldrick\r\n" +
    "2/10 Bean Street\r\n" +
    "3/GB/London\r\n" +
    ":52A:MYMBGB2LXXX\r\n" +
    ":56A:RZBRROBUXXX\r\n" +
    ":57A:GEBABEBBXXX\r\n" +
    ":59F:/65479512\r\n" +
    "1/A Tate\r\n" +
    "2/9 Dimitrie\r\n" +
    "3/RO/Bucharest\r\n" +
    ":70:/ROC/pacs008EndToEndId-001\r\n" +
    ":71A:OUR\r\n" +
    "-}";

string finMessage_10621a_p008_B_C = "{1:F01RZBRROBUXXXX0000000000}{2:O1030955221020INGBROBUXXXX00000000002210200955N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:pcs008bzmsgid-2\r\n" +
    ":23B:CRED\r\n" +
    ":32A:221020RON65784,32\r\n" +
    ":33B:RON65784,32\r\n" +
    ":50F:/25698745\r\n" +
    "1/S Baldrick\r\n" +
    "2/10 Bean Street\r\n" +
    "3/GB/London\r\n" +
    ":52A:MYMBGB2LXXX\r\n" +
    ":57A:GEBABEBBXXX\r\n" +
    ":59F:/65479512\r\n" +
    "1/A Tate\r\n" +
    "2/9 Dimitrie\r\n" +
    "3/RO/Bucharest\r\n" +
    ":70:/ROC/pacs008EndToEndId-001\r\n" +
    ":71A:OUR\r\n" +
    "-}";

string finMessage_10621a_p008_C_D = "{1:F01GEBABEBBXXXX0000000000}{2:O1030955221020RZBRROBUXXXX00000000002210200955N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:pcs008bzmsgid-3\r\n" +
    ":23B:CRED\r\n" +
    ":32A:221020RON65784,32\r\n" +
    ":33B:RON65784,32\r\n" +
    ":50F:/25698745\r\n" +
    "1/S Baldrick\r\n" +
    "2/10 Bean Street\r\n" +
    "3/GB/London\r\n" +
    ":52A:MYMBGB2LXXX\r\n" +
    ":57A:GEBABEBBXXX\r\n" +
    ":59F:/65479512\r\n" +
    "1/A Tate\r\n" +
    "2/9 Dimitrie\r\n" +
    "3/RO/Bucharest\r\n" +
    ":70:/ROC/pacs008EndToEndId-001\r\n" +
    ":71A:OUR\r\n" +
    ":72:/INS/INGBROBUXXX\r\n" +
    "-}";

string finMessage_10621a_p009_B_C = "{1:F01RZBRROBUXXXX0000000000}{2:O2020945221020INGBROBUXXXX00000000002210200945N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f002}}{4:\r\n" +
    ":20:pacs9bizmsgidr01\r\n" +
    ":21:camt106chrgid1\r\n" +
    ":32A:221020RON15,\r\n" +
    ":52A:INGBROBUXXX\r\n" +
    ":58A:RZBRROBUXXX\r\n" +
    "-}";
