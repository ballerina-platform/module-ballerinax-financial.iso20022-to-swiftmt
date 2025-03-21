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

import ballerinax/financial.iso20022.payments_clearing_and_settlement as pacsIsoRecord;
import ballerinax/financial.swift.mt as swiftmt;

# Transforms the given ISO 20022 Pacs.003 envelope.Document to its corresponding SWIFT MT104 format.
#
# + envelope - The Pacs003 envelope containing the corresponding document to be transformed.
# + messageType - The SWIFT message type
# + return - The transformed SWIFT MT104 message or an error if the transformation fails
isolated function transformPacs003DocumentToMT104(pacsIsoRecord:Pacs003Envelope envelope, string messageType) returns swiftmt:MT104Message|error => let
    pacsIsoRecord:DirectDebitTransactionInformation31[] dbtTrfTx = envelope.Document.FIToFICstmrDrctDbt.DrctDbtTxInf,
    swiftmt:MT50?|swiftmt:MT50C?|swiftmt:MT50L? instructingParty = getMT104Or107InstructionPartyFromPacs003Document(dbtTrfTx),
    swiftmt:MT50A?|swiftmt:MT50G?|swiftmt:MT50K?|swiftmt:MT50H?|swiftmt:MT50F? field50a = check getMT104Or107CreditorFromPacs003Document(dbtTrfTx),
    swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT52D? field52 = check getMT104Or107CreditorsBankFromPacs003Document(dbtTrfTx),
    swiftmt:MT53A?|swiftmt:MT53B?|swiftmt:MT53C?|swiftmt:MT53D? field53 = getField53(dbtTrfTx[0].IntrmyAgt1?.FinInstnId, dbtTrfTx[0].IntrmyAgt1Acct?.Id, isOptionBPresent = true),
    swiftmt:MT104Transaction[] transactions = check generateMT104TransactionsFromPacs003(dbtTrfTx)
    in {
        block1: generateBlock1(getSenderOrReceiver(envelope.Document.FIToFICstmrDrctDbt.GrpHdr.InstdAgt?.FinInstnId?.BICFI,
                        envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)),
        block2: check generateBlock2(messageType, getSenderOrReceiver(envelope.Document.FIToFICstmrDrctDbt.GrpHdr.InstgAgt?.FinInstnId?.BICFI,
                        envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI), envelope.Document.FIToFICstmrDrctDbt.GrpHdr.CreDtTm),
        block3: createMtBlock3(envelope.Document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].PmtId?.UETR),
        block4: {
            MT19: getField19(envelope.Document.FIToFICstmrDrctDbt.GrpHdr.CtrlSum),
            MT20: {
                name: MT20_NAME,
                msgId: {
                    content: getField20Content(envelope.Document.FIToFICstmrDrctDbt.GrpHdr.MsgId),
                    number: NUMBER1
                }
            },
            MT23E: getRepeatingField23EForPacs003(dbtTrfTx),
            MT26T: getRepeatingField26T(dbtTrfTx),
            MT30: {
                name: MT30_NAME,
                Dt: {content: convertToSWIFTStandardDate(dbtTrfTx[0].IntrBkSttlmDt), number: NUMBER1}
            },
            MT32B: envelope.Document.FIToFICstmrDrctDbt.GrpHdr.TtlIntrBkSttlmAmt is () ? {
                    name: MT32B_NAME,
                    Ccy: {content: dbtTrfTx[0].IntrBkSttlmAmt.Ccy, number: NUMBER1},
                    Amnt: {content: getTotalInterBankSettlementAmount(dbtTrfTx), number: NUMBER2}
                } : {
                    name: MT32B_NAME,
                    Ccy: {content: envelope.Document.FIToFICstmrDrctDbt.GrpHdr.TtlIntrBkSttlmAmt?.Ccy.toString(), number: NUMBER1},
                    Amnt: {content: convertDecimalToSwiftDecimal(envelope.Document.FIToFICstmrDrctDbt.GrpHdr.TtlIntrBkSttlmAmt?.content), number: NUMBER2}
                },
            MT50C: instructingParty is swiftmt:MT50C ? instructingParty : (),
            MT50L: instructingParty is swiftmt:MT50L ? instructingParty : (),
            MT50A: field50a is swiftmt:MT50A ? field50a : (),
            MT50K: field50a is swiftmt:MT50K ? field50a : (),
            MT51A: getField51A(envelope.Document.FIToFICstmrDrctDbt.GrpHdr.InstgAgt?.FinInstnId),
            MT52A: field52 is swiftmt:MT52A ? field52 : (),
            MT52C: field52 is swiftmt:MT52C ? field52 : (),
            MT52D: field52 is swiftmt:MT52D ? field52 : (),
            MT53A: field53 is swiftmt:MT53A ? field53 : (),
            MT53B: field53 is swiftmt:MT53B ? field53 : (),
            MT71A: getRepeatingField71A(dbtTrfTx),
            MT71F: dbtTrfTx[0].ChrgsInf is () ? () : {
                    name: MT71F_NAME,
                    Ccy: {content: (<pacsIsoRecord:Charges16?>getFirstElementFromArray(dbtTrfTx[0].ChrgsInf))?.Amt?.Ccy.toString(), number: NUMBER1},
                    Amnt: {content: convertDecimalToSwiftDecimal((<pacsIsoRecord:Charges16?>getFirstElementFromArray(dbtTrfTx[0].ChrgsInf))?.Amt?.content), number: NUMBER2}
                },
            MT71G: dbtTrfTx[0].ChrgsInf is () ? () : {
                    name: MT71G_NAME,
                    Ccy: {content: (<pacsIsoRecord:Charges16?>getFirstElementFromArray(dbtTrfTx[0].ChrgsInf))?.Amt?.Ccy.toString(), number: NUMBER1},
                    Amnt: {content: convertDecimalToSwiftDecimal((<pacsIsoRecord:Charges16?>getFirstElementFromArray(dbtTrfTx[0].ChrgsInf))?.Amt?.content), number: NUMBER2}
                },
            MT77B: getRepeatingField77BForPacs003(dbtTrfTx),
            Transaction: transactions
        },
        block5: check generateMtBlock5FromSupplementaryData(envelope.Document.FIToFICstmrDrctDbt.SplmtryData)
    };

