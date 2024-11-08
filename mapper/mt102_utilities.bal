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

import ballerinax/financial.iso20022.payments_clearing_and_settlement as SwiftMxRecords;
import ballerinax/financial.swift.mt as swiftmt;

# Get the ordering customer from the Pacs008 document.
#
# + document - The Pacs008 document
# + return - The ordering customer or an empty record
isolated function getMT102OrderingCustomerFromPacs008Document(SwiftMxRecords:Pacs008Document document)
returns swiftmt:MT50A?|swiftmt:MT50F?|swiftmt:MT50K? {

    SwiftMxRecords:PartyIdentification272? initgPty = document.FIToFICstmrCdtTrf.CdtTrfTxInf[0].InitgPty;

    if initgPty is () {
        return ();
    }

    if initgPty.Id != () && initgPty.PstlAdr == () {
        return <swiftmt:MT50F>{
            name: "50F",
            PrtyIdn: {
                content: getEmptyStrIfNull(initgPty.Id),
                number: "1"
            },
            CdTyp: [
                {
                    content: getEmptyStrIfNull(initgPty.Nm),
                    number: "2"
                }
            ],
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>initgPty.PstlAdr?.AdrLine)
        };
    }

    if initgPty.Id != () {
        return <swiftmt:MT50A>{
            name: "50A",
            Acc: (),
            IdnCd: {
                content: getEmptyStrIfNull(initgPty.Id),
                number: "1"
            }
        };
    }

    if initgPty.Nm == () && initgPty.PstlAdr != () {
        return <swiftmt:MT50K>{
            name: "50K",
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>initgPty.PstlAdr?.AdrLine),
            Nm: getNamesArrayFromNameString(getEmptyStrIfNull(initgPty.Nm))
        };
    }

    return ();
}

# Get the ordering institution from the Pacs008 document.
#
# + document - The Pacs008 document
# + isSTP - A flag to indicate if the message is STP
# + return - The ordering institution or an empty record
# Get the ordering institution from the Pacs008 document.
#
# + document - The Pacs008 document
# + isSTP - A flag to indicate if the message is STP
# + return - The ordering institution or an empty record
isolated function getMT102OrderingInstitutionFromPacs008Document(SwiftMxRecords:Pacs008Document document, boolean isSTP)
returns swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C? {

    SwiftMxRecords:FinancialInstitutionIdentification23? FinInstnId = document.FIToFICstmrCdtTrf.CdtTrfTxInf[0].InstgAgt?.FinInstnId;

    if FinInstnId is () {
        return ();
    }

    // Check if BICFI is present for MT52A (BIC-based identification)
    if FinInstnId.BICFI != () {
        return <swiftmt:MT52A>{
            name: "52A",
            PrtyIdnTyp: (),
            PrtyIdn: (),
            IdnCd: {
                content: getEmptyStrIfNull(FinInstnId.BICFI),
                number: "1"
            }
        };
    }

    // Check if Other Id and Scheme Name are available for MT52A or MT52B (Clearing system or other identifiers)
    if FinInstnId.Othr?.Id != () {
        if isSTP {
            // Use MT52A format for STP messages
            return <swiftmt:MT52A>{
                name: "52A",
                PrtyIdnTyp: {
                    content: getEmptyStrIfNull(FinInstnId.Othr?.SchmeNm?.Cd),
                    number: "1"
                },
                PrtyIdn: {
                    content: getEmptyStrIfNull(FinInstnId.Othr?.Id),
                    number: "2"
                },
                IdnCd: {
                    content: getEmptyStrIfNull(FinInstnId.Othr?.Id),
                    number: "1"
                }
            };
        } else {
            // Use MT52B format for non-STP messages
            return <swiftmt:MT52B>{
                name: "52B",
                PrtyIdnTyp: {
                    content: getEmptyStrIfNull(FinInstnId.Othr?.SchmeNm?.Cd),
                    number: "1"
                },
                PrtyIdn: {
                    content: getEmptyStrIfNull(FinInstnId.Othr?.Id),
                    number: "2"
                },
                Lctn: {
                    content: getEmptyStrIfNull(FinInstnId.Othr?.Id),
                    number: "1"
                }
            };
        }
    }

    // Check if Postal Address is available for MT52B (Location-based identification)
    if FinInstnId.PstlAdr != () {
        return <swiftmt:MT52B>{
            name: "52B",
            PrtyIdnTyp: (),
            PrtyIdn: (),
            Lctn: {
                content: getEmptyStrIfNull(FinInstnId.PstlAdr?.AdrLine),
                number: "1"
            }
        };
    }

    return ();
}

