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
    groups: ["toSwiftMtMessage", "c56_4_1"],
    dataProvider: dataGen5641
}
isolated function testC5641(xml mx, string mt) returns error? {
    record{} rec = check toSwiftMtMessage(mx);
    test:assertEquals((check swiftmt:getFinMessage(rec)).toString(), mt, msg = "Use case c.56.4.1 result incorrect");
}

function dataGen5641() returns map<[xml, string]>|error {
    // pacs 002 C_B, pacs 002 D_C and pacs 009.adv B_E are not translated in translation portal
    map<[xml, string]> dataSet = {
        "c29_E_B": [check io:fileReadXml("./tests/c_56_4_1/CBPR+ c.56.4.1 camt.029-EtoB.xml"), finMessage_5641_c29_E_B],
        "c53_D_E": [check io:fileReadXml("./tests/c_56_4_1/CBPR+ c.56.4.1 camt.053-DtoE.xml"), finMessage_5641_c53_D_E],
        "c54_D_E": [check io:fileReadXml("./tests/c_56_4_1/CBPR+ c.56.4.1 camt.054-DtoE.xml"), finMessage_5641_c54_D_E],
        "c54_E_F": [check io:fileReadXml("./tests/c_56_4_1/CBPR+ c.56.4.1 camt.054-EtoF.xml"), finMessage_5641_c54_E_F],
        "c56_B_E": [check io:fileReadXml("./tests/c_56_4_1/CBPR+ c.56.4.1 camt.056 BtoE.xml"), finMessage_5641_c56_B_E],
        "p9_B_C": [check io:fileReadXml("./tests/c_56_4_1/CBPR+ c.56.4.1 pacs.009-BtoC.xml"), finMessage_5641_p9_B_C],
        "p9_C_D": [check io:fileReadXml("./tests/c_56_4_1/CBPR+ c.56.4.1 pacs.009-CtoD.xml"), finMessage_5641_p9_C_D]
    };
    return dataSet;
}

string finMessage_5641_c29_E_B = "{1:F01TDOMUS33XXXX0000000000}{2:O2962010210427NWBKGB2LXXXX00000000002104272010N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:CNCL-ID001\r\n" +
    ":21:CSE-001\r\n" +
    ":76:/PDCR/\r\n" +
    ":77A:/UETR/7a562c67-ca16-48ba-b074-65581\r\n" +
    "//be6f001\r\n" +
    ":11R:202\r\n" +
    "210427\r\n" +
    "-}";

string finMessage_5641_c53_D_E = "{1:F01NWBKGB2LXXXX0000000000}{2:O9401800210427ROYCCAT2XXXX00000000002104271800N}{4:\r\n" +
    ":20:Stmnt-100-01\r\n" +
    ":25:9875687\r\n" +
    ":28C:1001/1\r\n" +
    ":60F:D210427CAD96544,\r\n" +
    ":61:210427C2565972,NTRFpacs9bizmsgidr01\r\n" +
    ":62F:C210427CAD2469428,\r\n" +
    "-}";

string finMessage_5641_c54_D_E = "{1:F01NWBKGB2LXXXX0000000000}{2:O9101800210427ROYCCAT2XXXX00000000002104271800N}{4:\r\n" +
    ":20:cmt054bizmsgidr+\r\n" +
    ":21:pacs9bizmsgidr03\r\n" +
    ":25:9875687\r\n" +
    ":32A:210427CAD2565972,\r\n" +
    ":52D:NOTPROVIDED\r\n" +
    "-}";

string finMessage_5641_c54_E_F = "{1:F01RBOSGB2LXXXX0000000000}{2:O9100920210427NWBKGB2LXXXX00000000002104270920N}{4:\r\n" +
    ":20:cmt054bizmsgidr+\r\n" +
    ":21:pacs9bizmsgidr01\r\n" +
    ":25:75830739\r\n" +
    ":32A:210427CAD2565972,\r\n" +
    ":52D:NOTPROVIDED\r\n" +
    "-}";

string finMessage_5641_c56_B_E = "{1:F01NWBKGB2LXXXX0000000000}{2:O2921515210427TDOMUS33XXXX00000000002104271515N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:CSE-001\r\n" +
    ":21:pacs9bizmsgidr01\r\n" +
    ":11S:202\r\n" +
    "210427\r\n" +
    ":79:/AM09/\r\n" +
    "/UETR/7a562c67-ca16-48ba-b074-65581be6f001\r\n" +
    ":32A:210427CAD2565972,\r\n" +
    "-}";

string finMessage_5641_p9_B_C = "{1:F01TDOMCATTXXXX0000000000}{2:O2021415210427TDOMUS33XXXX00000000002104271415N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:pacs9bizmsgidr02\r\n" +
    ":21:pacs9bizmsgidr01\r\n" +
    ":32A:210427CAD2565972,\r\n" +
    ":52A:TDOMUS33\r\n" +
    ":57A:ROYCCAT2\r\n" +
    ":58A:NWBKGB2L\r\n" +
    ":72:/UDLC/RBOSGB2L\r\n" +
    "/INS/TDOMCATT\r\n" +
    "-}";

string finMessage_5641_p9_C_D = "{1:F01ROYCCAT2XXXX0000000000}{2:O2021425210427TDOMCATTXXXX00000000002104271425N}{3:{121:7a562c67-ca16-48ba-b074-65581be6f001}}{4:\r\n" +
    ":20:pacs9bizmsgidr03\r\n" +
    ":21:pacs9bizmsgidr01\r\n" +
    ":32A:210427CAD2565972,\r\n" +
    ":52A:TDOMUS33\r\n" +
    ":57A:ROYCCAT2\r\n" +
    ":58A:NWBKGB2L\r\n" +
    ":72:/UDLC/RBOSGB2L\r\n" +
    "/INS/TDOMCATT\r\n" +
    "-}";
