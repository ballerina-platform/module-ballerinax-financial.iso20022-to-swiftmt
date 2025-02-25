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
    groups: ["toSwiftMtMessage", "c29_1_1"],
    dataProvider: dataGen2911
}
isolated function testC2911(xml mx, string mt) returns error? {
    record{} rec = check toSwiftMtMessage(mx);
    test:assertEquals((check swiftmt:toFinMessage(rec)).toString(), mt, msg = "Use case c.29.1.1 result incorrect");
}

function dataGen2911() returns map<[xml, string]>|error {
    map<[xml, string]> dataSet = {
        "B_A": [check io:fileReadXml("./tests/c_29_1_1/CBPR+ c.29.1.1 camt.029-BtoA.xml"), finMessage_2911_B_A],
        "D_C": [check io:fileReadXml("./tests/c_29_1_1/CBPR+ c.29.1.1 camt.029-DtoC.xml"), finMessage_2911_D_C],
        "A_B": [check io:fileReadXml("./tests/c_29_1_1/CBPR+ c.29.1.1 camt.056-AtoB.xml"), finMessage_2911_A_B],
        "C_D": [check io:fileReadXml("./tests/c_29_1_1/CBPR+ c.29.1.1 camt.056-CtoD.xml"), finMessage_2911_C_D],
        "pacs8_A_B": [check io:fileReadXml("./tests/c_29_1_1/CBPR+ c.29.1.1 pacs.008 AtoB.xml"), finMessage_2911_pacs008_A_B],
        "pacs8_C_D": [check io:fileReadXml("./tests/c_29_1_1/CBPR+ c.29.1.1 pacs.008 CtoD.xml"), finMessage_2911_pacs008_C_D],
        "C_B_MI": [check io:fileReadXml("./tests/c_29_1_1/HVPS c.29.1.1 camt.029-CtoB_MI.xml"), finMessage_2911_C_B_MI],
        "B_C_MI": [check io:fileReadXml("./tests/c_29_1_1/HVPS c.29.1.1 camt.056-BtoC_MI.xml"), finMessage_2911_B_C_MI],
        "pacs8_B_C_MI": [check io:fileReadXml("./tests/c_29_1_1/HVPS c.29.1.1 pacs.008 BtoC_MI.xml"), finMessage_2911_pacs008_B_C_MI]
    };
    return dataSet;
}

string finMessage_2911_B_A = "{1:F01MYMBGB2LXXXX0000000000}{2:O1961355221020INGBROBUXXXX00000000002210201355N}{3:{121:174c245f-2682-4291-ad67-2a41e530cd27}}{4:\r\n" +
    ":20:CNCL-IJKL\r\n" +
    ":21:MYMBGB2LXXXCSE-1\r\n" +
    ":76:/CNCL/\r\n" +
    ":77A:/UETR/174c245f-2682-4291-ad67-2a41e\r\n" +
    "//530cd27\r\n" +
    ":11R:103\r\n" +
    "221020\r\n" +
    "-}";

string finMessage_2911_D_C = "{1:F01RZBRROBUXXXX0000000000}{2:O1961335221020GEBABEBBXXXX00000000002210201335N}{3:{121:174c245f-2682-4291-ad67-2a41e530cd27}}{4:\r\n" +
    ":20:CNCL-ABCD\r\n" +
    ":21:NBORROBACSE-1\r\n" +
    ":76:/CNCL/\r\n" +
    ":77A:/UETR/174c245f-2682-4291-ad67-2a41e\r\n" +
    "//530cd27\r\n" +
    ":11R:103\r\n" +
    "221020\r\n" +
    "-}";

string finMessage_2911_A_B = "{1:F01INGBROBUXXXX0000000000}{2:O1921135221020MYMBGB2LXXXX00000000002210201135N}{3:{121:174c245f-2682-4291-ad67-2a41e530cd27}}{4:\r\n" +
    ":20:MYMBGB2LXXXCSE-1\r\n" +
    ":21:pcs008bzmsgidr-1\r\n" +
    ":11S:103\r\n" +
    "221020\r\n" +
    ":79:/DUPL/\r\n" +
    "/UETR/174c245f-2682-4291-ad67-2a41e530cd27\r\n" +
    ":32A:221020RON591636,\r\n" +
    "-}";

string finMessage_2911_C_D = "{1:F01GEBABEBBXXXX0000000000}{2:O1920955221020RZBRROBUXXXX00000000002210200955N}{3:{121:174c245f-2682-4291-ad67-2a41e530cd27}}{4:\r\n" +
    ":20:NBORROBACSE-1\r\n" +
    ":21:pcs008bzmsgidr-3\r\n" +
    ":11S:103\r\n" +
    "221020\r\n" +
    ":79:/DUPL/\r\n" +
    "/UETR/174c245f-2682-4291-ad67-2a41e530cd27\r\n" +
    ":32A:221020RON591636,\r\n" +
    "-}";

string finMessage_2911_pacs008_A_B = "{1:F01INGBROBUXXXX0000000000}{2:O1030905221020MYMBGB2LXXXX00000000002210200905N}{3:{121:174c245f-2682-4291-ad67-2a41e530cd27}}{4:\r\n" +
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

string finMessage_2911_pacs008_C_D = "{1:F01GEBABEBBXXXX0000000000}{2:O1030735221020RZBRROBUXXXX00000000002210200735N}{3:{121:174c245f-2682-4291-ad67-2a41e530cd27}}{4:\r\n" +
    ":20:pcs008bzmsgidr-3\r\n" +
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

string finMessage_2911_C_B_MI = "{1:F01INGBROBUXXXX0000000000}{2:O1961345221020RZBRROBUXXXX00000000002210201345N}{3:{121:174c245f-2682-4291-ad67-2a41e530cd27}}{4:\r\n" +
    ":20:CNCL-EFGH\r\n" +
    ":21:\r\n" +
    ":76:/CNCL/\r\n" +
    ":77A:/UETR/174c245f-2682-4291-ad67-2a41e\r\n" +
    "//530cd27\r\n" +
    ":11R:103\r\n" +
    "221020\r\n" +
    "-}";

string finMessage_2911_B_C_MI = "{1:F01RZBRROBUXXXX0000000000}{2:O1920945221020INGBROBUXXXX00000000002210200945N}{3:{121:174c245f-2682-4291-ad67-2a41e530cd27}}{4:\r\n" +
    ":20:\r\n" +
    ":21:pcs008bzmsgidr-2\r\n" +
    ":11S:103\r\n" +
    "221020\r\n" +
    ":79:/DUPL/\r\n" +
    "/UETR/174c245f-2682-4291-ad67-2a41e530cd27\r\n" +
    ":32A:221020RON591636,\r\n" +
    "-}";

string finMessage_2911_pacs008_B_C_MI = "{1:F01RZBRROBUXXXX0000000000}{2:O1030725221020INGBROBUXXXX00000000002210200725N}{3:{121:174c245f-2682-4291-ad67-2a41e530cd27}}{4:\r\n" +
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