import ballerina/test;
import ballerinax/financial.iso20022 as swiftmx;
import ballerinax/financial.iso20022.payment_initiation as painIsoRecord;
import ballerinax/financial.iso20022.payments_clearing_and_settlement as pacsIsoRecord;
import ballerinax/financial.swift.mt as swiftmt;

@test:Config {}
function testTransformPain001DocumentToMT101() returns error? {
    xml documentXML = xml `
        <Pain001Document>
            <CstmrCdtTrfInitn>
                <GrpHdr>
                    <MsgId>83f55e7c-a2c6-44e1-a495-31231a36ac1</MsgId>
                    <CreDtTm>2024-11-01T06:14:29.252329200Z</CreDtTm>
                    <NbOfTxs>3</NbOfTxs>
                    <InitgPty>
                        <Id>
                            <OrgId/>
                            <PrvtId>
                                <Othr/>
                            </PrvtId>
                        </Id>
                    </InitgPty>
                </GrpHdr>
                <PmtInf>
                    <PmtInfId>11FF99RR</PmtInfId>
                    <PmtMtd>TRF</PmtMtd>
                    <PmtTpInf>
                        <SvcLvl>
                            <Cd/>
                        </SvcLvl>
                        <CtgyPurp>
                            <Cd/>
                        </CtgyPurp>
                    </PmtTpInf>
                    <ReqdExctnDt>
                        <Dt>2009-03-27</Dt>
                    </ReqdExctnDt>
                    <Dbtr>
                        <Nm>FINPETROL INC.</Nm>
                        <PstlAdr>
                            <AdrLine>ANDRELAE SPINKATU 7</AdrLine>
                        </PstlAdr>
                        <Id>
                            <OrgId/>
                            <PrvtId>
                                <Othr>
                                    <SchmeNm/>
                                </Othr>
                            </PrvtId>
                        </Id>
                    </Dbtr>
                    <DbtrAcct>
                        <Id>
                            <Othr>
                                <Id>9020123100</Id>
                                <SchmeNm>
                                    <Cd>BBAN</Cd>
                                </SchmeNm>
                            </Othr>
                        </Id>
                    </DbtrAcct>
                    <DbtrAgt>
                        <FinInstnId/>
                    </DbtrAgt>
                    <ChrgsAcct>
                        <Id>
                            <Othr>
                                <Id>9101000123</Id>
                                <SchmeNm>
                                    <Cd>BBAN</Cd>
                                </SchmeNm>
                            </Othr>
                        </Id>
                    </ChrgsAcct>
                    <CdtTrfTxInf>
                        <PmtId>
                            <InstrId>11FF99RR</InstrId>
                            <EndToEndId>REF501</EndToEndId>
                        </PmtId>
                        <Amt>
                            <InstdAmt>
                                <ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="USD">
                                    <ActiveOrHistoricCurrencyAndAmount_SimpleType>100000.00</ActiveOrHistoricCurrencyAndAmount_SimpleType>
                                </ActiveOrHistoricCurrencyAndAmount_SimpleType>
                            </InstdAmt>
                        </Amt>
                        <XchgRateInf>
                            <XchgRate>0.90</XchgRate>
                        </XchgRateInf>
                        <IntrmyAgt1>
                            <FinInstnId>
                                <PstlAdr/>
                            </FinInstnId>
                        </IntrmyAgt1>
                        <CdtrAgt>
                            <FinInstnId>
                                <LEI>/CP9999</LEI>
                                <PstlAdr/>
                            </FinInstnId>
                        </CdtrAgt>
                        <Cdtr>
                            <Nm>SOFTEASE PC GRAPHICS</Nm>
                            <PstlAdr>
                                <TwnNm>SEAFORD, NEW YORK, 11246</TwnNm>
                                <Ctry>US</Ctry>
                                <AdrLine>34 BRENTWOOD ROAD</AdrLine>
                            </PstlAdr>
                            <Id>
                                <OrgId/>
                            </Id>
                        </Cdtr>
                        <CdtrAcct>
                            <Id>
                                <Othr>
                                    <Id>756-857489-21</Id>
                                    <SchmeNm>
                                        <Cd>BBAN</Cd>
                                    </SchmeNm>
                                </Othr>
                            </Id>
                        </CdtrAcct>
                        <InstrForCdtrAgt/>
                        <InstrForDbtrAgt/>
                        <RgltryRptg>
                            <Dtls>
                                <Ctry>US</Ctry>
                                <Cd>BENEFRES</Cd>
                                <Inf>/34 BRENTWOOD ROAD SEAFORD, NEW YORK 11246</Inf>
                            </Dtls>
                        </RgltryRptg>
                        <RmtInf>
                            <Ustrd>/INV/19S95</Ustrd>
                        </RmtInf>
                    </CdtTrfTxInf>
                </PmtInf>
            </CstmrCdtTrfInitn>
        </Pain001Document>
    `;

    painIsoRecord:Pain001Document pain001Message =
        <painIsoRecord:Pain001Document>(check swiftmx:fromIso20022(documentXML, painIsoRecord:Pain001Document));
    swiftmt:MT101Message|error mt101Message = transformPain001DocumentToMT101(pain001Message);
    test:assertEquals(pain001Message.CstmrCdtTrfInitn.PmtInf[0].PmtInfId, "11FF99RR");

    if (mt101Message is swiftmt:MT101Message) {
        test:assertEquals(mt101Message.block2.messageType, "101");
    } else {
        test:assertFail("Error occurred while transforming Pain001 to MT101");
    }
}

