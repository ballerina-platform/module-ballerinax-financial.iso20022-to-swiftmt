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

import ballerina/log;
import ballerinax/financial.iso20022.cash_management as camtIsoRecord;
import ballerinax/financial.iso20022.payment_initiation as painIsoRecord;
import ballerinax/financial.iso20022.payments_clearing_and_settlement as pacsIsoRecord;

const PAIN001 = "pain.001";
const PAIN008 = "pain.008";
const PACS002 = "pacs.002";
const PACS003 = "pacs.003";
const PACS004 = "pacs.004";
const PACS008 = "pacs.008";
const PACS009 = "pacs.009";
const PACS010 = "pacs.010";
const CAMT026 = "camt.026";
const CAMT029 = "camt.029";
const CAMT050 = "camt.050";
const CAMT052 = "camt.052";
const CAMT053 = "camt.053";
const CAMT054 = "camt.054";
const CAMT056 = "camt.056";
const CAMT057 = "camt.057";
const CAMT060 = "camt.060";
const CAMT105 = "camt.105";
const CAMT106 = "camt.106";
const CAMT107 = "camt.107";
const CAMT108 = "camt.108";
const CAMT109 = "camt.109";

const MT101 = "MT101";
const MT102 = "MT102";
const MT102_STP = "MT102_STP";
const MT103 = "MT103";
const MT103_STP = "MT103_STP";
const MT103_REMIT = "MT103_REMIT";
const MT104 = "MT104";
const MT107 = "MT107";
const MT192 = "MT192";
const MT195 = "MT195";
const MT196 = "MT196";

const MT200 = "MT200";
const MT201 = "MT201";
const MT202 = "MT202";
const MT202_COV = "MT202_COV";
const MT203 = "MT203";
const MT204 = "MT204";
const MT205 = "MT205";
const MT205_COV = "MT205_COV";
const MT210 = "MT210";
const MT292 = "MT292";
const MT295 = "MT295";

const MESSAGETYPE_101 = "101";
const MESSAGETYPE_102 = "102";
const MESSAGETYPE_103 = "103";
const MESSAGETYPE_103_STP = "103STP";
const MESSAGETYPE_103_REMIT = "103REMIT";
const MESSAGETYPE_103_RETN = "103RETN";
const MESSAGETYPE_104 = "104";
const MESSAGETYPE_102_STP = "102STP";
const MESSAGETYPE_107 = "107";
const MESSAGETYPE_110 = "110";
const MESSAGETYPE_111 = "111";
const MESSAGETYPE_112 = "112";
const MESSAGETYPE_190 = "190";
const MESSAGETYPE_191 = "191";
const MESSAGETYPE_192 = "192";
const MESSAGETYPE_195 = "195";
const MESSAGETYPE_196 = "196";
const MESSAGETYPE_199 = "199";
const MESSAGETYPE_200 = "200";
const MESSAGETYPE_201 = "201";
const MESSAGETYPE_202 = "202";
const MESSAGETYPE_202_ADV = "202ADV";
const MESSAGETYPE_202_COV = "202COV";
const MESSAGETYPE_202_RETN = "202RETN";
const MESSAGETYPE_203 = "203";
const MESSAGETYPE_204 = "204";
const MESSAGETYPE_205 = "205";
const MESSAGETYPE_205_COV = "205COV";
const MESSAGETYPE_205_RETN = "205RETN";
const MESSAGETYPE_210 = "210";
const MESSAGETYPE_290 = "290";
const MESSAGETYPE_291 = "291";
const MESSAGETYPE_292 = "292";
const MESSAGETYPE_296 = "296";
const MESSAGETYPE_299 = "299";
const MESSAGETYPE_900 = "900";
const MESSAGETYPE_910 = "910";
const MESSAGETYPE_940 = "940";
const MESSAGETYPE_942 = "942";

const NUMBER1 = "1";
const NUMBER2 = "2";
const NUMBER3 = "3";
const NUMBER4 = "4";
const NUMBER5 = "5";
const NUMBER6 = "6";
const NUMBER7 = "7";
const NUMBER8 = "8";
const NUMBER9 = "9";
const NUMBER10 = "10";

