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
        return <swiftmt:MT50C>{
            name: MT50C_NAME,
            IdnCd: {
                content: getEmptyStrIfNull(OrgId?.AnyBIC),
                number: NUMBER1
            }
        };
    }

    painIsoRecord:PersonIdentification18? PrvtId = id?.PrvtId;
    if (PrvtId != ()) {
        painIsoRecord:GenericPersonIdentification2[]? Othr = id?.PrvtId?.Othr;

        if (Othr != () && Othr.length() > 0) {
            return <swiftmt:MT50L>{
                name: MT50L_NAME,
                PrtyIdn: {
                    content: getEmptyStrIfNull(Othr[0].Id),
                    number: NUMBER1
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
            name: MT50F_NAME,
            Nm: getNamesArrayFromNameString(firstTransaction.Dbtr?.Nm.toString()),
            CdTyp: [],
            PrtyIdn: {content: "/" + firstTransaction.DbtrAcct?.Id?.Othr?.Id.toString(), number: NUMBER1},
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>firstTransaction.Dbtr?.PstlAdr?.AdrLine),
            CntyNTw: getMtCountryAndTownFromMxCountryAndTown(getEmptyStrIfNull(firstTransaction.Dbtr?.PstlAdr?.Ctry), getEmptyStrIfNull(firstTransaction.Dbtr?.PstlAdr?.TwnNm))
        };
    }

    // TODO - Need to implement MT50G and MT50H

    return ();

}

# Get the account servicing institution from the Pain001 document.
#
# + document - The Pain001 document
# + return - The account servicing institution or an empty record
isolated function getMT101AccountServicingInstitutionFromPain001Document(painIsoRecord:Pain001Document document)
returns swiftmt:MT52A?|swiftmt:MT52C? {
    painIsoRecord:CustomerCreditTransferInitiationV12 cstmrDrctDbtInitn = document.CstmrCdtTrfInitn;
    painIsoRecord:PaymentInstruction44[] payments = cstmrDrctDbtInitn.PmtInf;
    painIsoRecord:PaymentInstruction44 firstTransaction = payments[0];
    painIsoRecord:BranchAndFinancialInstitutionIdentification8? dbtrAgt = firstTransaction.DbtrAgt;

    if (payments.length() == 0) {
        return ();
    }

    if dbtrAgt is () {
        return ();
    }

    if dbtrAgt.FinInstnId?.BICFI != () {
        return <swiftmt:MT52A>{
            name: MT52A_NAME,
            IdnCd: {content: getEmptyStrIfNull(dbtrAgt.FinInstnId?.BICFI.toString()), number: NUMBER1}
        };
    } else if dbtrAgt.FinInstnId?.ClrSysMmbId?.MmbId != () {
        return <swiftmt:MT52C>{
            name: MT52C_NAME,
            PrtyIdn: {content: getEmptyStrIfNull(dbtrAgt.FinInstnId.ClrSysMmbId?.MmbId.toString()), number: NUMBER1}
        };
    }

    return ();
}

# Get the transaction intermediary from the Pain001 document.
#
# + mxTransaction - A transaction in the Pain001 document
# + return - The transaction intermediary or an empty record
isolated function getMT101TransactionIntermediaryFromPain001Document(painIsoRecord:PaymentInstruction44 mxTransaction)
returns swiftmt:MT56A?|swiftmt:MT56C?|swiftmt:MT56D? {
    painIsoRecord:BranchAndFinancialInstitutionIdentification8? intrmyAgt = mxTransaction.CdtTrfTxInf[0]?.IntrmyAgt1;

    if intrmyAgt is () {
        return ();
    }

    if intrmyAgt.FinInstnId?.BICFI != () {
        return <swiftmt:MT56A>{
            name: MT56A_NAME,
            IdnCd: {content: getEmptyStrIfNull(intrmyAgt.FinInstnId.BICFI.toString()), number: NUMBER1},
            PrtyIdn: {content: getEmptyStrIfNull(intrmyAgt.FinInstnId.ClrSysMmbId?.MmbId.toString()), number: NUMBER1}
        };
    } else if intrmyAgt.FinInstnId?.ClrSysMmbId?.MmbId != () {
        return <swiftmt:MT56C>{
            name: MT56C_NAME,
            PrtyIdn: {content: getEmptyStrIfNull(intrmyAgt.FinInstnId.ClrSysMmbId?.MmbId.toString()), number: NUMBER1}
        };
    } else if intrmyAgt.FinInstnId?.Othr?.Id != () {
        return <swiftmt:MT56D>{
            name: MT56D_NAME,
            PrtyIdn: {content: getEmptyStrIfNull(intrmyAgt.FinInstnId.Othr?.Id.toString()), number: NUMBER1},
            Nm: getNamesArrayFromNameString(intrmyAgt.FinInstnId.Nm.toString()),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>intrmyAgt.FinInstnId.PstlAdr?.AdrLine)
        };
    }

    return ();
}

