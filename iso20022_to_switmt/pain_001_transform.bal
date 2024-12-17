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
# + document - The Pain001 document
# + messageType - The SWIFT message type
# + return - The MT101 message or an error if the transformation fails
isolated function transformPain001DocumentToMT101(painIsoRecord:Pain001Document document, string messageType) returns swiftmt:MT101Message|error => let swiftmt:MT50?|swiftmt:MT50C?|swiftmt:MT50L? instructingParty = getField50Or50COr50L(document.CstmrCdtTrfInitn.GrpHdr.InitgPty?.Id?.OrgId?.AnyBIC, (), (), document.CstmrCdtTrfInitn.GrpHdr.InitgPty?.Id?.PrvtId?.Othr) in {
        block1: {
            logicalTerminal: getSenderOrReceiver(())
        },
        block2: {
            'type: "output",
            messageType: messageType,
            MIRLogicalTerminal: getSenderOrReceiver(()),
            senderInputTime: {content: check convertToSwiftTimeFormat(document.CstmrCdtTrfInitn.GrpHdr.CreDtTm.substring(11))},
            MIRDate: {content: convertToSWIFTStandardDate(document.CstmrCdtTrfInitn.GrpHdr.CreDtTm.substring(0, 10))}
        },
        block3: createMtBlock3(document.CstmrCdtTrfInitn.PmtInf[0].CdtTrfTxInf[0].PmtId?.UETR),
        block4: {
            MT20: {
                name: MT20_NAME,
                msgId: {
                    content: ((document.CstmrCdtTrfInitn.PmtInf[0].CdtTrfTxInf[0].PmtId.InstrId != ()) ? document.CstmrCdtTrfInitn.PmtInf[0].CdtTrfTxInf[0].PmtId.InstrId.toString() : ""),
                    number: NUMBER1
                }
            },
            MT21R: {
                name: MT21R_NAME,
                Ref: {
                    content: document.CstmrCdtTrfInitn.GrpHdr.MsgId,
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
                Dt: check convertISODateStringToSwiftMtDate(document.CstmrCdtTrfInitn.PmtInf[0].ReqdExctnDt.Dt.toString(), NUMBER1)
            },
            MT50C: instructingParty is swiftmt:MT50C ? instructingParty : (),
            MT50L: instructingParty is swiftmt:MT50L ? instructingParty : (),
            MT50F: (check getMT101OrderingCustomerFromPain001Document(document.CstmrCdtTrfInitn.PmtInf))[4],
            MT50G: (check getMT101OrderingCustomerFromPain001Document(document.CstmrCdtTrfInitn.PmtInf))[1],
            MT50H: (check getMT101OrderingCustomerFromPain001Document(document.CstmrCdtTrfInitn.PmtInf))[3],
            MT51A: getField51A(document.CstmrCdtTrfInitn.GrpHdr.FwdgAgt?.FinInstnId?.BICFI, document.CstmrCdtTrfInitn.GrpHdr.FwdgAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd),
            MT52A: (check getMT101AccountServicingInstitutionFromPain001Document(document.CstmrCdtTrfInitn.PmtInf))[0],
            MT52C: (check getMT101AccountServicingInstitutionFromPain001Document(document.CstmrCdtTrfInitn.PmtInf))[2],
            Transaction: check generateMT101Transactions(document.CstmrCdtTrfInitn.PmtInf, instructingParty)
        },
        block5: check generateMtBlock5FromSupplementaryData(document.CstmrCdtTrfInitn.SplmtryData)
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
        swiftmt:MT56A?|swiftmt:MT56C?|swiftmt:MT56D? intermediary = check getField56(creditTransferTransaction.IntrmyAgt1?.FinInstnId?.BICFI, creditTransferTransaction.IntrmyAgt1?.FinInstnId?.Nm, creditTransferTransaction.IntrmyAgt1?.FinInstnId?.PstlAdr?.AdrLine, creditTransferTransaction.IntrmyAgt1?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, creditTransferTransaction.IntrmyAgt1Acct?.Id?.IBAN, creditTransferTransaction.IntrmyAgt1Acct?.Id?.Othr?.Id, true);
        swiftmt:MT57A?|swiftmt:MT57B?|swiftmt:MT57C?|swiftmt:MT57D? accountWithInstitution = check getField57(creditTransferTransaction.CdtrAgt?.FinInstnId?.BICFI, creditTransferTransaction.CdtrAgt?.FinInstnId?.Nm, creditTransferTransaction.CdtrAgt?.FinInstnId?.PstlAdr?.AdrLine, creditTransferTransaction.CdtrAgt?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd, creditTransferTransaction.CdtrAgtAcct?.Id?.IBAN, creditTransferTransaction.CdtrAgtAcct?.Id?.Othr?.Id, isOptionCPresent = true);

        transactions.push({
            MT21: {
                name: MT21_NAME,
                Ref: {
                    content: getEmptyStrIfNull(creditTransferTransaction.PmtId.EndToEndId),
                    number: NUMBER1
                }
            },
            MT32B: {
                name: MT32B_NAME,
                Ccy: {
                    content: getActiveOrHistoricCurrencyAndAmountCcy(creditTransferTransaction.Amt.InstdAmt),
                    number: NUMBER1
                },
                Amnt: {
                    content: getActiveOrHistoricCurrencyAndAmountValue(creditTransferTransaction.Amt.InstdAmt),
                    number: NUMBER2
                }
            },

            MT23E: getfield23EForMt101(creditTransferTransaction.InstrForCdtrAgt, creditTransferTransaction.InstrForDbtrAgt, creditTransferTransaction.PmtTpInf?.SvcLvl, creditTransferTransaction.PmtTpInf?.CtgyPurp),
            MT50C: instructingParty is swiftmt:MT50C ? instructingParty : (),
            MT50L: instructingParty is swiftmt:MT50L ? instructingParty : (),

            MT50F: (check getMT101OrderingCustomerFromPain001Document(mxTransactions, item))[4],
            MT50G: (check getMT101OrderingCustomerFromPain001Document(mxTransactions, item))[1],
            MT50H: (check getMT101OrderingCustomerFromPain001Document(mxTransactions, item))[3],

            MT52A: (check getMT101AccountServicingInstitutionFromPain001Document(mxTransactions, item))[0],
            MT52C: (check getMT101AccountServicingInstitutionFromPain001Document(mxTransactions, item))[2],

            MT56A: intermediary is swiftmt:MT56A ? intermediary : (),
            MT56C: intermediary is swiftmt:MT56C ? intermediary : (),
            MT56D: intermediary is swiftmt:MT56D ? intermediary : (),

            MT57A: accountWithInstitution is swiftmt:MT57A ? accountWithInstitution : (),
            MT57C: accountWithInstitution is swiftmt:MT57C ? accountWithInstitution : (),
            MT57D: accountWithInstitution is swiftmt:MT57D ? accountWithInstitution : (),

            MT59: getField59a(creditTransferTransaction.Cdtr?.Id?.OrgId?.AnyBIC, creditTransferTransaction.Cdtr?.Nm, creditTransferTransaction.Cdtr?.PstlAdr?.AdrLine, creditTransferTransaction.CdtrAcct?.Id?.IBAN, creditTransferTransaction.CdtrAcct?.Id?.Othr?.Id, townName = creditTransferTransaction.Cdtr?.PstlAdr?.TwnNm, countryCode = creditTransferTransaction.Cdtr?.PstlAdr?.Ctry)[0],
            MT59A: getField59a(creditTransferTransaction.Cdtr?.Id?.OrgId?.AnyBIC, creditTransferTransaction.Cdtr?.Nm, creditTransferTransaction.Cdtr?.PstlAdr?.AdrLine, creditTransferTransaction.CdtrAcct?.Id?.IBAN, creditTransferTransaction.CdtrAcct?.Id?.Othr?.Id, townName = creditTransferTransaction.Cdtr?.PstlAdr?.TwnNm, countryCode = creditTransferTransaction.Cdtr?.PstlAdr?.Ctry)[1],
            MT59F: getField59a(creditTransferTransaction.Cdtr?.Id?.OrgId?.AnyBIC, creditTransferTransaction.Cdtr?.Nm, creditTransferTransaction.Cdtr?.PstlAdr?.AdrLine, creditTransferTransaction.CdtrAcct?.Id?.IBAN, creditTransferTransaction.CdtrAcct?.Id?.Othr?.Id, townName = creditTransferTransaction.Cdtr?.PstlAdr?.TwnNm, countryCode = creditTransferTransaction.Cdtr?.PstlAdr?.Ctry)[2],

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
