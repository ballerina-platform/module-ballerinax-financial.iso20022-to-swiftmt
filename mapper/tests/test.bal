import ballerina/data.xmldata;
// import ballerina/io;
import ballerina/test;
// import ballerinax/financial.iso20022 as swiftmx;
import ballerinax/financial.iso20022.payment_initiation as painIsoRecord;
import ballerinax/financial.iso20022.payments_clearing_and_settlement as pacsIsoRecord;
import ballerinax/financial.swift.mt as swiftmt;

@test:Config {}
function testTransformPain001DocumentToMT101() returns error? {
    xml documentXML = xml `<Document xmlns="urn:iso:std:iso:20022:tech:xsd:pain.001.001.12"><CstmrCdtTrfInitn><GrpHdr><MsgId>EXAMPLE123456</MsgId><CreDtTm>2024-11-06T09:30:00Z</CreDtTm>${
""}<NbOfTxs>2</NbOfTxs><CtrlSum>1500.00</CtrlSum><InitgPty><Nm>ABC Corporation</Nm><Id><OrgId><AnyBIC>ABCDEF12</AnyBIC></OrgId></Id></InitgPty></GrpHdr><PmtInf><PmtInfId>11FF99RR</PmtInfId><PmtMtd>${
""}TRF</PmtMtd><PmtTpInf><SvcLvl/><CtgyPurp/></PmtTpInf><ReqdExctnDt><Dt>2009-03-27</Dt><DtTm/></ReqdExctnDt><Dbtr><Nm>${
""}FINPETROL INC.</Nm><PstlAdr><AdrLine>ANDRELAE SPINKATU 7</AdrLine></PstlAdr><Id><OrgId/><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><Othr><Id>${
""}9020123100</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId/></DbtrAgt>${
""}<ChrgsAcct><Id><Othr><Id>9101000123</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></ChrgsAcct><CdtTrfTxInf><PmtId><InstrId>${
""}11FF99RR</InstrId><EndToEndId>REF501</EndToEndId></PmtId><Amt><InstdAmt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="USD"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}100000.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></InstdAmt></Amt><XchgRateInf><XchgRate>${
""}0.90</XchgRate></XchgRateInf><IntrmyAgt1><FinInstnId><PstlAdr/></FinInstnId></IntrmyAgt1><CdtrAgt><FinInstnId><LEI>${
""}/CP9999</LEI><PstlAdr/></FinInstnId></CdtrAgt><Cdtr><Nm>SOFTEASE PC GRAPHICS</Nm><PstlAdr><TwnNm>SEAFORD, NEW YORK, ${
""}11246</TwnNm><Ctry>US</Ctry><AdrLine>34 BRENTWOOD ROAD</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>${
""}756-857489-21</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><InstrForCdtrAgt/><InstrForDbtrAgt/><RgltryRptg><Dtls><Ctry>${
""}US</Ctry><Cd>BENEFRES</Cd><Inf>34 BRENTWOOD ROAD SEAFORD, NEW YORK 11246</Inf></Dtls></RgltryRptg><RmtInf><Ustrd>${
""}/INV/19S95</Ustrd></RmtInf></CdtTrfTxInf></PmtInf><PmtInf><PmtInfId>11FF99RR</PmtInfId><PmtMtd>TRF</PmtMtd><PmtTpInf><SvcLvl/><CtgyPurp/></PmtTpInf><ReqdExctnDt><Dt>${
""}2009-03-27</Dt><DtTm/></ReqdExctnDt><Dbtr><Nm>FINPETROL INC.</Nm><PstlAdr><TwnNm>HELSINKI</TwnNm><Ctry>FI</Ctry><AdrLine>${
""}ANDRELAE SPINKATU 7</AdrLine></PstlAdr><Id><OrgId/><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><Othr><Id>${
""}9020123100</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId/></DbtrAgt>${
""}<ChrgsAcct><Id><Othr><Id>9101000123</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></ChrgsAcct><CdtTrfTxInf><PmtId><InstrId>${
""}11FF99RR</InstrId><EndToEndId>REF502</EndToEndId></PmtId><Amt><InstdAmt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="USD"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}2000.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></InstdAmt></Amt><XchgRateInf><XchgRate>${
""}0.9</XchgRate></XchgRateInf><IntrmyAgt1><FinInstnId><PstlAdr/></FinInstnId></IntrmyAgt1><CdtrAgt><FinInstnId><PstlAdr/></FinInstnId></CdtrAgt><Cdtr><Nm>${
""}MYRTLE AVENUE 3159</Nm><PstlAdr><AdrLine>US/BROOKLYN, NEW YORK 11245</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>${
""}TONY BALONEY</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><InstrForCdtrAgt><Cd>${
""}CHQB</Cd></InstrForCdtrAgt><InstrForDbtrAgt/><RmtInf><Ustrd>09-02 PENSION PAYMENT</Ustrd></RmtInf></CdtTrfTxInf></PmtInf><PmtInf><PmtInfId>${
""}11FF99RR</PmtInfId><PmtMtd>TRF</PmtMtd><PmtTpInf><SvcLvl/><CtgyPurp><Cd>INTC</Cd></CtgyPurp></PmtTpInf><ReqdExctnDt><Dt>2009-03-27</Dt><DtTm/></ReqdExctnDt><Dbtr><Nm>${
""}FINPETROL INC.</Nm><PstlAdr><TwnNm>HELSINKI</TwnNm><Ctry>FI</Ctry><AdrLine>ANDRELAE SPINKATU ${
""}7</AdrLine></PstlAdr><Id><OrgId/><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><Othr><Id>${
""}9102099999</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId><BICFI>CHXXUS33BBB</BICFI></FinInstnId></DbtrAgt>${
""}<ChrgsAcct><Id><Othr><SchmeNm/></Othr></Id></ChrgsAcct><CdtTrfTxInf><PmtId><InstrId>11FF99RR</InstrId><EndToEndId>${
""}REF503</EndToEndId></PmtId><Amt><InstdAmt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="USD"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}0</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></InstdAmt></Amt><XchgRateInf/><IntrmyAgt1><FinInstnId><PstlAdr/></FinInstnId></IntrmyAgt1><CdtrAgt><FinInstnId><PstlAdr/></FinInstnId></CdtrAgt><Cdtr><Nm>${
""}FINPETROL INC.</Nm><PstlAdr><TwnNm>HELSINKI</TwnNm><Ctry>FI</Ctry><AdrLine>ANDRELAE SPINKATU 7</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>${
""}9020123100</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><InstrForCdtrAgt/><InstrForDbtrAgt><Cd>${
""}CMZB</Cd></InstrForDbtrAgt><RmtInf><Ustrd/></RmtInf></CdtTrfTxInf></PmtInf></CstmrCdtTrfInitn></Document>`;

    painIsoRecord:Pain001Document pain001Message = check xmldata:parseAsType(documentXML);
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
    xml documentXML = xml `<Document xmlns="urn:iso:std:iso:20022:tech:xsd:pacs.008.001.12"><FIToFICstmrCdtTrf><GrpHdr><MsgId>ABC123456789</MsgId>${
""}<CreDtTm>2024-11-04T12:30:00Z</CreDtTm><NbOfTxs>1</NbOfTxs><SttlmInf><SttlmMtd></SttlmMtd></SttlmInf><InstgAgt><FinInstnId><BIC>DEUTDEFF</BIC></FinInstnId></InstgAgt><InstdAgt><FinInstnId><BIC>CHASUS33</BIC></FinInstnId></InstdAgt></GrpHdr><CdtTrfTxInf><PmtId><InstrId>${
""}5362/MPB</InstrId><EndToEndId>ABC/123</EndToEndId><TxId>ABC/123</TxId><UETR>4ea37e81-98ec-4014-b7a4-1ff4611b3fca${
""}</UETR></PmtId><IntrBkSttlmAmt><ActiveCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveCurrencyAndAmount_SimpleType>${
""}1250.00</ActiveCurrencyAndAmount_SimpleType></ActiveCurrencyAndAmount_SimpleType></IntrBkSttlmAmt><IntrBkSttlmDt>${
""}2009-08-28</IntrBkSttlmDt><SttlmTmIndctn/><SttlmTmReq/><InstdAmt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}2000.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></InstdAmt><XchgRate>${
""}1.6</XchgRate><ChrgBr></ChrgBr><ChrgsInf><Amt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}5.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></Amt><Agt><FinInstnId/></Agt><Tp><Cd>${
""}</Cd></Tp></ChrgsInf><PrvsInstgAgt1><FinInstnId/></PrvsInstgAgt1><Dbtr><Nm>CONSORTIA PENSION SCHEME</Nm><PstlAdr><AdrLine>${
""}FRIEDRICHSTRASSE, 27</AdrLine><AdrLine>8022-ZURICH</AdrLine></PstlAdr><Id><OrgId/><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><IBAN>${
""}AL47212110090000000235698741</IBAN><Othr><SchmeNm/></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId/></DbtrAgt><CdtrAgt><FinInstnId/></CdtrAgt><Cdtr><Nm>${
""}JOHANN WILLEMS</Nm><PstlAdr><AdrLine>RUE JOSEPH II, 19</AdrLine><AdrLine>1040 BRUSSELS</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>${
""}001161685134</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><InstrForCdtrAgt/><InstrForNxtAgt/><Purp><Cd/></Purp><RmtInf><Ustrd>${
""}PENSION PAYMENT SEPTEMBER 2009</Ustrd></RmtInf></CdtTrfTxInf><CdtTrfTxInf><PmtId><InstrId>5362/MPB</InstrId><EndToEndId>${
""}ABC/124</EndToEndId><TxId>ABC/124</TxId><UETR>4ea37e81-98ec-4014-b7a4-1ff4611b3fca</UETR></PmtId><IntrBkSttlmAmt><ActiveCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveCurrencyAndAmount_SimpleType>${
""}1875.00</ActiveCurrencyAndAmount_SimpleType></ActiveCurrencyAndAmount_SimpleType></IntrBkSttlmAmt><IntrBkSttlmDt>${
""}2009-08-28</IntrBkSttlmDt><SttlmTmIndctn/><SttlmTmReq/><InstdAmt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}3000.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></InstdAmt><XchgRate>${
""}1.6</XchgRate><ChrgBr></ChrgBr><ChrgsInf><Amt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}5.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></Amt><Agt><FinInstnId/></Agt><Tp><Cd>${
""}</Cd></Tp></ChrgsInf><PrvsInstgAgt1><FinInstnId/></PrvsInstgAgt1><Dbtr><Nm>CONSORTIA PENSION SCHEME</Nm><PstlAdr><AdrLine>${
""}FRIEDRICHSTRASSE, 27</AdrLine><AdrLine>8022-ZURICH</AdrLine></PstlAdr><Id><OrgId/><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><IBAN>${
""}AL47212110090000000235698741</IBAN><Othr><SchmeNm/></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId/></DbtrAgt><CdtrAgt><FinInstnId/></CdtrAgt><Cdtr><Nm>${
""}JOAN MILLS</Nm><PstlAdr><AdrLine>AVENUE LOUISE 213</AdrLine><AdrLine>1050 BRUSSELS</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>${
""}510007547061</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><InstrForCdtrAgt/><InstrForNxtAgt/><Purp><Cd/></Purp><RmtInf><Ustrd>${
""}PENSION PAYMENT SEPTEMBER 2003</Ustrd></RmtInf></CdtTrfTxInf></FIToFICstmrCdtTrf></Document>`;

    pacsIsoRecord:Pacs008Document pacs008Message = check xmldata:parseAsType(documentXML);
    swiftmt:MT102Message|error mt102Message = transformPacs008DocumentToMT102(pacs008Message);

    if (mt102Message is swiftmt:MT102Message) {
        test:assertEquals(mt102Message.block2.messageType, "102");
    } else {
        test:assertFail("Error occurred while transforming Pacs008 to MT102");
    }
}

