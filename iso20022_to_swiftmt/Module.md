## Overview

The ISO 20022 to SWIFT MT connector provides a comprehensive toolkit designed to convert ISO 20022 XML messages into SWIFT MT format. It simplifies the process of mapping ISO 20022 elements to their corresponding SWIFT MT fields, leveraging predefined records and parsers from the ISO 20022 and SWIFT MT libraries. This enables developers to seamlessly convert financial messages from the structured ISO 20022 XML standard into SWIFT MT record value format, ensuring accurate and efficient data conversion.

### Key Features

- Convert ISO 20022 XML messages (pain, pacs, camt) to SWIFT MT format
- Support for a wide range of MT message types including MT101 through MT210 and MTn92 through MTn96
- Predefined mappings that leverage ISO 20022 and SWIFT MT library records and parsers
- Seamless integration for accurate and efficient financial message data conversion

## Supported Conversions

- pain.001.001.12 to SWIFT MT101
- pacs.008.001.12 to SWIFT MT102
- pacs.008.001.12 to SWIFT MT102STP
- pacs.008.001.12 to SWIFT MT103
- pacs.008.001.12 to SWIFT MT103STP
- pacs.008.001.12 to SWIFT MT103REMIT
- pacs.003.001.11 to SWIFT MT104
- pacs.003.001.11 to SWIFT MT107
- pacs.009.001.11 to SWIFT MT200
- pacs.009.001.11 to SWIFT MT201
- pacs.009.001.11 to SWIFT MT202
- pacs.009.001.11 to SWIFT MT202COV
- pacs.009.001.11 to SWIFT MT203
- pacs.010.001.06 to SWIFT MT204
- pacs.009.001.11 to SWIFT MT205
- pacs.009.001.11 to SWIFT MT205COV
- camt.057.001.08 to SWIFT MT210
- camt.056.001.11 to SWIFT MTn92
- camt.026.001.10 to SWIFT MTn95
- camt.029.001.13 to SWIFT MTn96

## Usage

### Conversion of ISO 20022 xml to SWIFT MT message

```ballerina
import ballerina/io;
import ballerinax/financial.iso20022ToSwiftMT as mxToMt;

public function main() returns error? {
    xml isoMessage = xml `<Envelope><Document xmlns="urn:iso:std:iso:20022:tech:xsd:camt.057.001.08">
    <NtfctnToRcv>
        <GrpHdr>
        <MsgId>318393</MsgId>
        <CreDtTm>2025-01-01T10:12:11.802172400Z</CreDtTm>
        </GrpHdr>
        <Ntfctn>
        <Id>318393</Id>
        <Itm>
            <Id>BEBEBB0023CRESZZ</Id>
            <EndToEndId>BEBEBB0023CRESZZ</EndToEndId>
            <Acct>
            <Id>
                <Othr>
                <SchmeNm/>
                </Othr>
            </Id>
            </Acct>
            <Amt>
            <ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="USD">
                <ActiveOrHistoricCurrencyAndAmount_SimpleType>230000.00</ActiveOrHistoricCurrencyAndAmount_SimpleType>
            </ActiveOrHistoricCurrencyAndAmount_SimpleType>
            </Amt>
            <XpctdValDt>2010-02-22</XpctdValDt>
            <Dbtr>
            <Pty>
                <PstlAdr/>
                <Id>
                <OrgId/>
                <PrvtId>
                    <Othr>
                    <SchmeNm/>
                    </Othr>
                </PrvtId>
                </Id>
            </Pty>
            </Dbtr>
            <DbtrAgt>
            <FinInstnId>
                <BICFI>CRESCHZZ</BICFI>
                <ClrSysMmbId>
                <ClrSysId/>
                <MmbId/>
                </ClrSysMmbId>
                <PstlAdr/>
            </FinInstnId>
            </DbtrAgt>
            <IntrmyAgt>
            <FinInstnId>
                <BICFI>CITIUS33</BICFI>
                <ClrSysMmbId>
                <ClrSysId/>
                <MmbId/>
                </ClrSysMmbId>
                <PstlAdr/>
            </FinInstnId>
            </IntrmyAgt>
        </Itm>
        </Ntfctn>
    </NtfctnToRcv>
    </Document>
</Envelope>`;
    io:println(mxToMt:toSwiftMtMessage(isoMessage));
}
```