@test:Config {}
function testTransformPacs008DocumentToMT102() returns error? {
    xml documentXML = xml `
        <Pacs008Document>
            <FIToFICstmrCdtTrf>
                <GrpHdr>
                    <MsgId>ABC123456789</MsgId>
                    <CreDtTm>2024-11-04T12:30:00Z</CreDtTm>
                    <NbOfTxs>1</NbOfTxs>
                    <SttlmInf>
                        <SttlmMtd></SttlmMtd>
                    </SttlmInf>
                    <InstgAgt>
                        <FinInstnId>
                            <BIC>DEUTDEFF</BIC>
                        </FinInstnId>
                    </InstgAgt>
                    <InstdAgt>
                        <FinInstnId>
                            <BIC>CHASUS33</BIC>
                        </FinInstnId>
                    </InstdAgt>
                </GrpHdr>
                <CdtTrfTxInf>
                    <PmtId>
                        <InstrId>INSTR123456789</InstrId>
                        <EndToEndId>E2E123456789</EndToEndId>
                        <TxId>TX123456789</TxId>
                    </PmtId>
                    <IntrBkSttlmAmt>\
                        <ActiveCurrencyAndAmount_SimpleType Ccy="USD">
                            <ActiveCurrencyAndAmount_SimpleType>100.00</ActiveCurrencyAndAmount_SimpleType>
                        </ActiveCurrencyAndAmount_SimpleType>
                    </IntrBkSttlmAmt>
                    <IntrBkSttlmDt>2024-11-04</IntrBkSttlmDt>
                    <ChrgsInf>
                        <Amt>\
                            <ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="USD">
                                <ActiveOrHistoricCurrencyAndAmount_SimpleType>5.00</ActiveOrHistoricCurrencyAndAmount_SimpleType>
                            </ActiveOrHistoricCurrencyAndAmount_SimpleType>
                        </Amt>
                        <Agt>
                            <FinInstnId>
                                <BIC>DEUTDEFF</BIC>
                            </FinInstnId>
                        </Agt>
                        <Tp>
                            <Prtry>CHRG</Prtry>
                            <Cd>CRED</Cd>
                        </Tp>
                    </ChrgsInf>
                    <ChrgBr></ChrgBr>
                    <Dbtr>
                        <Nm>John Doe</Nm>
                        <PstlAdr>
                            <StrtNm>Main Street</StrtNm>
                            <BldgNb>1</BldgNb>
                            <PstCd>12345</PstCd>
                            <TwnNm>Sampletown</TwnNm>
                            <Ctry>US</Ctry>
                        </PstlAdr>
                    </Dbtr>
                    <DbtrAcct>
                        <Id>
                            <IBAN>US12345678901234567890</IBAN>
                        </Id>
                    </DbtrAcct>
                    <DbtrAgt>
                        <FinInstnId>
                            <BIC>DEUTDEFF</BIC>
                        </FinInstnId>
                    </DbtrAgt>
                    <CdtrAgt>
                        <FinInstnId>
                            <BIC>CHASUS33</BIC>
                        </FinInstnId>
                    </CdtrAgt>
                    <Cdtr>
                        <Nm>Jane Smith</Nm>
                        <PstlAdr>
                            <StrtNm>Second Street</StrtNm>
                            <BldgNb>2</BldgNb>
                            <PstCd>54321</PstCd>
                            <TwnNm>Example City</TwnNm>
                            <Ctry>US</Ctry>
                        </PstlAdr>
                    </Cdtr>
                    <CdtrAcct>
                        <Id>
                            <IBAN>US09876543210987654321</IBAN>
                        </Id>
                    </CdtrAcct>
                    <RmtInf>
                        <Ustrd>Payment for invoice #12345</Ustrd>
                    </RmtInf>
                </CdtTrfTxInf>
            </FIToFICstmrCdtTrf>
        </Pacs008Document>
    `;

    pacsIsoRecord:Pacs008Document pacs008Message =
        <pacsIsoRecord:Pacs008Document>(check swiftmx:fromIso20022(documentXML, pacsIsoRecord:Pacs008Document));
    swiftmt:MT102Message|error mt102Message = transformPacs008DocumentToMT102(pacs008Message);

    if (mt102Message is swiftmt:MT102Message) {
        test:assertEquals(mt102Message.block2.messageType, "102");
    } else {
        test:assertFail("Error occurred while transforming Pacs008 to MT102");
    }
}