@test:Config {}
function testTransformPacs008DocumentToMT102STP() returns error? {
    xml documentXML = xml `<Document xmlns="urn:iso:std:iso:20022:tech:xsd:pacs.008.001.12"><FIToFICstmrCdtTrf><GrpHdr><MsgId>ABC123456789</MsgId>${
""}<CreDtTm>2024-11-04T12:30:00Z</CreDtTm><NbOfTxs>1</NbOfTxs><SttlmInf><SttlmMtd></SttlmMtd></SttlmInf><InstgAgt><FinInstnId><BIC>DEUTDEFF</BIC></FinInstnId></InstgAgt><InstdAgt><FinInstnId><BIC>CHASUS33</BIC></FinInstnId></InstdAgt></GrpHdr><CdtTrfTxInf><PmtId><InstrId>${
""}5362/MPB</InstrId><EndToEndId>ABC/123</EndToEndId><TxId>ABC/123</TxId><UETR>4ea37e81-98ec-4014-b7a4-1ff4611b3fca${
""}</UETR></PmtId><IntrBkSttlmAmt><ActiveCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveCurrencyAndAmount_SimpleType>${
""}1250.00</ActiveCurrencyAndAmount_SimpleType></ActiveCurrencyAndAmount_SimpleType></IntrBkSttlmAmt><IntrBkSttlmDt>${
""}2009-08-28</IntrBkSttlmDt><SttlmTmIndctn/><SttlmTmReq/><InstdAmt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}2000.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></InstdAmt><XchgRate>${
""}1.6</XchgRate><ChrgBr></ChrgBr><ChrgsInf><Amt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}5.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></Amt><Agt><FinInstnId/></Agt><Tp><Cd>${
""}</Cd></Tp></ChrgsInf><PrvsInstgAgt1><FinInstnId/></PrvsInstgAgt1><Dbtr><Nm>CONSORTIA PENSION SCHEME</Nm><PstlAdr><AdrLine>${
""}FRIEDRICHSTRASSE, 27</AdrLine><AdrLine>8022-ZURICH</AdrLine></PstlAdr><Id><OrgId/><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><IBAN>${
""}AL47212110090000000235698741</IBAN><Othr><SchmeNm/></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId/></DbtrAgt><CdtrAgt><FinInstnId/></CdtrAgt><Cdtr><Nm>${
""}JOHANN WILLEMS</Nm><PstlAdr><AdrLine>RUE JOSEPH II, 19</AdrLine><AdrLine>1040 BRUSSELS</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>${
""}001161685134</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><InstrForCdtrAgt/><InstrForNxtAgt/><Purp><Cd/></Purp><RmtInf><Ustrd>${
""}PENSION PAYMENT SEPTEMBER 2009</Ustrd></RmtInf></CdtTrfTxInf><CdtTrfTxInf><PmtId><InstrId>5362/MPB</InstrId><EndToEndId>${
""}ABC/124</EndToEndId><TxId>ABC/124</TxId><UETR>4ea37e81-98ec-4014-b7a4-1ff4611b3fca</UETR></PmtId><IntrBkSttlmAmt><ActiveCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveCurrencyAndAmount_SimpleType>${
""}1875.00</ActiveCurrencyAndAmount_SimpleType></ActiveCurrencyAndAmount_SimpleType></IntrBkSttlmAmt><IntrBkSttlmDt>${
""}2009-08-28</IntrBkSttlmDt><SttlmTmIndctn/><SttlmTmReq/><InstdAmt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}3000.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></InstdAmt><XchgRate>${
""}1.6</XchgRate><ChrgBr></ChrgBr><ChrgsInf><Amt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}5.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></Amt><Agt><FinInstnId/></Agt><Tp><Cd>${
""}</Cd></Tp></ChrgsInf><PrvsInstgAgt1><FinInstnId/></PrvsInstgAgt1><Dbtr><Nm>CONSORTIA PENSION SCHEME</Nm><PstlAdr><AdrLine>${
""}FRIEDRICHSTRASSE, 27</AdrLine><AdrLine>8022-ZURICH</AdrLine></PstlAdr><Id><OrgId/><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><IBAN>${
""}AL47212110090000000235698741</IBAN><Othr><SchmeNm/></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId/></DbtrAgt><CdtrAgt><FinInstnId/></CdtrAgt><Cdtr><Nm>${
""}JOAN MILLS</Nm><PstlAdr><AdrLine>AVENUE LOUISE 213</AdrLine><AdrLine>1050 BRUSSELS</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>${
""}510007547061</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><InstrForCdtrAgt/><InstrForNxtAgt/><Purp><Cd/></Purp><RmtInf><Ustrd>${
""}PENSION PAYMENT SEPTEMBER 2003</Ustrd></RmtInf></CdtTrfTxInf></FIToFICstmrCdtTrf></Document>`;

    pacsIsoRecord:Pacs008Document pacs008Message = check xmldata:parseAsType(documentXML);
    swiftmt:MT102STPMessage|error mt102stpMessage = transformPacs008DocumentToMT102STP(pacs008Message);

    if (mt102stpMessage is swiftmt:MT102STPMessage) {
        test:assertEquals(mt102stpMessage.block2.messageType, "102STP");
    } else {
        test:assertFail("Error occurred while transforming Pacs008 to MT102STP");
    }
}

