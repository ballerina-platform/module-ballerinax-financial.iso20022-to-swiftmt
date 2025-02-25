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
    groups: ["toSwiftMtMessage", "p2_3_1_b"],
    dataProvider: dataGen231b
}
isolated function testP231b(xml mx, string mt) returns error? {
    record{} rec = check toSwiftMtMessage(mx);
    test:assertEquals((check swiftmt:toFinMessage(rec)).toString(), mt, msg = "Use case p.2.3.1.b result incorrect");
}

function dataGen231b() returns map<[xml, string]>|error {
    map<[xml, string]> dataSet = {
        // Use Case p_2_3_1_b/CBPR+ p.2.3.1.b pacs.004-CtoB.xml && p_2_3_1_b/CBPR+ p.2.3.1.b pacs.004-DtoC.xml 
        // not translated in SWIFT translation portal
        "D_A": [check io:fileReadXml("./tests/p_2_3_1_b/CBPR+ p.2.3.1.b pacs.002 DtoA.xml"), finMessage_231b_D_A],
        "D_C": [check io:fileReadXml("./tests/p_2_3_1_b/CBPR+ p.2.3.1.b pacs.002 DtoC.xml"), finMessage_231b_D_C],
        "A_D": [check io:fileReadXml("./tests/p_2_3_1_b/CBPR+ p.2.3.1.b pacs.008 AtoD.xml"), finMessage_231b_A_D],
        "A_B": [check io:fileReadXml("./tests/p_2_3_1_b/CBPR+ p.2.3.1.b pacs.009.cov-AtoB.xml"), finMessage_231b_A_B],
        "B_C": [check io:fileReadXml("./tests/p_2_3_1_b/CBPR+ p.2.3.1.b pacs.009.cov-BtoC.xml"), finMessage_231b_B_C],
        "C_D": [check io:fileReadXml("./tests/p_2_3_1_b/CBPR+ p.2.3.1.b pacs.009.cov-CtoD.xml"), finMessage_231b_C_D]
    };
    return dataSet;
}

string finMessage_231b_D_A = "{1:F01CLYDGB2SXXXX0000000000}{2:O1990835221020BSCHGB2LXXXX00000000002210200835N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:pacs002bizmsgid+\r\n" +
    ":21:pcs008bzmsgidr-1\r\n" +
    ":79:/REJT/99\r\n" +
    "/AC04/\r\n" +
    "/MREF/pcs008bzmsgidr-1\r\n" +
    "/TREF/pacs008EndToEnd+\r\n" +
    "/TEXT//UETR/7a562c67-ca16-48ba-b074-65581be6f001\r\n" +
    "-}";

string finMessage_231b_D_C = "{1:F01BSCHESMMXXXX0000000000}{2:O2990900221020BSCHGB2LXXXX00000000002210200900N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:pacs002bizmsgid+\r\n" +
    ":21:pacs9bizmsgidr03\r\n" +
    ":79:/REJT/99\r\n" +
    "/AC04/\r\n" +
    "/MREF/pacs9bizmsgidr03\r\n" +
    "/TREF/pacs008EndToEnd+\r\n" +
    "/TEXT//UETR/7a562c67-ca16-48ba-b074-65581be6f001\r\n" +
    "-}";

string finMessage_231b_A_D = "{1:F01BSCHGB2LXXXX0000000000}{2:O1030925221020CLYDGB2SXXXX00000000002210200925N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:pcs008bzmsgidr-1\r\n" +
    ":23B:CRED\r\n" +
    ":32A:221020DKK591636,\r\n" +
    ":33B:DKK591636,\r\n" +
    ":50F:/NOTPROVIDED\r\n" +
    "1/A Debiter\r\n" +
    "2/High Street\r\n" +
    "3/GB/Epping London\r\n" +
    ":52A:CLYDGB2S\r\n" +
    ":53A:BOFSGB2L\r\n" +
    ":54A:BSCHESMM\r\n" +
    ":57A:BSCHGB2L\r\n" +
    ":59F:1/B Creditor Co\r\n" +
    "2/Las Ramblas\r\n" +
    "3/ES/Barcelona\r\n" +
    ":70:/ROC/pacs008EndToEndId-001\r\n" +
    ":71A:OUR\r\n" +
    "-}";

string finMessage_231b_A_B = "{1:F01BOFSGB2LXXXX0000000000}{2:O2020925221020CLYDGB2SXXXX00000000002210200925N}{3:{119:COV}{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:pacs9bizmsgidr01\r\n" +
    ":21:pacs008EndToEnd+\r\n" +
    ":32A:221020DKK591636,\r\n" +
    ":52A:CLYDGB2S\r\n" +
    ":57A:BSCHESMM\r\n" +
    ":58A:BSCHGB2L\r\n" +
    ":72:/INS/BOFSGB2L\r\n" +
    ":50F:/NOTPROVIDED\r\n" +
    "1/A Debiter\r\n" +
    "2/High Street\r\n" +
    "3/GB/Epping London\r\n" +
    ":52A:CLYDGB2S\r\n" +
    ":57A:BSCHGB2L\r\n" +
    ":59F:1/B Creditor Co\r\n" +
    "2/Las Ramblas\r\n" +
    "3/ES/Barcelona\r\n" +
    "-}";

string finMessage_231b_B_C = "{1:F01BSCHESMMXXXX0000000000}{2:O2020935221020BOFSGB2LXXXX00000000002210200935N}{3:{119:COV}{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:pacs9bizmsgidr02\r\n" +
    ":21:pacs008EndToEnd+\r\n" +
    ":32A:221020DKK591636,\r\n" +
    ":52A:CLYDGB2S\r\n" +
    ":57A:BSCHESMM\r\n" +
    ":58A:BSCHGB2L\r\n" +
    ":72:/INS/BOFSGB2L\r\n" +
    ":50F:/NOTPROVIDED\r\n" +
    "1/A Debiter\r\n" +
    "2/High Street\r\n" +
    "3/GB/Epping London\r\n" +
    ":52A:CLYDGB2S\r\n" +
    ":57A:BSCHGB2L\r\n" +
    ":59F:1/B Creditor Co\r\n" +
    "2/Las Ramblas\r\n" +
    "3/ES/Barcelona\r\n" +
    "-}";

string finMessage_231b_C_D = "{1:F01BSCHGB2LXXXX0000000000}{2:O2020845221020BSCHESMMXXXX00000000002210200845N}{3:{119:COV}{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:pacs9bizmsgidr03\r\n" +
    ":21:pacs008EndToEnd+\r\n" +
    ":32A:221020DKK591636,\r\n" +
    ":52A:CLYDGB2S\r\n" +
    ":57A:BSCHESMM\r\n" +
    ":58A:BSCHGB2L\r\n" +
    ":72:/INS/BOFSGB2L\r\n" +
    ":50F:/NOTPROVIDED\r\n" +
    "1/A Debiter\r\n" +
    "2/High Street\r\n" +
    "3/GB/Epping London\r\n" +
    ":52A:CLYDGB2S\r\n" +
    ":57A:BSCHGB2L\r\n" +
    ":59F:1/B Creditor Co\r\n" +
    "2/Las Ramblas\r\n" +
    "3/ES/Barcelona\r\n" +
    "-}";