# Creates the MT104 transactions from the Pacs003 envelope.Document's direct debit transaction information.
#
# + drctDbtTxInf - Array of DirectDebitTransactionInformation31 from Pacs003 envelope.Document
# + return - Array of MT104 transactions or an error
isolated function generateMT104TransactionsFromPacs003(
        pacsIsoRecord:DirectDebitTransactionInformation31[] drctDbtTxInf
) returns swiftmt:MT104Transaction[]|error {
    swiftmt:MT104Transaction[] transactions = [];
    foreach pacsIsoRecord:DirectDebitTransactionInformation31 tx in drctDbtTxInf {
        swiftmt:MT50?|swiftmt:MT50C?|swiftmt:MT50L? instructingParty = getMT104Or107InstructionPartyFromPacs003Document(drctDbtTxInf, tx, true);
        swiftmt:MT50A?|swiftmt:MT50G?|swiftmt:MT50K?|swiftmt:MT50H?|swiftmt:MT50F? field50a = check getMT104Or107CreditorFromPacs003Document(drctDbtTxInf, tx, true);
        swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT52D? field52 = check getMT104Or107CreditorsBankFromPacs003Document(drctDbtTxInf, tx, true);
        swiftmt:MT57A?|swiftmt:MT57B?|swiftmt:MT57C?|swiftmt:MT57D? field57 = check getField57(tx.DbtrAgt?.FinInstnId, tx.DbtrAgtAcct?.Id, isOptionCPresent = true);
        swiftmt:MT59?|swiftmt:MT59A?|swiftmt:MT59F? field59 = getField59a(tx.Dbtr, tx.DbtrAcct?.Id, isOptionFPresent = false);
        swiftmt:MT21 MT21 = {
            name: MT21_NAME,
            Ref: {
                content: truncate(tx.PmtId?.EndToEndId, 16),
                number: NUMBER1
            }
        };

        swiftmt:MT23E? MT23E = getRepeatingField23EForPacs003(drctDbtTxInf, tx.PmtTpInf?.CtgyPurp?.Cd, true);

        swiftmt:MT32B MT32B = {
            name: MT32B_NAME,
            Ccy: {content: tx.IntrBkSttlmAmt.Ccy, number: NUMBER1},
            Amnt: {content: convertDecimalToSwiftDecimal(tx.IntrBkSttlmAmt?.content), number: NUMBER2}
        };

        swiftmt:MT21C? MT21C = getField21C(tx.DrctDbtTx?.MndtRltdInf?.MndtId);
        swiftmt:MT26T? MT26T = getRepeatingField26T(drctDbtTxInf, tx.Purp, true);
        swiftmt:MT33B? MT33B = getField33B(tx.InstdAmt, tx.IntrBkSttlmAmt);
        swiftmt:MT36? MT36 = getField36(tx.XchgRate);

        swiftmt:MT50C? MT50C = instructingParty is swiftmt:MT50C ? instructingParty : ();
        swiftmt:MT50L? MT50L = instructingParty is swiftmt:MT50L ? instructingParty : ();

        swiftmt:MT50A? MT50A = field50a is swiftmt:MT50A ? field50a : ();
        swiftmt:MT50K? MT50K = field50a is swiftmt:MT50K ? field50a : ();

        swiftmt:MT52A? MT52A = field52 is swiftmt:MT52A ? field52 : ();
        swiftmt:MT52C? MT52C = field52 is swiftmt:MT52C ? field52 : ();
        swiftmt:MT52D? MT52D = field52 is swiftmt:MT52D ? field52 : ();

        swiftmt:MT57A? MT57A = field57 is swiftmt:MT57A ? field57 : ();
        swiftmt:MT57C? MT57C = field57 is swiftmt:MT57C ? field57 : ();
        swiftmt:MT57D? MT57D = field57 is swiftmt:MT57D ? field57 : ();

        swiftmt:MT59? MT59 = field59 is swiftmt:MT59 ? field59 : ();
        swiftmt:MT59A? MT59A = field59 is swiftmt:MT59A ? field59 : ();

        swiftmt:MT70? MT70 = getField70(tx.RmtInf?.Ustrd);
        swiftmt:MT71A? MT71A = getRepeatingField71A(drctDbtTxInf, tx.ChrgBr, true);
        swiftmt:MT77B? MT77B = getRepeatingField77BForPacs003(drctDbtTxInf, tx.RgltryRptg, true);

        transactions.push({
            MT21,
            MT21C,
            MT23E,
            MT26T,
            MT32B,
            MT33B,
            MT36,
            MT50C,
            MT50L,
            MT50A,
            MT50K,
            MT52A,
            MT52C,
            MT52D,
            MT57A,
            MT57C,
            MT57D,
            MT59,
            MT59A,
            MT70,
            MT71A,
            MT77B
        });
    }

    return transactions;
}

