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

import ballerinax/financial.iso20022.payment_initiation as painIsoRecord;
import ballerinax/financial.swift.mt as swiftmt;

# generate the MT101 message from the Pain001 document
#
# + envelope - The Pain001 envelope containing the corresponding document to be transformed.
# + messageType - The SWIFT message type
# + return - The MT101 message or an error if the transformation fails
isolated function transformPain001DocumentToMT101(painIsoRecord:Pain001Envelope envelope, string messageType) returns swiftmt:MT101Message|error => let
    swiftmt:MT50?|swiftmt:MT50C?|swiftmt:MT50L? instructingParty = getField50Or50COr50L(envelope.Document.CstmrCdtTrfInitn.GrpHdr.InitgPty),
    swiftmt:MT50A?|swiftmt:MT50G?|swiftmt:MT50K?|swiftmt:MT50H?|swiftmt:MT50F? field50a = check getMT101OrderingCustomerFromPain001Document(envelope.Document.CstmrCdtTrfInitn.PmtInf),
    swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT52D? field52 = check getMT101AccountServicingInstitutionFromPain001Document(envelope.Document.CstmrCdtTrfInitn.PmtInf) in {
        block1: generateBlock1(getSenderOrReceiver(envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)),
        block2: generateBlock2(messageType, getSenderOrReceiver(envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI),
                envelope.Document.CstmrCdtTrfInitn.GrpHdr.CreDtTm),
        block3: createMtBlock3(envelope.Document.CstmrCdtTrfInitn.PmtInf[0].CdtTrfTxInf[0].PmtId?.UETR),
        block4: {
            MT20: {
                name: MT20_NAME,
                msgId: {
                    content: getField20Content(envelope.Document.CstmrCdtTrfInitn.PmtInf[0].CdtTrfTxInf[0].PmtId.InstrId),
                    number: NUMBER1
                }
            },
            MT28D: { // TODO - Implement the correct mapping since this is a mandatory field
                name: MT28D_NAME,
                MsgIdx: {
                    content: NUMBER1,
                    number: NUMBER1
                },
                Ttl: {
                    content: NUMBER1,
                    number: NUMBER2
                }
            },
            MT30: {
                name: MT30_NAME,
                Dt: check convertISODateStringToSwiftMtDate(envelope.Document.CstmrCdtTrfInitn.PmtInf[0].ReqdExctnDt.Dt.toString(), NUMBER1)
            },
            MT50C: instructingParty is swiftmt:MT50C ? instructingParty : (),
            MT50L: instructingParty is swiftmt:MT50L ? instructingParty : (),
            MT50F: field50a is swiftmt:MT50F ? field50a : (),
            MT50G: field50a is swiftmt:MT50G ? field50a : (),
            MT50H: field50a is swiftmt:MT50H ? field50a : (),
            MT51A: getField51A(envelope.Document.CstmrCdtTrfInitn.GrpHdr.FwdgAgt?.FinInstnId),
            MT52A: field52 is swiftmt:MT52A ? field52 : (),
            MT52C: field52 is swiftmt:MT52C ? field52 : (),
            Transaction: check generateMT101Transactions(envelope.Document.CstmrCdtTrfInitn.PmtInf, instructingParty)
        },
        block5: check generateMtBlock5FromSupplementaryData(envelope.Document.CstmrCdtTrfInitn.SplmtryData)
    };

# generate the Transactions of the MT101 message
#
# + mxTransactions - The MX transactions
# + instructingParty - The instructing party
# + return - The MT101 transactions or an error if the transformation fails
isolated function generateMT101Transactions(
        painIsoRecord:PaymentInstruction44[] mxTransactions,
        swiftmt:MT50?|swiftmt:MT50C?|swiftmt:MT50L? instructingParty
) returns swiftmt:MT101Transaction[]|error {
    swiftmt:MT101Transaction[] transactions = [];
    foreach painIsoRecord:PaymentInstruction44 item in mxTransactions {
        painIsoRecord:CreditTransferTransaction61 creditTransferTransaction = item.CdtTrfTxInf[0];
        swiftmt:MT50A?|swiftmt:MT50G?|swiftmt:MT50K?|swiftmt:MT50H?|swiftmt:MT50F? field50a = check getMT101OrderingCustomerFromPain001Document(mxTransactions, item, true);
        swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT52D? field52 = check getMT101AccountServicingInstitutionFromPain001Document(mxTransactions, item, true);
        swiftmt:MT56A?|swiftmt:MT56C?|swiftmt:MT56D? intermediary = check getField56(creditTransferTransaction.IntrmyAgt1?.FinInstnId, creditTransferTransaction.IntrmyAgt1Acct?.Id, true);
        swiftmt:MT57A?|swiftmt:MT57B?|swiftmt:MT57C?|swiftmt:MT57D? accountWithInstitution = check getField57(creditTransferTransaction.CdtrAgt?.FinInstnId, creditTransferTransaction.CdtrAgtAcct?.Id, isOptionCPresent = true);
        swiftmt:MT59?|swiftmt:MT59A?|swiftmt:MT59F? field59 = getField59a(creditTransferTransaction.Cdtr, creditTransferTransaction.CdtrAcct?.Id);

        transactions.push({
            MT21: {
                name: MT21_NAME,
                Ref: {
                    content: truncate(creditTransferTransaction.PmtId.EndToEndId, 16),
                    number: NUMBER1
                }
            },
            MT32B: {
                name: MT32B_NAME,
                Ccy: {
                    content: creditTransferTransaction.Amt.InstdAmt?.Ccy ?: "",
                    number: NUMBER1
                },
                Amnt: {
                    content: convertDecimalToSwiftDecimal(creditTransferTransaction.Amt.InstdAmt?.content),
                    number: NUMBER2
                }
            },

            MT23E: getfield23EForMt101(creditTransferTransaction.InstrForCdtrAgt, creditTransferTransaction.InstrForDbtrAgt, creditTransferTransaction.PmtTpInf?.SvcLvl, creditTransferTransaction.PmtTpInf?.CtgyPurp),
            MT25A: getField25A(item.ChrgsAcct),
            MT50C: instructingParty is swiftmt:MT50C ? instructingParty : (),
            MT50L: instructingParty is swiftmt:MT50L ? instructingParty : (),

            MT50F: field50a is swiftmt:MT50F ? field50a : (),
            MT50G: field50a is swiftmt:MT50G ? field50a : (),
            MT50H: field50a is swiftmt:MT50H ? field50a : (),

            MT52A: field52 is swiftmt:MT52A ? field52 : (),
            MT52C: field52 is swiftmt:MT52C ? field52 : (),

            MT56A: intermediary is swiftmt:MT56A ? intermediary : (),
            MT56C: intermediary is swiftmt:MT56C ? intermediary : (),
            MT56D: intermediary is swiftmt:MT56D ? intermediary : (),

            MT57A: accountWithInstitution is swiftmt:MT57A ? accountWithInstitution : (),
            MT57C: accountWithInstitution is swiftmt:MT57C ? accountWithInstitution : (),
            MT57D: accountWithInstitution is swiftmt:MT57D ? accountWithInstitution : (),

            MT59: field59 is swiftmt:MT59 ? field59 : (),
            MT59A: field59 is swiftmt:MT59A ? field59 : (),
            MT59F: field59 is swiftmt:MT59F ? field59 : (),

            MT70: getField70(creditTransferTransaction.RmtInf?.Ustrd),
            MT77B: getField77B(creditTransferTransaction.RgltryRptg),
            MT71A: {
                name: MT71A_NAME,
                Cd: getDetailsOfChargesFromChargeBearerType1Code(creditTransferTransaction.ChrgBr)
            },
            MT36: check getField36(creditTransferTransaction.XchgRateInf?.XchgRate)
        });
    }

    return transactions;
}

