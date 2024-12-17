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

# Transforms the given ISO 20022 Pacs.003 document to its corresponding SWIFT MT104 format.
#
# + document - The Pacs003Document as an input
# + messageType - The SWIFT message type
# + return - The transformed SWIFT MT104 message or an error if the transformation fails
isolated function transformPacs003DocumentToMT104(pacsIsoRecord:Pacs003Document document, string messageType) returns swiftmt:MT104Message|error => let
    pacsIsoRecord:DirectDebitTransactionInformation31[] dbtTrfTx = document.FIToFICstmrDrctDbt.DrctDbtTxInf,
    swiftmt:MT50?|swiftmt:MT50C?|swiftmt:MT50L? instructingParty = getMT104Or107InstructionPartyFromPacs003Document(dbtTrfTx)[0],
    swiftmt:MT104Transaction[] transactions = check generateMT104TransactionsFromPacs003(dbtTrfTx)
    in {
        block1: {
            logicalTerminal: getSenderOrReceiver(document.FIToFICstmrDrctDbt.GrpHdr.InstdAgt?.FinInstnId?.BICFI)
        },
        block2: {
            'type: "output",
            messageType: messageType,
            MIRLogicalTerminal: getSenderOrReceiver(document.FIToFICstmrDrctDbt.GrpHdr.InstgAgt?.FinInstnId?.BICFI),
            senderInputTime: {content: check convertToSwiftTimeFormat(document.FIToFICstmrDrctDbt.GrpHdr.CreDtTm.substring(11))},
            MIRDate: {content: convertToSWIFTStandardDate(document.FIToFICstmrDrctDbt.GrpHdr.CreDtTm.substring(0, 10))}
        },
        block3: createMtBlock3(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].PmtId?.UETR),
        block4: {
            MT19: check getField19(document.FIToFICstmrDrctDbt.GrpHdr.CtrlSum),
            MT20: {
                name: MT20_NAME,
                msgId: {
                    content: document.FIToFICstmrDrctDbt.GrpHdr.MsgId,
                    number: NUMBER1
                }
            },
            MT23E: dbtTrfTx[0].PmtTpInf?.CtgyPurp?.Cd is () ? () : {
                    name: MT23E_NAME,
                    InstrnCd: {content: dbtTrfTx[0].PmtTpInf?.CtgyPurp?.Cd.toString(), number: NUMBER1}
                },
            MT26T: getRepeatingField26TForPacs003(dbtTrfTx),
            MT30: {
                name: MT30_NAME,
                Dt: {content: convertToSWIFTStandardDate(dbtTrfTx[0].IntrBkSttlmDt), number: NUMBER1}
            },
            MT32B: {
                name: MT32B_NAME,
                Ccy: {content: document.FIToFICstmrDrctDbt.GrpHdr.TtlIntrBkSttlmAmt?.ActiveCurrencyAndAmount_SimpleType?.Ccy.toString(), number: NUMBER1},
                Amnt: {content: document.FIToFICstmrDrctDbt.GrpHdr.TtlIntrBkSttlmAmt?.ActiveCurrencyAndAmount_SimpleType?.ActiveCurrencyAndAmount_SimpleType.toString(), number: NUMBER2}
            },
            MT50C: instructingParty is swiftmt:MT50C ? instructingParty : (),
            MT50L: instructingParty is swiftmt:MT50L ? instructingParty : (),
            MT50A: (check getMT104Or107CreditorFromPacs003Document(dbtTrfTx))[0][0],
            MT50K: (check getMT104Or107CreditorFromPacs003Document(dbtTrfTx))[0][2],
            MT51A: getField51A(document.FIToFICstmrDrctDbt.GrpHdr.InstgAgt?.FinInstnId?.BICFI, document.FIToFICstmrDrctDbt.GrpHdr.InstgAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd),
            MT52A: (check getMT104Or107CreditorsBankFromPacs003Document(dbtTrfTx))[0][0],
            MT52C: (check getMT104Or107CreditorsBankFromPacs003Document(dbtTrfTx))[0][2],
            MT52D: (check getMT104Or107CreditorsBankFromPacs003Document(dbtTrfTx))[0][3],
            MT53A: getField53(dbtTrfTx[0].IntrmyAgt1?.FinInstnId?.BICFI, dbtTrfTx[0].IntrmyAgt1?.FinInstnId?.Nm, dbtTrfTx[0].IntrmyAgt1?.FinInstnId?.PstlAdr?.AdrLine, dbtTrfTx[0].IntrmyAgt1Acct?.Id?.IBAN, dbtTrfTx[0].IntrmyAgt1Acct?.Id?.Othr?.Id, isOptionBPresent = true)[0],
            MT53B: getField53(dbtTrfTx[0].IntrmyAgt1?.FinInstnId?.BICFI, dbtTrfTx[0].IntrmyAgt1?.FinInstnId?.Nm, dbtTrfTx[0].IntrmyAgt1?.FinInstnId?.PstlAdr?.AdrLine, dbtTrfTx[0].IntrmyAgt1Acct?.Id?.IBAN, dbtTrfTx[0].IntrmyAgt1Acct?.Id?.Othr?.Id, isOptionBPresent = true)[1],
            MT71A: getRepeatingField71AForPacs003(dbtTrfTx),
            MT71F: dbtTrfTx[0].ChrgsInf is () ? () : {
                    name: MT71F_NAME,
                    Ccy: {content: (<pacsIsoRecord:Charges16?>getFirstElementFromArray(dbtTrfTx[0].ChrgsInf))?.Amt?.ActiveOrHistoricCurrencyAndAmount_SimpleType?.Ccy.toString(), number: NUMBER1},
                    Amnt: {content: (<pacsIsoRecord:Charges16?>getFirstElementFromArray(dbtTrfTx[0].ChrgsInf))?.Amt?.ActiveOrHistoricCurrencyAndAmount_SimpleType.toString(), number: NUMBER2}
                },
            MT71G: dbtTrfTx[0].ChrgsInf is () ? () : {
                    name: MT71G_NAME,
                    Ccy: {content: (<pacsIsoRecord:Charges16?>getFirstElementFromArray(dbtTrfTx[0].ChrgsInf))?.Amt?.ActiveOrHistoricCurrencyAndAmount_SimpleType?.Ccy.toString(), number: NUMBER1},
                    Amnt: {content: (<pacsIsoRecord:Charges16?>getFirstElementFromArray(dbtTrfTx[0].ChrgsInf))?.Amt?.ActiveOrHistoricCurrencyAndAmount_SimpleType.toString(), number: NUMBER2}
                },
            MT77B: getRepeatingField77BForPacs003(dbtTrfTx),
            Transaction: transactions
        },
        block5: check generateMtBlock5FromSupplementaryData(document.FIToFICstmrDrctDbt.SplmtryData)
    };

