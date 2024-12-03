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

    if FinInstnId.BICFI != () {
        return <swiftmt:MT52A>{
            name: MT52A_NAME,
            PrtyIdnTyp: (),
            PrtyIdn: (),
            IdnCd: {
                content: getEmptyStrIfNull(FinInstnId.BICFI),
                number: NUMBER1
            }
        };
    }

    if FinInstnId.Othr?.Id != () {
        if isSTP {
            return <swiftmt:MT52A>{
                name: MT52A_NAME,
                PrtyIdnTyp: {
                    content: getEmptyStrIfNull(FinInstnId.Othr?.SchmeNm?.Cd),
                    number: NUMBER1
                },
                PrtyIdn: {
                    content: getEmptyStrIfNull(FinInstnId.Othr?.Id),
                    number: NUMBER2
                },
                IdnCd: {
                    content: getEmptyStrIfNull(FinInstnId.Othr?.Id),
                    number: NUMBER1
                }
            };
        } else {
            return <swiftmt:MT52B>{
                name: MT52B_NAME,
                PrtyIdnTyp: {
                    content: getEmptyStrIfNull(FinInstnId.Othr?.SchmeNm?.Cd),
                    number: NUMBER1
                },
                PrtyIdn: {
                    content: getEmptyStrIfNull(FinInstnId.Othr?.Id),
                    number: NUMBER2
                },
                Lctn: {
                    content: getEmptyStrIfNull(FinInstnId.Othr?.Id),
                    number: NUMBER1
                }
            };
        }
    }

    if FinInstnId.PstlAdr != () {
        return <swiftmt:MT52B>{
            name: MT52B_NAME,
            PrtyIdnTyp: (),
            PrtyIdn: (),
            Lctn: {
                content: getEmptyStrIfNull(FinInstnId.PstlAdr?.AdrLine),
                number: NUMBER1
            }
        };
    }

    return ();
}

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

    if CreditorAgent?.FinInstnId?.BICFI != () {
        return <swiftmt:MT57A>{
            name: MT57A_NAME,
            PrtyIdnTyp: (),
            PrtyIdn: (),
            IdnCd: {
                content: getEmptyStrIfNull(CreditorAgent?.FinInstnId?.BICFI),
                number: NUMBER1
            }
        };
    }
    if CreditorAgentAccount?.Id?.Othr?.Id != () {
        return <swiftmt:MT57C>{
            name: MT57C_NAME,
            PrtyIdn: {
                content: getEmptyStrIfNull(CreditorAgentAccount?.Id?.Othr?.Id),
                number: NUMBER1
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
    SwiftMxRecords:CashAccount40? CdtrAcct = mxTransaction.CdtrAcct;

    if Cdtr is () {
        return ();
    }

    if Cdtr.Id != () && Cdtr.Nm != () && Cdtr.PstlAdr == () {
        return <swiftmt:MT59A>{
            name: MT56A_NAME,
            IdnCd: {
                content: getEmptyStrIfNull(Cdtr.Id),
                number: NUMBER1
            }
        };
    }
    if Cdtr.Nm != () && Cdtr.PstlAdr?.AdrLine != () {
        return <swiftmt:MT59F>{
            name: MT56F_NAME,
            Nm: getNamesArrayFromNameString(getEmptyStrIfNull(Cdtr.Nm)),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>Cdtr.PstlAdr?.AdrLine),
            CdTyp: [],
            Acc: {content: CdtrAcct?.Id?.Othr?.Id.toString(), number: NUMBER1},
            CntyNTw: getMtCountryAndTownFromMxCountryAndTown(getEmptyStrIfNull(Cdtr.PstlAdr?.Ctry),
                    getEmptyStrIfNull(Cdtr.PstlAdr?.TwnNm)
            )
        };
    }
    if Cdtr.PstlAdr != () && Cdtr.PstlAdr?.AdrLine != () {
        return <swiftmt:MT59>{
            name: MT56F_NAME,
            Nm: getNamesArrayFromNameString(getEmptyStrIfNull(Cdtr.Nm)),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>Cdtr.PstlAdr?.AdrLine)
        };
    }

    return ();

}

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

    if PrvsInstgAgt1?.FinInstnId?.BICFI != () {
        return <swiftmt:MT53A>{
            name: MT53A_NAME,
            PrtyIdnTyp: (),
            PrtyIdn: (),
            IdnCd: {
                content: getEmptyStrIfNull(PrvsInstgAgt1?.FinInstnId?.BICFI),
                number: NUMBER1
            }
        };
    }
    if PrvsInstgAgt1Acct?.Id?.Othr?.Id != () {
        return <swiftmt:MT53C>{
            name: MT53C_NAME,
            Acc: {
                content: getEmptyStrIfNull(PrvsInstgAgt1Acct?.Id?.IBAN),
                number: NUMBER1
            }
        };
    }

    return ();
}

