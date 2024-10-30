# Ballerina ISO 20022 to SWIFT MT Data Mapper Library

## Overview

The DataMapper Library is a comprehensive toolkit designed to convert ISO 20022 XML messages into SWIFT MT FIN format within Ballerina applications. It simplifies the process of mapping ISO 20022 elements to their corresponding SWIFT MT fields, leveraging predefined records and parsers from the ISO 20022 and SWIFT MT libraries. This enables developers to seamlessly convert financial messages from the structured ISO 20022 XML standard into the flat, text-based SWIFT format, ensuring accurate and efficient data conversion.

## Supported Conversions

- PAIN.001 Type Message to SWIFT MT101
- PACS.008 Type Message to SWIFT MT102, MT102STP, MT103, MT103STP, MT103REMIT
- PAIN.008 Type Message to SWIFT MT104

## Usage

### Conversion of SWIFT fin message to ISO 20022 Xml Standard

```ballerina
import ballerina/io;
import ballerinax/financial.ISO20022ToSwiftMT as mxToMt;

public function main() returns error? {
    xml iso20022XmlMessage = xml `
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
    io:println(mxToMt:convertToMTFinMessage(iso20022XmlMessage));
}
```