@test:Config {}
function testTransformPacs008DocumentToMT102STP() returns error? {
    xml documentXML = xml `
        <Pacs008Document>
            <FIToFICstmrCdtTrf>
                <GrpHdr>
                    <MsgId>ABC123456789</MsgId>
                    <CreDtTm>2024-11-04T12:30:00Z</CreDtTm>
                    <NbOfTxs>1</NbOfTxs>
                    <SttlmInf>
                        <SttlmMtd></SttlmMtd>
                    </SttlmInf>
                    <InstgAgt>
                        <FinInstnId>
                            <BIC>DEUTDEFF</BIC>
                        </FinInstnId>
                    </InstgAgt>
                    <InstdAgt>
                        <FinInstnId>
                            <BIC>CHASUS33</BIC>
                        </FinInstnId>
                    </InstdAgt>
                </GrpHdr>
                <CdtTrfTxInf>
                    <PmtId>
                        <InstrId>INSTR123456789</InstrId>
                        <EndToEndId>E2E123456789</EndToEndId>
                        <TxId>TX123456789</TxId>
                    </PmtId>
                    <IntrBkSttlmAmt>\
                        <ActiveCurrencyAndAmount_SimpleType Ccy="USD">
                            <ActiveCurrencyAndAmount_SimpleType>100.00</ActiveCurrencyAndAmount_SimpleType>
                        </ActiveCurrencyAndAmount_SimpleType>
                    </IntrBkSttlmAmt>
                    <IntrBkSttlmDt>2024-11-04</IntrBkSttlmDt>
                    <ChrgsInf>
                        <Amt>\
                            <ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="USD">
                                <ActiveOrHistoricCurrencyAndAmount_SimpleType>5.00</ActiveOrHistoricCurrencyAndAmount_SimpleType>
                            </ActiveOrHistoricCurrencyAndAmount_SimpleType>
                        </Amt>
                        <Agt>
                            <FinInstnId>
                                <BIC>DEUTDEFF</BIC>
                            </FinInstnId>
                        </Agt>
                        <Tp>
                            <Prtry>CHRG</Prtry>
                            <Cd>CRED</Cd>
                        </Tp>
                    </ChrgsInf>
                    <ChrgBr></ChrgBr>
                    <Dbtr>
                        <Nm>John Doe</Nm>
                        <PstlAdr>
                            <StrtNm>Main Street</StrtNm>
                            <BldgNb>1</BldgNb>
                            <PstCd>12345</PstCd>
                            <TwnNm>Sampletown</TwnNm>
                            <Ctry>US</Ctry>
                        </PstlAdr>
                    </Dbtr>
                    <DbtrAcct>
                        <Id>
                            <IBAN>US12345678901234567890</IBAN>
                        </Id>
                    </DbtrAcct>
                    <DbtrAgt>
                        <FinInstnId>
                            <BIC>DEUTDEFF</BIC>
                        </FinInstnId>
                    </DbtrAgt>
                    <CdtrAgt>
                        <FinInstnId>
                            <BIC>CHASUS33</BIC>
                        </FinInstnId>
                    </CdtrAgt>
                    <Cdtr>
                        <Nm>Jane Smith</Nm>
                        <PstlAdr>
                            <StrtNm>Second Street</StrtNm>
                            <BldgNb>2</BldgNb>
                            <PstCd>54321</PstCd>
                            <TwnNm>Example City</TwnNm>
                            <Ctry>US</Ctry>
                        </PstlAdr>
                    </Cdtr>
                    <CdtrAcct>
                        <Id>
                            <IBAN>US09876543210987654321</IBAN>
                        </Id>
                    </CdtrAcct>
                    <RmtInf>
                        <Ustrd>Payment for invoice #12345</Ustrd>
                    </RmtInf>
                </CdtTrfTxInf>
            </FIToFICstmrCdtTrf>
        </Pacs008Document>
    `;

    pacsIsoRecord:Pacs008Document pacs008Message =
        <pacsIsoRecord:Pacs008Document>(check swiftmx:fromIso20022(documentXML, pacsIsoRecord:Pacs008Document));
    swiftmt:MT102STPMessage|error mt102stpMessage = transformPacs008DocumentToMT102STP(pacs008Message);

    if (mt102stpMessage is swiftmt:MT102STPMessage) {
        test:assertEquals(mt102stpMessage.block2.messageType, "102STP");
    } else {
        test:assertFail("Error occurred while transforming Pacs008 to MT102STP");
    }
}

