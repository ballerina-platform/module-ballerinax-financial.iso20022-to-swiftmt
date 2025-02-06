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
    groups: ["toSwiftMtMessage", "p2_5_1"],
    dataProvider: dataGen251
}
isolated function testP251(xml mx, string mt) returns error? {
    record{} rec = check toSwiftMtMessage(mx);
    test:assertEquals((check swiftmt:getFinMessage(rec)).toString(), mt, msg = "Use case p.2.5.1 result incorrect");
}

function dataGen251() returns map<[xml, string]>|error {
    map<[xml, string]> dataSet = {
        // Use Case p_2_5_1/CBPR+ iso20022_to_swiftmt/tests/p_2_5_1/CBPR+ p.2.5.1 pacs.002 BtoA.xml not translated in 
        // SWIFT translation portal &&
        // no mapping for pacs.003 and pain, A_B, A_C and C_A ignored
        "B_Dbtr": [check io:fileReadXml("./tests/p_2_5_1/CBPR+ p.2.5.1 camt.053-BtoDbtr.xml"), finMessage_251_B_Dbtr]
        
    };
    return dataSet;
}

string finMessage_251_B_Dbtr = "{1:F01CNORGB22XXXX0000000000}{2:O9401700221020RBOSGB2LXXXX00000000002210201700N}{4:\r\n" +
    ":20:Stmnt-100-01\r\n" +
    ":25:25698745\r\n" +
    ":28C:1001/1\r\n" +
    ":60F:D221020EUR2564,\r\n" +
    ":61:221020D45250,NTRFNONREF\r\n" +
    ":62F:D221020EUR47814,\r\n" +
    "-}";