# Creates the MT104 transactions from the Pacs003 document's direct debit transaction information.
#
# + drctDbtTxInf - Array of DirectDebitTransactionInformation31 from Pacs003 document
# + return - Array of MT104 transactions or an error
isolated function generateMT104TransactionsFromPacs003(
        pacsIsoRecord:DirectDebitTransactionInformation31[] drctDbtTxInf
) returns swiftmt:MT104Transaction[]|error {
    swiftmt:MT104Transaction[] transactions = [];
    foreach pacsIsoRecord:DirectDebitTransactionInformation31 tx in drctDbtTxInf {
        swiftmt:MT50?|swiftmt:MT50C?|swiftmt:MT50L? instructingParty = getMT104Or107InstructionPartyFromPacs003Document(drctDbtTxInf, tx)[1];
        swiftmt:MT21 MT21 = {
            name: MT21_NAME,
            Ref: {
                content: getMandatoryField(tx.PmtId?.EndToEndId),
                number: NUMBER1
            }
        };

        swiftmt:MT23E MT23E = {
            name: MT23E_NAME,
            InstrnCd: {content: getEmptyStrIfNull(tx.PmtTpInf?.CtgyPurp?.Cd), number: NUMBER1}
        };

        swiftmt:MT32B MT32B = {
            name: MT23B_NAME,
            Ccy: {content: tx.IntrBkSttlmAmt.ActiveCurrencyAndAmount_SimpleType.Ccy, number: NUMBER1},
            Amnt: {content: tx.IntrBkSttlmAmt?.ActiveCurrencyAndAmount_SimpleType.toString(), number: NUMBER1}
        };

        swiftmt:MT21C? MT21C = getField21C(tx.DrctDbtTx?.MndtRltdInf?.MndtId);
        swiftmt:MT26T? MT26T = getRepeatingField26TForPacs003(drctDbtTxInf, tx.Purp);
        swiftmt:MT33B? MT33B = check getField33B(tx.InstdAmt, tx.IntrBkSttlmAmt);
        swiftmt:MT36? MT36 = check getField36(tx.XchgRate);

        swiftmt:MT50C? MT50C = instructingParty is swiftmt:MT50C ? instructingParty : ();
        swiftmt:MT50L? MT50L = instructingParty is swiftmt:MT50L ? instructingParty : ();

        swiftmt:MT50A? MT50A = (check getMT104Or107CreditorFromPacs003Document(drctDbtTxInf, tx))[1][0];
        swiftmt:MT50K? MT50K = (check getMT104Or107CreditorFromPacs003Document(drctDbtTxInf, tx))[1][2];

        swiftmt:MT52A? MT52A = (check getMT104Or107CreditorsBankFromPacs003Document(drctDbtTxInf, tx))[1][0];
        swiftmt:MT52C? MT52C = (check getMT104Or107CreditorsBankFromPacs003Document(drctDbtTxInf, tx))[1][2];
        swiftmt:MT52D? MT52D = (check getMT104Or107CreditorsBankFromPacs003Document(drctDbtTxInf, tx))[1][3];

        swiftmt:MT57A? MT57A = (check getField57Alt(tx.DbtrAgt?.FinInstnId?.BICFI, tx.DbtrAgt?.FinInstnId?.Nm, tx.DbtrAgt?.FinInstnId?.PstlAdr?.AdrLine, tx.DbtrAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, tx.DbtrAgtAcct?.Id?.IBAN, tx.DbtrAgtAcct?.Id?.Othr?.Id, isOptionCPresent = true))[0];
        swiftmt:MT57C? MT57C = (check getField57Alt(tx.DbtrAgt?.FinInstnId?.BICFI, tx.DbtrAgt?.FinInstnId?.Nm, tx.DbtrAgt?.FinInstnId?.PstlAdr?.AdrLine, tx.DbtrAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, tx.DbtrAgtAcct?.Id?.IBAN, tx.DbtrAgtAcct?.Id?.Othr?.Id, isOptionCPresent = true))[2];
        swiftmt:MT57D? MT57D = (check getField57Alt(tx.DbtrAgt?.FinInstnId?.BICFI, tx.DbtrAgt?.FinInstnId?.Nm, tx.DbtrAgt?.FinInstnId?.PstlAdr?.AdrLine, tx.DbtrAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, tx.DbtrAgtAcct?.Id?.IBAN, tx.DbtrAgtAcct?.Id?.Othr?.Id, isOptionCPresent = true))[3];

        swiftmt:MT59? MT59 = getField59a(tx.Dbtr?.Id?.OrgId?.AnyBIC, tx.Dbtr?.Nm, tx.Dbtr?.PstlAdr?.AdrLine, tx.DbtrAcct?.Id?.IBAN, tx.DbtrAcct?.Id?.Othr?.Id, isOptionFPresent = false)[0];
        swiftmt:MT59A? MT59A = getField59a(tx.Dbtr?.Id?.OrgId?.AnyBIC, tx.Dbtr?.Nm, tx.Dbtr?.PstlAdr?.AdrLine, tx.DbtrAcct?.Id?.IBAN, tx.DbtrAcct?.Id?.Othr?.Id, isOptionFPresent = false)[1];

        swiftmt:MT70? MT70 = getField70(tx.RmtInf?.Ustrd);
        swiftmt:MT71A? MT71A = getRepeatingField71AForPacs003(drctDbtTxInf, tx.ChrgBr);
        swiftmt:MT77B? MT77B = getRepeatingField77BForPacs003(drctDbtTxInf, tx.RgltryRptg);

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

# Tranform the given ISO 20022 Pacs.003 document to its corresponding SWIFT MT107 format.
# + document - The Pacs003Document as an input
# + messageType - The SWIFT message type
# + return - The transformed SWIFT MT107 message or an error if the transformation fails
isolated function transformPacs003DocumentToMT107(pacsIsoRecord:Pacs003Document document, string messageType) returns swiftmt:MT107Message|error => let
    pacsIsoRecord:DirectDebitTransactionInformation31[] dbtTrfTx = document.FIToFICstmrDrctDbt.DrctDbtTxInf,
    swiftmt:MT50?|swiftmt:MT50C?|swiftmt:MT50L? instructingParty = getMT104Or107InstructionPartyFromPacs003Document(dbtTrfTx)[0],
    swiftmt:MT104Transaction[] transactions = check generateMT107TransactionsFromPacs003(dbtTrfTx)
    in {
        block1: {
            logicalTerminal: getSenderOrReceiver(document.FIToFICstmrDrctDbt.GrpHdr.InstdAgt?.FinInstnId?.BICFI)
        },
        block2: {
            'type: "output",
            messageType: messageType,
            MIRLogicalTerminal: getSenderOrReceiver(document.FIToFICstmrDrctDbt.GrpHdr.InstgAgt?.FinInstnId?.BICFI),
            senderInputTime: {content: check convertToSwiftTimeFormat(document.FIToFICstmrDrctDbt.GrpHdr.CreDtTm.substring(11))},
            MIRDate: {content: convertToSWIFTStandardDate(document.FIToFICstmrDrctDbt.GrpHdr.CreDtTm.substring(0, 10))}
        },
        block3: createMtBlock3(document.FIToFICstmrDrctDbt.DrctDbtTxInf[0].PmtId?.UETR),
        block4: {
            MT19: check getField19(document.FIToFICstmrDrctDbt.GrpHdr.CtrlSum),
            MT20: {
                name: MT20_NAME,
                msgId: {
                    content: document.FIToFICstmrDrctDbt.GrpHdr.MsgId,
                    number: NUMBER1
                }
            },
            MT23E: dbtTrfTx[0].PmtTpInf?.CtgyPurp?.Cd is () ? () : {
                    name: MT23E_NAME,
                    InstrnCd: {content: dbtTrfTx[0].PmtTpInf?.CtgyPurp?.Cd.toString(), number: NUMBER1}
                },
            MT26T: getRepeatingField26TForPacs003(dbtTrfTx),
            MT30: {
                name: MT30_NAME,
                Dt: {content: convertToSWIFTStandardDate(dbtTrfTx[0].IntrBkSttlmDt), number: NUMBER1}
            },
            MT32B: {
                name: MT32B_NAME,
                Ccy: {content: document.FIToFICstmrDrctDbt.GrpHdr.TtlIntrBkSttlmAmt?.ActiveCurrencyAndAmount_SimpleType?.Ccy.toString(), number: NUMBER1},
                Amnt: {content: document.FIToFICstmrDrctDbt.GrpHdr.TtlIntrBkSttlmAmt?.ActiveCurrencyAndAmount_SimpleType?.ActiveCurrencyAndAmount_SimpleType.toString(), number: NUMBER2}
            },
            MT50C: instructingParty is swiftmt:MT50C ? instructingParty : (),
            MT50L: instructingParty is swiftmt:MT50L ? instructingParty : (),
            MT50A: (check getMT104Or107CreditorFromPacs003Document(dbtTrfTx))[0][0],
            MT50K: (check getMT104Or107CreditorFromPacs003Document(dbtTrfTx))[0][2],
            MT51A: getField51A(document.FIToFICstmrDrctDbt.GrpHdr.InstgAgt?.FinInstnId?.BICFI, document.FIToFICstmrDrctDbt.GrpHdr.InstgAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd),
            MT52A: (check getMT104Or107CreditorsBankFromPacs003Document(dbtTrfTx))[0][0],
            MT52C: (check getMT104Or107CreditorsBankFromPacs003Document(dbtTrfTx))[0][2],
            MT52D: (check getMT104Or107CreditorsBankFromPacs003Document(dbtTrfTx))[0][3],
            MT53A: getField53(dbtTrfTx[0].IntrmyAgt1?.FinInstnId?.BICFI, dbtTrfTx[0].IntrmyAgt1?.FinInstnId?.Nm, dbtTrfTx[0].IntrmyAgt1?.FinInstnId?.PstlAdr?.AdrLine, dbtTrfTx[0].IntrmyAgt1Acct?.Id?.IBAN, dbtTrfTx[0].IntrmyAgt1Acct?.Id?.Othr?.Id, isOptionBPresent = true)[0],
            MT53B: getField53(dbtTrfTx[0].IntrmyAgt1?.FinInstnId?.BICFI, dbtTrfTx[0].IntrmyAgt1?.FinInstnId?.Nm, dbtTrfTx[0].IntrmyAgt1?.FinInstnId?.PstlAdr?.AdrLine, dbtTrfTx[0].IntrmyAgt1Acct?.Id?.IBAN, dbtTrfTx[0].IntrmyAgt1Acct?.Id?.Othr?.Id, isOptionBPresent = true)[1],
            MT71A: getRepeatingField71AForPacs003(dbtTrfTx),
            MT71F: dbtTrfTx[0].ChrgsInf is () ? () : {
                    name: MT71F_NAME,
                    Ccy: {content: (<pacsIsoRecord:Charges16?>getFirstElementFromArray(dbtTrfTx[0].ChrgsInf))?.Amt?.ActiveOrHistoricCurrencyAndAmount_SimpleType?.Ccy.toString(), number: NUMBER1},
                    Amnt: {content: (<pacsIsoRecord:Charges16?>getFirstElementFromArray(dbtTrfTx[0].ChrgsInf))?.Amt?.ActiveOrHistoricCurrencyAndAmount_SimpleType.toString(), number: NUMBER2}
                },
            MT71G: dbtTrfTx[0].ChrgsInf is () ? () : {
                    name: MT71G_NAME,
                    Ccy: {content: (<pacsIsoRecord:Charges16?>getFirstElementFromArray(dbtTrfTx[0].ChrgsInf))?.Amt?.ActiveOrHistoricCurrencyAndAmount_SimpleType?.Ccy.toString(), number: NUMBER1},
                    Amnt: {content: (<pacsIsoRecord:Charges16?>getFirstElementFromArray(dbtTrfTx[0].ChrgsInf))?.Amt?.ActiveOrHistoricCurrencyAndAmount_SimpleType.toString(), number: NUMBER2}
                },
            MT77B: getRepeatingField77BForPacs003(dbtTrfTx),
            Transaction: transactions
        },
        block5: check generateMtBlock5FromSupplementaryData(document.FIToFICstmrDrctDbt.SplmtryData)
    };

# generate the MT107 transactions from the Pacs003 document's direct debit transaction information.
# + drctDbtTxInf - Array of DirectDebitTransactionInformation31 from Pacs003 document
# + return - Array of MT107 transactions or an error
isolated function generateMT107TransactionsFromPacs003(
        pacsIsoRecord:DirectDebitTransactionInformation31[] drctDbtTxInf
) returns swiftmt:MT107Transaction[]|error {
    swiftmt:MT107Transaction[] transactions = [];
    foreach pacsIsoRecord:DirectDebitTransactionInformation31 tx in drctDbtTxInf {
        swiftmt:MT50?|swiftmt:MT50C?|swiftmt:MT50L? instructingParty = getMT104Or107InstructionPartyFromPacs003Document(drctDbtTxInf, tx)[1];
        swiftmt:MT21 MT21 = {
            name: MT21_NAME,
            Ref: {
                content: getMandatoryField(tx.PmtId?.EndToEndId),
                number: NUMBER1
            }
        };

        swiftmt:MT23E MT23E = {
            name: MT23E_NAME,
            InstrnCd: {content: getEmptyStrIfNull(tx.PmtTpInf?.CtgyPurp?.Cd), number: NUMBER1}
        };

        swiftmt:MT32B MT32B = {
            name: MT23B_NAME,
            Ccy: {content: tx.IntrBkSttlmAmt.ActiveCurrencyAndAmount_SimpleType.Ccy, number: NUMBER1},
            Amnt: {content: tx.IntrBkSttlmAmt?.ActiveCurrencyAndAmount_SimpleType.toString(), number: NUMBER1}
        };

        swiftmt:MT21C? MT21C = getField21C(tx.DrctDbtTx?.MndtRltdInf?.MndtId);
        swiftmt:MT26T? MT26T = getRepeatingField26TForPacs003(drctDbtTxInf, tx.Purp);
        swiftmt:MT33B? MT33B = check getField33B(tx.InstdAmt, tx.IntrBkSttlmAmt);
        swiftmt:MT36? MT36 = check getField36(tx.XchgRate);

        swiftmt:MT50C? MT50C = instructingParty is swiftmt:MT50C ? instructingParty : ();
        swiftmt:MT50L? MT50L = instructingParty is swiftmt:MT50L ? instructingParty : ();

        swiftmt:MT50A? MT50A = (check getMT104Or107CreditorFromPacs003Document(drctDbtTxInf, tx))[1][0];
        swiftmt:MT50K? MT50K = (check getMT104Or107CreditorFromPacs003Document(drctDbtTxInf, tx))[1][2];

        swiftmt:MT52A? MT52A = (check getMT104Or107CreditorsBankFromPacs003Document(drctDbtTxInf, tx))[1][0];
        swiftmt:MT52C? MT52C = (check getMT104Or107CreditorsBankFromPacs003Document(drctDbtTxInf, tx))[1][2];
        swiftmt:MT52D? MT52D = (check getMT104Or107CreditorsBankFromPacs003Document(drctDbtTxInf, tx))[1][3];

        swiftmt:MT57A? MT57A = (check getField57Alt(tx.DbtrAgt?.FinInstnId?.BICFI, tx.DbtrAgt?.FinInstnId?.Nm, tx.DbtrAgt?.FinInstnId?.PstlAdr?.AdrLine, tx.DbtrAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, tx.DbtrAgtAcct?.Id?.IBAN, tx.DbtrAgtAcct?.Id?.Othr?.Id, isOptionCPresent = true))[0];
        swiftmt:MT57C? MT57C = (check getField57Alt(tx.DbtrAgt?.FinInstnId?.BICFI, tx.DbtrAgt?.FinInstnId?.Nm, tx.DbtrAgt?.FinInstnId?.PstlAdr?.AdrLine, tx.DbtrAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, tx.DbtrAgtAcct?.Id?.IBAN, tx.DbtrAgtAcct?.Id?.Othr?.Id, isOptionCPresent = true))[2];
        swiftmt:MT57D? MT57D = (check getField57Alt(tx.DbtrAgt?.FinInstnId?.BICFI, tx.DbtrAgt?.FinInstnId?.Nm, tx.DbtrAgt?.FinInstnId?.PstlAdr?.AdrLine, tx.DbtrAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, tx.DbtrAgtAcct?.Id?.IBAN, tx.DbtrAgtAcct?.Id?.Othr?.Id, isOptionCPresent = true))[3];

        swiftmt:MT59? MT59 = getField59a(tx.Dbtr?.Id?.OrgId?.AnyBIC, tx.Dbtr?.Nm, tx.Dbtr?.PstlAdr?.AdrLine, tx.DbtrAcct?.Id?.IBAN, tx.DbtrAcct?.Id?.Othr?.Id, isOptionFPresent = false)[0];
        swiftmt:MT59A? MT59A = getField59a(tx.Dbtr?.Id?.OrgId?.AnyBIC, tx.Dbtr?.Nm, tx.Dbtr?.PstlAdr?.AdrLine, tx.DbtrAcct?.Id?.IBAN, tx.DbtrAcct?.Id?.Othr?.Id, isOptionFPresent = false)[1];

        swiftmt:MT70? MT70 = getField70(tx.RmtInf?.Ustrd);
        swiftmt:MT71A? MT71A = getRepeatingField71AForPacs003(drctDbtTxInf, tx.ChrgBr);
        swiftmt:MT77B? MT77B = getRepeatingField77BForPacs003(drctDbtTxInf, tx.RgltryRptg);

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