@test:Config {}
function testTransformPacs008DocumentToMT103() returns error? {
    xml documentXML = xml `
        <Pacs008Document>
            <FIToFICstmrCdtTrf>
                <GrpHdr>
                    <MsgId>ABC123456789</MsgId>
                    <CreDtTm>2024-11-04T12:30:00Z</CreDtTm>
                    <NbOfTxs>1</NbOfTxs>
                    <SttlmInf>
                        <SttlmMtd></SttlmMtd>
                    </SttlmInf>
                    <InstgAgt>
                        <FinInstnId>
                            <BIC>DEUTDEFF</BIC>
                        </FinInstnId>
                    </InstgAgt>
                    <InstdAgt>
                        <FinInstnId>
                            <BIC>CHASUS33</BIC>
                        </FinInstnId>
                    </InstdAgt>
                </GrpHdr>
                <CdtTrfTxInf>
                    <PmtId>
                        <InstrId>INSTR123456789</InstrId>
                        <EndToEndId>E2E123456789</EndToEndId>
                        <TxId>TX123456789</TxId>
                    </PmtId>
                    <IntrBkSttlmAmt>\
                        <ActiveCurrencyAndAmount_SimpleType Ccy="USD">
                            <ActiveCurrencyAndAmount_SimpleType>100.00</ActiveCurrencyAndAmount_SimpleType>
                        </ActiveCurrencyAndAmount_SimpleType>
                    </IntrBkSttlmAmt>
                    <IntrBkSttlmDt>2024-11-04</IntrBkSttlmDt>
                    <ChrgsInf>
                        <Amt>\
                            <ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="USD">
                                <ActiveOrHistoricCurrencyAndAmount_SimpleType>5.00</ActiveOrHistoricCurrencyAndAmount_SimpleType>
                            </ActiveOrHistoricCurrencyAndAmount_SimpleType>
                        </Amt>
                        <Agt>
                            <FinInstnId>
                                <BIC>DEUTDEFF</BIC>
                            </FinInstnId>
                        </Agt>
                        <Tp>
                            <Prtry>CHRG</Prtry>
                            <Cd>CRED</Cd>
                        </Tp>
                    </ChrgsInf>
                    <ChrgBr></ChrgBr>
                    <Dbtr>
                        <Nm>John Doe</Nm>
                        <PstlAdr>
                            <StrtNm>Main Street</StrtNm>
                            <BldgNb>1</BldgNb>
                            <PstCd>12345</PstCd>
                            <TwnNm>Sampletown</TwnNm>
                            <Ctry>US</Ctry>
                        </PstlAdr>
                    </Dbtr>
                    <DbtrAcct>
                        <Id>
                            <IBAN>US12345678901234567890</IBAN>
                        </Id>
                    </DbtrAcct>
                    <DbtrAgt>
                        <FinInstnId>
                            <BIC>DEUTDEFF</BIC>
                        </FinInstnId>
                    </DbtrAgt>
                    <CdtrAgt>
                        <FinInstnId>
                            <BIC>CHASUS33</BIC>
                        </FinInstnId>
                    </CdtrAgt>
                    <Cdtr>
                        <Nm>Jane Smith</Nm>
                        <PstlAdr>
                            <StrtNm>Second Street</StrtNm>
                            <BldgNb>2</BldgNb>
                            <PstCd>54321</PstCd>
                            <TwnNm>Example City</TwnNm>
                            <Ctry>US</Ctry>
                        </PstlAdr>
                    </Cdtr>
                    <CdtrAcct>
                        <Id>
                            <IBAN>US09876543210987654321</IBAN>
                        </Id>
                    </CdtrAcct>
                    <RmtInf>
                        <Ustrd>Payment for invoice #12345</Ustrd>
                    </RmtInf>
                </CdtTrfTxInf>
            </FIToFICstmrCdtTrf>
        </Pacs008Document>
    `;

    pacsIsoRecord:Pacs008Document pacs008Message =
        <pacsIsoRecord:Pacs008Document>(check swiftmx:fromIso20022(documentXML, pacsIsoRecord:Pacs008Document));
    swiftmt:MT103Message|error mt103Message = transformPacs008DocumentToMT103(pacs008Message);

    if (mt103Message is swiftmt:MT103Message) {
        test:assertEquals(mt103Message.block2.messageType, "103");
    } else {
        test:assertFail("Error occurred while transforming Pacs008 to MT103");
    }
}

