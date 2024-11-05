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
        test:assertFail("Error occurred while transforming Pacs008 to MT102");
    }
}