# Tranform the given ISO 20022 Pacs.003 envelope.Document to its corresponding SWIFT MT107 format.
# + envelope - The Pacs003 envelope containing the corresponding document to be transformed.
# + messageType - The SWIFT message type
# + return - The transformed SWIFT MT107 message or an error if the transformation fails
isolated function transformPacs003DocumentToMT107(pacsIsoRecord:Pacs003Envelope envelope, string messageType) returns swiftmt:MT107Message|error => let
    pacsIsoRecord:DirectDebitTransactionInformation31[] dbtTrfTx = envelope.Document.FIToFICstmrDrctDbt.DrctDbtTxInf,
    swiftmt:MT50?|swiftmt:MT50C?|swiftmt:MT50L? instructingParty = getMT104Or107InstructionPartyFromPacs003Document(dbtTrfTx),
    swiftmt:MT50A?|swiftmt:MT50G?|swiftmt:MT50K?|swiftmt:MT50H?|swiftmt:MT50F? field50a = check getMT104Or107CreditorFromPacs003Document(dbtTrfTx),
    swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT52D? field52 = check getMT104Or107CreditorsBankFromPacs003Document(dbtTrfTx),
    swiftmt:MT53A?|swiftmt:MT53B?|swiftmt:MT53C?|swiftmt:MT53D? field53 = getField53(dbtTrfTx[0].IntrmyAgt1?.FinInstnId, dbtTrfTx[0].IntrmyAgt1Acct?.Id, isOptionBPresent = true),
    swiftmt:MT104Transaction[] transactions = check generateMT107TransactionsFromPacs003(dbtTrfTx)
    in {
        block1: generateBlock1(getSenderOrReceiver(envelope.Document.FIToFICstmrDrctDbt.GrpHdr.InstdAgt?.FinInstnId?.BICFI,
                        envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)),
        block2: check generateBlock2(messageType, getSenderOrReceiver(envelope.Document.FIToFICstmrDrctDbt.GrpHdr.InstgAgt?.FinInstnId?.BICFI,
                        envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI), envelope.Document.FIToFICstmrDrctDbt.GrpHdr.CreDtTm),
        block3: createMtBlock3(envelope.Document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].PmtId?.UETR),
        block4: {
            MT19: getField19(envelope.Document.FIToFICstmrDrctDbt.GrpHdr.CtrlSum),
            MT20: {
                name: MT20_NAME,
                msgId: {
                    content: getField20Content(envelope.Document.FIToFICstmrDrctDbt.GrpHdr.MsgId),
                    number: NUMBER1
                }
            },
            MT23E: getRepeatingField23EForPacs003(dbtTrfTx),
            MT26T: getRepeatingField26T(dbtTrfTx),
            MT30: {
                name: MT30_NAME,
                Dt: {content: convertToSWIFTStandardDate(dbtTrfTx[0].IntrBkSttlmDt), number: NUMBER1}
            },
            MT32B: envelope.Document.FIToFICstmrDrctDbt.GrpHdr.TtlIntrBkSttlmAmt is () ? {
                    name: MT32B_NAME,
                    Ccy: {content: dbtTrfTx[0].IntrBkSttlmAmt.Ccy, number: NUMBER1},
                    Amnt: {content: getTotalInterBankSettlementAmount(dbtTrfTx), number: NUMBER2}
                } : {
                    name: MT32B_NAME,
                    Ccy: {content: envelope.Document.FIToFICstmrDrctDbt.GrpHdr.TtlIntrBkSttlmAmt?.Ccy.toString(), number: NUMBER1},
                    Amnt: {content: convertDecimalToSwiftDecimal(envelope.Document.FIToFICstmrDrctDbt.GrpHdr.TtlIntrBkSttlmAmt?.content), number: NUMBER2}
                },
            MT50C: instructingParty is swiftmt:MT50C ? instructingParty : (),
            MT50L: instructingParty is swiftmt:MT50L ? instructingParty : (),
            MT50A: field50a is swiftmt:MT50A ? field50a : (),
            MT50K: field50a is swiftmt:MT50K ? field50a : (),
            MT51A: getField51A(envelope.Document.FIToFICstmrDrctDbt.GrpHdr.InstgAgt?.FinInstnId),
            MT52A: field52 is swiftmt:MT52A ? field52 : (),
            MT52C: field52 is swiftmt:MT52C ? field52 : (),
            MT52D: field52 is swiftmt:MT52D ? field52 : (),
            MT53A: field53 is swiftmt:MT53A ? field53 : (),
            MT53B: field53 is swiftmt:MT53B ? field53 : (),
            MT71A: getRepeatingField71A(dbtTrfTx),
            MT71F: dbtTrfTx[0].ChrgsInf is () ? () : {
                    name: MT71F_NAME,
                    Ccy: {content: (<pacsIsoRecord:Charges16?>getFirstElementFromArray(dbtTrfTx[0].ChrgsInf))?.Amt?.Ccy.toString(), number: NUMBER1},
                    Amnt: {content: convertDecimalToSwiftDecimal((<pacsIsoRecord:Charges16?>getFirstElementFromArray(dbtTrfTx[0].ChrgsInf))?.Amt?.content), number: NUMBER2}
                },
            MT71G: dbtTrfTx[0].ChrgsInf is () ? () : {
                    name: MT71G_NAME,
                    Ccy: {content: (<pacsIsoRecord:Charges16?>getFirstElementFromArray(dbtTrfTx[0].ChrgsInf))?.Amt?.Ccy.toString(), number: NUMBER1},
                    Amnt: {content: convertDecimalToSwiftDecimal((<pacsIsoRecord:Charges16?>getFirstElementFromArray(dbtTrfTx[0].ChrgsInf))?.Amt?.content), number: NUMBER2}
                },
            MT77B: getRepeatingField77BForPacs003(dbtTrfTx),
            Transaction: transactions
        },
        block5: check generateMtBlock5FromSupplementaryData(envelope.Document.FIToFICstmrDrctDbt.SplmtryData)
    };