@test:Config {}
function testTransformPacs008DocumentToMT103STP() returns error? {
    xml documentXML = xml `
        <Pacs008Document>
            <FIToFICstmrCdtTrf>
                <GrpHdr>
                    <MsgId>ABC123456789</MsgId>
                    <CreDtTm>2024-11-04T12:30:00Z</CreDtTm>
                    <NbOfTxs>1</NbOfTxs>
                    <SttlmInf>
                        <SttlmMtd></SttlmMtd>
                    </SttlmInf>
                    <InstgAgt>
                        <FinInstnId>
                            <BIC>DEUTDEFF</BIC>
                        </FinInstnId>
                    </InstgAgt>
                    <InstdAgt>
                        <FinInstnId>
                            <BIC>CHASUS33</BIC>
                        </FinInstnId>
                    </InstdAgt>
                </GrpHdr>
                <CdtTrfTxInf>
                    <PmtId>
                        <InstrId>INSTR123456789</InstrId>
                        <EndToEndId>E2E123456789</EndToEndId>
                        <TxId>TX123456789</TxId>
                    </PmtId>
                    <IntrBkSttlmAmt>\
                        <ActiveCurrencyAndAmount_SimpleType Ccy="USD">
                            <ActiveCurrencyAndAmount_SimpleType>100.00</ActiveCurrencyAndAmount_SimpleType>
                        </ActiveCurrencyAndAmount_SimpleType>
                    </IntrBkSttlmAmt>
                    <IntrBkSttlmDt>2024-11-04</IntrBkSttlmDt>
                    <ChrgsInf>
                        <Amt>\
                            <ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="USD">
                                <ActiveOrHistoricCurrencyAndAmount_SimpleType>5.00</ActiveOrHistoricCurrencyAndAmount_SimpleType>
                            </ActiveOrHistoricCurrencyAndAmount_SimpleType>
                        </Amt>
                        <Agt>
                            <FinInstnId>
                                <BIC>DEUTDEFF</BIC>
                            </FinInstnId>
                        </Agt>
                        <Tp>
                            <Prtry>CHRG</Prtry>
                            <Cd>CRED</Cd>
                        </Tp>
                    </ChrgsInf>
                    <ChrgBr></ChrgBr>
                    <Dbtr>
                        <Nm>John Doe</Nm>
                        <PstlAdr>
                            <StrtNm>Main Street</StrtNm>
                            <BldgNb>1</BldgNb>
                            <PstCd>12345</PstCd>
                            <TwnNm>Sampletown</TwnNm>
                            <Ctry>US</Ctry>
                        </PstlAdr>
                    </Dbtr>
                    <DbtrAcct>
                        <Id>
                            <IBAN>US12345678901234567890</IBAN>
                        </Id>
                    </DbtrAcct>
                    <DbtrAgt>
                        <FinInstnId>
                            <BIC>DEUTDEFF</BIC>
                        </FinInstnId>
                    </DbtrAgt>
                    <CdtrAgt>
                        <FinInstnId>
                            <BIC>CHASUS33</BIC>
                        </FinInstnId>
                    </CdtrAgt>
                    <Cdtr>
                        <Nm>Jane Smith</Nm>
                        <PstlAdr>
                            <StrtNm>Second Street</StrtNm>
                            <BldgNb>2</BldgNb>
                            <PstCd>54321</PstCd>
                            <TwnNm>Example City</TwnNm>
                            <Ctry>US</Ctry>
                        </PstlAdr>
                    </Cdtr>
                    <CdtrAcct>
                        <Id>
                            <IBAN>US09876543210987654321</IBAN>
                        </Id>
                    </CdtrAcct>
                    <RmtInf>
                        <Ustrd>Payment for invoice #12345</Ustrd>
                    </RmtInf>
                </CdtTrfTxInf>
            </FIToFICstmrCdtTrf>
        </Pacs008Document>
    `;

    pacsIsoRecord:Pacs008Document pacs008Message =
        <pacsIsoRecord:Pacs008Document>(check swiftmx:fromIso20022(documentXML, pacsIsoRecord:Pacs008Document));
    swiftmt:MT103STPMessage|error mt103stpMessage = transformPacs008DocumentToMT103STP(pacs008Message);

    if (mt103stpMessage is swiftmt:MT103STPMessage) {
        test:assertEquals(mt103stpMessage.block2.messageType, "103STP");
    } else {
        test:assertFail("Error occurred while transforming Pacs008 to MT103STP");
    }
}

