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
    groups: ["toSwiftMtMessage", "c29_1_2"],
    dataProvider: dataGen2912
}
isolated function testC2912(xml mx, string mt) returns error? {
    record{} rec = check toSwiftMtMessage(mx);
    test:assertEquals((check swiftmt:getFinMessage(rec)).toString(), mt, msg = "Use case c.29.1.2 result incorrect");
}

function dataGen2912() returns map<[xml, string]>|error {
    map<[xml, string]> dataSet = {
        "B_A": [check io:fileReadXml("./tests/c_29_1_2/CBPR+ c.29.1.2 camt.029-BtoA.xml"), finMessage_2912_B_A],
        "A_B": [check io:fileReadXml("./tests/c_29_1_2/CBPR+ c.29.1.2 camt.056-AtoB.xml"), finMessage_2912_A_B],
        "pacs8_A_B": [check io:fileReadXml("./tests/c_29_1_2/CBPR+ c.29.1.2 pacs.008 AtoB.xml"), finMessage_2912_pacs8_A_B],
        "C_B": [check io:fileReadXml("./tests/c_29_1_2/HVPS c.29.1.2 camt.029-CtoB_MI.xml"), finMessage_2912_C_B],
        "B_C": [check io:fileReadXml("./tests/c_29_1_2/HVPS c.29.1.2 camt.056-BtoC_MI.xml"), finMessage_2912_B_C],
        "pacs8_B_C": [check io:fileReadXml("./tests/c_29_1_2/HVPS c.29.1.2 pacs.008 BtoC_MI.xml"), finMessage_2912_pacs8_B_C]
    };
    return dataSet;
}

string finMessage_2912_B_A = "{1:F01MYMBGB2LXXXX0000000000}{2:O1961555221020INGBROBUXXXX00000000002210201555N}{3:{121:174c245f-2682-4291-ad67-2a41e530cd27}}{4:\r\n" +
    ":20:CNCL-EFGH\r\n" +
    ":21:CASEMYMBGB2L\r\n" +
    ":76:/CNCL/\r\n" +
    ":77A:/UETR/174c245f-2682-4291-ad67-2a41e\r\n" +
    "//530cd27\r\n" +
    ":11R:103\r\n" +
    "221020\r\n" +
    "-}";

string finMessage_2912_A_B = "{1:F01INGBROBUXXXX0000000000}{2:O1921135221020MYMBGB2LXXXX00000000002210201135N}{3:{121:174c245f-2682-4291-ad67-2a41e530cd27}}{4:\r\n" +
    ":20:CASEMYMBGB2L\r\n" +
    ":21:pcs008bzmsgidr-1\r\n" +
    ":11S:103\r\n" +
    "221020\r\n" +
    ":79:/CUST/\r\n" +
    "/UETR/174c245f-2682-4291-ad67-2a41e530cd27\r\n" +
    ":32A:221020RON591636,\r\n" +
    "-}";

string finMessage_2912_pacs8_A_B = "{1:F01INGBROBUXXXX0000000000}{2:O1030905221020MYMBGB2LXXXX00000000002210200905N}{3:{121:174c245f-2682-4291-ad67-2a41e530cd27}}{4:\r\n" +
    ":20:pcs008bzmsgidr-1\r\n" +
    ":23B:CRED\r\n" +
    ":32A:221020RON591636,\r\n" +
    ":33B:RON591636,\r\n" +
    ":50F:/25698745\r\n" +
    "1/Debtor Co\r\n" +
    "2/High Street\r\n" +
    "3/GB/Epping\r\n" +
    ":52A:MYMBGB2LXXX\r\n" +
    ":57A:GEBABEBBXXX\r\n" +
    ":59F:/65479512\r\n" +
    "1/Ardent Finance\r\n" +
    "2/Main Street\r\n" +
    "3/RO/Bucharest\r\n" +
    ":70:/ROC/E2E04044506271305\r\n" +
    ":71A:OUR\r\n" +
    "-}";

string finMessage_2912_C_B = "{1:F01INGBROBUXXXX0000000000}{2:O1961545221020RZBRROBUXXXX00000000002210201545N}{3:{121:174c245f-2682-4291-ad67-2a41e530cd27}}{4:\r\n" +
    ":20:\r\n" +
    ":21:\r\n" +
    ":76:/CNCL/\r\n" +
    ":77A:/UETR/174c245f-2682-4291-ad67-2a41e\r\n" +
    "//530cd27\r\n" +
    ":11R:103\r\n" +
    "221020\r\n" +
    "-}";

string finMessage_2912_B_C = "{1:F01RZBRROBUXXXX0000000000}{2:O1921145221020INGBROBUXXXX00000000002210201145N}{3:{121:174c245f-2682-4291-ad67-2a41e530cd27}}{4:\r\n" +
    ":20:\r\n" +
    ":21:pcs008bzmsgidr-2\r\n" +
    ":11S:103\r\n" +
    "221020\r\n" +
    ":79:/CUST/\r\n" +
    "/UETR/174c245f-2682-4291-ad67-2a41e530cd27\r\n" +
    ":32A:221020RON591636,\r\n" +
    "-}";

string finMessage_2912_pacs8_B_C = "{1:F01RZBRROBUXXXX0000000000}{2:O1030925221020INGBROBUXXXX00000000002210200925N}{3:{121:174c245f-2682-4291-ad67-2a41e530cd27}}{4:\r\n" +
    ":20:pcs008bzmsgidr-2\r\n" +
    ":23B:CRED\r\n" +
    ":32A:221020RON591636,\r\n" +
    ":33B:RON591636,\r\n" +
    ":50F:/25698745\r\n" +
    "1/Debtor Co\r\n" +
    "2/High Street\r\n" +
    "3/GB/Epping\r\n" +
    ":52A:MYMBGB2LXXX\r\n" +
    ":57A:GEBABEBBXXX\r\n" +
    ":59F:/65479512\r\n" +
    "1/Ardent Finance\r\n" +
    "2/Main Street\r\n" +
    "3/RO/Bucharest\r\n" +
    ":70:/ROC/E2E04044506271305\r\n" +
    ":71A:OUR\r\n" +
    "-}";