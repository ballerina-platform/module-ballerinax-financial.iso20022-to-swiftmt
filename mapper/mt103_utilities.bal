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
# + return - The ordering customer or null record
isolated function getMT103OrderingCustomerFromPacs008Document(SwiftMxRecords:Pacs008Document document)
returns swiftmt:MT50A?|swiftmt:MT50F?|swiftmt:MT50K? {

    SwiftMxRecords:PartyIdentification272? InitgPty = document.FIToFICstmrCdtTrf.CdtTrfTxInf[0].InitgPty;

    if InitgPty is () {
        return ();
    }

    // MT50A format: If Identifier Code (e.g., BIC) is present and no address details
    if InitgPty.Id?.OrgId?.AnyBIC != () && InitgPty.PstlAdr == () {
        return <swiftmt:MT50A>{
            name: "50A",
            IdnCd: {
                content: getEmptyStrIfNull(InitgPty.Id?.OrgId?.AnyBIC),
                number: "1"
            }
        };
    }

    // MT50F format: If Name, Address, and other structured fields like country are present
    if InitgPty.Nm != () && InitgPty.PstlAdr?.AdrLine != () {
        return <swiftmt:MT50F>{
            name: "50F",
            PrtyIdn: {
                content: InitgPty.Id?.OrgId?.AnyBIC.toString(),
                number: "1"
            },
            CdTyp: [],
            Nm: getNamesArrayFromNameString(InitgPty.Nm.toString()),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>InitgPty.PstlAdr?.AdrLine),
            CntyNTw: [
                {
                    content: getEmptyStrIfNull(InitgPty.PstlAdr?.Ctry),
                    number: "3"
                }
            ]
        };
    }

    // MT50K format: General name and address information without structured codes
    if InitgPty.Nm != () && InitgPty.PstlAdr != () {
        return <swiftmt:MT50K>{
            name: "50K",
            Nm: getNamesArrayFromNameString(InitgPty.Nm.toString()),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>InitgPty.PstlAdr?.AdrLine)
        };
    }

    return ();
}

# Get the ordering institution from the Pacs008 document.
#
# + document - The Pacs008 document
# + isSTP - A flag to indicate if the message is STP
# + return - The ordering institution or null record
isolated function getMT103OrderingInstitutionFromPacs008Document(SwiftMxRecords:Pacs008Document document, boolean isSTP)
returns swiftmt:MT52A?|swiftmt:MT52D? {

    SwiftMxRecords:FinancialInstitutionIdentification23? instgAgtFinInstnId = document.FIToFICstmrCdtTrf.CdtTrfTxInf[0].InstgAgt?.FinInstnId;

    if instgAgtFinInstnId is () {
        return ();
    }

    // MT52A: If BIC is present in Instructing Agent
    if instgAgtFinInstnId.BICFI != () {
        return <swiftmt:MT52A>{
            name: "52A",
            PrtyIdnTyp: (),
            PrtyIdn: (),
            IdnCd: {
                content: getEmptyStrIfNull(instgAgtFinInstnId.BICFI),
                number: "1"
            }
        };
    }

    // MT52D: If no BIC, use Name and Address
    if instgAgtFinInstnId.PstlAdr != () {
        return <swiftmt:MT52D>{
            name: "52D",
            PrtyIdnTyp: (),
            PrtyIdn: (),
            Nm: getNamesArrayFromNameString(instgAgtFinInstnId.Nm.toString()),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>instgAgtFinInstnId.PstlAdr?.AdrLine)
        };
    }

    return ();
}