@test:Config {}
function testTransformPacs008DocumentToMT103REMIT() returns error? {
    xml documentXML = xml `
        <Pacs008Document>
            <FIToFICstmrCdtTrf>
                <GrpHdr>
                    <MsgId>ABC123456789</MsgId>
                    <CreDtTm>2024-11-04T12:30:00Z</CreDtTm>
                    <NbOfTxs>1</NbOfTxs>
                    <SttlmInf>
                        <SttlmMtd></SttlmMtd>
                    </SttlmInf>
                    <InstgAgt>
                        <FinInstnId>
                            <BIC>DEUTDEFF</BIC>
                        </FinInstnId>
                    </InstgAgt>
                    <InstdAgt>
                        <FinInstnId>
                            <BIC>CHASUS33</BIC>
                        </FinInstnId>
                    </InstdAgt>
                </GrpHdr>
                <CdtTrfTxInf>
                    <PmtId>
                        <InstrId>INSTR123456789</InstrId>
                        <EndToEndId>E2E123456789</EndToEndId>
                        <TxId>TX123456789</TxId>
                    </PmtId>
                    <IntrBkSttlmAmt>\
                        <ActiveCurrencyAndAmount_SimpleType Ccy="USD">
                            <ActiveCurrencyAndAmount_SimpleType>100.00</ActiveCurrencyAndAmount_SimpleType>
                        </ActiveCurrencyAndAmount_SimpleType>
                    </IntrBkSttlmAmt>
                    <IntrBkSttlmDt>2024-11-04</IntrBkSttlmDt>
                    <ChrgsInf>
                        <Amt>\
                            <ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="USD">
                                <ActiveOrHistoricCurrencyAndAmount_SimpleType>5.00</ActiveOrHistoricCurrencyAndAmount_SimpleType>
                            </ActiveOrHistoricCurrencyAndAmount_SimpleType>
                        </Amt>
                        <Agt>
                            <FinInstnId>
                                <BIC>DEUTDEFF</BIC>
                            </FinInstnId>
                        </Agt>
                        <Tp>
                            <Prtry>CHRG</Prtry>
                            <Cd>CRED</Cd>
                        </Tp>
                    </ChrgsInf>
                    <ChrgBr></ChrgBr>
                    <Dbtr>
                        <Nm>John Doe</Nm>
                        <PstlAdr>
                            <StrtNm>Main Street</StrtNm>
                            <BldgNb>1</BldgNb>
                            <PstCd>12345</PstCd>
                            <TwnNm>Sampletown</TwnNm>
                            <Ctry>US</Ctry>
                        </PstlAdr>
                    </Dbtr>
                    <DbtrAcct>
                        <Id>
                            <IBAN>US12345678901234567890</IBAN>
                        </Id>
                    </DbtrAcct>
                    <DbtrAgt>
                        <FinInstnId>
                            <BIC>DEUTDEFF</BIC>
                        </FinInstnId>
                    </DbtrAgt>
                    <CdtrAgt>
                        <FinInstnId>
                            <BIC>CHASUS33</BIC>
                        </FinInstnId>
                    </CdtrAgt>
                    <Cdtr>
                        <Nm>Jane Smith</Nm>
                        <PstlAdr>
                            <StrtNm>Second Street</StrtNm>
                            <BldgNb>2</BldgNb>
                            <PstCd>54321</PstCd>
                            <TwnNm>Example City</TwnNm>
                            <Ctry>US</Ctry>
                        </PstlAdr>
                    </Cdtr>
                    <CdtrAcct>
                        <Id>
                            <IBAN>US09876543210987654321</IBAN>
                        </Id>
                    </CdtrAcct>
                    <RmtInf>
                        <Ustrd>Payment for invoice #12345</Ustrd>
                    </RmtInf>
                </CdtTrfTxInf>
            </FIToFICstmrCdtTrf>
        </Pacs008Document>
    `;

    pacsIsoRecord:Pacs008Document pacs008Message =
        <pacsIsoRecord:Pacs008Document>(check swiftmx:fromIso20022(documentXML, pacsIsoRecord:Pacs008Document));
    swiftmt:MT103REMITMessage|error mt103remitMessage = transformPacs008DocumentToMT103REMIT(pacs008Message);

    if (mt103remitMessage is swiftmt:MT103REMITMessage) {
        test:assertEquals(mt103remitMessage.block2.messageType, "103REMIT");
    } else {
        test:assertFail("Error occurred while transforming Pacs008 to MT103REMIT");
    }
}

