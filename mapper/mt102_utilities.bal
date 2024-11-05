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
    return ();
}

# Get the ordering institution from the Pacs008 document.
#
# + document - The Pacs008 document
# + isSTP - A flag to indicate if the message is STP
# + return - The ordering institution or an empty record
isolated function getMT102OrderingInstitutionFromPacs008Document(SwiftMxRecords:Pacs008Document document, boolean isSTP)
returns swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C? {
    return ();
}

# Get the transaction account with institution from the Pacs008 document.
#
# + mxTransaction - The MX transaction
# + isSTP - A flag to indicate if the message is STP
# + return - The transaction account with institution or an empty record
isolated function getMT102TransactionAccountWithInstitutionFromPacs008Document(SwiftMxRecords:CreditTransferTransaction64 mxTransaction, boolean isSTP)
returns swiftmt:MT57A?|swiftmt:MT57C? {
    return ();
}

# Get the transaction beneficiary customer from the Pacs008 document.
#
# + mxTransaction - The MX transaction
# + return - The transaction beneficiary customer or an empty record
isolated function getMT102TransactionBeneficiaryCustomerFromPacs008Document(SwiftMxRecords:CreditTransferTransaction64 mxTransaction)
returns swiftmt:MT59?|swiftmt:MT59A?|swiftmt:MT59F? {
    return ();
}

# Get the transaction sender correspondent from the Pacs008 document.
#
# + document - The Pacs008 document
# + return - The transaction sender correspondent or an empty record
isolated function getMT102SendersCorrespondentFromPacs008Document(SwiftMxRecords:Pacs008Document document)
returns swiftmt:MT53A?|swiftmt:MT53C? {
    return ();
}