@test:Config {}
function testTransformPacs008DocumentToMT103() returns error? {
    xml documentXML = xml `<Document xmlns="urn:iso:std:iso:20022:tech:xsd:pacs.008.001.12"><FIToFICstmrCdtTrf><GrpHdr><MsgId>ABC123456789</MsgId>${
""}<CreDtTm>2024-11-04T12:30:00Z</CreDtTm><NbOfTxs>1</NbOfTxs><SttlmInf><SttlmMtd></SttlmMtd></SttlmInf><InstgAgt><FinInstnId><BIC>DEUTDEFF</BIC></FinInstnId></InstgAgt><InstdAgt><FinInstnId><BIC>CHASUS33</BIC></FinInstnId></InstdAgt></GrpHdr><CdtTrfTxInf><PmtId><InstrId>${
""}5362/MPB</InstrId><EndToEndId>ABC/123</EndToEndId><TxId>ABC/123</TxId><UETR>4ea37e81-98ec-4014-b7a4-1ff4611b3fca${
""}</UETR></PmtId><IntrBkSttlmAmt><ActiveCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveCurrencyAndAmount_SimpleType>${
""}1250.00</ActiveCurrencyAndAmount_SimpleType></ActiveCurrencyAndAmount_SimpleType></IntrBkSttlmAmt><IntrBkSttlmDt>${
""}2009-08-28</IntrBkSttlmDt><SttlmTmIndctn/><SttlmTmReq/><InstdAmt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}2000.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></InstdAmt><XchgRate>${
""}1.6</XchgRate><ChrgBr></ChrgBr><ChrgsInf><Amt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}5.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></Amt><Agt><FinInstnId/></Agt><Tp><Cd>${
""}</Cd></Tp></ChrgsInf><PrvsInstgAgt1><FinInstnId/></PrvsInstgAgt1><Dbtr><Nm>CONSORTIA PENSION SCHEME</Nm><PstlAdr><AdrLine>${
""}FRIEDRICHSTRASSE, 27</AdrLine><AdrLine>8022-ZURICH</AdrLine></PstlAdr><Id><OrgId/><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><IBAN>${
""}AL47212110090000000235698741</IBAN><Othr><SchmeNm/></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId/></DbtrAgt><CdtrAgt><FinInstnId/></CdtrAgt><Cdtr><Nm>${
""}JOHANN WILLEMS</Nm><PstlAdr><AdrLine>RUE JOSEPH II, 19</AdrLine><AdrLine>1040 BRUSSELS</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>${
""}001161685134</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><InstrForCdtrAgt/><InstrForNxtAgt/><Purp><Cd/></Purp><RmtInf><Ustrd>${
""}PENSION PAYMENT SEPTEMBER 2009</Ustrd></RmtInf></CdtTrfTxInf><CdtTrfTxInf><PmtId><InstrId>5362/MPB</InstrId><EndToEndId>${
""}ABC/124</EndToEndId><TxId>ABC/124</TxId><UETR>4ea37e81-98ec-4014-b7a4-1ff4611b3fca</UETR></PmtId><IntrBkSttlmAmt><ActiveCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveCurrencyAndAmount_SimpleType>${
""}1875.00</ActiveCurrencyAndAmount_SimpleType></ActiveCurrencyAndAmount_SimpleType></IntrBkSttlmAmt><IntrBkSttlmDt>${
""}2009-08-28</IntrBkSttlmDt><SttlmTmIndctn/><SttlmTmReq/><InstdAmt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}3000.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></InstdAmt><XchgRate>${
""}1.6</XchgRate><ChrgBr></ChrgBr><ChrgsInf><Amt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}5.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></Amt><Agt><FinInstnId/></Agt><Tp><Cd>${
""}</Cd></Tp></ChrgsInf><PrvsInstgAgt1><FinInstnId/></PrvsInstgAgt1><Dbtr><Nm>CONSORTIA PENSION SCHEME</Nm><PstlAdr><AdrLine>${
""}FRIEDRICHSTRASSE, 27</AdrLine><AdrLine>8022-ZURICH</AdrLine></PstlAdr><Id><OrgId/><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><IBAN>${
""}AL47212110090000000235698741</IBAN><Othr><SchmeNm/></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId/></DbtrAgt><CdtrAgt><FinInstnId/></CdtrAgt><Cdtr><Nm>${
""}JOAN MILLS</Nm><PstlAdr><AdrLine>AVENUE LOUISE 213</AdrLine><AdrLine>1050 BRUSSELS</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>${
""}510007547061</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><InstrForCdtrAgt/><InstrForNxtAgt/><Purp><Cd/></Purp><RmtInf><Ustrd>${
""}PENSION PAYMENT SEPTEMBER 2003</Ustrd></RmtInf></CdtTrfTxInf></FIToFICstmrCdtTrf></Document>`;

    pacsIsoRecord:Pacs008Document pacs008Message = check xmldata:parseAsType(documentXML);
    swiftmt:MT103Message|error mt103Message = transformPacs008DocumentToMT103(pacs008Message);

    if (mt103Message is swiftmt:MT103Message) {
        test:assertEquals(mt103Message.block2.messageType, "103");
    } else {
        test:assertFail("Error occurred while transforming Pacs008 to MT103");
    }
}

