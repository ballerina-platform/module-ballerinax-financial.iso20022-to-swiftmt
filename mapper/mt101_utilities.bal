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

# Get the instructing party from the Pain001 document.
#
# + document - The Pain001 document
# + return - The instructing party or an empty record
isolated function getMT101InstructingPartyFromPain001Document(painIsoRecord:Pain001Document document)
returns swiftmt:MT50C?|swiftmt:MT50L? {
    painIsoRecord:Party52Choice? id = document.CstmrCdtTrfInitn.GrpHdr.InitgPty.Id;

    if (id is ()) {
        return ();
    }

    painIsoRecord:OrganisationIdentification39? OrgId = id?.OrgId;

    if (OrgId != ()) {
        return {
            name: "50C",
            IdnCd: {
                content: getEmptyStrIfNull(OrgId?.AnyBIC),
                number: "1"
            }
        };
    }

    painIsoRecord:PersonIdentification18? PrvtId = id?.PrvtId;

    if (PrvtId != ()) {
        painIsoRecord:GenericPersonIdentification2[]? Othr = id?.PrvtId?.Othr;

        if (Othr != () && Othr.length() > 0) {
            return {
                name: "50L",
                PrtyIdn: {
                    content: getEmptyStrIfNull(Othr[0].Id),
                    number: "1"
                }
            };
        }
    }

    return ();
}

# Get the ordering customer from the Pain001 document.
#
# + document - The Pain001 document
# + return - The ordering customer or an empty record
isolated function getMT101OrderingCustomerFromPain001Document(painIsoRecord:Pain001Document document)
returns swiftmt:MT50F?|swiftmt:MT50G?|swiftmt:MT50H? {
    painIsoRecord:CustomerCreditTransferInitiationV12 cstmrDrctDbtInitn = document.CstmrCdtTrfInitn;
    painIsoRecord:PaymentInstruction44[] payments = cstmrDrctDbtInitn.PmtInf;

    if (payments.length() == 0) {
        return ();
    }

    painIsoRecord:PaymentInstruction44 firstTransaction = payments[0];

    if (firstTransaction.Dbtr.Nm != () && firstTransaction.Dbtr.PstlAdr != ()) {
        return <swiftmt:MT50F>{
            name: "50F",
            Nm: getNamesArrayFromNameString(firstTransaction.Dbtr?.Nm.toString()),
            CdTyp: [],
            PrtyIdn: {content: "", number: "1"},
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>firstTransaction.Dbtr?.PstlAdr?.AdrLine),
            CntyNTw: getMtCountryAndTownFromMxCountryAndTown(getEmptyStrIfNull(firstTransaction.Dbtr?.PstlAdr?.Ctry), getEmptyStrIfNull(firstTransaction.Dbtr?.PstlAdr?.TwnNm))
        };
    }

    if (firstTransaction.DbtrAcct.Id != () && firstTransaction.Dbtr.Id != ()) {
        return <swiftmt:MT50G>{
            name: "50G",
            Acc: {content: "", number: "1"},
            IdnCd: {content: "", number: "1"}
        };
    }

    return ();

}

# Get the account servicing institution from the Pain001 document.
#
# + document - The Pain001 document
# + return - The account servicing institution or an empty record
isolated function getMT101AccountServicingInstitutionFromPain001Document(painIsoRecord:Pain001Document document)
returns swiftmt:MT52A?|swiftmt:MT52C? {
    return ();
}

# Get the transaction intermediary from the Pain001 document.
#
# + mxTransaction - A transaction in the Pain001 document
# + return - The transaction intermediary or an empty record
isolated function getMT101TransactionIntermediaryFromPain001Document(painIsoRecord:PaymentInstruction44 mxTransaction)
returns swiftmt:MT56A?|swiftmt:MT56C?|swiftmt:MT56D? {
    return ();
}

# Get the transaction acount with institution from a transaction in the Pain001 document.
#
# + mxTransaction - A transaction in the Pain001 document
# + return - The transaction acount with institution or an empty record
isolated function getMT101TransactionAcountWithInstitution(painIsoRecord:PaymentInstruction44 mxTransaction)
returns swiftmt:MT57A?|swiftmt:MT57C?|swiftmt:MT57D? {
    return ();
}

# Get the transaction beneficiary from a transaction in the Pain001 document.
#
# + mxTransaction - A transaction in the Pain001 document
# + return - The transaction beneficiary or an empty record
isolated function getMT101TransactionBeneficiary(painIsoRecord:PaymentInstruction44 mxTransaction)
returns swiftmt:MT59|swiftmt:MT59A?|swiftmt:MT59F? {
    return ();
}