# generate the MT107 transactions from the Pacs003 envelope.Document's direct debit transaction information.
# + drctDbtTxInf - Array of DirectDebitTransactionInformation31 from Pacs003 envelope.Document
# + return - Array of MT107 transactions or an error
isolated function generateMT107TransactionsFromPacs003(
        pacsIsoRecord:DirectDebitTransactionInformation31[] drctDbtTxInf
) returns swiftmt:MT107Transaction[]|error {
    swiftmt:MT107Transaction[] transactions = [];
    foreach pacsIsoRecord:DirectDebitTransactionInformation31 tx in drctDbtTxInf {
        swiftmt:MT50?|swiftmt:MT50C?|swiftmt:MT50L? instructingParty = getMT104Or107InstructionPartyFromPacs003Document(drctDbtTxInf, tx, true);
        swiftmt:MT50A?|swiftmt:MT50G?|swiftmt:MT50K?|swiftmt:MT50H?|swiftmt:MT50F? field50a = check getMT104Or107CreditorFromPacs003Document(drctDbtTxInf, tx, true);
        swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT52D? field52 = check getMT104Or107CreditorsBankFromPacs003Document(drctDbtTxInf, tx, true);
        swiftmt:MT57A?|swiftmt:MT57B?|swiftmt:MT57C?|swiftmt:MT57D? field57 = check getField57(tx.DbtrAgt?.FinInstnId, tx.DbtrAgtAcct?.Id, isOptionCPresent = true);
        swiftmt:MT59?|swiftmt:MT59A?|swiftmt:MT59F? field59 = getField59a(tx.Dbtr, tx.DbtrAcct?.Id, isOptionFPresent = false);
        swiftmt:MT21 MT21 = {
            name: MT21_NAME,
            Ref: {
                content: truncate(tx.PmtId?.EndToEndId, 16),
                number: NUMBER1
            }
        };

        swiftmt:MT23E? MT23E = getRepeatingField23EForPacs003(drctDbtTxInf, tx.PmtTpInf?.CtgyPurp?.Cd, true);

        swiftmt:MT32B MT32B = {
            name: MT32B_NAME,
            Ccy: {content: tx.IntrBkSttlmAmt.Ccy, number: NUMBER1},
            Amnt: {content: convertDecimalToSwiftDecimal(tx.IntrBkSttlmAmt?.content), number: NUMBER2}
        };

        swiftmt:MT21C? MT21C = getField21C(tx.DrctDbtTx?.MndtRltdInf?.MndtId);
        swiftmt:MT26T? MT26T = getRepeatingField26T(drctDbtTxInf, tx.Purp, true);
        swiftmt:MT33B? MT33B = getField33B(tx.InstdAmt, tx.IntrBkSttlmAmt);
        swiftmt:MT36? MT36 = getField36(tx.XchgRate);

        swiftmt:MT50C? MT50C = instructingParty is swiftmt:MT50C ? instructingParty : ();
        swiftmt:MT50L? MT50L = instructingParty is swiftmt:MT50L ? instructingParty : ();

        swiftmt:MT50A? MT50A = field50a is swiftmt:MT50A ? field50a : ();
        swiftmt:MT50K? MT50K = field50a is swiftmt:MT50K ? field50a : ();

        swiftmt:MT52A? MT52A = field52 is swiftmt:MT52A ? field52 : ();
        swiftmt:MT52C? MT52C = field52 is swiftmt:MT52C ? field52 : ();
        swiftmt:MT52D? MT52D = field52 is swiftmt:MT52D ? field52 : ();

        swiftmt:MT57A? MT57A = field57 is swiftmt:MT57A ? field57 : ();
        swiftmt:MT57C? MT57C = field57 is swiftmt:MT57C ? field57 : ();
        swiftmt:MT57D? MT57D = field57 is swiftmt:MT57D ? field57 : ();

        swiftmt:MT59? MT59 = field59 is swiftmt:MT59 ? field59 : ();
        swiftmt:MT59A? MT59A = field59 is swiftmt:MT59A ? field59 : ();

        swiftmt:MT70? MT70 = getField70(tx.RmtInf?.Ustrd);
        swiftmt:MT71A? MT71A = getRepeatingField71A(drctDbtTxInf, tx.ChrgBr, true);
        swiftmt:MT77B? MT77B = getRepeatingField77BForPacs003(drctDbtTxInf, tx.RgltryRptg, true);

        transactions.push({
            MT21,
            MT21C,
            MT23E,
            MT26T,
            MT32B,
            MT33B,
            MT36,
            MT50C,
            MT50L,
            MT50A,
            MT50K,
            MT52A,
            MT52C,
            MT52D,
            MT57A,
            MT57C,
            MT57D,
            MT59,
            MT59A,
            MT70,
            MT71A,
            MT77B
        });
    }

    return transactions;
}