const EMPTY_STRING = "";

const MT12_NAME = "12";
const MT19_NAME = "19";
const MT20_NAME = "20";
const MT21_NAME = "21";
const MT21R_NAME = "21R";
const MT23E_NAME = "23E";
const MT21E_NAME = "21E";
const MT30_NAME = "30";
const MT51A_NAME = "51A";
const MT26T_NAME = "26T";
const MT77B_NAME = "77B";
const MT71A_NAME = "71A";
const MT72_NAME = "72";
const MT32B_NAME = "32B";
const MT71F_NAME = "71F";
const MT71G_NAME = "71G";
const MT36_NAME = "36";
const MT21D_NAME = "21D";
const MT33B_NAME = "33B";
const MT28D_NAME = "28D";
const MT28C_NAME = "28C";
const MT28_NAME = "28";
const MT70_NAME = "70";
const MT25A_NAME = "25A";
const MT25_NAME = "25";
const MT25P_NAME = "25P";
const MT23_NAME = "23";
const MT77T_NAME = "77T";
const MT23B_NAME = "23B";
const MT79_NAME = "79";
const MT11S_NAME = "11S";
const MT11R_NAME = "11R";
const MT76_NAME = "76";
const MT75_NAME = "75";
const MT77A_NAME = "77A";
const MT50C_NAME = "50C";
const MT50L_NAME = "50L";
const MT50F_NAME = "50F";
const MT50G_NAME = "50G";
const MT50H_NAME = "50H";
const MT52A_NAME = "50A";
const MT52C_NAME = "50C";
const MT56A_NAME = "56A";
const MT56D_NAME = "56D";
const MT56C_NAME = "56C";
const MT57A_NAME = "57A";
const MT57C_NAME = "57C";
const MT57D_NAME = "57D";
const MT59A_NAME = "59A";
const MT59F_NAME = "59F";
const MT59_NAME = "59";
const MT50_NAME = "50";
const MT52B_NAME = "52B";
const MT56F_NAME = "56F";
const MT53A_NAME = "53A";
const MT53B_NAME = "53B";
const MT53C_NAME = "53C";
const MT53D_NAME = "53D";
const MT50A_NAME = "50A";
const MT50K_NAME = "50K";
const MT52D_NAME = "52D";
const MT54A_NAME = "54A";
const MT54B_NAME = "54B";
const MT54D_NAME = "54D";
const MT55A_NAME = "55A";
const MT55B_NAME = "55B";
const MT55D_NAME = "55D";
const MT57B_NAME = "57B";
const MT13C_NAME = "13C";
const MT13D_NAME = "13D";
const MT32A_NAME = "32A";
const MT60F_NAME = "60F";
const MT60M_NAME = "60M";
const MT61_NAME = "61";
const MT62F_NAME = "62F";
const MT62M_NAME = "62M";
const MT64_NAME = "64";
const MT65_NAME = "65";
const MT90D_NAME = "90D";
const MT90C_NAME = "90C";
const MT34F_NAME = "34F";
const MT32C_NAME = "32C";
const MT32D_NAME = "32D";
const MT71B_NAME = "71B";

const VALIDATION_FLAG_STP = "STP";
const VALIDATION_FLAG_COV = "COV";
const VALIDATION_FLAG_REMIT = "REMIT";

const INSTRUCTION_CODE_PREFIX = "/";
const CHARGE_REQUEST_PREFIX = "/CHRQ/";
const LINE_LENGTH = 35;

final readonly & string[] RETURN_REASON_CODES = [
    "AC01",
    "AC04",
    "AC06",
    "AM01",
    "AM02",
    "AM03",
    "AM04",
    "AM05",
    "AM06",
    "AM07",
    "BE01",
    "BE04",
    "BE05",
    "AG01",
    "AG02",
    "DT01",
    "RF01",
    "RC01",
    "RR01",
    "RR02",
    "RR03",
    "TM01"
];

string[] MT_101_INSTRC_CD = [
    "CHQB",
    "CMSW",
    "CMTO",
    "CMZB",
    "CORT",
    "EQUI",
    "INTC",
    "NETS",
    "OTHR",
    "PHON",
    "REPA",
    "RTGS",
    "URGP"
];