@test:Config {}
function testTransformPacs008DocumentToMT103STP() returns error? {
    xml documentXML = xml `<Document xmlns="urn:iso:std:iso:20022:tech:xsd:pacs.008.001.12"><FIToFICstmrCdtTrf><GrpHdr><MsgId>ABC123456789</MsgId>${
""}<CreDtTm>2024-11-04T12:30:00Z</CreDtTm><NbOfTxs>1</NbOfTxs><SttlmInf><SttlmMtd></SttlmMtd></SttlmInf><InstgAgt><FinInstnId><BIC>DEUTDEFF</BIC></FinInstnId></InstgAgt><InstdAgt><FinInstnId><BIC>CHASUS33</BIC></FinInstnId></InstdAgt></GrpHdr><CdtTrfTxInf><PmtId><InstrId>${
""}5362/MPB</InstrId><EndToEndId>ABC/123</EndToEndId><TxId>ABC/123</TxId><UETR>4ea37e81-98ec-4014-b7a4-1ff4611b3fca${
""}</UETR></PmtId><IntrBkSttlmAmt><ActiveCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveCurrencyAndAmount_SimpleType>${
""}1250.00</ActiveCurrencyAndAmount_SimpleType></ActiveCurrencyAndAmount_SimpleType></IntrBkSttlmAmt><IntrBkSttlmDt>${
""}2009-08-28</IntrBkSttlmDt><SttlmTmIndctn/><SttlmTmReq/><InstdAmt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}2000.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></InstdAmt><XchgRate>${
""}1.6</XchgRate><ChrgBr></ChrgBr><ChrgsInf><Amt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}5.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></Amt><Agt><FinInstnId/></Agt><Tp><Cd>${
""}</Cd></Tp></ChrgsInf><PrvsInstgAgt1><FinInstnId/></PrvsInstgAgt1><Dbtr><Nm>CONSORTIA PENSION SCHEME</Nm><PstlAdr><AdrLine>${
""}FRIEDRICHSTRASSE, 27</AdrLine><AdrLine>8022-ZURICH</AdrLine></PstlAdr><Id><OrgId/><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><IBAN>${
""}AL47212110090000000235698741</IBAN><Othr><SchmeNm/></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId/></DbtrAgt><CdtrAgt><FinInstnId/></CdtrAgt><Cdtr><Nm>${
""}JOHANN WILLEMS</Nm><PstlAdr><AdrLine>RUE JOSEPH II, 19</AdrLine><AdrLine>1040 BRUSSELS</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>${
""}001161685134</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><InstrForCdtrAgt/><InstrForNxtAgt/><Purp><Cd/></Purp><RmtInf><Ustrd>${
""}PENSION PAYMENT SEPTEMBER 2009</Ustrd></RmtInf></CdtTrfTxInf><CdtTrfTxInf><PmtId><InstrId>5362/MPB</InstrId><EndToEndId>${
""}ABC/124</EndToEndId><TxId>ABC/124</TxId><UETR>4ea37e81-98ec-4014-b7a4-1ff4611b3fca</UETR></PmtId><IntrBkSttlmAmt><ActiveCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveCurrencyAndAmount_SimpleType>${
""}1875.00</ActiveCurrencyAndAmount_SimpleType></ActiveCurrencyAndAmount_SimpleType></IntrBkSttlmAmt><IntrBkSttlmDt>${
""}2009-08-28</IntrBkSttlmDt><SttlmTmIndctn/><SttlmTmReq/><InstdAmt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}3000.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></InstdAmt><XchgRate>${
""}1.6</XchgRate><ChrgBr></ChrgBr><ChrgsInf><Amt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}5.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></Amt><Agt><FinInstnId/></Agt><Tp><Cd>${
""}</Cd></Tp></ChrgsInf><PrvsInstgAgt1><FinInstnId/></PrvsInstgAgt1><Dbtr><Nm>CONSORTIA PENSION SCHEME</Nm><PstlAdr><AdrLine>${
""}FRIEDRICHSTRASSE, 27</AdrLine><AdrLine>8022-ZURICH</AdrLine></PstlAdr><Id><OrgId/><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><IBAN>${
""}AL47212110090000000235698741</IBAN><Othr><SchmeNm/></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId/></DbtrAgt><CdtrAgt><FinInstnId/></CdtrAgt><Cdtr><Nm>${
""}JOAN MILLS</Nm><PstlAdr><AdrLine>AVENUE LOUISE 213</AdrLine><AdrLine>1050 BRUSSELS</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>${
""}510007547061</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><InstrForCdtrAgt/><InstrForNxtAgt/><Purp><Cd/></Purp><RmtInf><Ustrd>${
""}PENSION PAYMENT SEPTEMBER 2003</Ustrd></RmtInf></CdtTrfTxInf></FIToFICstmrCdtTrf></Document>`;

    pacsIsoRecord:Pacs008Document pacs008Message = check xmldata:parseAsType(documentXML);
    swiftmt:MT103STPMessage|error mt103stpMessage = transformPacs008DocumentToMT103STP(pacs008Message);

    if (mt103stpMessage is swiftmt:MT103STPMessage) {
        test:assertEquals(mt103stpMessage.block2.messageType, "103STP");
    } else {
        test:assertFail("Error occurred while transforming Pacs008 to MT103STP");
    }
}