# Get the transaction account with institution from the Pacs008 document.
#
# + mxTransaction - The MX transaction
# + isSTP - A flag to indicate if the message is STP
# + return - The transaction account with institution or an empty record
# Get the account with institution from the pacs.008 transaction.
#
# + mxTransaction - The CreditTransferTransaction64 transaction from pacs.008
# + isSTP - A flag to indicate if the message is STP
# + return - The account with institution as MT57A or MT57C, or an empty record if not found
isolated function getMT102TransactionAccountWithInstitutionFromPacs008Document(SwiftMxRecords:CreditTransferTransaction64 mxTransaction, boolean isSTP)
returns swiftmt:MT57A?|swiftmt:MT57C? {

    SwiftMxRecords:BranchAndFinancialInstitutionIdentification8? CreditorAgent = mxTransaction.CdtrAgt;
    SwiftMxRecords:CashAccount40? CreditorAgentAccount = mxTransaction.CdtrAgtAcct;

    if CreditorAgent is () && CreditorAgentAccount is () {
        return ();
    }

    // Check if BICFI is present in Creditor Agent (Option A)
    if CreditorAgent?.FinInstnId?.BICFI != () {
        return <swiftmt:MT57A>{
            name: "57A",
            PrtyIdnTyp: (),
            PrtyIdn: (),
            IdnCd: {
                content: getEmptyStrIfNull(CreditorAgent?.FinInstnId?.BICFI),
                number: "1"
            }
        };
    }

    // Check if account identification is available in Creditor Agent Account (Option C)
    if CreditorAgentAccount?.Id?.Othr?.Id != () {
        return <swiftmt:MT57C>{
            name: "57C",
            PrtyIdn: {
                content: getEmptyStrIfNull(CreditorAgentAccount?.Id?.Othr?.Id),
                number: "1"
            }
        };
    }

    return ();
}

# Get the transaction beneficiary customer from the Pacs008 document.
#
# + mxTransaction - The MX transaction
# + return - The transaction beneficiary customer or an empty record
isolated function getMT102TransactionBeneficiaryCustomerFromPacs008Document(SwiftMxRecords:CreditTransferTransaction64 mxTransaction)
returns swiftmt:MT59?|swiftmt:MT59A?|swiftmt:MT59F? {

    SwiftMxRecords:PartyIdentification272? Cdtr = mxTransaction.Cdtr;

    if Cdtr is () {
        return ();
    }

    if Cdtr.Id != () && Cdtr.Nm != () && Cdtr.PstlAdr == () {
        return <swiftmt:MT59A>{
            name: "59A",
            IdnCd: {
                content: getEmptyStrIfNull(Cdtr.Id),
                number: "1"
            }
        };
    }

    if Cdtr.Nm != () && Cdtr.PstlAdr?.AdrLine != () {
        return <swiftmt:MT59F>{
            name: "59F",
            Nm: getNamesArrayFromNameString(getEmptyStrIfNull(Cdtr.Nm)),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>Cdtr.PstlAdr?.AdrLine),
            CdTyp: []
        };
    }

    if Cdtr.PstlAdr != () && Cdtr.PstlAdr?.AdrLine != () {
        return <swiftmt:MT59>{
            name: "59",
            Nm: getNamesArrayFromNameString(getEmptyStrIfNull(Cdtr.Nm)),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>Cdtr.PstlAdr?.AdrLine)
        };
    }

    return ();

}

# Get the transaction sender correspondent from the Pacs008 document.
#
# + document - The Pacs008 document
# + return - The transaction sender correspondent or an empty record
# Get the sender's correspondent from the Pacs008 document.
#
# + document - The Pacs008 document
# + return - The sender's correspondent as MT53A or MT53C, or an empty record if not found
isolated function getMT102SendersCorrespondentFromPacs008Document(SwiftMxRecords:Pacs008Document document)
returns swiftmt:MT53A?|swiftmt:MT53C? {

    SwiftMxRecords:BranchAndFinancialInstitutionIdentification8? PrvsInstgAgt1 = document.FIToFICstmrCdtTrf.CdtTrfTxInf[0].PrvsInstgAgt1;
    SwiftMxRecords:CashAccount40? PrvsInstgAgt1Acct = document.FIToFICstmrCdtTrf.CdtTrfTxInf[0].PrvsInstgAgt1Acct;

    if PrvsInstgAgt1 is () && PrvsInstgAgt1Acct is () {
        return ();
    }

    // Check if BICFI (Option A) is available in Previous Instructing Agent 1
    if PrvsInstgAgt1?.FinInstnId?.BICFI != () {
        return <swiftmt:MT53A>{
            name: "53A",
            PrtyIdnTyp: (),
            PrtyIdn: (),
            IdnCd: {
                content: getEmptyStrIfNull(PrvsInstgAgt1?.FinInstnId?.BICFI),
                number: "1"
            }
        };
    }

    // Check if account identification (Option C) is available in Previous Instructing Agent 1 Account
    if PrvsInstgAgt1Acct?.Id?.Othr?.Id != () {
        return <swiftmt:MT53C>{
            name: "53C",
            Acc: {
                content: getEmptyStrIfNull(PrvsInstgAgt1Acct?.Id?.IBAN),
                number: "1"
            }
        };
    }

    return ();
}