// @test:Config {}
// function testTransformPain008DocumentToMT104() returns error? {
//     xml documentXML = xml `
//         <Pain008Document>
//             <CstmrDrctDbtInitn>
//                 <GrpHdr>
//                     <MsgId>EXAMPLE123456</MsgId>
//                     <CreDtTm>2024-11-06T09:30:00Z</CreDtTm>
//                     <NbOfTxs>2</NbOfTxs>
//                     <CtrlSum>1500.00</CtrlSum>
//                     <InitgPty>
//                         <Nm>ABC Corporation</Nm>
//                         <Id>
//                             <OrgId>
//                                 <AnyBIC>ABCDEF12</AnyBIC>
//                             </OrgId>
//                         </Id>
//                     </InitgPty>
//                 </GrpHdr>
//                 <PmtInf>
//                     <PmtInfId>PMT20241106</PmtInfId>
//                     <PmtMtd></PmtMtd>
//                     <BtchBookg>true</BtchBookg>
//                     <NbOfTxs>2</NbOfTxs>
//                     <CtrlSum>1500.00</CtrlSum>
//                     <PmtTpInf>
//                         <InstrPrty></InstrPrty>
//                         <SvcLvl>
//                             <Cd>SEPA</Cd>
//                         </SvcLvl>
//                     </PmtTpInf>
//                     <ReqdColltnDt>2024-11-07</ReqdColltnDt>
//                     <Cdtr>
//                         <Nm>XYZ Ltd</Nm>
//                         <PstlAdr>
//                             <Ctry>DE</Ctry>
//                             <AdrLine>123 Main Street</AdrLine>
//                         </PstlAdr>
//                     </Cdtr>
//                     <CdtrAcct>
//                         <Id>
//                             <IBAN>DE89370400440532013000</IBAN>
//                         </Id>
//                     </CdtrAcct>
//                     <CdtrAgt>
//                         <FinInstnId>
//                             <BICFI>DEUTDEFF</BICFI>
//                         </FinInstnId>
//                     </CdtrAgt>
//                     <ChrgBr></ChrgBr>
//                     <DrctDbtTxInf>
//                         <PmtId>
//                             <InstrId>INSTR12345</InstrId>
//                             <EndToEndId>ETOE12345</EndToEndId>
//                         </PmtId>
//                         <InstdAmt Ccy="USD">100.00</InstdAmt>
//                         <DrctDbtTx>
//                             <MndtRltdInf>
//                                 <MndtId>MANDATE123</MndtId>
//                                 <DtOfSgntr>2024-01-01</DtOfSgntr>
//                             </MndtRltdInf>
//                         </DrctDbtTx>
//                         <DbtrAgt>
//                             <FinInstnId>
//                                 <BICFI>DEUTDEBB</BICFI>
//                             </FinInstnId>
//                         </DbtrAgt>
//                         <Dbtr>
//                             <Nm>John Doe</Nm>
//                             <PstlAdr>
//                                 <Ctry>DE</Ctry>
//                                 <AdrLine>456 Sample Avenue</AdrLine>
//                             </PstlAdr>
//                         </Dbtr>
//                         <DbtrAcct>
//                             <Id>
//                                 <IBAN>DE62370400440532013001</IBAN>
//                             </Id>
//                         </DbtrAcct>
//                         <RmtInf>
//                             <Ustrd>Invoice 12345</Ustrd>
//                         </RmtInf>
//                     </DrctDbtTxInf>
//                     <DrctDbtTxInf>
//                         <PmtId>
//                             <InstrId>INSTR67890</InstrId>
//                             <EndToEndId>ETOE67890</EndToEndId>
//                         </PmtId>
//                         <InstdAmt Ccy="USD">500.00</InstdAmt>
//                         <DrctDbtTx>
//                             <MndtRltdInf>
//                                 <MndtId>MANDATE678</MndtId>
//                                 <DtOfSgntr>2024-05-15</DtOfSgntr>
//                             </MndtRltdInf>
//                         </DrctDbtTx>
//                         <DbtrAgt>
//                             <FinInstnId>
//                                 <BICFI>DEUTDEBB</BICFI>
//                             </FinInstnId>
//                         </DbtrAgt>
//                         <Dbtr>
//                             <Nm>Jane Smith</Nm>
//                             <PstlAdr>
//                                 <Ctry>DE</Ctry>
//                                 <AdrLine>789 Test Blvd</AdrLine>
//                             </PstlAdr>
//                         </Dbtr>
//                         <DbtrAcct>
//                             <Id>
//                                 <IBAN>DE89370400440532013002</IBAN>
//                             </Id>
//                         </DbtrAcct>
//                         <RmtInf>
//                             <Ustrd>Invoice 67890</Ustrd>
//                         </RmtInf>
//                     </DrctDbtTxInf>
//                 </PmtInf>
//             </CstmrDrctDbtInitn>
//         </Pain008Document>
//         `;
//     painIsoRecord:Pain008Document pain008Message = <painIsoRecord:Pain008Document>(check swiftmx:fromIso20022(documentXML, painIsoRecord:Pain008Document));