# Get the senders correspondent from the Pacs008 document.
#
# + document - The Pacs008 document
# + return - The senders correspondent or null record
isolated function getMT103SendersCorrespondentFromPacs008Document(SwiftMxRecords:Pacs008Document document)
returns swiftmt:MT53A?|swiftmt:MT53B?|swiftmt:MT53D? {

    SwiftMxRecords:BranchAndFinancialInstitutionIdentification8? PrvsInstgAgt1 = document.FIToFICstmrCdtTrf.CdtTrfTxInf[0].PrvsInstgAgt1;

    if PrvsInstgAgt1 is () {
        return ();
    }

    // MT53A format: If BIC (Identifier Code) is available
    if PrvsInstgAgt1.FinInstnId?.BICFI != () {
        return <swiftmt:MT53A>{
            name: "53A",
            PrtyIdnTyp: (),
            PrtyIdn: (),
            IdnCd: {
                content: getEmptyStrIfNull(PrvsInstgAgt1.FinInstnId?.BICFI),
                number: "1"
            }
        };
    }

    // MT53B format: If only the location (Lctn) is available without address details
    if PrvsInstgAgt1.FinInstnId?.Nm != () && PrvsInstgAgt1.FinInstnId?.PstlAdr == () {
        return <swiftmt:MT53B>{
            name: "53B",
            PrtyIdnTyp: (),
            PrtyIdn: (),
            Lctn: {
                content: getEmptyStrIfNull(PrvsInstgAgt1.FinInstnId?.Nm),
                number: "1"
            }
        };
    }

    // MT53D format: If Name and Address are available
    if PrvsInstgAgt1.FinInstnId?.PstlAdr != () {
        return <swiftmt:MT53D>{
            name: "53D",
            PrtyIdnTyp: (),
            PrtyIdn: (),
            Nm: getNamesArrayFromNameString(getEmptyStrIfNull(PrvsInstgAgt1.FinInstnId?.Nm)),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>PrvsInstgAgt1.FinInstnId?.PstlAdr?.AdrLine)
        };
    }

    return ();
}

# Get the receivers correspondent from the Pacs008 document.
#
# + document - The Pacs008 document
# + isSTP - A flag to indicate if the message is STP
# + return - The receivers correspondent or null record
isolated function getMT103ReceiversCorrespondentFromPacs008Document(SwiftMxRecords:Pacs008Document document, boolean isSTP)
returns swiftmt:MT54A?|swiftmt:MT54B?|swiftmt:MT54D? {

    SwiftMxRecords:BranchAndFinancialInstitutionIdentification8? IntrmyAgt1 = document.FIToFICstmrCdtTrf.CdtTrfTxInf[0].IntrmyAgt1;

    if IntrmyAgt1 is () {
        return ();
    }

    // MT54A: If BIC (Identifier Code) is available
    if IntrmyAgt1.FinInstnId?.BICFI != () {
        return <swiftmt:MT54A>{
            name: "54A",
            PrtyIdnTyp: (),
            PrtyIdn: (),
            IdnCd: {
                content: getEmptyStrIfNull(IntrmyAgt1.FinInstnId?.BICFI),
                number: "1"
            }
        };
    }

    // MT54B: If only location (Lctn) is available without address details
    if IntrmyAgt1.FinInstnId?.Nm != () && IntrmyAgt1.FinInstnId?.PstlAdr == () {
        return <swiftmt:MT54B>{
            name: "54B",
            PrtyIdnTyp: (),
            PrtyIdn: (),
            Lctn: {
                content: getEmptyStrIfNull(IntrmyAgt1.FinInstnId?.Nm),
                number: "1"
            }
        };
    }

    // MT54D: If Name and Address are available
    if IntrmyAgt1.FinInstnId?.PstlAdr != () {
        return <swiftmt:MT54D>{
            name: "54D",
            PrtyIdnTyp: (),
            PrtyIdn: (),
            Nm: getNamesArrayFromNameString(getEmptyStrIfNull(IntrmyAgt1.FinInstnId?.Nm)),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>IntrmyAgt1.FinInstnId?.PstlAdr?.AdrLine)
        };
    }

    return ();
}