@test:Config {}
function testTransformPacs008DocumentToMT103REMIT() returns error? {
    xml documentXML = xml `<Document xmlns="urn:iso:std:iso:20022:tech:xsd:pacs.008.001.12"><FIToFICstmrCdtTrf><GrpHdr><MsgId>ABC123456789</MsgId>${
""}<CreDtTm>2024-11-04T12:30:00Z</CreDtTm><NbOfTxs>1</NbOfTxs><SttlmInf><SttlmMtd></SttlmMtd></SttlmInf><InstgAgt><FinInstnId><BIC>DEUTDEFF</BIC></FinInstnId></InstgAgt><InstdAgt><FinInstnId><BIC>CHASUS33</BIC></FinInstnId></InstdAgt></GrpHdr><CdtTrfTxInf><PmtId><InstrId>${
""}5362/MPB</InstrId><EndToEndId>ABC/123</EndToEndId><TxId>ABC/123</TxId><UETR>4ea37e81-98ec-4014-b7a4-1ff4611b3fca${
""}</UETR></PmtId><IntrBkSttlmAmt><ActiveCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveCurrencyAndAmount_SimpleType>${
""}1250.00</ActiveCurrencyAndAmount_SimpleType></ActiveCurrencyAndAmount_SimpleType></IntrBkSttlmAmt><IntrBkSttlmDt>${
""}2009-08-28</IntrBkSttlmDt><SttlmTmIndctn/><SttlmTmReq/><InstdAmt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}2000.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></InstdAmt><XchgRate>${
""}1.6</XchgRate><ChrgBr></ChrgBr><ChrgsInf><Amt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}5.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></Amt><Agt><FinInstnId/></Agt><Tp><Cd>${
""}</Cd></Tp></ChrgsInf><PrvsInstgAgt1><FinInstnId/></PrvsInstgAgt1><Dbtr><Nm>CONSORTIA PENSION SCHEME</Nm><PstlAdr><AdrLine>${
""}FRIEDRICHSTRASSE, 27</AdrLine><AdrLine>8022-ZURICH</AdrLine></PstlAdr><Id><OrgId/><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><IBAN>${
""}AL47212110090000000235698741</IBAN><Othr><SchmeNm/></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId/></DbtrAgt><CdtrAgt><FinInstnId/></CdtrAgt><Cdtr><Nm>${
""}JOHANN WILLEMS</Nm><PstlAdr><AdrLine>RUE JOSEPH II, 19</AdrLine><AdrLine>1040 BRUSSELS</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>${
""}001161685134</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><InstrForCdtrAgt/><InstrForNxtAgt/><Purp><Cd/></Purp><RmtInf><Ustrd>${
""}PENSION PAYMENT SEPTEMBER 2009</Ustrd></RmtInf></CdtTrfTxInf><CdtTrfTxInf><PmtId><InstrId>5362/MPB</InstrId><EndToEndId>${
""}ABC/124</EndToEndId><TxId>ABC/124</TxId><UETR>4ea37e81-98ec-4014-b7a4-1ff4611b3fca</UETR></PmtId><IntrBkSttlmAmt><ActiveCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveCurrencyAndAmount_SimpleType>${
""}1875.00</ActiveCurrencyAndAmount_SimpleType></ActiveCurrencyAndAmount_SimpleType></IntrBkSttlmAmt><IntrBkSttlmDt>${
""}2009-08-28</IntrBkSttlmDt><SttlmTmIndctn/><SttlmTmReq/><InstdAmt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}3000.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></InstdAmt><XchgRate>${
""}1.6</XchgRate><ChrgBr></ChrgBr><ChrgsInf><Amt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}5.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></Amt><Agt><FinInstnId/></Agt><Tp><Cd>${
""}</Cd></Tp></ChrgsInf><PrvsInstgAgt1><FinInstnId/></PrvsInstgAgt1><Dbtr><Nm>CONSORTIA PENSION SCHEME</Nm><PstlAdr><AdrLine>${
""}FRIEDRICHSTRASSE, 27</AdrLine><AdrLine>8022-ZURICH</AdrLine></PstlAdr><Id><OrgId/><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><IBAN>${
""}AL47212110090000000235698741</IBAN><Othr><SchmeNm/></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId/></DbtrAgt><CdtrAgt><FinInstnId/></CdtrAgt><Cdtr><Nm>${
""}JOAN MILLS</Nm><PstlAdr><AdrLine>AVENUE LOUISE 213</AdrLine><AdrLine>1050 BRUSSELS</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>${
""}510007547061</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><InstrForCdtrAgt/><InstrForNxtAgt/><Purp><Cd/></Purp><RmtInf><Ustrd>${
""}PENSION PAYMENT SEPTEMBER 2003</Ustrd></RmtInf></CdtTrfTxInf></FIToFICstmrCdtTrf></Document>`;

    pacsIsoRecord:Pacs008Document pacs008Message = check xmldata:parseAsType(documentXML);
    swiftmt:MT103REMITMessage|error mt103remitMessage = transformPacs008DocumentToMT103REMIT(pacs008Message);

    if (mt103remitMessage is swiftmt:MT103REMITMessage) {
        test:assertEquals(mt103remitMessage.block2.messageType, "103REMIT");
    } else {
        test:assertFail("Error occurred while transforming Pacs008 to MT103REMIT");
    }
}

