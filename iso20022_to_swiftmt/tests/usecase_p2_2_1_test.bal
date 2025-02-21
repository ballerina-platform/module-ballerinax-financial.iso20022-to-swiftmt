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
    groups: ["toSwiftMtMessage", "p2_2_1"],
    dataProvider: dataGen221
}
isolated function testP221(xml mx, string mt) returns error? {
    record{} rec = check toSwiftMtMessage(mx);
    test:assertEquals((check swiftmt:getFinMessage(rec)).toString(), mt, msg = "Use case p.2.2.1 result incorrect");
}

function dataGen221() returns map<[xml, string]>|error {
    map<[xml, string]> dataSet = {
        "D_C": [check io:fileReadXml("./tests/p_2_2_1/CBPR+ p.2.2.1 pacs.002-DtoC.xml"), finMessage_221_D_C],
        "C_B": [check io:fileReadXml("./tests/p_2_2_1/CBPR+ p.2.2.1 pacs.004-CtoB.xml"), finMessage_221_C_B],
        "B_C": [check io:fileReadXml("./tests/p_2_2_1/CBPR+ p.2.2.1 pacs.009-BtoC.xml"), finMessage_221_B_C],
        "C_D": [check io:fileReadXml("./tests/p_2_2_1/CBPR+ p.2.2.1 pacs.009-CtoD.xml"), finMessage_221_C_D]
    };
    return dataSet;
}

string finMessage_221_D_C = "{1:F01NDEAFIHHXXXX0000000000}{2:O2991113200803HELSFIHHXXXX00000000002008031113N}{3:{121:dab3b64f-092b-4839-b7e9-8f438af50961}}{4:\r\n" +
    ":20:pacs2bizmsgidr01\r\n" +
    ":21:pacs9bizmsgidr02\r\n" +
    ":79:/REJT/99\r\n" +
    "/AC04/\r\n" +
    "/MREF/pacs9bizmsgidr02\r\n" +
    "/TREF/pacs009EndToEnd+\r\n" +
    "/TEXT//UETR/dab3b64f-092b-4839-b7e9-8f438af50961\r\n" +
    "-}";

string finMessage_221_C_B = "{1:F01ABNANL2AXXXX0000000000}{2:O2021213200803NDEAFIHHXXXX00000000002008031213N}{3:{121:dab3b64f-092b-4839-b7e9-8f438af50961}}{4:\r\n" +
    ":20:pacs4bizmsgidr02\r\n" +
    ":21:pacs009EndToEnd+\r\n" +
    ":32A:200803EUR654489,98\r\n" +
    ":52A:NDEAFIHHXXX\r\n" +
    ":57A:ABNANL2AXXX\r\n" +
    ":58A:RBOSGB2LXXX\r\n" +
    ":72:/RETN/99\r\n" +
    "/AC04/\r\n" +
    "/MREF/pacs9bizmsgidr01\r\n" +
    "/TREF/pacs009EndToEnd+\r\n" +
    "-}";

string finMessage_221_B_C = "{1:F01NDEAFIHHXXXX0000000000}{2:O2021013200803ABNANL2AXXXX00000000002008031013N}{3:{121:dab3b64f-092b-4839-b7e9-8f438af50961}}{4:\r\n" +
    ":20:pacs9bizmsgidr01\r\n" +
    ":21:pacs009EndToEnd+\r\n" +
    ":32A:200803EUR654489,98\r\n" +
    ":52A:RBOSGB2LXXX\r\n" +
    ":57A:HELSFIHHXXX\r\n" +
    ":58A:EVSEFIHHXXX\r\n" +
    ":72:/INS/ABNANL2AXXX\r\n" +
    "/BNF/Invoice: 456464-9663\r\n" +
    "-}";

string finMessage_221_C_D = "{1:F01HELSFIHHXXXX0000000000}{2:O2021023200803NDEAFIHHXXXX00000000002008031023N}{3:{121:dab3b64f-092b-4839-b7e9-8f438af50961}}{4:\r\n" +
    ":20:pacs9bizmsgidr02\r\n" +
    ":21:pacs009EndToEnd+\r\n" +
    ":32A:200803EUR654489,98\r\n" +
    ":52A:RBOSGB2LXXX\r\n" +
    ":57A:HELSFIHHXXX\r\n" +
    ":58A:EVSEFIHHXXX\r\n" +
    ":72:/INS/ABNANL2AXXX\r\n" +
    "/BNF/Invoice: 456464-9663\r\n" +
    "-}";