# Get the third reimbursement institution from the Pacs008 document.
#
# + document - The Pacs008 document
# + isSTP - A flag to indicate if the message is STP
# + return - The third reimbursement institution or null record
isolated function getMT103ThirdReimbursementInstitutionFromPacs008Document(SwiftMxRecords:Pacs008Document document, boolean isSTP)
returns swiftmt:MT55A?|swiftmt:MT55B?|swiftmt:MT55D? {

    SwiftMxRecords:BranchAndFinancialInstitutionIdentification8? IntrmyAgt2 = document.FIToFICstmrCdtTrf.CdtTrfTxInf[0].IntrmyAgt2;

    if IntrmyAgt2 is () {
        return ();
    }

    // MT55A format: If BIC (Identifier Code) is available
    if IntrmyAgt2.FinInstnId?.BICFI != () {
        return <swiftmt:MT55A>{
            name: "55A",
            PrtyIdnTyp: (),
            PrtyIdn: (),
            IdnCd: {
                content: getEmptyStrIfNull(IntrmyAgt2.FinInstnId?.BICFI),
                number: "1"
            }
        };
    }

    // MT55B format: If only location (Lctn) is available without address details
    if IntrmyAgt2.FinInstnId?.Nm != () && IntrmyAgt2.FinInstnId?.PstlAdr == () {
        return <swiftmt:MT55B>{
            name: "55B",
            PrtyIdnTyp: (),
            PrtyIdn: (),
            Lctn: {
                content: getEmptyStrIfNull(IntrmyAgt2.FinInstnId?.Nm),
                number: "1"
            }
        };
    }

    // MT55D format: If Name and Address are available
    if IntrmyAgt2.FinInstnId?.PstlAdr != () {
        return <swiftmt:MT55D>{
            name: "55D",
            PrtyIdnTyp: (),
            PrtyIdn: (),
            Nm: getNamesArrayFromNameString(getEmptyStrIfNull(IntrmyAgt2.FinInstnId?.Nm)),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>IntrmyAgt2.FinInstnId?.PstlAdr?.AdrLine)
        };
    }

    return ();
}

# Get the account with institution from the Pacs008 document.
#
# + document - The Pacs008 document
# + isSTP - A flag to indicate if the message is STP
# + return - The account with institution or null record
isolated function getMT103AccountWithInstitutionFromPacs008Document(SwiftMxRecords:Pacs008Document document, boolean isSTP)
returns swiftmt:MT57A?|swiftmt:MT57B?|swiftmt:MT57C?|swiftmt:MT57D? {

    SwiftMxRecords:BranchAndFinancialInstitutionIdentification8? CdtrAgt = document.FIToFICstmrCdtTrf.CdtTrfTxInf[0].CdtrAgt;

    if CdtrAgt is () {
        return ();
    }

    // MT57A format: If BIC (Identifier Code) is available
    if CdtrAgt.FinInstnId?.BICFI != () {
        return <swiftmt:MT57A>{
            name: "57A",
            PrtyIdnTyp: (),
            PrtyIdn: (),
            IdnCd: {
                content: getEmptyStrIfNull(CdtrAgt.FinInstnId?.BICFI),
                number: "1"
            }
        };
    }

    // MT57B format: If only the location (Lctn) is available without address details
    if CdtrAgt.FinInstnId?.Nm != () && CdtrAgt.FinInstnId?.PstlAdr == () {
        return <swiftmt:MT57B>{
            name: "57B",
            PrtyIdnTyp: (),
            PrtyIdn: (),
            Lctn: {
                content: getEmptyStrIfNull(CdtrAgt.FinInstnId?.Nm),
                number: "1"
            }
        };
    }

    // MT57C format: If only a party identifier (account) is available
    if CdtrAgt.FinInstnId?.Othr?.Id != () {
        return <swiftmt:MT57C>{
            name: "57C",
            PrtyIdn: {
                content: "",
                number: "1"
            }
        };
    }

    // MT57D format: If Name and Address are available
    if CdtrAgt.FinInstnId?.PstlAdr != () {
        return <swiftmt:MT57D>{
            name: "57D",
            PrtyIdnTyp: (),
            PrtyIdn: (),
            Nm: getNamesArrayFromNameString(getEmptyStrIfNull(CdtrAgt.FinInstnId?.Nm)),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>CdtrAgt.FinInstnId?.PstlAdr?.AdrLine)
        };
    }

    return ();
}