@test:Config {}
function testTransformPain008DocumentToMT104() returns error? {
    xml documentXML = xml `<Document xmlns="urn:iso:std:iso:20022:tech:xsd:pain.008.001.11"><CstmrDrctDbtInitn><GrpHdr><MsgId>EXAMPLE123456</MsgId><CreDtTm>2024-11-06T09:30:00Z</CreDtTm><NbOfTxs>2</NbOfTxs><CtrlSum>1500.00</CtrlSum><InitgPty><Nm>ABC Corporation</Nm><Id><OrgId><AnyBIC>ABCDEF12</AnyBIC></OrgId></Id></InitgPty></GrpHdr><PmtInf><PmtInfId>REF12444</PmtInfId><PmtMtd>${
""}DD</PmtMtd><PmtTpInf><CtgyPurp><Cd>RFDD</Cd></CtgyPurp></PmtTpInf><ReqdColltnDt>2009-09-21${
""}</ReqdColltnDt><Cdtr><PstlAdr/><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct><CdtrAgt><FinInstnId><PstlAdr/></FinInstnId></CdtrAgt><ChrgBr>${
""}DEBT</ChrgBr><DrctDbtTxInf><PmtId><InstrId>REFERENCE12345</InstrId><EndToEndId>REF12444</EndToEndId></PmtId><InstdAmt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}1875.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></InstdAmt><DrctDbtTx><MndtRltdInf/></DrctDbtTx><DbtrAgt><FinInstnId><PstlAdr/></FinInstnId></DbtrAgt><Dbtr><PstlAdr/><Id><OrgId/></Id></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><Purp><Cd/></Purp><RgltryRptg><Dtls><Ctry>${
""}BE</Ctry><Cd>ORDERRES</Cd><Inf>MEILAAN 1, 9000 GENT</Inf></Dtls></RgltryRptg><RmtInf><Ustrd/></RmtInf></DrctDbtTxInf></PmtInf><PmtInf><PmtInfId>${
""}REF12345</PmtInfId><PmtMtd>DD</PmtMtd><PmtTpInf><CtgyPurp><Cd>RFDD</Cd></CtgyPurp></PmtTpInf><ReqdColltnDt>2009-09-21${
""}</ReqdColltnDt><Cdtr><PstlAdr/><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct><CdtrAgt><FinInstnId><PstlAdr/></FinInstnId></CdtrAgt><ChrgBr>${
""}DEBT</ChrgBr><DrctDbtTxInf><PmtId><InstrId>REFERENCE12345</InstrId><EndToEndId>REF12345</EndToEndId></PmtId><InstdAmt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}1875.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></InstdAmt><DrctDbtTx><MndtRltdInf/></DrctDbtTx><DbtrAgt><FinInstnId><PstlAdr/></FinInstnId></DbtrAgt><Dbtr><PstlAdr/><Id><OrgId/></Id></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><Purp><Cd/></Purp><RgltryRptg><Dtls><Ctry>${
""}BE</Ctry><Cd>ORDERRES</Cd><Inf>MEILAAN 1, 9000 GENT</Inf></Dtls></RgltryRptg><RmtInf><Ustrd/></RmtInf></DrctDbtTxInf></PmtInf></CstmrDrctDbtInitn></Document>`;

    painIsoRecord:Pain008Document pain008Message = check xmldata:parseAsType(documentXML);
    swiftmt:MT104Message|error mt104Message = transformPain008DocumentToMT104(pain008Message);

    if (mt104Message is swiftmt:MT104Message) {
        test:assertEquals(mt104Message.block2.messageType, "104");
    } else {
        test:assertFail("Error occurred while transforming Pain008 to MT104");
    }
}

