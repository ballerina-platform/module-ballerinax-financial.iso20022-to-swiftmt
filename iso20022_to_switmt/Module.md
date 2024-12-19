# Ballerina SWIFT MT to ISO 20022 Data Mapper Library

## Overview

The DataMapper Library is a comprehensive toolkit designed to convert ISO 20022 XML messages into SWIFT MT format within Ballerina applications. It simplifies the process of mapping ISO 20022 elements to their corresponding SWIFT MT fields, leveraging predefined records and parsers from the ISO 20022 and SWIFT MT libraries. This enables developers to seamlessly convert financial messages from the structured ISO 20022 XML standard into SWIFT MT record value format, ensuring accurate and efficient data conversion.

## Supported Conversions

- ISO 20022 to SWIFT MT 1XX Category
- ISO 20022 to SWIFT MT 2XX Category

## Usage

### Conversion of SWIFT fin message to ISO 20022 Xml Standard

```ballerina
import ballerina/io;
import ballerinax/financial.iso20022ToSwiftMT as mxToMt;

public function main() returns error? {
    string isoMessage = string `<Document xmlns="urn:iso:std:iso:20022:tech:xsd:camt.054.001.04">
    <BkToCstmrDbtCdtNtfctn>
        <GrpHdr>
            <MsgId>C11126A1378</MsgId>
            <CreDtTm>2024-12-16T12:00:00Z</CreDtTm>
        </GrpHdr>
        <Ntfctn>
            <Id>5482ABC</Id>
            <Acct>
                <Id>
                    <IBAN>CH9380000000009876543</IBAN>
                </Id>
            </Acct>
            <TxsSummry>
                <TtlAmt>
                    <Amt Ccy="USD">233530.00</Amt>
                </TtlAmt>
            </TxsSummry>
        </Ntfctn>
    </BkToCstmrDbtCdtNtfctn>
</Document>`;
    io:println(mxToMt:toSwiftMtMessage(finMessage));
}
```
