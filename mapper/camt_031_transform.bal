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

import ballerinax/financial.iso20022.cash_management as camtIsoRecord;
import ballerinax/financial.swift.mt as swiftmt;

# This function transforms a camt.031 ISO 20022 message into an MT196 SWIFT format message.
#
# + document - The camt.031 message to be transformed, in `camtIsoRecord:Camt031Document` format.
# + return - Returns an MT196 message in the `swiftmt:MTn96Message` format if successful, otherwise returns an error.
isolated function transformCamt031ToMT196(camtIsoRecord:Camt031Document document) returns swiftmt:MTn96Message|error => {
    block1: check createBlock1FromAssgnmt(document.RjctInvstgtn.Assgnmt),
    block2: check createMtBlock2("196", document.RjctInvstgtn.SplmtryData, document.RjctInvstgtn.Assgnmt.CreDtTm),
    block3: check createMtBlock3(document.RjctInvstgtn.SplmtryData, (), ""),
    block4:
        {
        MT20: check deriveMT20(document.RjctInvstgtn.Case?.Id),
        MT21: {
            name: "21",
            Ref: {
                content: document.RjctInvstgtn.Assgnmt.Id,
                number: "1"
            }
        },
        MT11S: {
            name: "11S",
            MtNum: {
                content: "031",
                number: "1"
            },
            Dt: check convertISODateStringToSwiftMtDate(document.RjctInvstgtn.Assgnmt.CreDtTm.toString())
        }
,
        MT76: {
            name: "76",
            Nrtv: {
                content: getRejectionReasonNarrative(document.RjctInvstgtn.Justfn.RjctnRsn),
                number: "1"
            }
        },
        MT79: document.RjctInvstgtn.SplmtryData is camtIsoRecord:SupplementaryData1[] ? {
                name: "79",
                Nrtv: getAdditionalNarrativeInfo(document.RjctInvstgtn.SplmtryData)
            } : (),
        MessageCopy: ()
    },
    block5: check createMtBlock5FromSupplementaryData(document.RjctInvstgtn.SplmtryData)
};

# Maps an investigation rejection code to a narrative string.
# + rejectionCode - The rejection code from the camt.031 document.
# + return - The corresponding narrative string for the rejection code.
isolated function getRejectionReasonNarrative(camtIsoRecord:InvestigationRejection1Code rejectionCode) returns string {
    if rejectionCode == camtIsoRecord:NFND {
        return "Investigation rejected: Not found.";
    } else if (rejectionCode == camtIsoRecord:NAUT) {
        return "Investigation rejected: Not authorized.";
    } else if (rejectionCode == camtIsoRecord:UKNW) {
        return "Investigation rejected: Unknown.";
    } else if (rejectionCode == camtIsoRecord:PCOR) {
        return "Investigation rejected: Pending correction.";
    } else if (rejectionCode == camtIsoRecord:WMSG) {
        return "Investigation rejected: Wrong message.";
    } else if (rejectionCode == camtIsoRecord:RNCR) {
        return "Investigation rejected: Reason not clear.";
    } else if (rejectionCode == camtIsoRecord:MROI) {
        return "Investigation rejected: Message received out of scope.";
    }
}