@test:Config {}
function testTransformPacs003DocumenttoMT104() returns error? {
    xml documentXML = xml `<Document xmlns="urn:iso:std:iso:20022:tech:xsd:pacs.003.001.11"><FIToFICstmrDrctDbt><GrpHdr><MsgId>MSG12345</MsgId><CreDtTm>2024-11-19T09:00:00Z</CreDtTm><NbOfTxs>2</NbOfTxs><CtrlSum>3750.00</CtrlSum><TtlIntrBkSttlmAmt><ActiveCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveCurrencyAndAmount_SimpleType>1875.00</ActiveCurrencyAndAmount_SimpleType></ActiveCurrencyAndAmount_SimpleType></TtlIntrBkSttlmAmt><IntrBkSttlmDt>2024-11-19</IntrBkSttlmDt><InstgAgt>${
""}<FinInstnId><BIC>INSTG123</BIC></FinInstnId></InstgAgt><InstdAgt><FinInstnId><BIC>INSTD456</BIC></FinInstnId></InstdAgt><SttlmInf><SttlmMtd>INDA</SttlmMtd></SttlmInf></GrpHdr><DrctDbtTxInf><PmtId><InstrId>REFERENCE12345${
""}</InstrId><EndToEndId>REF12444</EndToEndId><TxId>REF12444</TxId></PmtId><PmtTpInf><CtgyPurp><Cd>OTHR</Cd></CtgyPurp></PmtTpInf><IntrBkSttlmAmt><ActiveCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveCurrencyAndAmount_SimpleType>${
""}1875.00</ActiveCurrencyAndAmount_SimpleType></ActiveCurrencyAndAmount_SimpleType></IntrBkSttlmAmt><IntrBkSttlmDt>${
""}2009-09-21</IntrBkSttlmDt><InstdAmt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}1875.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></InstdAmt><ChrgBr>${
""}DEBT</ChrgBr><DrctDbtTx><MndtRltdInf/></DrctDbtTx><Cdtr><PstlAdr/><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct><CdtrAgt><FinInstnId><PstlAdr/></FinInstnId></CdtrAgt><InitgPty><Id><OrgId/><PrvtId><Othr/></PrvtId></Id></InitgPty><IntrmyAgt1><FinInstnId/></IntrmyAgt1><Dbtr><PstlAdr/><Id><OrgId/></Id></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId><PstlAdr/></FinInstnId></DbtrAgt><RgltryRptg><Dtls><Ctry>${
""}BE</Ctry><Cd>ORDERRES</Cd><Inf>MEILAAN 1, 9000 GENT</Inf></Dtls></RgltryRptg><RmtInf><Ustrd/></RmtInf></DrctDbtTxInf><DrctDbtTxInf><PmtId><InstrId>${
""}REFERENCE12345</InstrId><EndToEndId>REF12345</EndToEndId><TxId>REF12345</TxId></PmtId><PmtTpInf><CtgyPurp><Cd>OTHR</Cd></CtgyPurp></PmtTpInf><IntrBkSttlmAmt><ActiveCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveCurrencyAndAmount_SimpleType>${
""}1875.00</ActiveCurrencyAndAmount_SimpleType></ActiveCurrencyAndAmount_SimpleType></IntrBkSttlmAmt><IntrBkSttlmDt>${
""}2009-09-21</IntrBkSttlmDt><InstdAmt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}1875.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></InstdAmt><ChrgBr>${
""}DEBT</ChrgBr><DrctDbtTx><MndtRltdInf/></DrctDbtTx><Cdtr><PstlAdr/><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct><CdtrAgt><FinInstnId><PstlAdr/></FinInstnId></CdtrAgt><InitgPty><Id><OrgId/><PrvtId><Othr/></PrvtId></Id></InitgPty><IntrmyAgt1><FinInstnId/></IntrmyAgt1><Dbtr><PstlAdr/><Id><OrgId/></Id></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId><PstlAdr/></FinInstnId></DbtrAgt><RgltryRptg><Dtls><Ctry>${
""}BE</Ctry><Cd>ORDERRES</Cd><Inf>MEILAAN 1, 9000 GENT</Inf></Dtls></RgltryRptg><RmtInf><Ustrd/></RmtInf></DrctDbtTxInf></FIToFICstmrDrctDbt></Document>`;

    // Parse the Pacs003Document XML
    pacsIsoRecord:Pacs003Document pacs003Message = check xmldata:parseAsType(documentXML);

    // Transform the Pacs003Document to MT104
    swiftmt:MT104Message|error mt104Message = transformPacs003DocumentToMT104(pacs003Message);

    // Validate the transformation
    if (mt104Message is swiftmt:MT104Message) {
        test:assertEquals(mt104Message.block2.messageType, "104");
    } else {
        test:assertFail("Error occurred while transforming Pacs003 to MT104");
    }
}

