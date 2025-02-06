// Copyright (c) 2025, WSO2 LLC. (https://www.wso2.com).
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

import ballerinax/financial.iso20022.cash_management as camtIsoRecord;
import ballerinax/financial.swift.mt as swiftmt;

# Transforms a camt.052 ISO 20022 document to its corresponding SWIFT MT971 format.
#
# + envelope - The camt.054 envelope containing the corresponding document to be transformed.
# + messageType - The SWIFT MT971 message type to be transformed.
# + return - The transformed SWIFT MT971 message or an error.
isolated function transformCamt052ToMt971(camtIsoRecord:Camt052Envelope envelope, string messageType) returns swiftmt:MT971Message|error => let
    swiftmt:MT25A?|swiftmt:MT25P? field25a = getCashAccount(envelope.Document.BkToCstmrAcctRpt.Rpt[0].Acct?.Id, envelope.Document.BkToCstmrAcctRpt.Rpt[0].Acct?.Ownr, true),
    [swiftmt:MT60F, swiftmt:MT60M[], swiftmt:MT62F, swiftmt:MT62M[], swiftmt:MT64[], swiftmt:MT65[]]
        [_, _, field62F, _, _, _] = check getBalanceInformation(envelope.Document.BkToCstmrAcctRpt.Rpt[0].Bal)
    in {
        block1: generateBlock1(getSenderOrReceiver(envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)),
        block2: generateBlock2(messageType, getSenderOrReceiver(envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI),
                envelope.Document.BkToCstmrAcctRpt.GrpHdr.CreDtTm),
        block4: {
            MT20: {name: MT20_NAME, msgId: {content: getMxToMTReference(envelope.Document.BkToCstmrAcctRpt.GrpHdr.MsgId), number: NUMBER1}},
            MT25: field25a is swiftmt:MT25A ? field25a : {name: MT25_NAME, Acc: {content: "NOTPROVIDED", number: NUMBER1}},
            MT62F: field62F
        }
    };

# Transforms a camt.052 ISO 20022 document to its corresponding SWIFT MT972 format.
#
# + envelope - The camt.054 envelope containing the corresponding document to be transformed.
# + messageType - The SWIFT MT972 message type to be transformed.
# + return - The transformed SWIFT MT972 message or an error.
isolated function transformCamt052ToMt972(camtIsoRecord:Camt052Envelope envelope, string messageType) returns swiftmt:MT972Message|error => let
    swiftmt:MT25A?|swiftmt:MT25P? field25a = getCashAccount(envelope.Document.BkToCstmrAcctRpt.Rpt[0].Acct?.Id, envelope.Document.BkToCstmrAcctRpt.Rpt[0].Acct?.Ownr, true),
    [swiftmt:MT60F, swiftmt:MT60M[], swiftmt:MT62F, swiftmt:MT62M[], swiftmt:MT64[], swiftmt:MT65[]]
        [field60F, field60M, field62F, field62M, field64, _] = check getBalanceInformation(envelope.Document.BkToCstmrAcctRpt.Rpt[0].Bal)
    in {
        block1: generateBlock1(getSenderOrReceiver(envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)),
        block2: generateBlock2(messageType, getSenderOrReceiver(envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI),
                envelope.Document.BkToCstmrAcctRpt.GrpHdr.CreDtTm),
        block4: {
            MT20: {name: MT20_NAME, msgId: {content: getMxToMTReference(envelope.Document.BkToCstmrAcctRpt.GrpHdr.MsgId), number: NUMBER1}},
            MT25: field25a is swiftmt:MT25A ? field25a : {name: MT25_NAME, Acc: {content: "NOTPROVIDED", number: NUMBER1}},
            MT28C: {name: MT28C_NAME, StmtNo: {content: envelope.Document.BkToCstmrAcctRpt.Rpt[0].LglSeqNb ?: 1, number: NUMBER1}, SeqNo: {content: envelope.Document.BkToCstmrAcctRpt.Rpt[0].ElctrncSeqNb ?: 1, number: NUMBER2}},
            MT60F: field60F,
            MT62F: field62F,
            MT61: check getField61(envelope.Document.BkToCstmrAcctRpt.Rpt[0].Ntry),
            MT60M: field60M.length() == 0 ? () : field60M,
            MT62M: field62M.length() == 0 ? () : field62M,
            MT64: field64.length() == 0 ? () : field64
        }
    };

