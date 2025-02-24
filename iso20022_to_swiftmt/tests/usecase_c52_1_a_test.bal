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
    groups: ["toSwiftMtMessage", "c52_1_a"],
    dataProvider: dataGen521a
}
isolated function testC521a(xml mx, string mt) returns error? {
    record{} rec = check toSwiftMtMessage(mx);
    test:assertEquals((check swiftmt:getFinMessage(rec)).toString(), mt, msg = "Use case c.52.1.a result incorrect");
}

function dataGen521a() returns map<[xml, string]>|error {
    map<[xml, string]> dataSet = {
        "c52_Cdtr": [check io:fileReadXml("./tests/c_52_1_a/CBPR+ c.52.1.a camt.052toCdtr.xml"), finMessage_521a_c52_Cdtr],
        "A_B": [check io:fileReadXml("./tests/c_52_1_a/CBPR+ c.52.1.a pacs.008-AtoB.xml"), finMessage_521a_A_B],
        "B_C": [check io:fileReadXml("./tests/c_52_1_a/CBPR+ c.52.1.a pacs.008-BtoC.xml"), finMessage_521a_B_C],
        "C_D": [check io:fileReadXml("./tests/c_52_1_a/CBPR+ c.52.1.a pacs.008-CtoD.xml"), finMessage_521a_C_D]
    };
    return dataSet;
}

string finMessage_521a_c52_Cdtr = "{1:F01AZSEDEMMXXXX0000000000}{2:O9421000201124DEUTDEFFXXXX00000000002011241000N}{4:\r\n" +
    ":20:100-01\r\n" +
    ":25:DE8547812\r\n" +
    ":28C:10001/3\r\n" +
    ":34F:EUR0,\r\n" +
    ":13D:2011241100+0100\r\n" +
    ":61:201124C750000,NTRFpacs008EndToEnd+\r\n" +
    "-}";
 
string finMessage_521a_A_B = "{1:F01CBRLGB2LXXXX0000000000}{2:O1030914201124RBOSGB2LXXXX00000000002011240914N}{3:{121:8a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:pacs8bizmsgidr01\r\n" +
    ":23B:CRED\r\n" +
    ":32A:201124EUR750000,\r\n" +
    ":33B:EUR750000,\r\n" +
    ":50F:/98756925\r\n" +
    "1/ABC Investments\r\n" +
    "2/36 Laurie Street\r\n" +
    "3/GB/London\r\n" +
    ":52A:RBOSGB2LXXX\r\n" +
    ":56A:LOYDGB2LXXX\r\n" +
    ":57A:DEUTDEFFXXX\r\n" +
    ":59F:/DE8547812\r\n" +
    "1/Allianz \r\n" +
    "2/Koeniginstrasse 28\r\n" +
    "3/DE/Munich\r\n" +
    ":70:/ROC/pacs008EndToEndId-001\r\n" +
    ":71A:OUR\r\n" +
    "-}";

string finMessage_521a_B_C = "{1:F01LOYDGB2LXXXX0000000000}{2:O1030924201124CBRLGB2LXXXX00000000002011240924N}{3:{121:8a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:pacs8bizmsgidr02\r\n" +
    ":23B:CRED\r\n" +
    ":32A:201124EUR750000,\r\n" +
    ":33B:EUR750000,\r\n" +
    ":50F:/98756925\r\n" +
    "1/ABC Investments\r\n" +
    "2/36 Laurie Street\r\n" +
    "3/GB/London\r\n" +
    ":52A:RBOSGB2LXXX\r\n" +
    ":57A:DEUTDEFFXXX\r\n" +
    ":59F:/DE8547812\r\n" +
    "1/Allianz \r\n" +
    "2/Koeniginstrasse 28\r\n" +
    "3/DE/Munich\r\n" +
    ":70:/ROC/pacs008EndToEndId-001\r\n" +
    ":71A:OUR\r\n" +
    "-}";

string finMessage_521a_C_D = "{1:F01DEUTDEFFXXXX0000000000}{2:O1030834201124LOYDGB2LXXXX00000000002011240834N}{3:{121:8a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:pacs8bizmsgidr03\r\n" +
    ":23B:CRED\r\n" +
    ":32A:201124EUR750000,\r\n" +
    ":33B:EUR750000,\r\n" +
    ":50F:/98756925\r\n" +
    "1/ABC Investments\r\n" +
    "2/36 Laurie Street\r\n" +
    "3/GB/London\r\n" +
    ":52A:RBOSGB2LXXX\r\n" +
    ":57A:DEUTDEFFXXX\r\n" +
    ":59F:/DE8547812\r\n" +
    "1/Allianz \r\n" +
    "2/Koeniginstrasse 28\r\n" +
    "3/DE/Munich\r\n" +
    ":70:/ROC/pacs008EndToEndId-001\r\n" +
    ":71A:OUR\r\n" +
    ":72:/INS/CBRLGB2LXXX\r\n" +
    "-}";
    