# Get the account servicing institution from the Pain001 document.
#
# + payments - The array of payment instructions.
# + transaxion - The payment instruction of the mapping transaction
# + isTransaction - The flag to identify whether it is a transaction or common field
# + return - The account servicing institution or an empty record
isolated function getMT101AccountServicingInstitutionFromPain001Document(painIsoRecord:PaymentInstruction44[] payments, painIsoRecord:PaymentInstruction44? transaxion = (), boolean isTransaction = false)
returns swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT52D?|error {
    [string?, string?, string?, string?] [iban, bban, identifierCode, partyIdentifier] = [payments[0].DbtrAgtAcct?.Id?.IBAN, payments[0].DbtrAgtAcct?.Id?.Othr?.Id, payments[0].DbtrAgt?.FinInstnId?.BICFI, payments[0].DbtrAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd];
    foreach int i in 1 ... payments.length() - 1 {
        if iban != payments[i].DbtrAgtAcct?.Id?.IBAN || bban != payments[i].DbtrAgtAcct?.Id?.Othr?.Id || identifierCode != payments[i].DbtrAgt?.FinInstnId?.BICFI || partyIdentifier != payments[i].DbtrAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd {
            return getField52(transaxion?.DbtrAgt?.FinInstnId, transaxion?.DbtrAgtAcct?.Id, isOptionCPresent = true);
        }
    }
    if isTransaction {
        return ();
    }
    return getField52(payments[0].DbtrAgt?.FinInstnId, payments[0].DbtrAgtAcct?.Id, isOptionCPresent = true);
}

# Get the ordering customer from the Pain001 document.
#
# + payments - The array of payment instructions.
# + transaxion - The payment instruction of the mapping transaction
# + isTransaction - The flag to identify whether it is a transaction or common field
# + return - The ordering customer or an empty record
isolated function getMT101OrderingCustomerFromPain001Document(painIsoRecord:PaymentInstruction44[] payments, painIsoRecord:PaymentInstruction44? transaxion = (), boolean isTransaction = false)
returns swiftmt:MT50A?|swiftmt:MT50G?|swiftmt:MT50K?|swiftmt:MT50H?|swiftmt:MT50F?|error {
    string? partyIdentifier = ();
    painIsoRecord:GenericPersonIdentification2[]? otherId = payments[0].Dbtr.Id?.PrvtId?.Othr;
    if otherId is painIsoRecord:GenericPersonIdentification2[] {
        partyIdentifier = otherId[0].Id;
    }
    [string?, string?, string?] [iban, bban, identifierCode] = [payments[0].DbtrAcct?.Id?.IBAN, payments[0].DbtrAcct?.Id?.Othr?.Id, payments[0].Dbtr.Id?.OrgId?.AnyBIC];
    foreach int i in 1 ... payments.length() - 1 {
        string? partyIdentifier2 = ();
        painIsoRecord:GenericPersonIdentification2[]? otherId2 = payments[i].Dbtr.Id?.PrvtId?.Othr;
        if otherId2 is painIsoRecord:GenericPersonIdentification2[] {
            partyIdentifier2 = otherId2[0].Id;
        }
        if iban != payments[i].DbtrAcct?.Id?.IBAN || bban != payments[i].DbtrAcct?.Id?.Othr?.Id || identifierCode != payments[i].Dbtr.Id?.OrgId?.AnyBIC || partyIdentifier != partyIdentifier2 {
            return getField50a(transaxion?.Dbtr, transaxion?.DbtrAcct?.Id, true);
        }
    }
    if isTransaction {
        return ();
    }
    return getField50a(payments[0].Dbtr, payments[0].DbtrAcct?.Id, true);
}
