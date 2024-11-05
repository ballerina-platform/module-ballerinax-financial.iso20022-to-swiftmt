import ballerina/io;
import ballerinax/financial.iso20022 as SwiftMx;
import ballerinax/financial.iso20022.payment_initiation as SwiftMxRecords;

public function main() returns error? {
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

    SwiftMxRecords:Pain001Document document =
        <SwiftMxRecords:Pain001Document>(check SwiftMx:fromIso20022(documentXML, SwiftMxRecords:Pain001Document));

    io:println(document);

    io:println(transformPain001DocumentToMT101(document));

}