@test:Config {}
function testTransformPacs003DocumenttoMT107() returns error? {
    xml documentXML = xml `<Document xmlns="urn:iso:std:iso:20022:tech:xsd:pacs.003.001.11"><FIToFICstmrDrctDbt><GrpHdr><MsgId>MSG12345</MsgId><CreDtTm>2024-11-19T09:00:00Z</CreDtTm><NbOfTxs>2</NbOfTxs><CtrlSum>3750.00</CtrlSum><TtlIntrBkSttlmAmt><ActiveCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveCurrencyAndAmount_SimpleType>1875.00</ActiveCurrencyAndAmount_SimpleType></ActiveCurrencyAndAmount_SimpleType></TtlIntrBkSttlmAmt><IntrBkSttlmDt>2024-11-19</IntrBkSttlmDt><InstgAgt>${
""}<FinInstnId><BIC>INSTG123</BIC></FinInstnId></InstgAgt><InstdAgt><FinInstnId><BIC>INSTD456</BIC></FinInstnId></InstdAgt><SttlmInf><SttlmMtd>INDA</SttlmMtd></SttlmInf></GrpHdr><DrctDbtTxInf><PmtId><InstrId>REFERENCE12345${
""}</InstrId><EndToEndId>REF12444</EndToEndId><TxId>REF12444</TxId></PmtId><PmtTpInf><CtgyPurp><Cd>OTHR</Cd></CtgyPurp></PmtTpInf><IntrBkSttlmAmt><ActiveCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveCurrencyAndAmount_SimpleType>${
""}1875.00</ActiveCurrencyAndAmount_SimpleType></ActiveCurrencyAndAmount_SimpleType></IntrBkSttlmAmt><IntrBkSttlmDt>${
""}2009-09-21</IntrBkSttlmDt><InstdAmt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}1875.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></InstdAmt><ChrgBr>${
""}DEBT</ChrgBr><DrctDbtTx><MndtRltdInf/></DrctDbtTx><Cdtr><PstlAdr/><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct><CdtrAgt><FinInstnId><PstlAdr/></FinInstnId></CdtrAgt><InitgPty><Id><OrgId/><PrvtId><Othr/></PrvtId></Id></InitgPty><IntrmyAgt1><FinInstnId/></IntrmyAgt1><Dbtr><PstlAdr/><Id><OrgId/></Id></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId><PstlAdr/></FinInstnId></DbtrAgt><RgltryRptg><Dtls><Ctry>${
""}BE</Ctry><Cd>ORDERRES</Cd><Inf>MEILAAN 1, 9000 GENT</Inf></Dtls></RgltryRptg><RmtInf><Ustrd/></RmtInf></DrctDbtTxInf><DrctDbtTxInf><PmtId><InstrId>${
""}REFERENCE12345</InstrId><EndToEndId>REF12345</EndToEndId><TxId>REF12345</TxId></PmtId><PmtTpInf><CtgyPurp><Cd>OTHR</Cd></CtgyPurp></PmtTpInf><IntrBkSttlmAmt><ActiveCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveCurrencyAndAmount_SimpleType>${
""}1875.00</ActiveCurrencyAndAmount_SimpleType></ActiveCurrencyAndAmount_SimpleType></IntrBkSttlmAmt><IntrBkSttlmDt>${
""}2009-09-21</IntrBkSttlmDt><InstdAmt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}1875.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></InstdAmt><ChrgBr>${
""}DEBT</ChrgBr><DrctDbtTx><MndtRltdInf/></DrctDbtTx><Cdtr><PstlAdr/><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><SchmeNm/></Othr></Id></CdtrAcct><CdtrAgt><FinInstnId><PstlAdr/></FinInstnId></CdtrAgt><InitgPty><Id><OrgId/><PrvtId><Othr/></PrvtId></Id></InitgPty><IntrmyAgt1><FinInstnId/></IntrmyAgt1><Dbtr><PstlAdr/><Id><OrgId/></Id></Dbtr><DbtrAcct><Id><Othr><SchmeNm/></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId><PstlAdr/></FinInstnId></DbtrAgt><RgltryRptg><Dtls><Ctry>${
""}BE</Ctry><Cd>ORDERRES</Cd><Inf>MEILAAN 1, 9000 GENT</Inf></Dtls></RgltryRptg><RmtInf><Ustrd/></RmtInf></DrctDbtTxInf></FIToFICstmrDrctDbt></Document>`;

    // Parse the Pacs003Document XML
    pacsIsoRecord:Pacs003Document pacs003Message = check xmldata:parseAsType(documentXML);

    // Transform the Pacs003Document to MT104
    swiftmt:MT107Message|error mt107Message = transformPacs003DocumentToMT107(pacs003Message);

    // Validate the transformation
    if (mt107Message is swiftmt:MT107Message) {
        test:assertEquals(mt107Message.block2.messageType, "107");
    } else {
        test:assertFail("Error occurred while transforming Pacs003 to MT107");
    }
}

