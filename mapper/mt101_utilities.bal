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

# Get the instructing party from the Pain001 document.
# 
# + document - The Pain001 document
# + return - The instructing party or an empty record
isolated function getMT101InstructingPartyFromPain001Document(SwiftMxRecords:Pain001Document document) 
returns SwiftMtRecords:MT50C? | SwiftMtRecords:MT50L? {
    SwiftMxRecords:Party52Choice? id = document.CstmrCdtTrfInitn.GrpHdr.InitgPty.Id;

    if (id is ()) {
        return ();
    }

    SwiftMxRecords:OrganisationIdentification39? OrgId = id?.OrgId;

    if (OrgId != ()) {
        return {
            name: "50C",
            IdnCd: {
                \#content: getEmptyStrIfNull(OrgId?.AnyBIC),
                number: "1"
            }
        };
    }

    SwiftMxRecords:PersonIdentification18? PrvtId = id?.PrvtId;

    if (PrvtId != ()) {
        SwiftMxRecords:GenericPersonIdentification2[]? Othr = id?.PrvtId?.Othr;
        
        if (Othr != () && Othr.length() > 0) {
            return {
                name: "50L",
                PrtyIdn: {
                    \#content: getEmptyStrIfNull(Othr[0].Id),
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
isolated function getMT101OrderingCustomerFromPain001Document(SwiftMxRecords:Pain001Document document) 
returns SwiftMtRecords:MT50F? | SwiftMtRecords:MT50G? | SwiftMtRecords:MT50H? {
    SwiftMxRecords:CustomerCreditTransferInitiationV12 cstmrDrctDbtInitn = document.CstmrCdtTrfInitn;
    SwiftMxRecords:PaymentInstruction44[] payments = cstmrDrctDbtInitn.PmtInf;

    if (payments.length() == 0) {
        return ();
    }

    SwiftMxRecords:PaymentInstruction44 firstTransaction = payments[0];

    if(firstTransaction.Dbtr.Nm != () && firstTransaction.Dbtr.PstlAdr != ()) {
        return <SwiftMtRecords:MT50F> {
            name: "50F",
            Nm : getNamesArrayFromNameString(firstTransaction.Dbtr?.Nm.toString()),
            CdTyp: [],
            PrtyIdn: {\#content: "", number: "1"},
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>firstTransaction.Dbtr?.PstlAdr?.AdrLine),
            CntyNTw: getMtCountryAndTownFromMxCountryAndTown(getEmptyStrIfNull(firstTransaction.Dbtr?.PstlAdr?.Ctry), getEmptyStrIfNull(firstTransaction.Dbtr?.PstlAdr?.TwnNm))
        };
    }

    if (firstTransaction.DbtrAcct.Id != () && firstTransaction.Dbtr.Id != ()) {
        return <SwiftMtRecords:MT50G> {
            name: "50G",
            Acc: {\#content: "", number: "1"},
            IdnCd: {\#content: "", number: "1"}
        };
    }



    return ();

}


# Get the account servicing institution from the Pain001 document.
# 
# + document - The Pain001 document
# + return - The account servicing institution or an empty record
isolated function getMT101AccountServicingInstitutionFromPain001Document(SwiftMxRecords:Pain001Document document) 
returns SwiftMtRecords:MT52A? | SwiftMtRecords:MT52C? {
    return ();
}

# Get the transaction intermediary from the Pain001 document.
# 
# + mxTransaction - A transaction in the Pain001 document
# + return - The transaction intermediary or an empty record
isolated function getMT101TransactionIntermediaryFromPain001Document(SwiftMxRecords:PaymentInstruction44 mxTransaction) 
returns SwiftMtRecords:MT56A? | SwiftMtRecords:MT56C? | SwiftMtRecords:MT56D? {
    return ();
}

# Get the transaction acount with institution from a transaction in the Pain001 document.
# 
# + mxTransaction - A transaction in the Pain001 document
# + return - The transaction acount with institution or an empty record
isolated function getMT101TransactionAcountWithInstitution(SwiftMxRecords:PaymentInstruction44 mxTransaction) 
returns SwiftMtRecords:MT57A? | SwiftMtRecords:MT57C? | SwiftMtRecords:MT57D? {
    return ();
}

# Get the transaction beneficiary from a transaction in the Pain001 document.
# 
# + mxTransaction - A transaction in the Pain001 document
# + return - The transaction beneficiary or an empty record
isolated function getMT101TransactionBeneficiary(SwiftMxRecords:PaymentInstruction44 mxTransaction) 
returns SwiftMtRecords:MT59 | SwiftMtRecords:MT59A? | SwiftMtRecords:MT59F? {
    return ();
}