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

# This function transforms a camt.028 ISO 20022 message into an MT196 SWIFT format message.
#
# + document - The camt.028 message to be transformed, in `camtIsoRecord:Camt028Document` format.
# + return - Returns an MT196 message in the `swiftmt:MTn96Message` format if successful, otherwise returns an error.
isolated function transformCamt028ToMT196(camtIsoRecord:Camt028Document document) returns swiftmt:MTn96Message|error => {
    block1: check generateMtBlock1FromAssgnmt(document.AddtlPmtInf.Assgnmt),
    block2: check generateMtBlock2WithDateTime(MESSAGETYPE_196, document.AddtlPmtInf.Assgnmt.CreDtTm),
    block3: check generateMtBlock3(document.AddtlPmtInf.SplmtryData, (), ""),
    block4: {
        MT20: check getMT20(document.AddtlPmtInf.Case?.Id),
        MT21: {
            name: MT21_NAME,
            Ref: {
                content: document.AddtlPmtInf.Undrlyg?.Initn?.OrgnlInstrId ?: "",
                number: NUMBER1
            }
        },
        MT11S: { // TODO - Implement the correct mapping for this field
            name: MT11S_NAME,
            MtNum: {
                content: "028", // TODO - Implement the correct mapping for this field
                number: NUMBER1
            },
            Dt: check convertISODateStringToSwiftMtDate(document.AddtlPmtInf.Assgnmt.CreDtTm.toString())
        }
,
        MT76: {
            name: MT76_NAME,
            Nrtv: {
                content: extractNarrativeFromSupplementaryData(document.AddtlPmtInf.SplmtryData),
                number: NUMBER1
            }
        },
        MT79: document.AddtlPmtInf.SplmtryData is camtIsoRecord:SupplementaryData1[] ? {
                name: MT79_NAME,
                Nrtv: getAdditionalNarrativeInfo(document.AddtlPmtInf.SplmtryData)
            } : (),
        MessageCopy: () // TODO - Need to add the relavent field mapping for this using the official mappings
    },
    block5: check generateMtBlock5FromSupplementaryData(document.AddtlPmtInf.SplmtryData),
    unparsedTexts: ()

};
