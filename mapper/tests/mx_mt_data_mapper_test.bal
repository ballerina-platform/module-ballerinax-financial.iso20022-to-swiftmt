// Copyright (c) 2023, WSO2 LLC. (https://www.wso2.com).
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
import ballerina/regex;

@test:Config {
}
function testConvertToMTFinMessage() returns error? {
    xml pain001Document = xml `
        <?xml version="1.0" encoding="UTF-8" ?>
        <Document xmlns="urn:iso:std:iso:20022:tech:xsd:pain.001.001.03">
            <CstmrCdtTrfInitn>
                <GrpHdr>
                    <MsgId>Message-Id</MsgId>
                    <CreDtTm>2024-05-10T16:10:02.017+00:00</CreDtTm>
                    <NbOfTxs>1</NbOfTxs>
                    <CtrlSum>510.24</CtrlSum>
                    <InitgPty>
                        <Id>
                            <OrgId>
                                <Othr>
                                    <Id>Client-Id</Id>
                                </Othr>
                            </OrgId>
                        </Id>
                    </InitgPty>
                </GrpHdr>
                <PmtInf>
                    <PmtInfId>Batch-Id</PmtInfId>
                    <PmtMtd>TRF</PmtMtd>
                    <ReqdExctnDt>YYYY-MM-DD</ReqdExctnDt>
                    <Dbtr>
                        <Nm>Debtor Account Holder Name</Nm>
                    </Dbtr>
                    <DbtrAcct>
                        <Id>
                            <Othr>
                                <Id>Debtor Account Id</Id>
                            </Othr>
                        </Id>
                    </DbtrAcct>
                    <DbtrAgt>
                        <FinInstnId>
                            <BIC>BANK BIC</BIC>
                        </FinInstnId>
                    </DbtrAgt>
                    <CdtTrfTxInf>
                        <PmtId>
                            <EndToEndId>End-to-End-Id</EndToEndId>
                        </PmtId>
                        <Amt>
                            <InstdAmt Ccy="USD">510.24</InstdAmt>
                        </Amt>
                        <CdtrAgt>
                            <FinInstnId>
                                <BIC>BANK BIC</BIC>
                            </FinInstnId>
                        </CdtrAgt>
                        <Cdtr>
                            <Nm>Creditor Account Holder Name</Nm>
                        </Cdtr>
                        <CdtrAcct>
                            <Id>
                                <Othr>
                                    <Id>Creditor Account ID</Id>
                                </Othr>
                            </Id>
                        </CdtrAcct>
                    </CdtTrfTxInf>
                </PmtInf>
            </CstmrCdtTrfInitn>
        </Document>
    `;

    string result = check convertToMTFinMessage(pain001Document);
    io:println(result);
};
