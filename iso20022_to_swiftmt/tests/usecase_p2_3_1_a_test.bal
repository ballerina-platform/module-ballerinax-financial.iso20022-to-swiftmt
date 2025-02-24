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
    groups: ["toSwiftMtMessage", "p2_3_1_a"],
    dataProvider: dataGen231a
}
isolated function testP231a(xml mx, string mt) returns error? {
    record{} rec = check toSwiftMtMessage(mx);
    test:assertEquals((check swiftmt:getFinMessage(rec)).toString(), mt, msg = "Use case p.2.3.1 result incorrect");
}

function dataGen231a() returns map<[xml, string]>|error {
    map<[xml, string]> dataSet = {
        "C_D": [check io:fileReadXml("./tests/p_2_3_1_a/CBPR+ p.2.3.1.a camt.053-CtoD.xml"), finMessage_231a_C_D],
        "D_A": [check io:fileReadXml("./tests/p_2_3_1_a/CBPR+ p.2.3.1.a pacs.002 DtoA.xml"), finMessage_231a_D_A],
        "B_A": [check io:fileReadXml("./tests/p_2_3_1_a/CBPR+ p.2.3.1.a pacs.004-BtoA.xml"), finMessage_231a_B_A],
        "C_B": [check io:fileReadXml("./tests/p_2_3_1_a/CBPR+ p.2.3.1.a pacs.004-CtoB.xml"), finMessage_231a_C_B],
        "D_C": [check io:fileReadXml("./tests/p_2_3_1_a/CBPR+ p.2.3.1.a pacs.004-DtoC.xml"), finMessage_231a_D_C],
        "A_D": [check io:fileReadXml("./tests/p_2_3_1_a/CBPR+ p.2.3.1.a pacs.008 AtoD.xml"), finMessage_231a_A_D],
        "A_B": [check io:fileReadXml("./tests/p_2_3_1_a/CBPR+ p.2.3.1.a pacs.009.cov-AtoB.xml"), finMessage_231a_A_B],
        "B_C": [check io:fileReadXml("./tests/p_2_3_1_a/CBPR+ p.2.3.1.a pacs.009.cov-BtoC.xml"), finMessage_231a_B_C]
    };
    return dataSet;
}

string finMessage_231a_C_D = "{1:F01CAIXESBBXXXX0000000000}{2:O9401100221020BSCHESMMXXXX00000000002210201100N}{4:\r\n" +
    ":20:100-01\r\n" +
    ":25:48751258\r\n" +
    ":28C:1001/1\r\n" +
    ":60F:D221020EUR8547,25\r\n" +
    ":61:221020C65784,32NTRFpacs008EndToEnd+\r\n" +
    ":62F:C221020EUR57237,07\r\n" +
    "-}";

string finMessage_231a_A_D = "{1:F01CAIXESBBXXXX0000000000}{2:O1030925221020CLYDGB2SXXXX00000000002210200925N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:pcs008bzmsgidr-1\r\n" +
    ":23B:CRED\r\n" +
    ":32A:221020EUR65784,32\r\n" +
    ":33B:EUR65784,32\r\n" +
    ":50F:/25698745\r\n" +
    "1/A Debiter\r\n" +
    "2/High Street\r\n" +
    "3/GB/Epping\r\n" +
    ":52A:CLYDGB2S\r\n" +
    ":53A:BOFSGB2L\r\n" +
    ":54A:BSCHESMM\r\n" +
    ":57A:BSCHESMM\r\n" +
    ":59F:/65479512\r\n" +
    "1/B Creditor Co\r\n" +
    "2/Las Ramblas\r\n" +
    "3/ES/Barcelona\r\n" +
    ":70:/ROC/pacs008EndToEndId-001\r\n" +
    ":71A:OUR\r\n" +
    "-}";

string finMessage_231a_D_A = "{1:F01CLYDGB2SXXXX0000000000}{2:O1990825221020CAIXESBBXXXX00000000002210200825N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:pacs002bizmsgid+\r\n" +
    ":21:pcs008bzmsgidr-1\r\n" +
    ":79:/REJT/99\r\n" +
    "/AC04/\r\n" +
    "/MREF/pcs008bzmsgidr-1\r\n" +
    "/TREF/pacs008EndToEnd+\r\n" +
    "/TEXT//UETR/7a562c67-ca16-48ba-b074-65581be6f001\r\n" +
    "-}";

