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

# Transforms a camt.026 ISO 20022 document to its corresponding SWIFT MTn95 format.
#
# + document - The camt.026 document to be transformed.
# + messageType - The SWIFT MTn95 message type to be transformed.
# + return - The transformed SWIFT MTn95 message or an error.
isolated function transformCamt026ToMtn95(camtIsoRecord:Camt026Document document, string messageType) returns swiftmt:MTn95Message|error => let
    camtIsoRecord:SupplementaryData1[]? splmtryData = document.UblToApply.SplmtryData
    in {
        block1: {
            logicalTerminal: getSenderOrReceiver(document.UblToApply.Assgnmt.Assgne.Agt?.FinInstnId?.BICFI)
        },
        block2: {
            'type: "output",
            messageType: messageType,
            MIRLogicalTerminal: getSenderOrReceiver(document.UblToApply.Assgnmt.Assgne.Agt?.FinInstnId?.BICFI),
            senderInputTime: {content: check convertToSwiftTimeFormat(document.UblToApply.Assgnmt.CreDtTm.substring(11))},
            MIRDate: {content: convertToSWIFTStandardDate(document.UblToApply.Assgnmt.CreDtTm.substring(0, 10))}
        },
        block3: createMtBlock3(document.UblToApply.Undrlyg.Initn?.OrgnlUETR),
        block4: {
            MT20: check getMT20(document.UblToApply.Case?.Id),
            MT21: {
                name: MT21_NAME,
                Ref: {
                    content: document.UblToApply.Undrlyg.Initn?.OrgnlInstrId.toString(),
                    number: NUMBER1
                }
            },
            MT75: {
                name: MT75_NAME,
                Nrtv: {
                    content: getConcatenatedQueries(document.UblToApply.Justfn.MssngOrIncrrctInf),
                    number: NUMBER1
                }
            },
            MT79: {
                name: MT79_NAME,
                Nrtv: splmtryData is camtIsoRecord:SupplementaryData1[] &&
                            splmtryData.length() > 0 &&
                            splmtryData[0]?.Envlp?.CpOfOrgnlMsg is string
                    ? formatNarrativeDescription(splmtryData[0].Envlp?.CpOfOrgnlMsg.toString())
                    : []
            },
            MT77A: splmtryData is camtIsoRecord:SupplementaryData1[] &&
                        splmtryData.length() > 0 &&
                        splmtryData[0].Envlp?.Nrtv is string
                ? {
                    name: MT77A_NAME,
                    Nrtv: formatNarrative(splmtryData[0].Envlp?.Nrtv)
                }
                : (),
            MessageCopy: () // TODO - Need to add the relavent field mapping for this using the official mappings

        },
        block5: check generateMtBlock5FromSupplementaryData(document.UblToApply.SplmtryData),
        unparsedTexts: ()
    };
