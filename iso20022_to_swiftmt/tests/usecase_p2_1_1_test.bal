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
    groups: ["toSwiftMtMessage", "p2_1_1"],
    dataProvider: dataGen211
}
isolated function testP211(xml mx, string mt) returns error? {
    record{} rec = check toSwiftMtMessage(mx);
    test:assertEquals((check swiftmt:getFinMessage(rec)).toString(), mt, msg = "Use case p.2.1.1 result incorrect");
}

string finMessage_211_A_B = "{1:F01ABNANL2AXXXX0000000000}{2:O1030900210409RBOSGB2LXXXX00000000002104090900N}{3:{121:8a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n"+
        ":20:pacs8bizmsgidr01\r\n" +
        ":23B:CRED\r\n" +
        ":32A:210409EUR15669,38\r\n" +
        ":33B:EUR15669,38\r\n" +
        ":50F:/12547896\r\n" +
        "1/C Consumer\r\n" +
        "2/High Street\r\n" +
        "3/GB/Epping\r\n" +
        ":52A:RBOSGB2LXXX\r\n" +
        ":56A:NDEAFIHHXXX\r\n" +
        ":57A:HELSFIHHXXX\r\n" +
        ":59F:/98653214\r\n" +
        "1/Evli\r\n" +
        "2/Aleksanterinkatu 19\r\n" +
        "3/FI/Helsinki\r\n" +
        ":70:/ROC/pacs008EndToEndId-001\r\n" +
        ":71A:OUR\r\n" +
        "-}";

string finMessage_211_B_C = "{1:F01NDEAFIHHXXXX0000000000}{2:O1030910210409ABNANL2AXXXX00000000002104090910N}{3:{121:8a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
        ":20:pacs8bizmsgidr02\r\n" +
        ":23B:CRED\r\n" +
        ":32A:210409EUR15669,38\r\n" +
        ":33B:EUR15669,38\r\n" +
        ":50F:/12547896\r\n" +
        "1/C Consumer\r\n" +
        "2/High Street\r\n" +
        "3/GB/Epping\r\n" +
        ":52A:RBOSGB2LXXX\r\n" +
        ":57A:HELSFIHHXXX\r\n" +
        ":59F:/98653214\r\n" +
        "1/Evli\r\n" +
        "2/Aleksanterinkatu 19\r\n" +
        "3/FI/Helsinki\r\n" +
        ":70:/ROC/pacs008EndToEndId-001\r\n" +
        ":71A:OUR\r\n" +
        "-}";

string finMessage_211_C_D = "{1:F01HELSFIHHXXXX0000000000}{2:O1030920210409NDEAFIHHXXXX00000000002104090920N}{3:{121:8a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
        ":20:pacs8bizmsgidr03\r\n" +
        ":23B:CRED\r\n" +
        ":32A:210409EUR15669,38\r\n" +
        ":33B:EUR15669,38\r\n" +
        ":50F:/12547896\r\n" +
        "1/C Consumer\r\n" +
        "2/High Street\r\n" +
        "3/GB/Epping\r\n" +
        ":52A:RBOSGB2LXXX\r\n" +
        ":57A:HELSFIHHXXX\r\n" +
        ":59F:/98653214\r\n" +
        "1/Evli\r\n" +
        "2/Aleksanterinkatu 19\r\n" +
        "3/FI/Helsinki\r\n" +
        ":70:/ROC/pacs008EndToEndId-001\r\n" +
        ":71A:OUR\r\n" +
        ":72:/INS/ABNANL2AXXX\r\n" +
        "-}";
function dataGen211() returns map<[xml, string]>|error {
    // Use Case p.2.1.1/CBPR+ p.2.1.1 pacs.002-BtoA_ACSP.xml & p.2.1.1/CBPR+ p.2.1.1 pacs.002-BtoA_ACTC.xml are not 
    // translated in SWIFT translation portal
    map<[xml, string]> dataSet = {
        "A_B": [check io:fileReadXml("./tests/p_2_1_1/CBPR+ p.2.1.1 pacs.008-AtoB.xml"), finMessage_211_A_B],
        "B_C": [check io:fileReadXml("./tests/p_2_1_1/CBPR+ p.2.1.1 pacs.008-BtoC.xml"), finMessage_211_B_C],
        "C_D": [check io:fileReadXml("./tests/p_2_1_1/CBPR+ p.2.1.1 pacs.008-CtoD.xml"), finMessage_211_C_D]
    };
    return dataSet;
}