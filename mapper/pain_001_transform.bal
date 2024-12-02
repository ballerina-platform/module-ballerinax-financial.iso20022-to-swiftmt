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

# Create the MT101 message from the Pain001 document
#
# + document - The Pain001 document
# + return - The MT101 message or an error if the transformation fails
function transformPain001DocumentToMT101(painIsoRecord:Pain001Document document) returns swiftmt:MT101Message|error => let swiftmt:MT50C?|swiftmt:MT50L? instructingParty = getMT101InstructingPartyFromPain001Document(document), swiftmt:MT50F?|swiftmt:MT50G?|swiftmt:MT50H? orderingCustomer = getMT101OrderingCustomerFromPain001Document(document), swiftmt:MT52A?|swiftmt:MT52C? accountServicingInstitution = getMT101AccountServicingInstitutionFromPain001Document(document) in {
        block1: check createMtBlock1FromSupplementaryData(document.CstmrCdtTrfInitn.SplmtryData),
        block2: check createMtBlock2("101", document.CstmrCdtTrfInitn.SplmtryData, document.CstmrCdtTrfInitn.GrpHdr.CreDtTm),
        block3: check createMtBlock3(document.CstmrCdtTrfInitn.SplmtryData, document.CstmrCdtTrfInitn.PmtInf[0].CdtTrfTxInf[0].PmtId.UETR, ""),
        block4: {
            MT20: {
                name: "20",
                msgId: {
                    content: ((document.CstmrCdtTrfInitn.PmtInf[0].CdtTrfTxInf[0].PmtId.InstrId != ()) ? document.CstmrCdtTrfInitn.PmtInf[0].CdtTrfTxInf[0].PmtId.InstrId.toString() : ""),
                    number: "1"
                }
            },
            MT21R: {
                name: "21R",
                Ref: {
                    content: document.CstmrCdtTrfInitn.GrpHdr.MsgId,
                    number: "1"
                }
            },
            MT28D: {
                name: "28D",
                MsgIdx: {
                    content: "1",
                    number: "1"
                },
                Ttl: {
                    content: "1",
                    number: "2"
                }
            },
            MT30: {
                name: "30",
                Dt: check convertISODateStringToSwiftMtDate(document.CstmrCdtTrfInitn.PmtInf[0].ReqdExctnDt.Dt.toString(), "1")
            },
            MT25: {
                name: "25",
                Auth: {
                    content: "",
                    number: "1"
                }
            },
            MT50C: instructingParty is swiftmt:MT50C ? instructingParty : (),
            MT50L: instructingParty is swiftmt:MT50L ? instructingParty : (),
            MT50F: orderingCustomer is swiftmt:MT50F ? orderingCustomer : (),
            MT50G: orderingCustomer is swiftmt:MT50G ? orderingCustomer : (),
            MT50H: orderingCustomer is swiftmt:MT50H ? orderingCustomer : (),
            MT52A: accountServicingInstitution is swiftmt:MT52A ? accountServicingInstitution : (),
            MT52C: accountServicingInstitution is swiftmt:MT52C ? accountServicingInstitution : (),
            Transaction: check createMT101Transactions(document.CstmrCdtTrfInitn.PmtInf, getMT101InstructingPartyFromPain001Document(document), getMT101OrderingCustomerFromPain001Document(document), getMT101AccountServicingInstitutionFromPain001Document(document))
        },
        block5: check createMtBlock5FromSupplementaryData(document.CstmrCdtTrfInitn.SplmtryData)
    };

# Create the Transactions of the MT101 message
#
# + mxTransactions - The MX transactions
# + instructingParty - The instructing party
# + orderingCustomer - The ordering customer
# + accountServicingInstitution - The account servicing institution
# + return - The MT101 transactions or an error if the transformation fails
isolated function createMT101Transactions(
        painIsoRecord:PaymentInstruction44[] mxTransactions,
        swiftmt:MT50C?|swiftmt:MT50L? instructingParty,
        swiftmt:MT50F?|swiftmt:MT50G?|swiftmt:MT50H? orderingCustomer,
        swiftmt:MT52A?|swiftmt:MT52C? accountServicingInstitution
) returns swiftmt:MT101Transaction[]|error {
    // Create the Transactions of the MT101 message
    swiftmt:MT101Transaction[] transactions = [];
    foreach painIsoRecord:PaymentInstruction44 item in mxTransactions {
        painIsoRecord:CreditTransferTransaction61 creditTransferTransaction = item.CdtTrfTxInf[0];
        swiftmt:MT56A?|swiftmt:MT56C?|swiftmt:MT56D? intermediary = getMT101TransactionIntermediaryFromPain001Document(item);
        swiftmt:MT57A?|swiftmt:MT57C?|swiftmt:MT57D? accountWithInstitution = getMT101TransactionAcountWithInstitution(item);
        swiftmt:MT59|swiftmt:MT59A?|swiftmt:MT59F? beneficiary = getMT101TransactionBeneficiary(item);

        transactions.push({
            MT21: {
                name: "21",
                Ref: {
                    content: getEmptyStrIfNull(creditTransferTransaction.PmtId.EndToEndId),
                    number: "1"
                }
            },

            MT21F: {
                name: "21F",
                Ref: {
                    content: "",
                    number: "1"
                }
            },

            MT70: {
                name: "70",
                Nrtv: {
                    "content": getEmptyStrIfNull(creditTransferTransaction.RmtInf?.Ustrd),
                    "number": "1"
                }
            },

            MT32B: {
                name: "32B",
                Ccy: {
                    content: getActiveOrHistoricCurrencyAndAmountCcy(creditTransferTransaction.Amt.InstdAmt),
                    number: "1"
                },
                Amnt: {
                    content: getActiveOrHistoricCurrencyAndAmountValue(creditTransferTransaction.Amt.InstdAmt),
                    number: "2"
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
                name: "77B",
                Nrtv: getNarrativeFromRegulatoryCreditTransferTransaction61(creditTransferTransaction.RgltryRptg)
            },

            MT33B: {
                name: "33B",
                Ccy: {
                    content: getActiveOrHistoricCurrencyAndAmountCcy(creditTransferTransaction.Amt.InstdAmt),
                    number: "1"
                },
                Amnt: {
                    content: getActiveOrHistoricCurrencyAndAmountValue(creditTransferTransaction.Amt.InstdAmt),
                    number: "2"
                }
            },

            MT71A: {
                name: "71A",
                Cd: getDetailsOfChargesFromChargeBearerType1Code(creditTransferTransaction.ChrgBr)
            },

            MT25A: {
                name: "25A",
                Acc: {
                    content: "",
                    number: "1"
                }
            },

            MT36: {
                name: "36",
                Rt: {
                    content: convertDecimalNumberToSwiftDecimal(creditTransferTransaction.XchgRateInf?.XchgRate),
                    number: "1"
                }
            }
        });
    }

    return transactions;
}