# Get the intermediary institution from the Pacs008 document.
#
# + document - The Pacs008 document
# + isSTP - A flag to indicate if the message is STP
# + return - The intermediary institution or null record
isolated function getMT103IntermediaryInstitutionFromPacs008Document(SwiftMxRecords:Pacs008Document document, boolean isSTP)
returns swiftmt:MT56A?|swiftmt:MT56C?|swiftmt:MT56D? {
    SwiftMxRecords:BranchAndFinancialInstitutionIdentification8? intrmyAgt = document.FIToFICstmrCdtTrf.CdtTrfTxInf[0]?.IntrmyAgt1;

    if intrmyAgt is () {
        return ();
    }

    // MT56A: Use this if the intermediary institution's BIC is available.
    if intrmyAgt.FinInstnId?.BICFI != () {
        return <swiftmt:MT56A>{
            name: "56A",
            IdnCd: {content: getEmptyStrIfNull(intrmyAgt.FinInstnId.BICFI.toString()), number: "1"}
        };
    }
    // MT56C: Use this if the Clearing System Member ID is available.
    else if intrmyAgt.FinInstnId?.ClrSysMmbId?.MmbId != () {
        return <swiftmt:MT56C>{
            name: "56C",
            PrtyIdn: {content: getEmptyStrIfNull(intrmyAgt.FinInstnId?.ClrSysMmbId?.MmbId.toString()), number: "1"}
        };
    }
    // MT56D: Use this if "Other" identification (like local codes) is available, with name and address.
    else if intrmyAgt.FinInstnId?.Othr?.Id != () {
        return <swiftmt:MT56D>{
            name: "56D",
            PrtyIdn: {content: getEmptyStrIfNull(intrmyAgt.FinInstnId?.Othr?.Id), number: "1"},
            Nm: getNamesArrayFromNameString(intrmyAgt.FinInstnId.Nm.toString()),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>intrmyAgt.FinInstnId.PstlAdr?.AdrLine)
        };
    }

    return ();
}

# Get the beneficiary customer from the Pacs008 document.
#
# + document - The Pacs008 document
# + return - The beneficiary customer or null record
isolated function getMT103BeneficiaryCustomerFromPacs008Document(SwiftMxRecords:Pacs008Document document)
returns swiftmt:MT59?|swiftmt:MT59A?|swiftmt:MT59F? {
    SwiftMxRecords:PartyIdentification272? cdtr = document.FIToFICstmrCdtTrf.CdtTrfTxInf[0]?.Cdtr;

    if cdtr is () {
        return ();
    }

    // MT59A: Use this if the creditor's BIC is available.
    if cdtr.Id?.OrgId?.AnyBIC != () {
        return <swiftmt:MT59A>{
            name: "59A",
            IdnCd: {content: getEmptyStrIfNull(cdtr.Id?.OrgId?.AnyBIC), number: "1"}
        };
    }
    // MT59F: Use this if structured name, address, and possibly other fields are available.
    else if cdtr.PstlAdr?.AdrLine == () {
        return <swiftmt:MT59F>{
            name: "59F",
            CdTyp: []
        };
    }
    // MT59: Use this if only the basic beneficiary information (name or account) is available.
    else {
        return <swiftmt:MT59>{
            name: "59",
            Nm: getNamesArrayFromNameString(cdtr.Nm.toString()),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>cdtr.PstlAdr?.AdrLine)
        };
    }
}

