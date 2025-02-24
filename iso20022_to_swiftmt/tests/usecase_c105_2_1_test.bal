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
    groups: ["toSwiftMtMessage", "c105_2_1"],
    dataProvider: dataGen10521
}
isolated function testC10521(xml mx, string mt) returns error? {
    record{} rec = check toSwiftMtMessage(mx);
    test:assertEquals((check swiftmt:getFinMessage(rec)).toString(), mt, msg = "Use case c.105.2.1 result incorrect");
}

function dataGen10521() returns map<[xml, string]>|error {
    map<[xml, string]> dataSet = {
        "c053_B_A": [check io:fileReadXml("./tests/c_105_2_1/CBPR+ c.105.2.1 camt.053-BtoA.xml"), finMessage_10521_c53_B_A],
        "c105_B_A": [check io:fileReadXml("./tests/c_105_2_1/CBPR+ c.105.2.1 camt.105-BtoA.xml"), finMessage_10521_c105_B_A]
    };
    return dataSet;
}

string finMessage_10521_c53_B_A = "{1:F01CBRLGB2LXXXX0000000000}{2:O9401000221020RBOSGBCHXXXX00000000002210201000N}{4:\r\n" +
    ":20:100-01\r\n" +
    ":25:48751258\r\n" +
    ":28C:1001/1\r\n" +
    ":60F:D221020GBP10,\r\n" +
    ":61:221020D10,NTRFcamt108bzmsgidr1\r\n" +
    ":62F:D221020GBP20,\r\n" +
    "-}";

string finMessage_10521_c105_B_A = "{1:F01CBRLGB2LXXXX0000000000}{2:O2901020221020RBOSGBCHXXXX00000000002210201020N}{4:\r\n" +
    ":20:camt105chrgid1\r\n" +
    ":21:camt108bzmsgidr1\r\n" +
    ":25:48751258\r\n" +
    ":32D:221020GBP10,\r\n" +
    ":71B:/CANF/GBP10,/D\r\n" +
    ":72:/CHRQ/RBOSGBCHXXX\r\n" +
    "-}";
