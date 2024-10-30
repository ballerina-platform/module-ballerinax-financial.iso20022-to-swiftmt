// Copyright (c) 2023, WSO2 LLC. (https://www.wso2.com).
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

import ballerinax/swiftmt as SwiftMtRecords;
import ballerinax/iso20022records as SwiftMxRecords;

# Create the MT101 message from the Pain001 document
# 
# + document - The Pain001 document
# + return - The MT101 message or an error if the transformation fails
isolated function transformPain001DocumentToMT101(SwiftMxRecords:Pain001Document document) returns SwiftMtRecords:MT101Message | error {

    SwiftMxRecords:CustomerCreditTransferInitiationV12 cstmrCdtTrfInitn = document.CstmrCdtTrfInitn;

    // Create the Metadata blocks of the MT message
    SwiftMtRecords:Block1? block1 = check createMtBlock1FromSupplementaryData(cstmrCdtTrfInitn.SplmtryData);
    SwiftMtRecords:Block2 block2 = check createMtBlock2FromSupplementaryData("101", cstmrCdtTrfInitn.SplmtryData);
    SwiftMtRecords:Block3? block3 = check createMtBlock3FromSupplementaryData(cstmrCdtTrfInitn.SplmtryData);
    SwiftMtRecords:Block5? block5 = check createMtBlock5FromSupplementaryData(cstmrCdtTrfInitn.SplmtryData);

    SwiftMtRecords:MT50C? | SwiftMtRecords:MT50L? instructingParty = getMT101InstructingPartyFromPain001Document(document);
    SwiftMtRecords:MT50F? | SwiftMtRecords:MT50G? | SwiftMtRecords:MT50H? orderingCustomer = getMT101OrderingCustomerFromPain001Document(document);
    SwiftMtRecords:MT52A? | SwiftMtRecords:MT52C? accountServicingInstitution = getMT101AccountServicingInstitutionFromPain001Document(document);

    // Create the data block of the MT message
    SwiftMtRecords:MT101Block4 block4 = {

        MT20: {
            name: "20", 
            msgId: {
                \#content: getEmptyStrIfNull(cstmrCdtTrfInitn.PmtInf[0].CdtTrfTxInf[0].PmtId.InstrId),
                number: "1"
            }
        },

        MT21R: {
            name: "21R", 
            Ref: {
                \#content: cstmrCdtTrfInitn.GrpHdr.MsgId,
                number: "1"
            }
        },

        // Setting this to empty string as the value is not available in the input
        MT28D: {
            name: "28D", 
            MsgIdx: {
                \#content: "",
                number: "1"
            }, 
            Ttl: {
                \#content: "",
                number: "2"
            }
        },

        MT50C: instructingParty is SwiftMtRecords:MT50C ? instructingParty : (),
        MT50L: instructingParty is SwiftMtRecords:MT50L ? instructingParty : (),

        MT50F: orderingCustomer is SwiftMtRecords:MT50F ? orderingCustomer : (),
        MT50G: orderingCustomer is SwiftMtRecords:MT50G ? orderingCustomer : (),
        MT50H: orderingCustomer is SwiftMtRecords:MT50H ? orderingCustomer : (),

        MT52A: accountServicingInstitution is SwiftMtRecords:MT52A ? accountServicingInstitution : (),
        MT52C: accountServicingInstitution is SwiftMtRecords:MT52C ? accountServicingInstitution : (),

        MT30: {
            name: "30", 
            Dt: check convertISODateStringToSwiftMtDate(cstmrCdtTrfInitn.PmtInf[0].ReqdExctnDt.Dt.toString(), "1")
        },
        MT25: {
            name: "25", 
            Auth: {
                \#content: "",
                number: "1"
            }
        },
        Transaction: check createMT101Transactions(cstmrCdtTrfInitn.PmtInf, instructingParty, orderingCustomer, accountServicingInstitution)
    };



    SwiftMtRecords:MT101Message message = {
        block1: block1,
        block2: block2,
        block3: block3,
        block4: block4,
        block5: block5
    };

    return message;
}


