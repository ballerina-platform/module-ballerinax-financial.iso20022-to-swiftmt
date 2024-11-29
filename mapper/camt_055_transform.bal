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
isolated function transformCamt055ToMT192(camtIsoRecord:Camt055Document document) returns swiftmt:MTn92Message|error {
    // Step 1: Create Block 1
    swiftmt:Block1? block1 = check createBlock1FromAssgnmt(document.CstmrPmtCxlReq.Assgnmt);

    // Step 2: Create Block 2
    swiftmt:Block2 block2 = check createMtBlock2(
            "192",
            document.CstmrPmtCxlReq.SplmtryData,
            document.CstmrPmtCxlReq.Assgnmt.CreDtTm
    );

    // Step 3: Create Block 3
    swiftmt:Block3? block3 = check createMtBlock3(
            document.CstmrPmtCxlReq.SplmtryData,
            (),
            ""
    );

    // Step 4: Create Block 4
    swiftmt:MT20 mt20 = check deriveMT20(document.CstmrPmtCxlReq.Case?.Id);

    swiftmt:MT21 mt21 = {
        name: "21",
        Ref: {
            content: getOriginalInstructionOrUETRFromCamt055(document.CstmrPmtCxlReq.Undrlyg),
            number: "1"
        }
    };

    swiftmt:MT11S mt11s = check deriveMT11S(
                document.CstmrPmtCxlReq.Undrlyg[0].OrgnlGrpInfAndCxl,
            document.CstmrPmtCxlReq.Undrlyg[0].OrgnlGrpInfAndCxl?.OrgnlCreDtTm
    );

    swiftmt:MT79 mt79 = {
        name: "79",
        Nrtv: extractNarrativeFromCancellationReason(document.CstmrPmtCxlReq)
    };

    swiftmt:MTn92Block4 block4 = {
        MT20: mt20,
        MT21: mt21,
        MT11S: mt11s,
        MT79: mt79,
        MessageCopy: ()
    };

    // Step 5: Create Block 5
    swiftmt:Block5? block5 = check createMtBlock5FromSupplementaryData(document.CstmrPmtCxlReq.SplmtryData);

    // Assemble and return the MT192 message
    return {
        block1: block1,
        block2: block2,
        block3: block3,
        block4: block4,
        block5: block5
    };
}