# Transforms a camt.052 ISO 20022 document to its corresponding SWIFT MT941 format.
#
# + envelope - The camt.054 envelope containing the corresponding document to be transformed.
# + messageType - The SWIFT MT941 message type to be transformed.
# + return - The transformed SWIFT MT941 message or an error.
isolated function transformCamt052ToMt941(camtIsoRecord:Camt052Envelope envelope, string messageType) returns swiftmt:MT941Message|error => let
    swiftmt:MT25A?|swiftmt:MT25P? field25a = getCashAccount(envelope.Document.BkToCstmrAcctRpt.Rpt[0].Acct?.Id, envelope.Document.BkToCstmrAcctRpt.Rpt[0].Acct?.Ownr, true),
    [swiftmt:MT60F, swiftmt:MT60M[], swiftmt:MT62F, swiftmt:MT62M[], swiftmt:MT64[], swiftmt:MT65[]]
        [field60F, _, field62F, _, field64, field65] = check getBalanceInformation(envelope.Document.BkToCstmrAcctRpt.Rpt[0].Bal)
    in {
        block1: generateBlock1(getSenderOrReceiver(envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)),
        block2: generateBlock2(messageType, getSenderOrReceiver(envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI),
                envelope.Document.BkToCstmrAcctRpt.GrpHdr.CreDtTm),
        block4: {
            MT20: {name: MT20_NAME, msgId: {content: getMxToMTReference(envelope.Document.BkToCstmrAcctRpt.GrpHdr.MsgId), number: NUMBER1}},
            MT25: field25a is swiftmt:MT25A ? field25a : {name: MT25_NAME, Acc: {content: "NOTPROVIDED", number: NUMBER1}},
            MT28: {name: MT28_NAME, StmtNo: {content: envelope.Document.BkToCstmrAcctRpt.Rpt[0].LglSeqNb ?: 1, number: NUMBER1}, SeqNo: {content: envelope.Document.BkToCstmrAcctRpt.Rpt[0].ElctrncSeqNb ?: 1, number: NUMBER2}},
            MT13D: getField13D(envelope.Document.BkToCstmrAcctRpt.Rpt[0].CreDtTm),
            MT60F: field60F,
            MT62F: field62F,
            MT65: field65.length() == 0 ? () : field65,
            MT64: field64.length() == 0 ? () : field64,
            MT90D: check getField90D(envelope.Document.BkToCstmrAcctRpt.Rpt[0].TxsSummry?.TtlDbtNtries),
            MT90C: check getField90C(envelope.Document.BkToCstmrAcctRpt.Rpt[0].TxsSummry?.TtlCdtNtries)
        }
    };

# Transforms a camt.052 ISO 20022 document to its corresponding SWIFT MT942 format.
#
# + envelope - The camt.054 envelope containing the corresponding document to be transformed.
# + messageType - The SWIFT MT942 message type to be transformed.
# + return - The transformed SWIFT MT942 message or an error.
isolated function transformCamt052ToMt942(camtIsoRecord:Camt052Envelope envelope, string messageType) returns swiftmt:MT942Message|error => let
    camtIsoRecord:AccountReport33 report = envelope.Document.BkToCstmrAcctRpt.Rpt[0],
    swiftmt:MT25A?|swiftmt:MT25P? field25a = getCashAccount(report.Acct?.Id, report.Acct?.Ownr, true) in {
        block1: generateBlock1(getSenderOrReceiver(envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)),
        block2: generateBlock2(messageType, getSenderOrReceiver(envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI),
                envelope.Document.BkToCstmrAcctRpt.GrpHdr.CreDtTm),
        block4: {
            MT20: {name: MT20_NAME, msgId: {content: getMxToMTReference(report.Id), number: NUMBER1}},
            MT25: field25a is swiftmt:MT25A ? field25a : {name: MT25_NAME, Acc: {content: "NOTPROVIDED", number: NUMBER1}},
            MT28C: {
                name: MT28C_NAME,
                StmtNo: getStatementNumber(report.LglSeqNb,
                        report.ElctrncSeqNb),
                SeqNo: {content: check getSequenceNumber(report.RptPgntn), number: NUMBER2}
            },
            MT13D: check getField13DforCamt(envelope.Document.BkToCstmrAcctRpt),
            MT34F: getField34FforCamt052(report.Acct?.Ccy),
            MT61: check getField61(report.Ntry),
            MT90D: check getField90D(report.TxsSummry?.TtlDbtNtries),
            MT90C: check getField90C(report.TxsSummry?.TtlCdtNtries)
        }
    };

# Get sequence number from pagination.
#
# + pagntn - pagination
# + return - decimal sequence number or an error
isolated function getSequenceNumber(camtIsoRecord:Pagination1? pagntn) returns decimal|error {
    if pagntn is camtIsoRecord:Pagination1 {
        return decimal:fromString(pagntn.PgNb.toString());
    }
    return 1;
}

# Get field 13D.
# 
# + bkToCstmrAcctRpt - bank to customer account report
# + return - MT13D field or an error
isolated function getField13DforCamt(camtIsoRecord:BankToCustomerAccountReportV12 bkToCstmrAcctRpt) returns swiftmt:MT13D|error {
    if bkToCstmrAcctRpt.Rpt[0].CreDtTm !is () {
        return getField13D(bkToCstmrAcctRpt.Rpt[0].CreDtTm).ensureType();
    }
    return getField13D(bkToCstmrAcctRpt.GrpHdr.CreDtTm).ensureType();
}

# Get field 34F.
#
# + currency - currency
# + return - MT34F field array
isolated function getField34FforCamt052(camtIsoRecord:ActiveOrHistoricCurrencyCode? currency) returns swiftmt:MT34F[] {
    swiftmt:MT34F[] field34F = [];
    if currency is camtIsoRecord:ActiveOrHistoricCurrencyCode {
        field34F.push({name: MT34F_NAME, Ccy: {content: currency, number: NUMBER1}, Amnt: {content: "0,", number: NUMBER3}});
    }
    return field34F;
}