isolated string[] MT_103_INSTRC_CD = [
    "CHQB",
    "CORT",
    "INTC",
    "SDVA",
    "TELB",
    "PHOB",
    "HOLD"
];

final readonly & map<string> chequeCancelStatusCode = {
    "ACCP": "Accepted",
    "REJT": "Rejected",
    "ACCR": "Accepted",
    "RJCR": "Rejected"
};

final readonly & map<string> chequeCancelReasonCode = {
    "DUPL": "DuplicateCheque",
    "CUST": "RequestedByCustomer",
    "FRAD": "FraudulentOrigin",
    "LOST": "ChequeLost",
    "NARR": "Narrative"
};

# This record is used to store any type of MT message record and the type name
#
# + mtTypeName - The MT record type name
# + mtData - The MT record
type MtMessage record {|
    // The MT record type name
    string mtTypeName;
    // The MT record
    record {} mtData;
|};

# This record is used to store any type of MX message record and the type name
#
# + mxTypeName - The MX record type name
# + mxData - The MX record
type MxMessage record {|
    // The MX record type name
    string mxTypeName;
    // The MX record
    record {} mxData;
|};

isolated function getTransformFunction(string isoMsgType, record {} isoData) returns record {}|error {

    string mtMsgType = check getOutputMtType(isoMsgType, isoData);
    match isoMsgType {
        PACS002 => {
            return function:call(check getTransformFunctionForPacs002(mtMsgType), isoData, mtMsgType).ensureType();
        }
        PACS004 => {
            return function:call(check getTransformFunctionForPacs004(mtMsgType), isoData, mtMsgType).ensureType();

        }
        PACS008 => {
            return function:call(check getTransformFunctionForPacs008(mtMsgType), isoData, mtMsgType).ensureType();

        }
        PACS009 => {
            return function:call(check getTransformFunctionForPacs009(mtMsgType), isoData, mtMsgType).ensureType();
        }
        PACS010 => {
            return function:call(getTransformFunctionForPacs010(mtMsgType), isoData, mtMsgType).ensureType();
        }
        CAMT026 => {
            return function:call(getTransformFunctionForCamt026(mtMsgType), isoData, mtMsgType).ensureType();
        }
        CAMT029 => {
            return function:call(getTransformFunctionForCamt029(mtMsgType), isoData, mtMsgType).ensureType();
        }
        CAMT052 => {
            return function:call(getTransformFunctionForCamt052(mtMsgType), isoData, mtMsgType).ensureType();
        }
        CAMT053 => {
            return function:call(getTransformFunctionForCamt053(mtMsgType), isoData, mtMsgType).ensureType();
        }
        CAMT054 => {
            return function:call(getTransformFunctionForCamt054(mtMsgType), isoData, mtMsgType).ensureType();
        }
        CAMT056 => {
            return function:call(getTransformFunctionForCamt056(mtMsgType), isoData, mtMsgType).ensureType();
        }
        CAMT057 => {
            return function:call(getTransformFunctionForCamt057(mtMsgType), isoData, mtMsgType).ensureType();
        }
        CAMT105 => {
            return function:call(getTransformFunctionForCamt105(mtMsgType), isoData, mtMsgType).ensureType();
        }
        CAMT106 => {
            return function:call(check getTransformFunctionForCamt106(mtMsgType), isoData, mtMsgType).ensureType();
        }
        CAMT107 => {
            return function:call(getTransformFunctionForCamt107(mtMsgType), isoData, mtMsgType).ensureType();
        }
        CAMT108 => {
            return function:call(getTransformFunctionForCamt108(mtMsgType), isoData, mtMsgType).ensureType();
        }
        CAMT109 => {
            return function:call(getTransformFunctionForCamt109(mtMsgType), isoData, mtMsgType).ensureType();
        }
        PAIN001 => {
            return function:call(getTransformFunctionForPain001(mtMsgType), isoData, mtMsgType).ensureType();
        }
        PAIN008 => {
            return function:call(getTransformFunctionForPain008(mtMsgType), isoData, mtMsgType).ensureType();
        }
        _ => {
            return error("ISO 20022 message type is not supported.");
        }
    }
}

