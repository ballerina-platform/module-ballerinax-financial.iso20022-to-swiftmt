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

# This function transforms a camt.055 ISO 20022 message into an MT192 SWIFT format message.
#
# + document - The camt.055 message to be transformed, in `camtIsoRecord:Camt055Document` format.
# + return - Returns an MT192 message in the `swiftmt:MTn92Message` format if successful, otherwise returns an error.
isolated function transformCamt055ToMT192(camtIsoRecord:Camt055Document document) returns swiftmt:MTn92Message|error => {
    block1: check generateBlock1FromAssgnmt(document.CstmrPmtCxlReq.Assgnmt),
    block2: check generateMtBlock2(
            MESSAGETYPE_192,
            document.CstmrPmtCxlReq.Assgnmt.CreDtTm
    ),
    block3: check generateMtBlock3(
            document.CstmrPmtCxlReq.SplmtryData,
            (),
            ""
    ),
    block4: {
        MT20: check getMT20(document.CstmrPmtCxlReq.Case?.Id),
        MT21: {
            name: MT21_NAME,
            Ref: {
                content: getOriginalInstructionOrUETRFromCamt055(document.CstmrPmtCxlReq.Undrlyg),
                number: NUMBER1
            }
        },
        MT11S: check getMT11S(
                document.CstmrPmtCxlReq.Undrlyg[0].OrgnlGrpInfAndCxl,
                document.CstmrPmtCxlReq.Undrlyg[0].OrgnlGrpInfAndCxl?.OrgnlCreDtTm
        ),
        MT79: {
            name: MT79_NAME,
            Nrtv: extractNarrativeFromCancellationReason(document.CstmrPmtCxlReq)
        },
        MessageCopy: ()
    },
    block5: check generateMtBlock5FromSupplementaryData(document.CstmrPmtCxlReq.SplmtryData)
};
