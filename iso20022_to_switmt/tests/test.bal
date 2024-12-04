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

import ballerina/data.xmldata;
import ballerina/io;
import ballerina/log;
import ballerina/test;
import ballerinax/financial.iso20022.cash_management as camtIsoRecord;
import ballerinax/financial.iso20022.payment_initiation as painIsoRecord;
import ballerinax/financial.iso20022.payments_clearing_and_settlement as pacsIsoRecord;
import ballerinax/financial.swift.mt as swiftmt;

@test:Config {}
function testTransformPain001DocumentToMT101() returns error? {
    xml documentXML = xml `<Document xmlns="urn:iso:std:iso:20022:tech:xsd:pain.001.001.12"><CstmrCdtTrfInitn><GrpHdr><MsgId>EXAMPLE123456</MsgId><CreDtTm>2024-11-06T09:30:00Z</CreDtTm>${
""}<NbOfTxs>2</NbOfTxs><CtrlSum>1500.00</CtrlSum><InitgPty><Nm>ABC Corporation</Nm><Id><OrgId><AnyBIC>ABCDEF12</AnyBIC></OrgId></Id></InitgPty></GrpHdr><PmtInf><PmtInfId>11FF99RR</PmtInfId><PmtMtd>${
""}TRF</PmtMtd><PmtTpInf><SvcLvl/><CtgyPurp/></PmtTpInf><ReqdExctnDt><Dt>2009-03-27</Dt><DtTm/></ReqdExctnDt><Dbtr><Nm>${
""}FINPETROL INC.</Nm><PstlAdr><AdrLine>ANDRELAE SPINKATU 7</AdrLine></PstlAdr><Id><OrgId/><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><Othr><Id>${
""}9020123100</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId/></DbtrAgt><ChrgBr>${
""}SHAR</ChrgBr><ChrgsAcct><Id><Othr><Id>9101000123</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></ChrgsAcct><CdtTrfTxInf><PmtId><InstrId>${
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
""}9020123100</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId/></DbtrAgt><ChrgBr>${
""}DEBT</ChrgBr><ChrgsAcct><Id><Othr><Id>9101000123</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></ChrgsAcct><CdtTrfTxInf><PmtId><InstrId>${
""}11FF99RR</InstrId><EndToEndId>REF502</EndToEndId></PmtId><Amt><InstdAmt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="USD"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}2000.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></InstdAmt></Amt><XchgRateInf><XchgRate>${
""}0.9</XchgRate></XchgRateInf><IntrmyAgt1><FinInstnId><PstlAdr/></FinInstnId></IntrmyAgt1><CdtrAgt><FinInstnId><PstlAdr/></FinInstnId></CdtrAgt><Cdtr><Nm>${
""}MYRTLE AVENUE 3159</Nm><PstlAdr><AdrLine>US/BROOKLYN, NEW YORK 11245</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>${
""}TONY BALONEY</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><InstrForCdtrAgt><Cd>${
""}CHQB</Cd></InstrForCdtrAgt><InstrForDbtrAgt/><RmtInf><Ustrd>09-02 PENSION PAYMENT</Ustrd></RmtInf></CdtTrfTxInf></PmtInf><PmtInf><PmtInfId>${
""}11FF99RR</PmtInfId><PmtMtd>TRF</PmtMtd><PmtTpInf><SvcLvl/><CtgyPurp><Cd>INTC</Cd></CtgyPurp></PmtTpInf><ReqdExctnDt><Dt>2009-03-27</Dt><DtTm/></ReqdExctnDt><Dbtr><Nm>${
""}FINPETROL INC.</Nm><PstlAdr><TwnNm>HELSINKI</TwnNm><Ctry>FI</Ctry><AdrLine>ANDRELAE SPINKATU ${
""}7</AdrLine></PstlAdr><Id><OrgId/><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><Othr><Id>${
""}9102099999</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId><BICFI>CHXXUS33BBB</BICFI></FinInstnId></DbtrAgt><ChrgBr>${
""}SHAR</ChrgBr><ChrgsAcct><Id><Othr><SchmeNm/></Othr></Id></ChrgsAcct><CdtTrfTxInf><PmtId><InstrId>11FF99RR</InstrId><EndToEndId>${
""}REF503</EndToEndId></PmtId><Amt><InstdAmt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="USD"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}0</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></InstdAmt></Amt><XchgRateInf/><IntrmyAgt1><FinInstnId><PstlAdr/></FinInstnId></IntrmyAgt1><CdtrAgt><FinInstnId><PstlAdr/></FinInstnId></CdtrAgt><Cdtr><Nm>${
""}FINPETROL INC.</Nm><PstlAdr><TwnNm>HELSINKI</TwnNm><Ctry>FI</Ctry><AdrLine>ANDRELAE SPINKATU 7</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>${
""}9020123100</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><InstrForCdtrAgt/><InstrForDbtrAgt><Cd>${
""}CMZB</Cd></InstrForDbtrAgt><RmtInf><Ustrd/></RmtInf></CdtTrfTxInf></PmtInf></CstmrCdtTrfInitn></Document>`;

    painIsoRecord:Pain001Document pain001Message = check xmldata:parseAsType(documentXML);
    swiftmt:MT101Message|error mt101Message = transformPain001DocumentToMT101(pain001Message);

    if (mt101Message is swiftmt:MT101Message) {
        string|error finMessage = swiftmt:getFinMessage(mt101Message);
        if finMessage is error {
            log:printError(finMessage.toString());
            test:assertFail("Error occurred while getting the FIN message");
        }
        test:assertEquals(mt101Message.block2.messageType, "101");
        test:assertEquals(pain001Message.CstmrCdtTrfInitn.GrpHdr.MsgId, mt101Message.block4.MT21R?.Ref?.content, "Message ID mismatch");
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
""}1.6</XchgRate><ChrgBr>DEBT</ChrgBr><ChrgsInf><Amt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}5.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></Amt><Agt><FinInstnId/></Agt><Tp><Cd>${
""}DEBT</Cd></Tp></ChrgsInf><PrvsInstgAgt1><FinInstnId/></PrvsInstgAgt1><Dbtr><Nm>CONSORTIA PENSION SCHEME</Nm><PstlAdr><AdrLine>${
""}FRIEDRICHSTRASSE, 27</AdrLine><AdrLine>8022-ZURICH</AdrLine></PstlAdr><Id><OrgId/><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><IBAN>${
""}AL47212110090000000235698741</IBAN><Othr><SchmeNm/></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId/></DbtrAgt><CdtrAgt><FinInstnId/></CdtrAgt><Cdtr><Nm>${
""}JOHANN WILLEMS</Nm><PstlAdr><AdrLine>RUE JOSEPH II, 19</AdrLine><AdrLine>1040 BRUSSELS</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>${
""}001161685134</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><InstrForCdtrAgt/><InstrForNxtAgt/><Purp><Cd/></Purp><RmtInf><Ustrd>${
""}PENSION PAYMENT SEPTEMBER 2009</Ustrd></RmtInf></CdtTrfTxInf><CdtTrfTxInf><PmtId><InstrId>5362/MPB</InstrId><EndToEndId>${
""}ABC/124</EndToEndId><TxId>ABC/124</TxId><UETR>4ea37e81-98ec-4014-b7a4-1ff4611b3fca</UETR></PmtId><IntrBkSttlmAmt><ActiveCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveCurrencyAndAmount_SimpleType>${
""}1875.00</ActiveCurrencyAndAmount_SimpleType></ActiveCurrencyAndAmount_SimpleType></IntrBkSttlmAmt><IntrBkSttlmDt>${
""}2009-08-28</IntrBkSttlmDt><SttlmTmIndctn/><SttlmTmReq/><InstdAmt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}3000.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></InstdAmt><XchgRate>${
""}1.6</XchgRate><ChrgBr>DEBT</ChrgBr><ChrgsInf><Amt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}5.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></Amt><Agt><FinInstnId/></Agt><Tp><Cd>${
""}DEBT</Cd></Tp></ChrgsInf><PrvsInstgAgt1><FinInstnId/></PrvsInstgAgt1><Dbtr><Nm>CONSORTIA PENSION SCHEME</Nm><PstlAdr><AdrLine>${
""}FRIEDRICHSTRASSE, 27</AdrLine><AdrLine>8022-ZURICH</AdrLine></PstlAdr><Id><OrgId/><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><IBAN>${
""}AL47212110090000000235698741</IBAN><Othr><SchmeNm/></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId/></DbtrAgt><CdtrAgt><FinInstnId/></CdtrAgt><Cdtr><Nm>${
""}JOAN MILLS</Nm><PstlAdr><AdrLine>AVENUE LOUISE 213</AdrLine><AdrLine>1050 BRUSSELS</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>${
""}510007547061</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><InstrForCdtrAgt/><InstrForNxtAgt/><Purp><Cd/></Purp><RmtInf><Ustrd>${
""}PENSION PAYMENT SEPTEMBER 2003</Ustrd></RmtInf></CdtTrfTxInf></FIToFICstmrCdtTrf></Document>`;

    pacsIsoRecord:Pacs008Document pacs008Message = check xmldata:parseAsType(documentXML);
    swiftmt:MT102Message|error mt102Message = transformPacs008DocumentToMT102(pacs008Message);

    if (mt102Message is swiftmt:MT102Message) {
        string|error finMessage = swiftmt:getFinMessage(mt102Message);
        if finMessage is error {
            log:printError(finMessage.toString());
            test:assertFail("Error occurred while getting the FIN message");
        }
        test:assertEquals(mt102Message.block2.messageType, "102");
        test:assertTrue(mt102Message.block4.MT20.msgId.content == "5362/MPB", "Message ID is not a string");
    } else {
        io:println(mt102Message);
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
""}1.6</XchgRate><ChrgBr>DEBT</ChrgBr><ChrgsInf><Amt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}5.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></Amt><Agt><FinInstnId/></Agt><Tp><Cd>${
""}DEBT</Cd></Tp></ChrgsInf><PrvsInstgAgt1><FinInstnId/></PrvsInstgAgt1><Dbtr><Nm>CONSORTIA PENSION SCHEME</Nm><PstlAdr><AdrLine>${
""}FRIEDRICHSTRASSE, 27</AdrLine><AdrLine>8022-ZURICH</AdrLine></PstlAdr><Id><OrgId/><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><IBAN>${
""}AL47212110090000000235698741</IBAN><Othr><SchmeNm/></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId/></DbtrAgt><CdtrAgt><FinInstnId/></CdtrAgt><Cdtr><Nm>${
""}JOHANN WILLEMS</Nm><PstlAdr><AdrLine>RUE JOSEPH II, 19</AdrLine><AdrLine>1040 BRUSSELS</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>${
""}001161685134</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><InstrForCdtrAgt/><InstrForNxtAgt/><Purp><Cd/></Purp><RmtInf><Ustrd>${
""}PENSION PAYMENT SEPTEMBER 2009</Ustrd></RmtInf></CdtTrfTxInf><CdtTrfTxInf><PmtId><InstrId>5362/MPB</InstrId><EndToEndId>${
""}ABC/124</EndToEndId><TxId>ABC/124</TxId><UETR>4ea37e81-98ec-4014-b7a4-1ff4611b3fca</UETR></PmtId><IntrBkSttlmAmt><ActiveCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveCurrencyAndAmount_SimpleType>${
""}1875.00</ActiveCurrencyAndAmount_SimpleType></ActiveCurrencyAndAmount_SimpleType></IntrBkSttlmAmt><IntrBkSttlmDt>${
""}2009-08-28</IntrBkSttlmDt><SttlmTmIndctn/><SttlmTmReq/><InstdAmt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}3000.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></InstdAmt><XchgRate>${
""}1.6</XchgRate><ChrgBr>DEBT</ChrgBr><ChrgsInf><Amt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}5.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></Amt><Agt><FinInstnId/></Agt><Tp><Cd>${
""}DEBT</Cd></Tp></ChrgsInf><PrvsInstgAgt1><FinInstnId/></PrvsInstgAgt1><Dbtr><Nm>CONSORTIA PENSION SCHEME</Nm><PstlAdr><AdrLine>${
""}FRIEDRICHSTRASSE, 27</AdrLine><AdrLine>8022-ZURICH</AdrLine></PstlAdr><Id><OrgId/><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><IBAN>${
""}AL47212110090000000235698741</IBAN><Othr><SchmeNm/></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId/></DbtrAgt><CdtrAgt><FinInstnId/></CdtrAgt><Cdtr><Nm>${
""}JOAN MILLS</Nm><PstlAdr><AdrLine>AVENUE LOUISE 213</AdrLine><AdrLine>1050 BRUSSELS</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>${
""}510007547061</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><InstrForCdtrAgt/><InstrForNxtAgt/><Purp><Cd/></Purp><RmtInf><Ustrd>${
""}PENSION PAYMENT SEPTEMBER 2003</Ustrd></RmtInf></CdtTrfTxInf></FIToFICstmrCdtTrf></Document>`;

    pacsIsoRecord:Pacs008Document pacs008Message = check xmldata:parseAsType(documentXML);
    swiftmt:MT102STPMessage|error mt102stpMessage = transformPacs008DocumentToMT102STP(pacs008Message);

    if (mt102stpMessage is swiftmt:MT102STPMessage) {
        string|error finMessage = swiftmt:getFinMessage(mt102stpMessage);
        if finMessage is error {
            log:printError(finMessage.toString());
            test:assertFail("Error occurred while getting the FIN message");
        }
        test:assertEquals(mt102stpMessage.block2.messageType, "102STP");
        test:assertTrue(mt102stpMessage.block4.MT20.msgId.content == "5362/MPB", "Message ID is not a string");
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
""}1.6</XchgRate><ChrgBr>DEBT</ChrgBr><ChrgsInf><Amt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}5.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></Amt><Agt><FinInstnId/></Agt><Tp><Cd>${
""}DEBT</Cd></Tp></ChrgsInf><PrvsInstgAgt1><FinInstnId/></PrvsInstgAgt1><Dbtr><Nm>CONSORTIA PENSION SCHEME</Nm><PstlAdr><AdrLine>${
""}FRIEDRICHSTRASSE, 27</AdrLine><AdrLine>8022-ZURICH</AdrLine></PstlAdr><Id><OrgId/><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><IBAN>${
""}AL47212110090000000235698741</IBAN><Othr><SchmeNm/></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId/></DbtrAgt><CdtrAgt><FinInstnId/></CdtrAgt><Cdtr><Nm>${
""}JOHANN WILLEMS</Nm><PstlAdr><AdrLine>RUE JOSEPH II, 19</AdrLine><AdrLine>1040 BRUSSELS</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>${
""}001161685134</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><InstrForCdtrAgt/><InstrForNxtAgt/><Purp><Cd/></Purp><RmtInf><Ustrd>${
""}PENSION PAYMENT SEPTEMBER 2009</Ustrd></RmtInf></CdtTrfTxInf><CdtTrfTxInf><PmtId><InstrId>5362/MPB</InstrId><EndToEndId>${
""}ABC/124</EndToEndId><TxId>ABC/124</TxId><UETR>4ea37e81-98ec-4014-b7a4-1ff4611b3fca</UETR></PmtId><IntrBkSttlmAmt><ActiveCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveCurrencyAndAmount_SimpleType>${
""}1875.00</ActiveCurrencyAndAmount_SimpleType></ActiveCurrencyAndAmount_SimpleType></IntrBkSttlmAmt><IntrBkSttlmDt>${
""}2009-08-28</IntrBkSttlmDt><SttlmTmIndctn/><SttlmTmReq/><InstdAmt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}3000.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></InstdAmt><XchgRate>${
""}1.6</XchgRate><ChrgBr>DEBT</ChrgBr><ChrgsInf><Amt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}5.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></Amt><Agt><FinInstnId/></Agt><Tp><Cd>${
""}DEBT</Cd></Tp></ChrgsInf><PrvsInstgAgt1><FinInstnId/></PrvsInstgAgt1><Dbtr><Nm>CONSORTIA PENSION SCHEME</Nm><PstlAdr><AdrLine>${
""}FRIEDRICHSTRASSE, 27</AdrLine><AdrLine>8022-ZURICH</AdrLine></PstlAdr><Id><OrgId/><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><IBAN>${
""}AL47212110090000000235698741</IBAN><Othr><SchmeNm/></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId/></DbtrAgt><CdtrAgt><FinInstnId/></CdtrAgt><Cdtr><Nm>${
""}JOAN MILLS</Nm><PstlAdr><AdrLine>AVENUE LOUISE 213</AdrLine><AdrLine>1050 BRUSSELS</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>${
""}510007547061</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><InstrForCdtrAgt/><InstrForNxtAgt/><Purp><Cd/></Purp><RmtInf><Ustrd>${
""}PENSION PAYMENT SEPTEMBER 2003</Ustrd></RmtInf></CdtTrfTxInf></FIToFICstmrCdtTrf></Document>`;

    pacsIsoRecord:Pacs008Document pacs008Message = check xmldata:parseAsType(documentXML);
    swiftmt:MT103Message|error mt103Message = transformPacs008DocumentToMT103(pacs008Message);

    if (mt103Message is swiftmt:MT103Message) {
        string|error finMessage = swiftmt:getFinMessage(mt103Message);
        if finMessage is error {
            log:printError(finMessage.toString());
            test:assertFail("Error occurred while getting the FIN message");
        }
        test:assertEquals(mt103Message.block2.messageType, "103");
        test:assertTrue(mt103Message.block4.MT20.msgId.content == "5362/MPB", "Message ID is not a string");
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
""}1.6</XchgRate><ChrgBr>DEBT</ChrgBr><ChrgsInf><Amt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}5.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></Amt><Agt><FinInstnId/></Agt><Tp><Cd>${
""}DEBT</Cd></Tp></ChrgsInf><PrvsInstgAgt1><FinInstnId/></PrvsInstgAgt1><Dbtr><Nm>CONSORTIA PENSION SCHEME</Nm><PstlAdr><AdrLine>${
""}FRIEDRICHSTRASSE, 27</AdrLine><AdrLine>8022-ZURICH</AdrLine></PstlAdr><Id><OrgId/><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><IBAN>${
""}AL47212110090000000235698741</IBAN><Othr><SchmeNm/></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId/></DbtrAgt><CdtrAgt><FinInstnId/></CdtrAgt><Cdtr><Nm>${
""}JOHANN WILLEMS</Nm><PstlAdr><AdrLine>RUE JOSEPH II, 19</AdrLine><AdrLine>1040 BRUSSELS</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>${
""}001161685134</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><InstrForCdtrAgt/><InstrForNxtAgt/><Purp><Cd/></Purp><RmtInf><Ustrd>${
""}PENSION PAYMENT SEPTEMBER 2009</Ustrd></RmtInf></CdtTrfTxInf><CdtTrfTxInf><PmtId><InstrId>5362/MPB</InstrId><EndToEndId>${
""}ABC/124</EndToEndId><TxId>ABC/124</TxId><UETR>4ea37e81-98ec-4014-b7a4-1ff4611b3fca</UETR></PmtId><IntrBkSttlmAmt><ActiveCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveCurrencyAndAmount_SimpleType>${
""}1875.00</ActiveCurrencyAndAmount_SimpleType></ActiveCurrencyAndAmount_SimpleType></IntrBkSttlmAmt><IntrBkSttlmDt>${
""}2009-08-28</IntrBkSttlmDt><SttlmTmIndctn/><SttlmTmReq/><InstdAmt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}3000.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></InstdAmt><XchgRate>${
""}1.6</XchgRate><ChrgBr>DEBT</ChrgBr><ChrgsInf><Amt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}5.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></Amt><Agt><FinInstnId/></Agt><Tp><Cd>${
""}DEBT</Cd></Tp></ChrgsInf><PrvsInstgAgt1><FinInstnId/></PrvsInstgAgt1><Dbtr><Nm>CONSORTIA PENSION SCHEME</Nm><PstlAdr><AdrLine>${
""}FRIEDRICHSTRASSE, 27</AdrLine><AdrLine>8022-ZURICH</AdrLine></PstlAdr><Id><OrgId/><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><IBAN>${
""}AL47212110090000000235698741</IBAN><Othr><SchmeNm/></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId/></DbtrAgt><CdtrAgt><FinInstnId/></CdtrAgt><Cdtr><Nm>${
""}JOAN MILLS</Nm><PstlAdr><AdrLine>AVENUE LOUISE 213</AdrLine><AdrLine>1050 BRUSSELS</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>${
""}510007547061</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><InstrForCdtrAgt/><InstrForNxtAgt/><Purp><Cd/></Purp><RmtInf><Ustrd>${
""}PENSION PAYMENT SEPTEMBER 2003</Ustrd></RmtInf></CdtTrfTxInf></FIToFICstmrCdtTrf></Document>`;

    pacsIsoRecord:Pacs008Document pacs008Message = check xmldata:parseAsType(documentXML);
    swiftmt:MT103STPMessage|error mt103stpMessage = transformPacs008DocumentToMT103STP(pacs008Message);

    if (mt103stpMessage is swiftmt:MT103STPMessage) {
        string|error finMessage = swiftmt:getFinMessage(mt103stpMessage);
        if finMessage is error {
            log:printError(finMessage.toString());
            test:assertFail("Error occurred while getting the FIN message");
        }
        test:assertEquals(mt103stpMessage.block2.messageType, "103STP");
        test:assertTrue(mt103stpMessage.block4.MT20.msgId.content == "5362/MPB", "Message ID is not a string");
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
""}1.6</XchgRate><ChrgBr>DEBT</ChrgBr><ChrgsInf><Amt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}5.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></Amt><Agt><FinInstnId/></Agt><Tp><Cd>${
""}DEBT</Cd></Tp></ChrgsInf><PrvsInstgAgt1><FinInstnId/></PrvsInstgAgt1><Dbtr><Nm>CONSORTIA PENSION SCHEME</Nm><PstlAdr><AdrLine>${
""}FRIEDRICHSTRASSE, 27</AdrLine><AdrLine>8022-ZURICH</AdrLine></PstlAdr><Id><OrgId/><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><IBAN>${
""}AL47212110090000000235698741</IBAN><Othr><SchmeNm/></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId/></DbtrAgt><CdtrAgt><FinInstnId/></CdtrAgt><Cdtr><Nm>${
""}JOHANN WILLEMS</Nm><PstlAdr><AdrLine>RUE JOSEPH II, 19</AdrLine><AdrLine>1040 BRUSSELS</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>${
""}001161685134</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><InstrForCdtrAgt/><InstrForNxtAgt/><Purp><Cd/></Purp><RmtInf><Ustrd>${
""}PENSION PAYMENT SEPTEMBER 2009</Ustrd></RmtInf></CdtTrfTxInf><CdtTrfTxInf><PmtId><InstrId>5362/MPB</InstrId><EndToEndId>${
""}ABC/124</EndToEndId><TxId>ABC/124</TxId><UETR>4ea37e81-98ec-4014-b7a4-1ff4611b3fca</UETR></PmtId><IntrBkSttlmAmt><ActiveCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveCurrencyAndAmount_SimpleType>${
""}1875.00</ActiveCurrencyAndAmount_SimpleType></ActiveCurrencyAndAmount_SimpleType></IntrBkSttlmAmt><IntrBkSttlmDt>${
""}2009-08-28</IntrBkSttlmDt><SttlmTmIndctn/><SttlmTmReq/><InstdAmt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}3000.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></InstdAmt><XchgRate>${
""}1.6</XchgRate><ChrgBr>DEBT</ChrgBr><ChrgsInf><Amt><ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="EUR"><ActiveOrHistoricCurrencyAndAmount_SimpleType>${
""}5.00</ActiveOrHistoricCurrencyAndAmount_SimpleType></ActiveOrHistoricCurrencyAndAmount_SimpleType></Amt><Agt><FinInstnId/></Agt><Tp><Cd>${
""}DEBT</Cd></Tp></ChrgsInf><PrvsInstgAgt1><FinInstnId/></PrvsInstgAgt1><Dbtr><Nm>CONSORTIA PENSION SCHEME</Nm><PstlAdr><AdrLine>${
""}FRIEDRICHSTRASSE, 27</AdrLine><AdrLine>8022-ZURICH</AdrLine></PstlAdr><Id><OrgId/><PrvtId><Othr><SchmeNm/></Othr></PrvtId></Id></Dbtr><DbtrAcct><Id><IBAN>${
""}AL47212110090000000235698741</IBAN><Othr><SchmeNm/></Othr></Id></DbtrAcct><DbtrAgt><FinInstnId/></DbtrAgt><CdtrAgt><FinInstnId/></CdtrAgt><Cdtr><Nm>${
""}JOAN MILLS</Nm><PstlAdr><AdrLine>AVENUE LOUISE 213</AdrLine><AdrLine>1050 BRUSSELS</AdrLine></PstlAdr><Id><OrgId/></Id></Cdtr><CdtrAcct><Id><Othr><Id>${
""}510007547061</Id><SchmeNm><Cd>BBAN</Cd></SchmeNm></Othr></Id></CdtrAcct><InstrForCdtrAgt/><InstrForNxtAgt/><Purp><Cd/></Purp><RmtInf><Ustrd>${
""}PENSION PAYMENT SEPTEMBER 2003</Ustrd></RmtInf></CdtTrfTxInf></FIToFICstmrCdtTrf></Document>`;

    pacsIsoRecord:Pacs008Document pacs008Message = check xmldata:parseAsType(documentXML);
    swiftmt:MT103REMITMessage|error mt103remitMessage = transformPacs008DocumentToMT103REMIT(pacs008Message);

    if (mt103remitMessage is swiftmt:MT103REMITMessage) {
        string|error finMessage = swiftmt:getFinMessage(mt103remitMessage);
        if finMessage is error {
            log:printError(finMessage.toString());
            test:assertFail("Error occurred while getting the FIN message");
        }
        test:assertEquals(mt103remitMessage.block2.messageType, "103REMIT");
        test:assertTrue(mt103remitMessage.block4.MT20.msgId.content == "5362/MPB", "Message ID is not a string");
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
        string|error finMessage = swiftmt:getFinMessage(mt104Message);
        if finMessage is error {
            log:printError(finMessage.toString());
            test:assertFail("Error occurred while getting the FIN message");
        }
        test:assertEquals(mt104Message.block2.messageType, "104");
        test:assertTrue(mt104Message.block4.MT20.msgId.content == "REFERENCE12345", "Message ID is not a string");
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

    pacsIsoRecord:Pacs003Document pacs003Message = check xmldata:parseAsType(documentXML);
    swiftmt:MT104Message|error mt104Message = transformPacs003DocumentToMT104(pacs003Message);

    if (mt104Message is swiftmt:MT104Message) {
        string|error finMessage = swiftmt:getFinMessage(mt104Message);
        if finMessage is error {
            log:printError(finMessage.toString());
            test:assertFail("Error occurred while getting the FIN message");
        }
        test:assertEquals(mt104Message.block2.messageType, "104");
        test:assertTrue(mt104Message.block4.MT20.msgId.content == "REFERENCE12345", "Message ID is not a string");
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

    pacsIsoRecord:Pacs003Document pacs003Message = check xmldata:parseAsType(documentXML);
    swiftmt:MT107Message|error mt107Message = transformPacs003DocumentToMT107(pacs003Message);

    if (mt107Message is swiftmt:MT107Message) {
        string|error finMessage = swiftmt:getFinMessage(mt107Message);
        if finMessage is error {
            log:printError(finMessage.toString());
            test:assertFail("Error occurred while getting the FIN message");
        }
        test:assertEquals(mt107Message.block2.messageType, "107");
        test:assertTrue(mt107Message.block4.MT20.msgId.content == "REFERENCE12345", "Message ID is not a string");
    } else {
        test:assertFail("Error occurred while transforming Pacs003 to MT107");
    }
}

@test:Config {}
function testTransformCamt056DocumenttoMT192() returns error? {
    xml documentXML = xml `
    <Document xmlns="urn:iso:std:iso:20022:tech:xsd:camt.056.001.11">
        <FIToFIPmtCxlReq>
            <Assgnmt>
                <Id>CaseAssignmentID12345</Id>
                <Assgnr>
                    <Nm>Bank A</Nm>
                    <PstlAdr>
                        <Ctry>US</Ctry>
                        <AdrLine>123 Street Name</AdrLine>
                    </PstlAdr>
                </Assgnr>
                <Assgne>
                    <Nm>Bank B</Nm>
                    <PstlAdr>
                        <Ctry>GB</Ctry>
                        <AdrLine>456 Avenue Name</AdrLine>
                    </PstlAdr>
                </Assgne>
                <CreDtTm>2024-11-29T12:34:56Z</CreDtTm>
            </Assgnmt>
            <Case>
                <Id>CaseID12345</Id>
                <Cretr>
                    <Nm>Bank A</Nm>
                </Cretr>
            </Case>
            <CtrlData>
                <NbOfTxs>2</NbOfTxs>
            </CtrlData>
            <Undrlyg>
                <OrgnlGrpInfAndCxl>
                    <OrgnlMsgId>OriginalMessageID12345</OrgnlMsgId>
                    <OrgnlMsgNmId>camt.053</OrgnlMsgNmId>
                </OrgnlGrpInfAndCxl>
                <TxInf>
                    <CxlId>CancellationID12345</CxlId>
                    <OrgnlInstrId>OriginalInstructionID12345</OrgnlInstrId>
                    <OrgnlEndToEndId>EndToEndID12345</OrgnlEndToEndId>
                    <OrgnlTxId>TransactionID12345</OrgnlTxId>
                    <OrgnlUETR>550e8400-e29b-41d4-a716-446655440000</OrgnlUETR>
                    <OrgnlIntrBkSttlmAmt Ccy="USD">
                        <ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="USD">
                            <ActiveOrHistoricCurrencyAndAmount_SimpleType>100000.00</ActiveOrHistoricCurrencyAndAmount_SimpleType>
                        </ActiveOrHistoricCurrencyAndAmount_SimpleType>
                    </OrgnlIntrBkSttlmAmt>
                    <OrgnlIntrBkSttlmDt>2024-11-28</OrgnlIntrBkSttlmDt>
                    <CxlRsnInf>
                        <Rsn>
                            <Cd>DCOR</Cd>
                        </Rsn>
                    </CxlRsnInf>
                </TxInf>
            </Undrlyg>
            <SplmtryData>
                <PlcAndNm>AdditionalInformation</PlcAndNm>
                <Envlp>
                    <Any>CustomData</Any>
                </Envlp>
            </SplmtryData>
        </FIToFIPmtCxlReq>
    </Document>`;

    camtIsoRecord:Camt056Document camt056Message = check xmldata:parseAsType(documentXML);
    swiftmt:MTn92Message|error mt192Message = transformCamt056ToMT192(camt056Message);

    if (mt192Message is swiftmt:MTn92Message) {
        string|error finMessage = swiftmt:getFinMessage(mt192Message);
        if finMessage is error {
            log:printError(finMessage.toString());
            test:assertFail("Error occurred while getting the FIN message");
        }
        test:assertEquals(mt192Message.block2.messageType, "192");
        test:assertTrue(mt192Message.block4.MT20.msgId.content == "CaseID12345", "Message ID is not a string");

    } else {
        test:assertFail("Error occurred while transforming Camt056 to MT192");
    }
}

@test:Config {}
function testTransformCamt055DocumenttoMT192() returns error? {
    xml documentXML = xml `
    <Document xmlns="urn:iso:std:iso:20022:tech:xsd:camt.055.001.12">
        <CstmrPmtCxlReq>
            <Assgnmt>
                <Id>AssignmentID12345</Id>
                <Assgnr>
                    <Nm>Bank A</Nm>
                    <PstlAdr>
                        <Ctry>US</Ctry>
                        <AdrLine>123 Main Street</AdrLine>
                    </PstlAdr>
                </Assgnr>
                <Assgne>
                    <Nm>Bank B</Nm>
                    <PstlAdr>
                        <Ctry>GB</Ctry>
                        <AdrLine>456 High Road</AdrLine>
                    </PstlAdr>
                </Assgne>
                <CreDtTm>2024-11-29T12:00:00Z</CreDtTm>
            </Assgnmt>
            <Case>
                <Id>CaseID67890</Id>
                <Cretr>
                    <Nm>Bank A</Nm>
                </Cretr>
            </Case>
            <CtrlData>
                <NbOfTxs>1</NbOfTxs>
            </CtrlData>
            <Undrlyg>
                <OrgnlGrpInfAndCxl>
                    <OrgnlMsgId>OriginalMsgID12345</OrgnlMsgId>
                    <OrgnlMsgNmId>pacs.008</OrgnlMsgNmId>
                    <NbOfTxs>1</NbOfTxs>
                    <CtrlSum>1000.00</CtrlSum>
                </OrgnlGrpInfAndCxl>
                <OrgnlPmtInfAndCxl>
                    <OrgnlPmtInfId>OriginalPmtInfoID123</OrgnlPmtInfId>
                    <NbOfTxs>1</NbOfTxs>
                    <CtrlSum>1000.00</CtrlSum>
                    <CxlRsnInf>
                        <Rsn>
                            <Cd>DCOR</Cd>
                        </Rsn>
                    </CxlRsnInf>
                    <TxInf>
                        <CxlId>CancellationID123</CxlId>
                        <OrgnlInstrId>OriginalInstructionID123</OrgnlInstrId>
                        <OrgnlEndToEndId>EndToEndID123</OrgnlEndToEndId>
                        <OrgnlUETR>550e8400-e29b-41d4-a716-446655440000</OrgnlUETR>
                        <OrgnlInstdAmt Ccy="USD">
                            <ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="USD">
                                <ActiveOrHistoricCurrencyAndAmount_SimpleType>100000.00</ActiveOrHistoricCurrencyAndAmount_SimpleType>
                            </ActiveOrHistoricCurrencyAndAmount_SimpleType>
                        </OrgnlInstdAmt>
                        <OrgnlReqdExctnDt>2024-11-28</OrgnlReqdExctnDt>
                        <CxlRsnInf>
                            <Rsn>
                                <Cd>DCOR</Cd>
                            </Rsn>
                        </CxlRsnInf>
                    </TxInf>
                </OrgnlPmtInfAndCxl>
            </Undrlyg>
            <SplmtryData>
                <PlcAndNm>SupplementaryInformation</PlcAndNm>
                <Envlp>
                    <Any>CustomData</Any>
                </Envlp>
            </SplmtryData>
        </CstmrPmtCxlReq>
    </Document>`;

    camtIsoRecord:Camt055Document camt055Message = check xmldata:parseAsType(documentXML);
    swiftmt:MTn92Message|error mt192Message = transformCamt055ToMT192(camt055Message);

    if (mt192Message is swiftmt:MTn92Message) {
        string|error finMessage = swiftmt:getFinMessage(mt192Message);
        if finMessage is error {
            log:printError(finMessage.toString());
            test:assertFail("Error occurred while getting the FIN message");
        }
        test:assertEquals(mt192Message.block2.messageType, "192");
        test:assertTrue(mt192Message.block4.MT20.msgId.content == "CaseID67890", "Message ID is not a string");
    } else {
        test:assertFail("Error occurred while transforming Camt056 to MT192");
    }
}

@test:Config {}
function testTransformCamt031DocumenttoMT196() returns error? {
    xml documentXML = xml `
    <Document xmlns="urn:iso:std:iso:20022:tech:xsd:camt.031.001.07">
        <RjctInvstgtn>
            <Assgnmt>
                <Id>AssignmentID456</Id>
                <Assgnr>
                    <Nm>Bank C</Nm>
                    <PstlAdr>
                        <Ctry>US</Ctry>
                        <AdrLine>789 Oak Street</AdrLine>
                    </PstlAdr>
                </Assgnr>
                <Assgne>
                    <Nm>Bank D</Nm>
                    <PstlAdr>
                        <Ctry>FR</Ctry>
                        <AdrLine>101 Maple Avenue</AdrLine>
                    </PstlAdr>
                </Assgne>
                <CreDtTm>2024-11-29T15:00:00Z</CreDtTm>
            </Assgnmt>
            <Case>
                <Id>CaseID789</Id>
                <Cretr>
                    <Nm>Bank C</Nm>
                </Cretr>
            </Case>
            <Justfn>
                <RjctnRsn>NFND</RjctnRsn>
            </Justfn>
            <SplmtryData>
                <PlcAndNm>SupplementaryInfo</PlcAndNm>
                <Envlp>
                    <Any>AdditionalData</Any>
                </Envlp>
            </SplmtryData>
        </RjctInvstgtn>
    </Document>`;

    camtIsoRecord:Camt031Document camt031Message = check xmldata:parseAsType(documentXML);
    swiftmt:MTn96Message|error mt196Message = transformCamt031ToMT196(camt031Message);

    if (mt196Message is swiftmt:MTn96Message) {
        string|error finMessage = swiftmt:getFinMessage(mt196Message);
        if finMessage is error {
            log:printError(finMessage.toString());
            test:assertFail("Error occurred while getting the FIN message");
        }
        test:assertEquals(mt196Message.block2.messageType, "196");
        test:assertTrue(mt196Message.block4.MT20.msgId.content == "CaseID789", "Message ID is not a string");
    } else {
        test:assertFail("Error occurred while transforming Camt031 to MT196");
    }
}

@test:Config {}
function testTransformCamt028DocumenttoMT196() returns error? {
    xml documentXML = xml `
    <Document xmlns="urn:iso:std:iso:20022:tech:xsd:camt.028.001.12">
        <AddtlPmtInf>
            <Assgnmt>
                <Id>Assignment123</Id>
                <Assgnr>
                    <Nm>Bank X</Nm>
                    <PstlAdr>
                        <Ctry>US</Ctry>
                        <AdrLine>123 Elm Street</AdrLine>
                    </PstlAdr>
                </Assgnr>
                <Assgne>
                    <Nm>Bank Y</Nm>
                    <PstlAdr>
                        <Ctry>DE</Ctry>
                        <AdrLine>456 Pine Avenue</AdrLine>
                    </PstlAdr>
                </Assgne>
                <CreDtTm>2024-11-29T10:30:00Z</CreDtTm>
            </Assgnmt>
            <Case>
                <Id>Case123</Id>
                <Cretr>
                    <Nm>Bank X</Nm>
                </Cretr>
            </Case>
            <Undrlyg>
                <TxId>Transaction789</TxId>
            </Undrlyg>
            <Inf>
                <InstrId>InstrID12345</InstrId>
                <EndToEndId>E2EID45678</EndToEndId>
                <TxId>TxID123456</TxId>
                <ReqdExctnDt>
                    <Dt>2024-12-01</Dt>
                </ReqdExctnDt>
                <Amt>
                    <InstdAmt Ccy="USD">
                        <ActiveOrHistoricCurrencyAndAmount_SimpleType Ccy="USD">
                            <ActiveOrHistoricCurrencyAndAmount_SimpleType>100000.00</ActiveOrHistoricCurrencyAndAmount_SimpleType>
                        </ActiveOrHistoricCurrencyAndAmount_SimpleType>
                    </InstdAmt>
                </Amt>
                <ChrgBr>SLEV</ChrgBr>
                <Dbtr>
                    <Nm>Debtor Name</Nm>
                    <PstlAdr>
                        <Ctry>US</Ctry>
                        <AdrLine>789 Birch Lane</AdrLine>
                    </PstlAdr>
                </Dbtr>
                <DbtrAcct>
                    <Id>
                        <IBAN>US12345678901234567890</IBAN>
                    </Id>
                </DbtrAcct>
                <Cdtr>
                    <Nm>Creditor Name</Nm>
                    <PstlAdr>
                        <Ctry>FR</Ctry>
                        <AdrLine>12 Maple Drive</AdrLine>
                    </PstlAdr>
                </Cdtr>
                <CdtrAcct>
                    <Id>
                        <IBAN>FR09876543210987654321</IBAN>
                    </Id>
                </CdtrAcct>
                <Purp>
                    <Cd>TRFD</Cd>
                </Purp>
            </Inf>
            <SplmtryData>
                <PlcAndNm>SupplementaryInfo</PlcAndNm>
                <Envlp>
                    <Any>AdditionalDetails</Any>
                </Envlp>
            </SplmtryData>
        </AddtlPmtInf>
    </Document>`;

    camtIsoRecord:Camt028Document camt028Message = check xmldata:parseAsType(documentXML);
    swiftmt:MTn96Message|error mt196Message = transformCamt028ToMT196(camt028Message);

    if (mt196Message is swiftmt:MTn96Message) {
        string|error finMessage = swiftmt:getFinMessage(mt196Message);
        if finMessage is error {
            log:printError(finMessage.toString());
            test:assertFail("Error occurred while getting the FIN message");
        }
        test:assertEquals(mt196Message.block2.messageType, "196");
        test:assertTrue(mt196Message.block4.MT20.msgId.content == "Case123", "Message ID is not a string");
    } else {
        test:assertFail("Error occurred while transforming Camt031 to MT196");
    }
}

@test:Config {}
function testTransformCamt026DocumenttoMT195() returns error? {
    xml documentXML = xml `
    <Document xmlns="urn:iso:std:iso:20022:tech:xsd:camt.026.001.10">
        <UblToApply>
            <Assgnmt>
                <Id>Assign123</Id>
                <Assgnr>
                    <Nm>Bank A</Nm>
                    <PstlAdr>
                        <Ctry>US</Ctry>
                        <AdrLine>123 First Avenue</AdrLine>
                    </PstlAdr>
                </Assgnr>
                <Assgne>
                    <Nm>Bank B</Nm>
                    <PstlAdr>
                        <Ctry>GB</Ctry>
                        <AdrLine>456 Second Street</AdrLine>
                    </PstlAdr>
                </Assgne>
                <CreDtTm>2024-11-29T12:00:00Z</CreDtTm>
            </Assgnmt>
            <Case>
                <Id>Case987</Id>
                <Cretr>
                    <Nm>Bank A</Nm>
                </Cretr>
            </Case>
            <Undrlyg>
                <TxId>Tx123456</TxId>
            </Undrlyg>
            <Justfn>
                <MssngOrIncrrctInf>
                    <AMLReq>true</AMLReq>
                    <MssngInf>
                        <Tp>
                            <Cd>MSSNGDTA</Cd>
                        </Tp>
                        <AddtlMssngInf>Missing Account Number</AddtlMssngInf>
                    </MssngInf>
                    <IncrrctInf>
                        <Tp>
                            <Cd>INCRRCTDTA</Cd>
                        </Tp>
                        <AddtlIncrrctInf>Incorrect Beneficiary Name</AddtlIncrrctInf>
                    </IncrrctInf>
                </MssngOrIncrrctInf>
            </Justfn>
            <SplmtryData>
                <PlcAndNm>AdditionalInformation</PlcAndNm>
                <Envlp>
                    <Any>Supplementary Details</Any>
                </Envlp>
            </SplmtryData>
        </UblToApply>
    </Document>`;

    camtIsoRecord:Camt026Document camt026Message = check xmldata:parseAsType(documentXML);
    swiftmt:MTn95Message|error mt195Message = transformCamt026ToMT195(camt026Message);

    if (mt195Message is swiftmt:MTn95Message) {
        string|error finMessage = swiftmt:getFinMessage(mt195Message);
        if finMessage is error {
            log:printError(finMessage.toString());
            test:assertFail("Error occurred while getting the FIN message");
        }
        test:assertEquals(mt195Message.block2.messageType, "195");
        test:assertTrue(mt195Message.block4.MT20.msgId.content == "Case987", "Message ID is not a string");
    } else {
        test:assertFail("Error occurred while transforming Camt026 to MT195");
    }
}
