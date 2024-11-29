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

# Transforms a camt.026 ISO 20022 document to its corresponding SWIFT MT195 format.
#
# + document - The camt.026 document to be transformed.
# + return - The transformed SWIFT MT195 message or an error.
isolated function transformCamt026ToMT195(camtIsoRecord:Camt026Document document) returns swiftmt:MTn95Message|error => let
    camtIsoRecord:SupplementaryData1[]? splmtryData = document.UblToApply.SplmtryData
    in {
        block1: check createBlock1FromAssgnmt(document.UblToApply.Assgnmt),
        block2: check createMtBlock2("195", document.UblToApply.SplmtryData, document.UblToApply.Assgnmt.CreDtTm),
        block3: check createMtBlock3(document.UblToApply.SplmtryData, (), ""),
        block4: {
            MT20: check deriveMT20(document.UblToApply.Case?.Id),
            MT21: {
                name: "21",
                Ref: {
                    content: document.UblToApply.Undrlyg.Initn?.OrgnlInstrId.toString(),
                    number: "1"
                }
            },
            MT75: {
                name: "75",
                Nrtv: {
                    content: getConcatenatedQueries(document.UblToApply.Justfn.MssngOrIncrrctInf),
                    number: "1"
                }
            },
            MT79: {
                name: "79",
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
                    name: "77A",
                    Nrtv: formatNarrative(splmtryData[0].Envlp?.Nrtv)
                }
                : (),
            MessageCopy: ()

        },
        block5: check createMtBlock5FromSupplementaryData(document.UblToApply.SplmtryData)
    };

# Formats the narrative for Field 77A to comply with the 20*35x format.
#
# + narrative - The original narrative as a string.
# + return - An Nrtv record containing the formatted narrative.
isolated function formatNarrative(string? narrative) returns swiftmt:Nrtv {
    string formattedNarrative = "";
    int lineLength = 35;

    if narrative is () {
        return {
            content: "",
            number: "1"
        };
    }

    foreach int i in 0 ... narrative.length() / lineLength {
        string line = narrative.substring(i * lineLength, int:min((i + 1) * lineLength, narrative.length()));
        formattedNarrative += line + (i == narrative.length() / lineLength ? "" : "\n");
    }

    return {
        content: formattedNarrative,
        number: "1"
    };
}

# Formats the narrative description for Field 79 to comply with the 35*50x format.
#
# + narrative - The original narrative as a string.
# + return - An array of Nrtv records, each containing a part of the narrative.
isolated function formatNarrativeDescription(string narrative) returns swiftmt:Nrtv[] {
    swiftmt:Nrtv[] formattedNarrative = [];
    int lineCount = 1;
    foreach int i in 0 ... narrative.length() / 50 {
        string line = narrative.substring(i * 50, int:min((i + 1) * 50, narrative.length()));
        formattedNarrative.push({
            content: line,
            number: lineCount.toString()
        });
        lineCount += 1;
    }
    return formattedNarrative;
}

# Constructs a concatenated queries narrative for the MT75 field.
#
# + missingOrIncorrectInfo - The `MissingOrIncorrectData1` structure containing missing and incorrect information.
# + return - Returns a concatenated string of queries or an empty string if no data is available.
isolated function getConcatenatedQueries(camtIsoRecord:MissingOrIncorrectData1? missingOrIncorrectInfo) returns string {
    if missingOrIncorrectInfo is () {
        return "";
    }

    string queriesContent = "";
    int queryNumber = 1;
    camtIsoRecord:UnableToApplyMissing2[]? missingInfo = missingOrIncorrectInfo.MssngInf;

    if !(missingInfo is ()) && missingInfo.length() > 0 {
        foreach camtIsoRecord:UnableToApplyMissing2 missing in missingInfo {
            string queryContent = "/" + queryNumber.toString() + "/";
            if missing.Tp.Cd is string {
                queryContent += missing.Tp.Cd.toString();
            } else if missing.Tp.Prtry is string {
                queryContent += missing.Tp.Prtry.toString();
            } else {
                queryContent += "Unknown Type";
            }

            if missing.AddtlMssngInf is string {
                queryContent += " " + missing.AddtlMssngInf.toString();
            }

            queriesContent += queryContent + "\n";
            queryNumber += 1;
        }
    }

    camtIsoRecord:UnableToApplyIncorrect2[]? incorrectInfo = missingOrIncorrectInfo.IncrrctInf;

    if incorrectInfo is camtIsoRecord:UnableToApplyIncorrect2[] && incorrectInfo.length() > 0 {
        foreach camtIsoRecord:UnableToApplyIncorrect2 incorrect in incorrectInfo {
            string queryContent = "/" + queryNumber.toString() + "/";

            if incorrect.Tp.Cd is string {
                queryContent += incorrect.Tp.Cd.toString();
            } else if incorrect.Tp.Prtry is string {
                queryContent += incorrect.Tp.Prtry.toString();
            } else {
                queryContent += "Unknown Type";
            }

            if incorrect.AddtlIncrrctInf is string {
                queryContent += " " + incorrect.AddtlIncrrctInf.toString();
            }

            queriesContent += queryContent + "\n";
            queryNumber += 1;
        }
    }

    return queriesContent.substring(0, queriesContent.length() - 1);
}

