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
    groups: ["toSwiftMtMessage", "p3_1_1"],
    dataProvider: dataGen311
}
isolated function testP311(xml mx, string mt) returns error? {
    record{} rec = check toSwiftMtMessage(mx);
    test:assertEquals((check swiftmt:getFinMessage(rec)).toString(), mt, msg = "Use case p.3.1.1 result incorrect");
}

function dataGen311() returns map<[xml, string]>|error {
    map<[xml, string]> dataSet = {
        // pacs.003 and pain mappings N/A, A_B, A_C, C_A ignored
        // Use Case p_3_1_1_/CBPR+ p.3.1.1 pacs.002 BtoA.xml not translated in SWIFT translation portal
        "B_Dbtr": [check io:fileReadXml("./tests/p_3_1_1/CBPR+ p.3.1.1 camt.053-BtoDbtr.xml"), finMessage_311_B_Dbtr]
    };
    return dataSet;
}

string finMessage_311_B_Dbtr = "{1:F01CNORGB22XXXX0000000000}{2:O9401700221020RBOSGB2LXXXX00000000002210201700N}{4:\r\n" +
    ":20:Stmnt-100-01\r\n" +
    ":25:25698745\r\n" +
    ":28C:1001/1\r\n" +
    ":60F:D221020EUR2564,\r\n" +
    ":61:221020D45250,NTRFNONREF\r\n" +
    ":62F:D221020EUR47814,\r\n" +
    "-}";

