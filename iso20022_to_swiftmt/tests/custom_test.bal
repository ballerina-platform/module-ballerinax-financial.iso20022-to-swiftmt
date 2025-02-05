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
    groups: ["toSwiftMtMessage", "custom"],
    dataProvider: dataGenCustom
}
isolated function testCustom(xml mx, string mt) returns error? {
    record{} rec = check toSwiftMtMessage(mx);
    test:assertEquals((check swiftmt:getFinMessage(rec)).toString(), mt, msg = "Custom Use case result incorrect");
}

function dataGenCustom() returns map<[xml, string]>|error {
    map<[xml, string]> dataSet = {
        "pacs004_to_205RETN": [check io:fileReadXml("./tests/custom_tests/pacs004_to_MT205RETN"), finMessage_pacs004_to_205RETN]
    };
    return dataSet;
}

string finMessage_pacs004_to_205RETN = "{1:F01CHASUS33XXXX0000000000}{2:O2051153210511ANBTUS44XXXX00000000002105111153N}{3:{121:174c245f-2682-4291-ad67-2a41e530cd27}}{4:\r\n" +
    ":20:P4C2B-005\r\n" +
    ":21:E2E040445062713+\r\n" +
    ":32A:210511USD136480,\r\n" +
    ":52A:ANBTUS44XXX\r\n" +
    ":57A:CHASGB2LXXX\r\n" +
    ":58A:BSCHGB2L\r\n" +
    ":72:/RETN/99\r\n" +
    "/AC04/\r\n" +
    "/MREF/B2C0506272708\r\n" +
    "/TREF/E2E040445062713+\r\n" +
    "-}";

string finMessage_pacs009_to_202 = "{1:F01NWBKGB2LXXXX0000000000}{2:O2021500210427TDOMUS33XXXX00000000002104271500N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:pacs9bizmsgidr01\r\n" +
    ":21:pacs9AdvEndToEn+\r\n" +
    ":32A:210427CAD2565972,\r\n" +
    ":52A:HKBCCATTCLS\r\n" +
    ":53A:TDOMCATT\r\n" +
    ":54A:ROYCCAT2\r\n" +
    ":57A:NWBKGB2L\r\n" +
    ":58A:RBOSGB2L\r\n" +
    ":72:/INS/TDOMUS33\r\n" +
    "-}";
