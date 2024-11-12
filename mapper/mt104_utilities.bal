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

isolated function getMT104OrgIdFromPain008Document(painIsoRecord:Pain008Document document) returns string {

    string orgId = "";

    if (document.CstmrDrctDbtInitn.PmtInf[0].CdtrSchmeId?.Id?.OrgId?.Othr is ()) {
        return orgId;
    }

    orgId = document.CstmrDrctDbtInitn.PmtInf[0].CdtrSchmeId?.Id?.OrgId?.Othr[0].Id.toString();

    return orgId;
}

# Get the instructing party from the Pain008 document.
#
# + document - The Pain008 document
# + return - The instructing party or an empty record
isolated function getMT104InstructionPartyFromPain008Document(painIsoRecord:Pain008Document document)
returns swiftmt:MT50C?|swiftmt:MT50L? {
    return ();
}

# Get the ordering customer from the Pain008 document.
#
# + document - The Pain008 document
# + return - The ordering customer or an empty record
isolated function getMT104CreditorFromPain008Document(painIsoRecord:Pain008Document document)
returns swiftmt:MT50A?|swiftmt:MT50K? {
    return ();
}

# Get the account servicing institution from the Pain008 document.
#
# + document - The Pain008 document
# + return - The account servicing institution or an empty record
isolated function getMT104CreditorsBankFromPain008Document(painIsoRecord:Pain008Document document)
returns swiftmt:MT52A?|swiftmt:MT52C?|swiftmt:MT52D? {
    return ();
}

# Get the transaction debtor from the Pain008 document.
#
# + mxTransaction - The MX transaction
# + return - The transaction debtor or an empty record
isolated function getMT104TransactionDebtorsBankFromPain008Document(painIsoRecord:PaymentInstruction45 mxTransaction)
returns swiftmt:MT57A?|swiftmt:MT57C?|swiftmt:MT57D? {
    return ();
}

# Get the transaction debtor from the Pain008 document.
#
# + mxTransaction - The MX transaction
# + return - The transaction debtor or an empty record
isolated function getMT104TransactionDebtorFromPain008Document(painIsoRecord:PaymentInstruction45 mxTransaction)
returns swiftmt:MT59?|swiftmt:MT59A? {
    return ();
}

# Get the senders correspondent from the Pain008 document.
#
# + document - The Pain008 document
# + return - The senders correspondent or an empty record
isolated function getMT104SendersCorrespondentFromPain008Document(painIsoRecord:Pain008Document document)
returns swiftmt:MT53A?|swiftmt:MT53B? {
    return ();
}