# Get the repeating field 77B for Pacs003.
#
# + dbtTrfTx - Array of DirectDebitTransactionInformation31 from Pacs003 envelope.Document
# + rgltryRptg - pac003 regulatory reporting array
# + isTransaction - boolean value to check whether it is a transaction
# + return - return the repeating field 77B or an error
isolated function getRepeatingField77BForPacs003(pacsIsoRecord:DirectDebitTransactionInformation31[] dbtTrfTx, pacsIsoRecord:RegulatoryReporting3[]? rgltryRptg = (), boolean isTransaction = false) returns swiftmt:MT77B? {
    swiftmt:MT77B? regulatoryReport = getField77B(dbtTrfTx[0].RgltryRptg);
    foreach int i in 1 ... dbtTrfTx.length() - 1 {
        swiftmt:MT77B? regulatoryReport2 = getField77B(dbtTrfTx[i].RgltryRptg);
        if regulatoryReport?.Nrtv?.content != regulatoryReport2?.Nrtv?.content {
            return getField77B(rgltryRptg);
        }
    }
    if isTransaction {
        return ();
    }
    return regulatoryReport;
}

# Get the instructing party from the Pacs003 document.
#
# + dbtTrfTx - The array of direct debit transactions
# + transaxion - The current direct debit transaction
# + isTransaction - The flag to identify whether it is a transaction or common field
# + return - The instructing party or an empty record
isolated function getMT104Or107InstructionPartyFromPacs003Document(pacsIsoRecord:DirectDebitTransactionInformation31[] dbtTrfTx,
        pacsIsoRecord:DirectDebitTransactionInformation31? transaxion = (), boolean isTransaction = false)
    returns swiftmt:MT50?|swiftmt:MT50C?|swiftmt:MT50L? {
    string? partyIdentifier = ();
    pacsIsoRecord:GenericPersonIdentification2[]? otherId = dbtTrfTx[0].InitgPty?.Id?.PrvtId?.Othr;
    if otherId is pacsIsoRecord:GenericPersonIdentification2[] {
        partyIdentifier = otherId[0].Id;
    }
    string? identifierCode = dbtTrfTx[0].InitgPty?.Id?.OrgId?.AnyBIC;
    foreach int i in 1 ... dbtTrfTx.length() - 1 {
        string? partyIdentifier2 = ();
        pacsIsoRecord:GenericPersonIdentification2[]? otherId2 = dbtTrfTx[i].InitgPty?.Id?.PrvtId?.Othr;
        if otherId2 is pacsIsoRecord:GenericPersonIdentification2[] {
            partyIdentifier2 = otherId2[0].Id;
        }
        if identifierCode != dbtTrfTx[i].InitgPty?.Id?.OrgId?.AnyBIC || partyIdentifier != partyIdentifier2 {
            return getField50Or50COr50L(transaxion?.InitgPty);
        }
    }
    if isTransaction {
        return ();
    }
    return getField50Or50COr50L(dbtTrfTx[0]?.InitgPty);
}

