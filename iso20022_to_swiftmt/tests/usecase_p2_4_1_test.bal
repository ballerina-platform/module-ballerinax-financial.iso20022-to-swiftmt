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
    groups: ["toSwiftMtMessage", "p2_4_1"],
    dataProvider: dataGen241
}
isolated function testP241(xml mx, string mt) returns error? {
    record{} rec = check toSwiftMtMessage(mx);
    test:assertEquals((check swiftmt:toFinMessage(rec)).toString(), mt, msg = "Use case p.2.4.1 result incorrect");
}

function dataGen241() returns map<[xml, string]>|error {
    map<[xml, string]> dataSet = {
        // Use Case p_2_4_1/CBPR+ p_2_4_1/CBPR+ p.2.4.1 pacs.002 BtoE.xml not translated in SWIFT translation portal &&
        // no mapping for pacs.010, E_B ignored
        "D_E": [check io:fileReadXml("./tests/p_2_4_1/CBPR+ p.2.4.1 camt.053-DtoE.xml"), finMessage_241_D_E],
        "B_C": [check io:fileReadXml("./tests/p_2_4_1/CBPR+ p.2.4.1 pacs.009-BtoC.xml"), finMessage_241_B_C],
        "C_D": [check io:fileReadXml("./tests/p_2_4_1/CBPR+ p.2.4.1 pacs.009-CtoD.xml"), finMessage_241_C_D]
    };
    return dataSet;
}

string finMessage_241_D_E = "{1:F01BANODKKKXXXX0000000000}{2:O9401100221020AAKRDK22XXXX00000000002210201100N}{4:\r\n" +
    ":20:100-01\r\n" +
    ":25:65479512\r\n" +
    ":28C:1001/1\r\n" +
    ":60F:D221020DKK8547,25\r\n" +
    ":61:221020C350000,NTRFpacs010EndToEnd+\r\n" +
    ":62F:C221020DKK341452,75\r\n" +
    "-}";

string finMessage_241_B_C = "{1:F01AAKRDK22XXXX0000000000}{2:O2020935221020BOFSGB2LXXXX00000000002210200935N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:pacs9bizmsgidr02\r\n" +
    ":21:pacs010EndToEnd+\r\n" +
    ":32A:221020DKK350000,\r\n" +
    ":52A:/87545213\r\n" +
    "CLYDGB2S\r\n" +
    ":57A:BANODKKK\r\n" +
    ":58A:/75315985\r\n" +
    "NDEADKK2XXX\r\n" +
    ":72:/INS/BOFSGB2L\r\n" +
    "-}";

string finMessage_241_C_D = "{1:F01BANODKKKXXXX0000000000}{2:O2020845221020AAKRDK22XXXX00000000002210200845N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:pacs9bizmsgidr03\r\n" +
    ":21:pacs010EndToEnd+\r\n" +
    ":32A:221020DKK350000,\r\n" +
    ":52A:/87545213\r\n" +
    "CLYDGB2S\r\n" +
    ":57A:BANODKKK\r\n" +
    ":58A:/75315985\r\n" +
    "NDEADKK2XXX\r\n" +
    ":72:/INS/BOFSGB2L\r\n" +
    "-}";