# Create the Transactions of the MT101 message
# 
# + mxTransactions - The MX transactions
# + instructingParty - The instructing party
# + orderingCustomer - The ordering customer
# + accountServicingInstitution - The account servicing institution
# + return - The MT101 transactions or an error if the transformation fails
isolated function createMT101Transactions(
    SwiftMxRecords:PaymentInstruction44[] mxTransactions,
    SwiftMtRecords:MT50C? | SwiftMtRecords:MT50L? instructingParty,
    SwiftMtRecords:MT50F? | SwiftMtRecords:MT50G? | SwiftMtRecords:MT50H? orderingCustomer,
    SwiftMtRecords:MT52A? | SwiftMtRecords:MT52C? accountServicingInstitution
) returns SwiftMtRecords:MT101Transaction[] | error {
    // Create the Transactions of the MT101 message
    SwiftMtRecords:MT101Transaction[] transactions = [];
    foreach SwiftMxRecords:PaymentInstruction44 item in mxTransactions {
        SwiftMxRecords:CreditTransferTransaction61 creditTransferTransaction = item.CdtTrfTxInf[0];
        
        SwiftMtRecords:MT56A? | SwiftMtRecords:MT56C? | SwiftMtRecords:MT56D? intermediary = getMT101TransactionIntermediaryFromPain001Document(item);
        SwiftMtRecords:MT57A? | SwiftMtRecords:MT57C? | SwiftMtRecords:MT57D? accountWithInstitution = getMT101TransactionAcountWithInstitution(item);
        SwiftMtRecords:MT59 | SwiftMtRecords:MT59A? | SwiftMtRecords:MT59F? beneficiary = getMT101TransactionBeneficiary(item);

        transactions.push({

            MT21: {
                name: "21", 
                Ref: {
                    \#content: getEmptyStrIfNull(creditTransferTransaction.PmtId.InstrId),
                    number: "1"
                }
            },

            // Setting this to empty string as the value is not available in the input
            MT21F: {
                name: "21F", 
                Ref: {
                    \#content: "",
                    number: "1"
                }
            },

            MT32B: {
                name: "32B", 
                Ccy: {
                    \#content: getActiveOrHistoricCurrencyAndAmountCcy(creditTransferTransaction.Amt.InstdAmt),
                    number: "1"
                }, 
                Amnt: {
                    \#content: getActiveOrHistoricCurrencyAndAmountValue(creditTransferTransaction.Amt.InstdAmt),
                    number: "2"
                }
            },

            MT50C: instructingParty is SwiftMtRecords:MT50C ? instructingParty : (),
            MT50L: instructingParty is SwiftMtRecords:MT50L ? instructingParty : (),

            MT50F: orderingCustomer is SwiftMtRecords:MT50F ? orderingCustomer : (),
            MT50G: orderingCustomer is SwiftMtRecords:MT50G ? orderingCustomer : (),
            MT50H: orderingCustomer is SwiftMtRecords:MT50H ? orderingCustomer : (),

            MT52A: accountServicingInstitution is SwiftMtRecords:MT52A ? accountServicingInstitution : (),
            MT52C: accountServicingInstitution is SwiftMtRecords:MT52C ? accountServicingInstitution : (),

            MT56A: intermediary is SwiftMtRecords:MT56A ? intermediary : (),
            MT56C: intermediary is SwiftMtRecords:MT56C ? intermediary : (),
            MT56D: intermediary is SwiftMtRecords:MT56D ? intermediary : (),

            MT57A: accountWithInstitution is SwiftMtRecords:MT57A ? accountWithInstitution : (),
            MT57C: accountWithInstitution is SwiftMtRecords:MT57C ? accountWithInstitution : (),
            MT57D: accountWithInstitution is SwiftMtRecords:MT57D ? accountWithInstitution : (),

            MT59: beneficiary is SwiftMtRecords:MT59 ? beneficiary : (),
            MT59A: beneficiary is SwiftMtRecords:MT59A ? beneficiary : (),
            MT59F: beneficiary is SwiftMtRecords:MT59F ? beneficiary : (),

            MT33B: {
                name: "33B", 
                Ccy: {
                    \#content: getActiveOrHistoricCurrencyAndAmountCcy(creditTransferTransaction.Amt.InstdAmt),
                    number: "1"
                }, 
                Amnt: {
                    \#content: getActiveOrHistoricCurrencyAndAmountValue(creditTransferTransaction.Amt.InstdAmt),
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
                    \#content: "",
                    number: "1"
                }
            },

            MT36: {
                name: "36", 
                Rt: {
                    \#content: convertDecimalNumberToSwiftDecimal(creditTransferTransaction.XchgRateInf?.XchgRate),
                    number: "1"
                }
            }
        });    
    }

    return transactions;
}