isolated function getOutputMtType(string isoMsgType, record {} isoData) returns string|error {

    match isoMsgType {

        PACS002 => {
            pacsIsoRecord:Pacs002Envelope envelope = check isoData.cloneWithType(pacsIsoRecord:Pacs002Envelope);
            pacsIsoRecord:PaymentTransaction161[]? txInfo = envelope.Document.FIToFIPmtStsRpt.TxInfAndSts;
            if txInfo is pacsIsoRecord:PaymentTransaction161[] {
                string orgnlMsgNmId = txInfo[0].OrgnlGrpInf?.OrgnlMsgNmId.toString();
                string:RegExp regex10x = re `MT10[0-9]`;
                string:RegExp regex20x = re `MT20[0-9]`;
                if orgnlMsgNmId.startsWith(PACS003) || orgnlMsgNmId.startsWith(PACS008) || regex10x.isFullMatch(orgnlMsgNmId) {
                    return MESSAGETYPE_199;
                } else if orgnlMsgNmId.startsWith(PACS009) || orgnlMsgNmId.startsWith(PACS010) || regex20x.isFullMatch(orgnlMsgNmId) {
                    return MESSAGETYPE_299;
                }
            }
            log:printWarn(getSwiftLogMessage(WARNING, "T20092"));
            return MESSAGETYPE_299;
        }

        PACS003 => {
            // todo: check derived mappings for 104, 107
            return error("To be implemented");
        }

        PACS004 => {
            pacsIsoRecord:Pacs004Envelope envelope = check isoData.cloneWithType(pacsIsoRecord:Pacs004Envelope);
            pacsIsoRecord:PaymentTransaction159[]? txInfo = envelope.Document.PmtRtr.TxInf;
            if (txInfo is pacsIsoRecord:PaymentTransaction159[]) {
                string orgnlMsgNmId = txInfo[0].OrgnlGrpInf?.OrgnlMsgNmId ?: EMPTY_STRING;
                pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? dbtr = txInfo[0].RtrChain?.Dbtr?.Agt;
                pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? cdtr = txInfo[0].RtrChain?.Cdtr?.Agt;

                if (orgnlMsgNmId.startsWith(PACS008) || orgnlMsgNmId.startsWith(MT103)) {
                    return MESSAGETYPE_103_RETN;
                } else if (orgnlMsgNmId.startsWith(PACS009) || orgnlMsgNmId.startsWith(MT202)) {
                    return MESSAGETYPE_202_RETN;
                } else if (orgnlMsgNmId.startsWith(MT205)) {
                    return MESSAGETYPE_205_RETN;
                } else if (dbtr is pacsIsoRecord:BranchAndFinancialInstitutionIdentification8 &&
                        cdtr is pacsIsoRecord:BranchAndFinancialInstitutionIdentification8) {
                    return MESSAGETYPE_202_RETN;
                }

            }
            return MESSAGETYPE_103_RETN;
        }

        PACS008 => {
            pacsIsoRecord:Pacs008Envelope envelope = check isoData.cloneWithType(pacsIsoRecord:Pacs008Envelope);
            if envelope.AppHdr?.BizSvc is string && envelope.AppHdr?.BizSvc.toString().includes(".stp.") {
                if envelope.Document.FIToFICstmrCdtTrf.CdtTrfTxInf.length() > 1 {
                    // derived mapping
                    return MESSAGETYPE_102_STP;
                }
                return MESSAGETYPE_103_STP;
            }
            if envelope.Document.FIToFICstmrCdtTrf.CdtTrfTxInf.length() > 1 {
                // derived mapping
                return MESSAGETYPE_102;
            }
            return MESSAGETYPE_103;
        }

        PACS009 => {
            // todo: check 205 mapping
            pacsIsoRecord:Pacs009Envelope envelope = check isoData.cloneWithType(pacsIsoRecord:Pacs009Envelope);
            pacsIsoRecord:CreditTransferTransaction62[] cdtrTrfTxInf = envelope.Document.FICdtTrf.CdtTrfTxInf;
            if cdtrTrfTxInf[0].UndrlygCstmrCdtTrf is pacsIsoRecord:CreditTransferTransaction63 {
                return MESSAGETYPE_202_COV;
            } else if (envelope.AppHdr?.BizSvc is string && envelope.AppHdr?.BizSvc.toString().includes(".adv.")) {
                return MESSAGETYPE_202_ADV;
            } else {
                return MESSAGETYPE_202;
            }

        }
        PACS010 => {
            // derived mapping
            return MESSAGETYPE_204;
        }

        CAMT029 => {
            camtIsoRecord:Camt029Envelope envelope = check isoData.cloneWithType(camtIsoRecord:Camt029Envelope);
            camtIsoRecord:UnderlyingTransaction32[]? cxldtls = envelope.Document.RsltnOfInvstgtn.CxlDtls;
            if cxldtls is camtIsoRecord:UnderlyingTransaction32[] {
                camtIsoRecord:PaymentTransaction152[]? txInfo = cxldtls[0]?.TxInfAndSts;
                if txInfo is camtIsoRecord:PaymentTransaction152[] {
                    string orgnlMsgNmId = txInfo[0].OrgnlGrpInf?.OrgnlMsgNmId.toString();
                    string:RegExp regex10x = re `MT10[0-9]`;
                    string:RegExp regex20x = re `MT20[0-9]`;
                    if (orgnlMsgNmId.includes(PACS008) || orgnlMsgNmId.includes(PACS003) || regex10x.isFullMatch(orgnlMsgNmId)) {
                        return MESSAGETYPE_196;
                    } else if (orgnlMsgNmId.includes(PACS009) || orgnlMsgNmId.includes(PACS010) || regex20x.isFullMatch(orgnlMsgNmId)) {
                        return MESSAGETYPE_296;
                    }
                }
            }
            log:printWarn(getSwiftLogMessage(WARNING, "T20092"));
            return MESSAGETYPE_296;
        }

        CAMT052 => {
            return MESSAGETYPE_942;
        }

        CAMT053 => {
            return MESSAGETYPE_940;
        }

        CAMT054 => {
            camtIsoRecord:Camt054Envelope envelope = check isoData.cloneWithType(camtIsoRecord:Camt054Envelope);
            camtIsoRecord:ReportEntry14[]? reportEntries = envelope.Document.BkToCstmrDbtCdtNtfctn.Ntfctn[0].Ntry;
            if reportEntries is camtIsoRecord:ReportEntry14[] {
                string cdtDbtInd = reportEntries[0].CdtDbtInd;
                if (cdtDbtInd == "CRDT") {
                    return MESSAGETYPE_910;
                }
            }
            return MESSAGETYPE_900;
        }
        CAMT056 => {
            camtIsoRecord:Camt056Envelope envelope = check isoData.cloneWithType(camtIsoRecord:Camt056Envelope);
            camtIsoRecord:PaymentTransaction155[]? txInfo = envelope.Document.FIToFIPmtCxlReq.Undrlyg[0].TxInf;
            if txInfo is camtIsoRecord:PaymentTransaction155[] {
                string orgnlMsgNmId = txInfo[0].OrgnlGrpInf?.OrgnlMsgNmId.toString();
                string:RegExp regex10x = re `MT10[0-9]`;
                string:RegExp regex20x = re `MT20[0-9]`;
                if (orgnlMsgNmId.includes(PACS008) || orgnlMsgNmId.includes(PACS003) || regex10x.isFullMatch(orgnlMsgNmId)) {
                    return MESSAGETYPE_192;
                } else if (orgnlMsgNmId.includes(PACS009) || orgnlMsgNmId.includes(PACS010) || regex20x.isFullMatch(orgnlMsgNmId)) {
                    return MESSAGETYPE_292;
                }
            }
            log:printWarn(getSwiftLogMessage(WARNING, "T20092"));
            return MESSAGETYPE_292;
        }

        CAMT057 => {
            return MESSAGETYPE_210;
        }
        CAMT105 => {
            camtIsoRecord:Camt105Envelope envelope = check isoData.cloneWithType(camtIsoRecord:Camt105Envelope);
            camtIsoRecord:ChargesPerTransaction4? perTx = envelope.Document.ChrgsPmtNtfctn.Chrgs.PerTx;
            if perTx is camtIsoRecord:ChargesPerTransaction4 {
                string msgNmid = perTx.Rcrd[0].UndrlygTx.MsgNmId ?: EMPTY_STRING;
                if (msgNmid.startsWith(PACS008) || msgNmid.startsWith(MT103)) {
                    return MESSAGETYPE_190;
                }
            }
            return MESSAGETYPE_290;

        }
        CAMT106 => {
            camtIsoRecord:Camt106Envelope envelope = check isoData.cloneWithType(camtIsoRecord:Camt106Envelope);
            camtIsoRecord:ChargesPerTransaction3? perTx = envelope.Document.ChrgsPmtReq.Chrgs.PerTx;
            if perTx is camtIsoRecord:ChargesPerTransaction3 {
                string msgNmid = perTx.Rcrd[0].UndrlygTx.MsgNmId ?: EMPTY_STRING;
                if (msgNmid.startsWith(PACS008) || msgNmid.startsWith(MT103)) {
                    return MESSAGETYPE_191;
                }
            }
            return MESSAGETYPE_291;
        }
        CAMT107 => {
            return MESSAGETYPE_110;
        }
        CAMT108 => {
            return MESSAGETYPE_111;
        }
        CAMT109 => {
            return MESSAGETYPE_112;
        }
        PAIN001 => {
            //derived mapping
            return MESSAGETYPE_101;
        }
        PAIN008 => {
            //derived mapping
            return MESSAGETYPE_104;
        }
        _ => {
            return error("ISO 20022 message type is not supported.");
        }
    }
}

