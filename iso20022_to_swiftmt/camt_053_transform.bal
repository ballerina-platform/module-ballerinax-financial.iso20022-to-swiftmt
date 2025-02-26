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

# Transforms a camt.054 ISO 20022 document to its corresponding SWIFT MT940 format.
#
# + envelope - The camt.054 envelope containing the corresponding document to be transformed.
# + messageType - The SWIFT MT940 message type to be transformed.
# + return - The transformed SWIFT MT940 message or an error.
isolated function transformCamt053ToMt940(camtIsoRecord:Camt053Envelope envelope, string messageType) returns swiftmt:MT940Message|error => let
    camtIsoRecord:AccountStatement13 statement = envelope.Document.BkToCstmrStmt.Stmt[0],
    swiftmt:MT25A?|swiftmt:MT25P? field25a = getCashAccount(statement.Acct?.Id, statement.Acct?.Ownr),
    [swiftmt:MT60F, swiftmt:MT60M[], swiftmt:MT62F, swiftmt:MT62M[], swiftmt:MT64[], swiftmt:MT65[]]
        [field60F, field60M, field62F, field62M, field64, field65] = check getBalanceInformation(statement.Bal)
    in {
        block1: generateBlock1(getSenderOrReceiver(envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)),
        block2: check generateBlock2(messageType, getSenderOrReceiver(envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI),
                envelope.Document.BkToCstmrStmt.GrpHdr.CreDtTm),
        block4: {
            MT20: {name: MT20_NAME, msgId: {content: getField20Content(statement.Id), number: NUMBER1}},
            MT25: field25a is swiftmt:MT25A ? field25a : (),
            MT25P: field25a is swiftmt:MT25P ? field25a : (),
            MT28C: {
                name: MT28C_NAME,
                StmtNo: getStatementNumber(statement.LglSeqNb,
                        statement.ElctrncSeqNb),
                SeqNo: statement.StmtPgntn?.PgNb is string ?
                    {content: check decimal:fromString(statement.StmtPgntn?.PgNb.toString()), number: NUMBER2} : ()
            },
            MT60F: field60F,
            MT62F: field62F,
            MT61: getField61(statement.Ntry),
            MT60M: field60M.length() == 0 ? () : field60M,
            MT62M: field62M.length() == 0 ? () : field62M,
            MT64: field64.length() == 0 ? () : field64,
            MT65: field65.length() == 0 ? () : field65
        }
    };

# Transforms a camt.053 ISO 20022 document to its corresponding SWIFT MT950 format.
#
# + envelope - The camt.054 envelope containing the corresponding document to be transformed.
# + messageType - The SWIFT MT950 message type to be transformed.
# + return - The transformed SWIFT MT950 message or an error.
isolated function transformCamt053ToMt950(camtIsoRecord:Camt053Envelope envelope, string messageType) returns swiftmt:MT950Message|error => let
    camtIsoRecord:AccountStatement13 statement = envelope.Document.BkToCstmrStmt.Stmt[0],
    swiftmt:MT25A?|swiftmt:MT25P? field25a = getCashAccount(statement.Acct?.Id, statement.Acct?.Ownr, true),
    [swiftmt:MT60F, swiftmt:MT60M[], swiftmt:MT62F, swiftmt:MT62M[], swiftmt:MT64[], swiftmt:MT65[]]
        [field60F, field60M, field62F, field62M, field64, _] = check getBalanceInformation(statement.Bal)
    in {
        block1: generateBlock1(getSenderOrReceiver(envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)),
        block2: check generateBlock2(messageType, getSenderOrReceiver(envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI),
                envelope.Document.BkToCstmrStmt.GrpHdr.CreDtTm),
        block4: {
            MT20: {name: MT20_NAME, msgId: {content: getField20Content(statement.Id), number: NUMBER1}},
            MT25: field25a is swiftmt:MT25A ? field25a : {name: MT25_NAME, Acc: {content: "NOTPROVIDED", number: NUMBER1}},
            MT28C: {
                name: MT28C_NAME,
                StmtNo: getStatementNumber(statement.LglSeqNb,
                        statement.ElctrncSeqNb),
                SeqNo: statement.StmtPgntn?.PgNb is string ?
                    {content: check decimal:fromString(statement.StmtPgntn?.PgNb.toString()), number: NUMBER2} : ()
            },
            MT60F: field60F,
            MT62F: field62F,
            MT61: getField61(statement.Ntry),
            MT60M: field60M.length() == 0 ? () : field60M,
            MT62M: field62M.length() == 0 ? () : field62M,
            MT64: field64.length() == 0 ? () : field64
        }
    };

# Transforms a camt.053 ISO 20022 document to its corresponding SWIFT MT970 format.
#
# + envelope - The camt.054 envelope containing the corresponding document to be transformed.
# + messageType - The SWIFT MT970 message type to be transformed.
# + return - The transformed SWIFT MT970 message or an error.
isolated function transformCamt053ToMt970(camtIsoRecord:Camt053Envelope envelope, string messageType) returns swiftmt:MT970Message|error => let
    camtIsoRecord:AccountStatement13 statement = envelope.Document.BkToCstmrStmt.Stmt[0],
    swiftmt:MT25A?|swiftmt:MT25P? field25a = getCashAccount(statement.Acct?.Id, statement.Acct?.Ownr, true),
    [swiftmt:MT60F, swiftmt:MT60M[], swiftmt:MT62F, swiftmt:MT62M[], swiftmt:MT64[], swiftmt:MT65[]]
        [field60F, field60M, field62F, field62M, field64, _] = check getBalanceInformation(statement.Bal)
    in {
        block1: generateBlock1(getSenderOrReceiver(envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)),
        block2: check generateBlock2(messageType, getSenderOrReceiver(envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI),
                envelope.Document.BkToCstmrStmt.GrpHdr.CreDtTm),
        block4: {
            MT20: {name: MT20_NAME, msgId: {content: getField20Content(statement.Id), number: NUMBER1}},
            MT25: field25a is swiftmt:MT25A ? field25a : {name: MT25_NAME, Acc: {content: "NOTPROVIDED", number: NUMBER1}},
            MT28C: {
                name: MT28C_NAME,
                StmtNo: getStatementNumber(statement.LglSeqNb,
                        statement.ElctrncSeqNb),
                SeqNo: statement.StmtPgntn?.PgNb is string ?
                    {content: check decimal:fromString(statement.StmtPgntn?.PgNb.toString()), number: NUMBER2} : ()
            },
            MT60F: field60F,
            MT62F: field62F,
            MT61: getField61(statement.Ntry),
            MT60M: field60M.length() == 0 ? () : field60M,
            MT62M: field62M.length() == 0 ? () : field62M,
            MT64: field64.length() == 0 ? () : field64
        }
    };