# Get the ordering customer from the Pacs003 document.
#
# + dbtTrfTx - The array of direct debit transactions
# + transaxion - The current direct debit transaction
# + isTransaction - The flag to identify whether it is a transaction or common field
# + return - The ordering customer or an empty record
isolated function getMT104Or107CreditorFromPacs003Document(pacsIsoRecord:DirectDebitTransactionInformation31[] dbtTrfTx, pacsIsoRecord:DirectDebitTransactionInformation31? transaxion = (), boolean isTransaction = false)
    returns swiftmt:MT50A?|swiftmt:MT50G?|swiftmt:MT50K?|swiftmt:MT50H?|swiftmt:MT50F?|error {
    [string?, string?, string?] [iban, bban, identifierCode] = [dbtTrfTx[0].CdtrAcct?.Id?.IBAN, dbtTrfTx[0].CdtrAcct?.Id?.Othr?.Id, dbtTrfTx[0].Cdtr.Id?.OrgId?.AnyBIC];
    foreach int i in 1 ... dbtTrfTx.length() - 1 {
        if iban != dbtTrfTx[i].CdtrAcct?.Id?.IBAN || bban != dbtTrfTx[i].CdtrAcct?.Id?.Othr?.Id || identifierCode != dbtTrfTx[i].Cdtr.Id?.OrgId?.AnyBIC {
            return getField50a(transaxion?.Cdtr, transaxion?.CdtrAcct?.Id, false, false);
        }
    }
    if isTransaction {
        return ();
    }
    return getField50a(dbtTrfTx[0].Cdtr, dbtTrfTx[0].CdtrAcct?.Id, false, false);
}

