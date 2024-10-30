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

# Get the ordering customer from the Pacs008 document.
# 
# + document - The Pacs008 document
# + return - The ordering customer or null record
isolated function getMT103OrderingCustomerFromPacs008Document(SwiftMxRecords:Pacs008Document document) 
returns SwiftMtRecords:MT50A? | SwiftMtRecords:MT50F? | SwiftMtRecords:MT50K? {
    return ();
}

# Get the ordering institution from the Pacs008 document.
# 
# + document - The Pacs008 document
# + isSTP - A flag to indicate if the message is STP
# + return - The ordering institution or null record
isolated function getMT103OrderingInstitutionFromPacs008Document(SwiftMxRecords:Pacs008Document document, boolean isSTP) 
returns SwiftMtRecords:MT52A? | SwiftMtRecords:MT52D? {
    return ();
}


# Get the senders correspondent from the Pacs008 document.
# 
# + document - The Pacs008 document
# + return - The senders correspondent or null record
isolated function getMT103SendersCorrespondentFromPacs008Document(SwiftMxRecords:Pacs008Document document)
returns SwiftMtRecords:MT53A? | SwiftMtRecords:MT53B? | SwiftMtRecords:MT53D? {
    return ();
}

# Get the receivers correspondent from the Pacs008 document.
# 
# + document - The Pacs008 document
# + isSTP - A flag to indicate if the message is STP
# + return - The receivers correspondent or null record
isolated function getMT103ReceiversCorrespondentFromPacs008Document(SwiftMxRecords:Pacs008Document document, boolean isSTP)
returns SwiftMtRecords:MT54A? | SwiftMtRecords:MT54B? | SwiftMtRecords:MT54D? {
    return ();
}

# Get the third reimbursement institution from the Pacs008 document.
# 
# + document - The Pacs008 document
# + isSTP - A flag to indicate if the message is STP
# + return - The third reimbursement institution or null record
isolated function getMT103ThirdReimbursementInstitutionFromPacs008Document(SwiftMxRecords:Pacs008Document document, boolean isSTP)
returns SwiftMtRecords:MT55A? | SwiftMtRecords:MT55B? | SwiftMtRecords:MT55D? {
    return ();
}

# Get the intermediary institution from the Pacs008 document.
# 
# + document - The Pacs008 document
# + isSTP - A flag to indicate if the message is STP
# + return - The intermediary institution or null record
isolated function getMT103IntermediaryInstitutionFromPacs008Document(SwiftMxRecords:Pacs008Document document, boolean isSTP)
returns SwiftMtRecords:MT56A? | SwiftMtRecords:MT56C? | SwiftMtRecords:MT56D? {
    return ();
}

# Get the account with institution from the Pacs008 document.
# 
# + document - The Pacs008 document
# + isSTP - A flag to indicate if the message is STP
# + return - The account with institution or null record
isolated function getMT103AccountWithInstitutionFromPacs008Document(SwiftMxRecords:Pacs008Document document, boolean isSTP)
returns SwiftMtRecords:MT57A? | SwiftMtRecords:MT57B? | SwiftMtRecords:MT57C? | SwiftMtRecords:MT57D? {
    return ();
}

# Get the beneficiary customer from the Pacs008 document.
# 
# + document - The Pacs008 document
# + return - The beneficiary customer or null record
isolated function getMT103BeneficiaryCustomerFromPacs008Document(SwiftMxRecords:Pacs008Document document)
returns SwiftMtRecords:MT59? | SwiftMtRecords:MT59A? | SwiftMtRecords:MT59F? {
    return ();
}