isolated function getTransformFunctionForPacs002(string mtMsgType) returns isolated function|error {
    // for MT199 and MT299
    return transformPacs002DocumentToMTn99;
}

isolated function getTransformFunctionForPacs003(string mtMsgType) returns isolated function|error {
    match mtMsgType {
        // derived mapping
        MESSAGETYPE_104 => {
            return transformPacs003DocumentToMT104;
        }
        MESSAGETYPE_107 => {
            return transformPacs003DocumentToMT107;
        }
    }
    return transformPacs003DocumentToMT107;
}

isolated function getTransformFunctionForPacs004(string mtMsgType) returns isolated function|error {
    match mtMsgType {
        MESSAGETYPE_103_RETN => {
            return transformPacs004DocumentToMT103RETN;
        }
        MESSAGETYPE_202_RETN => {
            return transformPacs004ToMt202RETN;
        }
        MESSAGETYPE_205_RETN => {
            return transformPacs004ToMt205RETN;
        }
        _ => {
            return transformPacs004DocumentToMT103RETN;
        }
    }
}

isolated function getTransformFunctionForPacs008(string mtMsgType) returns isolated function|error {
    match mtMsgType {
        MESSAGETYPE_103_STP => {
            return transformPacs008DocumentToMT103STP;
        }
        MESSAGETYPE_102_STP => {
            return transformPacs008DocumentToMT102STP;
        }
        MESSAGETYPE_102 => {
            return transformPacs008DocumentToMT102;
        }
        _ => {
            return transformPacs008DocumentToMT103;
        }
    }
}