# Get the account servicing institution from the Pacs003 document.
#
# + dbtTrfTx - The array of direct debit transactions
# + transaxion - The current direct debit transaction
# + isTransaction - The flag to identify whether it is a transaction or common field
# + return - The account servicing institution or an empty record
isolated function getMT104Or107CreditorsBankFromPacs003Document(pacsIsoRecord:DirectDebitTransactionInformation31[] dbtTrfTx,
        pacsIsoRecord:DirectDebitTransactionInformation31? transaxion = (), boolean isTransaction = false)
    returns swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT52D?|error {

    [string?, string?, string?, string?] [iban, bban, identifierCode, partyIdentifier] = [dbtTrfTx[0].DbtrAgtAcct?.Id?.IBAN, dbtTrfTx[0].DbtrAgtAcct?.Id?.Othr?.Id, dbtTrfTx[0].DbtrAgt?.FinInstnId?.BICFI, dbtTrfTx[0].DbtrAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd];
    foreach int i in 1 ... dbtTrfTx.length() - 1 {
        if iban != dbtTrfTx[i].CdtrAgtAcct?.Id?.IBAN || bban != dbtTrfTx[i].CdtrAgtAcct?.Id?.Othr?.Id || identifierCode != dbtTrfTx[i].CdtrAgt?.FinInstnId?.BICFI || partyIdentifier != dbtTrfTx[i].CdtrAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd {
            return check getField52(transaxion?.CdtrAgt?.FinInstnId, transaxion?.CdtrAgtAcct?.Id, isOptionCPresent = true);
        }
    }
    if isTransaction {
        return ();
    }
    return check getField52(dbtTrfTx[0].CdtrAgt?.FinInstnId, dbtTrfTx[0].CdtrAgtAcct?.Id, isOptionCPresent = true);
}

isolated function getTotalInterBankSettlementAmount(pacsIsoRecord:DirectDebitTransactionInformation31[] drctDbtTxInf) returns string {
    decimal totalAmount = 0;
    foreach pacsIsoRecord:DirectDebitTransactionInformation31 tx in drctDbtTxInf {
        totalAmount = totalAmount + tx.IntrBkSttlmAmt.content;
    }
    string totalAmountStr = convertDecimalToSwiftDecimal(totalAmount);

    if (totalAmountStr.length() > 15) {
        return "NOTPROVIDED";
    } else {
        return totalAmountStr;
    }
}
