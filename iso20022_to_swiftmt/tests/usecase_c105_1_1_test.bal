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
    groups: ["toSwiftMtMessage", "c105_1_1"],
    dataProvider: dataGen10511
}
isolated function testC10511(xml mx, string mt) returns error? {
    record{} rec = check toSwiftMtMessage(mx);
    test:assertEquals((check swiftmt:getFinMessage(rec)).toString(), mt, msg = "Use case c.105.1.1 result incorrect");
}

function dataGen10511() returns map<[xml, string]>|error {
    map<[xml, string]> dataSet = {
        "c053_B_A": [check io:fileReadXml("./tests/c_105_1_1/CBPR+ c.105.1.1 camt.053-BtoA.xml"), finMessage_10511_c53_B_A],
        "c105_B_A": [check io:fileReadXml("./tests/c_105_1_1/CBPR+ c.105.1.1 camt.105-BtoA.xml"), finMessage_10511_c105_B_A],
        "p008_A_B": [check io:fileReadXml("./tests/c_105_1_1/CBPR+ c.105.1.1 pacs.008 AtoB.xml"), finMessage_10511_p008_A_B]
    };
    return dataSet;
}

string finMessage_10511_c53_B_A = "{1:F01CBRLGB2LXXXX0000000000}{2:O9401000221020RBOSGBCHXXXX00000000002210201000N}{4:\r\n" +
    ":20:100-01\r\n" +
    ":25:48751258\r\n" +
    ":28C:1001/1\r\n" +
    ":60F:D221020GBP10,\r\n" +
    ":61:221020D2450,NTRFpacs008bzmsgid-1\r\n" +
    ":61:221020D10,NTRFpacs008bzmsgid-1\r\n" +
    ":62F:D221020GBP2470,\r\n" +
    "-}";

string finMessage_10511_c105_B_A = "{1:F01CBRLGB2LXXXX0000000000}{2:O1901020221020RBOSGBCHXXXX00000000002210201020N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:camt105chrgid1\r\n" +
    ":21:pacs008bzmsgid-1\r\n" +
    ":25:48751258\r\n" +
    ":32D:221020GBP10,\r\n" +
    ":71B:/NSTP/GBP10,/D\r\n" +
    ":72:/CHRQ/RBOSGBCHXXX\r\n" +
    "-}";

string finMessage_10511_p008_A_B = "{1:F01RBOSGBCHXXXX0000000000}{2:O1030925221020CBRLGB2LXXXX00000000002210200925N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:pacs008bzmsgid-1\r\n" +
    ":23B:CRED\r\n" +
    ":32A:221020GBP2450,\r\n" +
    ":33B:GBP2450,\r\n" +
    ":50F:/25698745\r\n" +
    "1/S Baldrick\r\n" +
    "2/10 Bean Street\r\n" +
    "3/GB/London\r\n" +
    ":52A:CBRLGB2LXXX\r\n" +
    ":56A:DEUTGB2LXXX\r\n" +
    ":57A:DEUTDEFFXXX\r\n" +
    ":59F:/65479512\r\n" +
    "1/A Tate\r\n" +
    "2/9 Dimitrie\r\n" +
    "3/RO/Bucharest\r\n" +
    ":70:/ROC/pacs008EndToEndId-001\r\n" +
    ":71A:OUR\r\n" +
    "-}";