isolated function getTransformFunctionForPacs009(string mtMsgType) returns isolated function|error {
    match mtMsgType {
        MESSAGETYPE_202_COV => {
            return transformPacs009ToMt202COV;
        }
        MESSAGETYPE_202_ADV => {
            return transformPacs009ToMt202;
        }
        MESSAGETYPE_205_COV => {
            return transformPacs009ToMt205COV;
        }
        MESSAGETYPE_205 => {
            return transformPacs009ToMt205;
        }
        _ => {
            // MESSAGETYPE_202
            return transformPacs009ToMt202;
        }
    }
}

isolated function getTransformFunctionForPacs010(string mtMsgType) returns isolated function {
    // derived mapping
    return transformPacs010ToMt204;
}

isolated function getTransformFunctionForCamt026(string mtMsgType) returns isolated function {
    // derived mapping
    return transformCamt029ToMtn96;
}

isolated function getTransformFunctionForCamt029(string mtMsgType) returns isolated function {
    // derived mapping
    return transformCamt029ToMtn96;
}

isolated function getTransformFunctionForCamt052(string mtMsgType) returns isolated function {
    return transformCamt052ToMt942;
}

isolated function getTransformFunctionForCamt053(string mtMsgType) returns isolated function {
    return transformCamt053ToMt940;
}

