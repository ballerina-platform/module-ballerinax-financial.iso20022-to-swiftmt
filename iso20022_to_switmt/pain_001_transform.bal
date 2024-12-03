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
# + return - The MT101 message or an error if the transformation fails
function transformPain001DocumentToMT101(painIsoRecord:Pain001Document document) returns swiftmt:MT101Message|error => let swiftmt:MT50C?|swiftmt:MT50L? instructingParty = getMT101InstructingPartyFromPain001Document(document), swiftmt:MT50F?|swiftmt:MT50G?|swiftmt:MT50H? orderingCustomer = getMT101OrderingCustomerFromPain001Document(document), swiftmt:MT52A?|swiftmt:MT52C? accountServicingInstitution = getMT101AccountServicingInstitutionFromPain001Document(document) in {
        block1: check generateMtBlock1FromSupplementaryData(document.CstmrCdtTrfInitn.SplmtryData),
        block2: check generateMtBlock2WithDateTime(MESSAGETYPE_101, document.CstmrCdtTrfInitn.GrpHdr.CreDtTm),
        block3: check generateMtBlock3(document.CstmrCdtTrfInitn.SplmtryData, document.CstmrCdtTrfInitn.PmtInf[0].CdtTrfTxInf[0].PmtId.UETR, ""),
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
            MT50F: orderingCustomer is swiftmt:MT50F ? orderingCustomer : (),
            MT50G: orderingCustomer is swiftmt:MT50G ? orderingCustomer : (),
            MT50H: orderingCustomer is swiftmt:MT50H ? orderingCustomer : (),
            MT52A: accountServicingInstitution is swiftmt:MT52A ? accountServicingInstitution : (),
            MT52C: accountServicingInstitution is swiftmt:MT52C ? accountServicingInstitution : (),
            Transaction: check generateMT101Transactions(document.CstmrCdtTrfInitn.PmtInf, getMT101InstructingPartyFromPain001Document(document), getMT101OrderingCustomerFromPain001Document(document), getMT101AccountServicingInstitutionFromPain001Document(document))
        },
        block5: check generateMtBlock5FromSupplementaryData(document.CstmrCdtTrfInitn.SplmtryData)
    };

# generate the Transactions of the MT101 message
#
# + mxTransactions - The MX transactions
# + instructingParty - The instructing party
# + orderingCustomer - The ordering customer
# + accountServicingInstitution - The account servicing institution
# + return - The MT101 transactions or an error if the transformation fails
isolated function generateMT101Transactions(
        painIsoRecord:PaymentInstruction44[] mxTransactions,
        swiftmt:MT50C?|swiftmt:MT50L? instructingParty,
        swiftmt:MT50F?|swiftmt:MT50G?|swiftmt:MT50H? orderingCustomer,
        swiftmt:MT52A?|swiftmt:MT52C? accountServicingInstitution
) returns swiftmt:MT101Transaction[]|error {
    swiftmt:MT101Transaction[] transactions = [];
    foreach painIsoRecord:PaymentInstruction44 item in mxTransactions {
        painIsoRecord:CreditTransferTransaction61 creditTransferTransaction = item.CdtTrfTxInf[0];
        swiftmt:MT56A?|swiftmt:MT56C?|swiftmt:MT56D? intermediary = getMT101TransactionIntermediaryFromPain001Document(item);
        swiftmt:MT57A?|swiftmt:MT57C?|swiftmt:MT57D? accountWithInstitution = getMT101TransactionAcountWithInstitution(item);
        swiftmt:MT59|swiftmt:MT59A?|swiftmt:MT59F? beneficiary = getMT101TransactionBeneficiary(item);

        transactions.push({
            MT21: {
                name: MT21_NAME,
                Ref: {
                    content: getEmptyStrIfNull(creditTransferTransaction.PmtId.EndToEndId),
                    number: NUMBER1
                }
            },

            MT70: {
                name: MT70_NAME,
                Nrtv: {
                    content: getEmptyStrIfNull(creditTransferTransaction.RmtInf?.Ustrd),
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

            MT50C: instructingParty is swiftmt:MT50C ? instructingParty : (),
            MT50L: instructingParty is swiftmt:MT50L ? instructingParty : (),

            MT50F: orderingCustomer is swiftmt:MT50F ? orderingCustomer : (),
            MT50G: orderingCustomer is swiftmt:MT50G ? orderingCustomer : (),
            MT50H: orderingCustomer is swiftmt:MT50H ? orderingCustomer : (),

            MT52A: accountServicingInstitution is swiftmt:MT52A ? accountServicingInstitution : (),
            MT52C: accountServicingInstitution is swiftmt:MT52C ? accountServicingInstitution : (),

            MT56A: intermediary is swiftmt:MT56A ? intermediary : (),
            MT56C: intermediary is swiftmt:MT56C ? intermediary : (),
            MT56D: intermediary is swiftmt:MT56D ? intermediary : (),

            MT57A: accountWithInstitution is swiftmt:MT57A ? accountWithInstitution : (),
            MT57C: accountWithInstitution is swiftmt:MT57C ? accountWithInstitution : (),
            MT57D: accountWithInstitution is swiftmt:MT57D ? accountWithInstitution : (),

            MT59: beneficiary is swiftmt:MT59 ? beneficiary : (),
            MT59A: beneficiary is swiftmt:MT59A ? beneficiary : (),
            MT59F: beneficiary is swiftmt:MT59F ? beneficiary : (),

            MT77B: {
                name: MT77B_NAME,
                Nrtv: getNarrativeFromRegulatoryCreditTransferTransaction61(creditTransferTransaction.RgltryRptg)
            },

            MT33B: {
                name: MT33B_NAME,
                Ccy: {
                    content: getActiveOrHistoricCurrencyAndAmountCcy(creditTransferTransaction.Amt.InstdAmt),
                    number: NUMBER1
                },
                Amnt: {
                    content: getActiveOrHistoricCurrencyAndAmountValue(creditTransferTransaction.Amt.InstdAmt),
                    number: NUMBER2
                }
            },

            MT71A: {
                name: MT71A_NAME,
                Cd: getDetailsOfChargesFromChargeBearerType1Code(creditTransferTransaction.ChrgBr)
            },

            MT36: {
                name: MT36_NAME,
                Rt: {
                    content: convertDecimalNumberToSwiftDecimal(creditTransferTransaction.XchgRateInf?.XchgRate),
                    number: NUMBER1
                }
            }
        });
    }

    return transactions;
}
