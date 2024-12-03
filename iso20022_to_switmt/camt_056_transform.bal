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

# This function transforms a camt.056 ISO 20022 message into an MT192 SWIFT format message.
#
# + document - The camt.056 message to be transformed, in `camtIsoRecord:Camt056Document` format.
# + return - Returns an MT192 message in the `swiftmt:MTn92Message` format if successful, otherwise returns an error.
isolated function transformCamt056ToMT192(camtIsoRecord:Camt056Document document) returns swiftmt:MTn92Message|error => let
    camtIsoRecord:UnderlyingTransaction34[] undrlyg = document.FIToFIPmtCxlReq.Undrlyg,
    camtIsoRecord:PaymentTransaction155[] txInf = undrlyg[0].TxInf ?: [],
    camtIsoRecord:PaymentTransaction155 txInf0 = txInf[0]
    in {

        block1: check generateBlock1FromAssgnmt(document.FIToFIPmtCxlReq.Assgnmt),
        block2: check generateMtBlock2WithDateTime(
                MESSAGETYPE_192,
                document.FIToFIPmtCxlReq.Assgnmt.CreDtTm
        ),
        block3: check generateMtBlock3(
                document.FIToFIPmtCxlReq.SplmtryData,
                (),
                ""
        ),
        block4: {
            MT20: check getMT20(document.FIToFIPmtCxlReq.Case?.Id),
            MT21: {
                name: MT21_NAME,
                Ref: {
                    content: getOriginalInstructionOrUETR(document.FIToFIPmtCxlReq.Undrlyg),
                    number: NUMBER1
                }
            },
            MT11S: check getMT11S(
                            document.FIToFIPmtCxlReq.Undrlyg[0].OrgnlGrpInfAndCxl,
                    document.FIToFIPmtCxlReq.Undrlyg[0].OrgnlGrpInfAndCxl?.OrgnlCreDtTm
                    ),
            MT79: {
                name: MT79_NAME,
                Nrtv: getNarrativeFromCancellationReason(document.FIToFIPmtCxlReq.Undrlyg)
            },
            MessageCopy: {
                MT32A: check getMT32A(txInf0.OrgnlIntrBkSttlmAmt, txInf0.OrgnlIntrBkSttlmDt)
            }
        },
        block5: check generateMtBlock5FromSupplementaryData(
                document.FIToFIPmtCxlReq.SplmtryData
        )
    };
