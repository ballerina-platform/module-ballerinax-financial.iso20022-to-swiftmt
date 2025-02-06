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

# Transforms a camt.054 ISO 20022 document to its corresponding SWIFT MT900 format.
#
# + envelope - The camt.054 envelope containing the corresponding document to be transformed.
# + messageType - The SWIFT MT900 message type to be transformed.
# + return - The transformed SWIFT MT900 message or an error.
isolated function transformCamt054ToMt900(camtIsoRecord:Camt054Envelope envelope, string messageType) returns swiftmt:MT900Message|error => let
camtIsoRecord:ReportEntry14? entry = getEntry(envelope.Document.BkToCstmrDbtCdtNtfctn.Ntfctn[0].Ntry),
camtIsoRecord:EntryTransaction14? transactionDetails = getTransactionDetails(entry?.NtryDtls),
swiftmt:MT25A?|swiftmt:MT25P? field25a = getCashAccount(envelope.Document.BkToCstmrDbtCdtNtfctn.Ntfctn[0].Acct?.Id, envelope.Document.BkToCstmrDbtCdtNtfctn.Ntfctn[0].Acct?.Ownr),
swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT52D? field52 = check getField52(transactionDetails?.RltdPties?.Dbtr?.Agt?.FinInstnId, transactionDetails?.RltdPties?.DbtrAcct?.Id) in {
        block1: generateBlock1(getSenderOrReceiver(envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)),
        block2: generateBlock2(messageType, getSenderOrReceiver(envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI),
                envelope.Document.BkToCstmrDbtCdtNtfctn.GrpHdr.CreDtTm),
        block4: {
            MT20: {name: MT20_NAME, msgId: {content: getMxToMTReference(envelope.Document.BkToCstmrDbtCdtNtfctn.GrpHdr.MsgId), number: NUMBER1}},
            MT21: {name: MT21_NAME, Ref: {content: getMessageReference(transactionDetails?.Refs), number: NUMBER1}},
            MT32A: {
                name: MT32A_NAME,
                Dt: {content: extractDate(entry), number: NUMBER1},
                Ccy: {content: getMandatoryField(entry?.Amt?.Ccy), number: NUMBER2},
                Amnt: {content: check convertToString(entry?.Amt?.content), number: NUMBER3}
            },
            MT13D: getField13D(entry?.BookgDt?.DtTm),
            MT25: field25a is swiftmt:MT25A ? field25a : (),
            MT25P: field25a is swiftmt:MT25P ? field25a : (),
            MT52A: field52 is swiftmt:MT52A ? field52 : (),
            MT52D: field52 is swiftmt:MT52D ? field52 : (),
            MT72: getField72ForMt900Or910(transactionDetails?.AddtlTxInf)
        }
    };

# Transforms a camt.054 ISO 20022 document to its corresponding SWIFT MT900 format.
#
# + envelope - The camt.054 envelope containing the corresponding document to be transformed.
# + messageType - The SWIFT MT910 message type to be transformed.
# + return - The transformed SWIFT MT950 message or an error.
isolated function transformCamt054ToMt910(camtIsoRecord:Camt054Envelope envelope, string messageType) returns swiftmt:MT910Message|error => let
camtIsoRecord:ReportEntry14? entry = getEntry(envelope.Document.BkToCstmrDbtCdtNtfctn.Ntfctn[0].Ntry),
camtIsoRecord:EntryTransaction14? transactionDetails = getTransactionDetails(entry?.NtryDtls),
swiftmt:MT25A?|swiftmt:MT25P? field25a = getCashAccount(envelope.Document.BkToCstmrDbtCdtNtfctn.Ntfctn[0].Acct?.Id, envelope.Document.BkToCstmrDbtCdtNtfctn.Ntfctn[0].Acct?.Ownr),
swiftmt:MT50A?|swiftmt:MT50G?|swiftmt:MT50K?|swiftmt:MT50H?|swiftmt:MT50F? field50a = check getField50a(transactionDetails?.RltdPties?.Dbtr?.Pty, transactionDetails?.RltdPties?.DbtrAcct?.Id),
swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT52D? field52 = check getDebtorAgentForMt910(transactionDetails?.RltdAgts?.DbtrAgt, transactionDetails?.RltdPties?.Dbtr?.Agt, transactionDetails?.RltdPties?.DbtrAcct),
swiftmt:MT56A?|swiftmt:MT56C?|swiftmt:MT56D? field56 = check getField56(transactionDetails?.RltdAgts?.IntrmyAgt1?.FinInstnId, ()) in {
        block1: generateBlock1(getSenderOrReceiver(envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)),
        block2: generateBlock2(messageType, getSenderOrReceiver(envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI),
                envelope.Document.BkToCstmrDbtCdtNtfctn.GrpHdr.CreDtTm),
        block4: {
            MT20: {name: MT20_NAME, msgId: {content: getMxToMTReference(envelope.Document.BkToCstmrDbtCdtNtfctn.GrpHdr.MsgId), number: NUMBER1}},
            MT21: {name: MT21_NAME, Ref: {content: getMessageReference(transactionDetails?.Refs), number: NUMBER1}},
            MT32A: {
                name: MT32A_NAME,
                Dt: {content: extractDate(entry), number: NUMBER1},
                Ccy: {content: getMandatoryField(entry?.Amt?.Ccy), number: NUMBER2},
                Amnt: {content: check convertToString(entry?.Amt?.content), number: NUMBER3}
            },
            MT13D: getField13D(entry?.BookgDt?.DtTm),
            MT25: field25a is swiftmt:MT25A ? field25a : (),
            MT25P: field25a is swiftmt:MT25P ? field25a : (),
            MT50A: field50a is swiftmt:MT50A ? field50a : (),
            MT50F: field50a is swiftmt:MT50F ? field50a : (),
            MT50K: field50a is swiftmt:MT50K ? field50a : (),
            MT52A: field52 is swiftmt:MT52A ? field52 : (),
            MT52D: field52 is swiftmt:MT52D ? field52 : getdefaultField52(field52),
            MT56A: field56 is swiftmt:MT56A ? field56 : (),
            MT56D: field56 is swiftmt:MT56D ? field56 : (),
            MT72: getField72ForMt900Or910(transactionDetails?.AddtlTxInf)
        }
    };

# Extract date from report entry.
#
# + reportEntry - report entry
# + return - return swift standard date
isolated function extractDate(camtIsoRecord:ReportEntry14? reportEntry) returns string {
    string date = "";
    if getTransactionDetails(reportEntry?.NtryDtls)?.RltdDts?.IntrBkSttlmDt is string {
        date = getTransactionDetails(reportEntry?.NtryDtls)?.RltdDts?.IntrBkSttlmDt.toString();
    }
    if reportEntry?.ValDt?.DtTm is string {
        date = reportEntry?.ValDt?.DtTm.toString();
    }
    if reportEntry?.BookgDt?.Dt is string {
        date = reportEntry?.BookgDt?.Dt.toString();
    }
    return convertToSWIFTStandardDate(date);
}

# Get default field 52.
#
# + field52 - field 52
# + return - return swift field 52 D or nill
isolated function getdefaultField52(swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT52D? field52) returns ()|swiftmt:MT52D {
    if field52 !is swiftmt:MT52A && field52 !is swiftmt:MT52D {
        return {name: MT52D_NAME, Nm: [], AdrsLine: [], PrtyIdn: {content: "NOTPROVIDED", number: NUMBER3}};
    }
    return ();
}