isolated function getTransformFunctionForCamt054(string mtMsgType) returns isolated function {
    match mtMsgType {
        MESSAGETYPE_910 => {
            return transformCamt054ToMt910;
        }
        MESSAGETYPE_900 => {
            return transformCamt054ToMt900;
        }
        _ => {
            return transformCamt054ToMt900;
        }
    }
}

isolated function getTransformFunctionForCamt056(string mtMsgType) returns isolated function {
    return transformCamt056ToMtn92;
}

isolated function getTransformFunctionForCamt057(string mtMsgType) returns isolated function {
    return transformCamt057ToMt210;
}

isolated function getTransformFunctionForCamt105(string mtMsgType) returns isolated function {
    return transformCamt105ToMtn90;
}

isolated function getTransformFunctionForCamt106(string mtMsgType) returns isolated function|error {
    return error("To be implemented");
    // return transformCamt106ToMtn91;
}

isolated function getTransformFunctionForCamt107(string mtMsgType) returns isolated function {
    return transformCamt107ToMt110;
}

isolated function getTransformFunctionForCamt108(string mtMsgType) returns isolated function {
    return transformCamt108ToMt111;
}

isolated function getTransformFunctionForCamt109(string mtMsgType) returns isolated function {
    return transformCamt109ToMt112;
}

isolated function getTransformFunctionForPain001(string mtMsgType) returns isolated function {
    // derived mapping
    return transformPain001DocumentToMT101;
}

isolated function getTransformFunctionForPain008(string mtMsgType) returns isolated function {
    // derived mapping
    return transformPain008DocumentToMT104;
}

final readonly & map<typedesc<record {}>> isoMessageTypes = {
    "pacs.002": pacsIsoRecord:Pacs002Envelope,
    "pacs.003": pacsIsoRecord:Pacs003Envelope,
    "pacs.004": pacsIsoRecord:Pacs004Envelope,
    "pacs.008": pacsIsoRecord:Pacs008Envelope,
    "pacs.009": pacsIsoRecord:Pacs009Envelope,
    "pacs.010": pacsIsoRecord:Pacs010Envelope,
    "pain.001": painIsoRecord:Pain001Envelope,
    "pain.008": painIsoRecord:Pain008Envelope,
    "camt.026": camtIsoRecord:Camt026Envelope,
    "camt.027": camtIsoRecord:Camt027Envelope,
    "camt.028": camtIsoRecord:Camt028Envelope,
    "camt.029": camtIsoRecord:Camt029Envelope,
    "camt.031": camtIsoRecord:Camt031Envelope,
    "camt.033": camtIsoRecord:Camt033Envelope,
    "camt.034": camtIsoRecord:Camt034Envelope,
    "camt.050": camtIsoRecord:Camt050Envelope,
    "camt.052": camtIsoRecord:Camt052Envelope,
    "camt.053": camtIsoRecord:Camt053Envelope,
    "camt.054": camtIsoRecord:Camt054Envelope,
    "camt.055": camtIsoRecord:Camt055Envelope,
    "camt.056": camtIsoRecord:Camt056Envelope,
    "camt.057": camtIsoRecord:Camt057Envelope,
    "camt.060": camtIsoRecord:Camt060Envelope,
    "camt.105": camtIsoRecord:Camt105Envelope,
    "camt.106": camtIsoRecord:Camt106Envelope,
    "camt.107": camtIsoRecord:Camt107Envelope,
    "camt.108": camtIsoRecord:Camt108Envelope,
    "camt.109": camtIsoRecord:Camt109Envelope
};