string finMessage_231a_B_A = "{1:F01CLYDGB2SXXXX0000000000}{2:O2020820221020BOFSGB2LXXXX00000000002210200820N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:pacs004bizmsgid+\r\n" +
    ":21:pacs008EndToEnd+\r\n" +
    ":32A:221020EUR65784,32\r\n" +
    ":52A:CAIXESBB\r\n" +
    ":57A:BOFSGB2L\r\n" +
    ":58A:CLYDGB2S\r\n" +
    ":72:/RETN/99\r\n" +
    "/AC04/\r\n" +
    "/MREF/pacs9bizmsgidr01\r\n" +
    "/TREF/pacs008EndToEnd+\r\n" +
    "-}";

string finMessage_231a_C_B = "{1:F01BOFSGB2LXXXX0000000000}{2:O2020920221020BSCHESMMXXXX00000000002210200920N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:pacs002bizmsgid+\r\n" +
    ":21:pacs008EndToEnd+\r\n" +
    ":32A:221020EUR65784,32\r\n" +
    ":52A:CAIXESBB\r\n" +
    ":57A:BOFSGB2L\r\n" +
    ":58A:CLYDGB2S\r\n" +
    ":72:/RETN/99\r\n" +
    "/AC04/\r\n" +
    "/MREF/pacs9bizmsgidr02\r\n" +
    "/TREF/pacs008EndToEnd+\r\n" +
    "-}";

string finMessage_231a_D_C = "{1:F01BSCHESMMXXXX0000000000}{2:O2020910221020CAIXESBBXXXX00000000002210200910N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:pacs002bizmsgid+\r\n" +
    ":21:pacs008EndToEnd+\r\n" +
    ":32A:221020EUR65784,32\r\n" +
    ":52A:CAIXESBB\r\n" +
    ":57A:BOFSGB2L\r\n" +
    ":58A:CLYDGB2S\r\n" +
    ":72:/RETN/99\r\n" +
    "/AC04/\r\n" +
    "/MREF/pacs9bizmsgidr02\r\n" +
    "/TREF/pacs008EndToEnd+\r\n" +
    "-}";

string finMessage_231a_A_B = "{1:F01BOFSGB2LXXXX0000000000}{2:O2020935221020CLYDGB2SXXXX00000000002210200935N}{3:{119:COV}{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:pacs9bizmsgidr01\r\n" +
    ":21:pacs008EndToEnd+\r\n" +
    ":32A:221020EUR65784,32\r\n" +
    ":52A:CLYDGB2S\r\n" +
    ":57A:BSCHESMM\r\n" +
    ":58A:CAIXESBB\r\n" +
    ":72:/INS/BOFSGB2L\r\n" +
    ":50F:/25698745\r\n" +
    "1/A Debiter\r\n" +
    "2/High Street\r\n" +
    "3/GB/Epping\r\n" +
    ":52A:CLYDGB2S\r\n" +
    ":57A:CAIXESBB\r\n" +
    ":59F:/65479512\r\n" +
    "1/B Creditor Co\r\n" +
    "2/Las Ramblas\r\n" +
    "3/ES/Barcelona\r\n" +
    "-}";

string finMessage_231a_B_C = "{1:F01BSCHESMMXXXX0000000000}{2:O2020845221020BOFSGB2LXXXX00000000002210200845N}{3:{119:COV}{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:pacs9bizmsgidr02\r\n" +
    ":21:pacs008EndToEnd+\r\n" +
    ":32A:221020EUR65784,32\r\n" +
    ":52A:CLYDGB2S\r\n" +
    ":57A:BSCHESMM\r\n" +
    ":58A:CAIXESBB\r\n" +
    ":72:/INS/BOFSGB2L\r\n" +
    ":50F:/25698745\r\n" +
    "1/A Debiter\r\n" +
    "2/High Street\r\n" +
    "3/GB/Epping\r\n" +
    ":52A:CLYDGB2S\r\n" +
    ":57A:CAIXESBB\r\n" +
    ":59F:/65479512\r\n" +
    "1/B Creditor Co\r\n" +
    "2/Las Ramblas\r\n" +
    "3/ES/Barcelona\r\n" +
    "-}";