//     swiftmt:MT104Message|error mt104Message = transformPain008DocumentToMT104(pain008Message);

//     if (mt104Message is swiftmt:MT104Message) {
//         test:assertEquals(mt104Message.block2.messageType, "104");
//     } else {
//         test:assertFail("Error occurred while transforming Pain008 to MT104");
//     }
// }

@test:Config {}
function testTransformPacs003DocumenttoMT104() returns error? {
    // Define the test Pacs003Document XML
    xml documentXML = xml `
        <Pacs003Document>
            <FIToFICstmrDrctDbt>
                <GrpHdr></GrpHdr>
                <DrctDbtTxInf>
                    <PmtId>
                        <InstrId>ABC/123</InstrId>
                        <EndToEndId>REF100</EndToEndId>
                        <TxId>REF100</TxId>
                    </PmtId>
                    <PmtTpInf>
                        <CtgyPurp>
                            <Cd>AUTH</Cd>
                        </CtgyPurp>
                    </PmtTpInf>
                    <IntrBkSttlmAmt>
                        <ActiveCurrencyAndAmount_SimpleType Ccy="USD">
                            <ActiveCurrencyAndAmount_SimpleType>1000.00</ActiveCurrencyAndAmount_SimpleType>
                        </ActiveCurrencyAndAmount_SimpleType>
                    </IntrBkSttlmAmt>
                    <IntrBkSttlmDt>2022-10-24</IntrBkSttlmDt>
                    <InstdAmt>
                        <ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="USD">
                            <ActiveOrHistoricCurrencyAndAmount_SimpleType>1000.00</ActiveOrHistoricCurrencyAndAmount_SimpleType>
                        </ActiveOrHistoricCurrencyAndAmount_SimpleType>
                    </InstdAmt>
                    <ChrgBr>CRED</ChrgBr>
                    <DrctDbtTx>
                        <MndtRltdInf/>
                    </DrctDbtTx>
                    <Cdtr>
                        <PstlAdr/>
                        <Id>
                            <OrgId/>
                        </Id>
                    </Cdtr>
                    <CdtrAcct>
                        <Id>
                            <Othr>
                                <SchmeNm/>
                            </Othr>
                        </Id>
                    </CdtrAcct>
                    <CdtrAgt>
                        <FinInstnId>
                            <PstlAdr/>
                        </FinInstnId>
                    </CdtrAgt>
                    <InitgPty>
                        <Id>
                            <OrgId/>
                            <PrvtId>
                                <Othr/>
                            </PrvtId>
                        </Id>
                    </InitgPty>
                    <IntrmyAgt1>
                        <FinInstnId/>
                    </IntrmyAgt1>
                    <Dbtr>
                        <Nm>JOHANN WILLEMS</Nm>
                        <PstlAdr>
                            <AdrLine>RUE JOSEPH II, 19</AdrLine>
                            <AdrLine>1040 BRUSSELS</AdrLine>
                        </PstlAdr>
                        <Id>
                            <OrgId/>
                        </Id>
                    </Dbtr>
                    <DbtrAcct>
                        <Id>
                            <IBAN>BE62510007547061</IBAN>
                            <Othr>
                                <SchmeNm/>
                            </Othr>
                        </Id>
                    </DbtrAcct>
                    <DbtrAgt>
                        <FinInstnId>
                            <PstlAdr/>
                        </FinInstnId>
                    </DbtrAgt>
                    <RmtInf>
                        <Ustrd/>
                    </RmtInf>
                </DrctDbtTxInf>
            </FIToFICstmrDrctDbt>
        </Pacs003Document>
    `;

    // Parse the Pacs003Document XML
    pacsIsoRecord:Pacs003Document pacs003Message =
        <pacsIsoRecord:Pacs003Document>(check swiftmx:fromIso20022(documentXML, pacsIsoRecord:Pacs003Document));

    // Transform the Pacs003Document to MT104
    swiftmt:MT104Message|error mt104Message = transformPacs003DocumentToMT104(pacs003Message);

    // Validate the transformation
    if (mt104Message is swiftmt:MT104Message) {
        test:assertEquals(mt104Message.block2.messageType, "104");
    } else {
        test:assertFail("Error occurred while transforming Pacs003 to MT104");
    }
}