# Get the transaction acount with institution from a transaction in the Pain001 document.
#
# + mxTransaction - A transaction in the Pain001 document
# + return - The transaction acount with institution or an empty record
isolated function getMT101TransactionAcountWithInstitution(painIsoRecord:PaymentInstruction44 mxTransaction)
returns swiftmt:MT57A?|swiftmt:MT57C?|swiftmt:MT57D? {
    painIsoRecord:BranchAndFinancialInstitutionIdentification8? cdtrAgt = mxTransaction.CdtTrfTxInf[0]?.CdtrAgt;

    if cdtrAgt is () {
        return ();
    }

    if cdtrAgt.FinInstnId?.BICFI != () {
        return <swiftmt:MT57A>{
            name: MT57A_NAME,
            IdnCd: {content: getEmptyStrIfNull(cdtrAgt.FinInstnId.BICFI.toString()), number: NUMBER1}
        };
    }
    else if cdtrAgt.FinInstnId?.ClrSysMmbId?.MmbId != () {
        return <swiftmt:MT57C>{
            name: MT57C_NAME,
            PrtyIdn: {content: cdtrAgt.FinInstnId.ClrSysMmbId?.MmbId.toString(), number: NUMBER1}
        };
    }
    else if cdtrAgt.FinInstnId?.Othr?.Id != () {
        return <swiftmt:MT57D>{
            name: MT57D_NAME,
            PrtyIdn: {content: cdtrAgt.FinInstnId.Othr?.Id.toString(), number: NUMBER1},
            Nm: getNamesArrayFromNameString(cdtrAgt.FinInstnId.Nm.toString()),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>cdtrAgt.FinInstnId.PstlAdr?.AdrLine)

        };
    }

    return ();

}

# Get the transaction beneficiary from a transaction in the Pain001 document.
#
# + mxTransaction - A transaction in the Pain001 document
# + return - The transaction beneficiary or an empty record
isolated function getMT101TransactionBeneficiary(painIsoRecord:PaymentInstruction44 mxTransaction)
returns swiftmt:MT59|swiftmt:MT59A?|swiftmt:MT59F? {
    painIsoRecord:PartyIdentification272? cdtr = mxTransaction.CdtTrfTxInf[0]?.Cdtr;
    painIsoRecord:CashAccount40? cdtrAcct = mxTransaction.CdtTrfTxInf[0]?.CdtrAcct;

    if cdtr is () {
        return ();
    }

    if cdtr.Id?.OrgId?.AnyBIC != () {
        return <swiftmt:MT59A>{
            name: MT59A_NAME,
            IdnCd: {content: getEmptyStrIfNull(cdtr.Id?.OrgId?.AnyBIC), number: NUMBER1}
        };
    }
    else if cdtr.PstlAdr?.AdrLine != () {
        return <swiftmt:MT59F>{
            name: MT59F_NAME,
            Acc: {content: cdtrAcct?.Id?.Othr?.Id.toString(), number: NUMBER1},
            Nm: getNamesArrayFromNameString(cdtr.Nm.toString()),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>cdtr.PstlAdr?.AdrLine),
            CdTyp: [],
            CntyNTw: getMtCountryAndTownFromMxCountryAndTown(getEmptyStrIfNull(cdtr.PstlAdr?.Ctry),
                    getEmptyStrIfNull(cdtr.PstlAdr?.TwnNm)
            )
        };
    }
    else {
        return <swiftmt:MT59>{
            name: MT59_NAME,
            Nm: getNamesArrayFromNameString(cdtr.Nm.toString()),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>cdtr.PstlAdr?.AdrLine)
        };
    }

}
