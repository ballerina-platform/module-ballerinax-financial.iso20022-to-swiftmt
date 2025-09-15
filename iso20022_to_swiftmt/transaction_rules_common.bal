// Copyright (c) 2025, WSO2 LLC. (https://www.wso2.com).
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

import ballerinax/financial.iso20022.payments_clearing_and_settlement as pacsIsoRecord;

# The function translates an MX AnyBIC party identification to an MT AnyBIC.  
#
# + anybic - MXPartyIdentification
# + return - return AnyBIC identifying the party in the MT format
isolated function mx_to_mtAnyBIC(pacsIsoRecord:AnyBICDec2014Identifier? anybic) returns string {
    return anybic is string ? anybic : "";
}

# The function translates an MX account to an MT account.
#
# + identification - MX account identification  
# + appendSlash - boolean value to check whether to append a slash or not
# + return - return MTAccount
isolated function mx_to_mtAccount(pacsIsoRecord:AccountIdentification4Choice? identification, boolean appendSlash = false) returns string {
    string mtAccount = "";
    if identification?.IBAN is string {
        mtAccount = identification?.IBAN.toString();
    } else if identification?.Othr?.Id is string {
        string account = identification?.Othr?.Id.toString();
        // if identification?.Othr?.SchmeNm?.Cd is string {
        string code = identification?.Othr?.SchmeNm?.Cd.toString();
        if code == "CUID" && account.length() == 6 {
            mtAccount = "/CH".concat(account);
        } else {
            mtAccount = appendSlash ? "/" + account : account;
        }
    }
    return mtAccount;
}

// isolated function mx_to_mtFATFIdentification(pacsIsoRecord:Party52Choice? identification) returns string {
//     pacsIsoRecord:GenericOrganisationIdentification3[]? othrId = identification?.OrgId?.Othr;

//     string mtCountryCode = "";
//     string mtSchemeCode = "";
//     string mtIssuer = "";
//     boolean successfulFATF = false;
//     if othrId is pacsIsoRecord:GenericOrganisationIdentification3[] {
//         foreach pacsIsoRecord:GenericOrganisationIdentification3 item in othrId {
//             string mxCode = item.SchmeNm?.Cd ?: "";
//             string mxIssuer = item.Issr ?: "";
//             string mtIdentifier = item.Id ?: "";

//             if mxIssuer.length() == 2 && isValidCountryCode(mxIssuer) {
//                 mtCountryCode = mxIssuer;
//                 mxIssuer = "";
//             } else if mxIssuer.length() > 3 && isValidCountryCode(mxIssuer.substring(0, 2)) && mxIssuer.substring(2, 3) == "/" {
//                 mtCountryCode = mxIssuer.substring(0, 2);
//                 mxIssuer = mxIssuer.substring(3);   
//             }

//             string[] codes = ["GS1G,DUNS"];
//             if codes.indexOf(mxCode) != -1 {
//                 mtSchemeCode = "CUST";
//                 if mxIssuer.length() > 0 {
//                     mtIssuer = mxCode + " " + mxIssuer;
//                 } else {
//                     mtIssuer = mxCode;
//                 }

//                 if mtCountryCode.length() > 0 {
//                     successfulFATF = true;
//                     break;
//                 }
//             } else if mxCode == "TXID" {
//                 mtSchemeCode = mxCode;
//                 mtIssuer = "";
//                 if mtCountryCode.length() > 0 && mtIdentifier != "NOTPROVIDED" {
//                     successfulFATF = true;
//                     break;
//                 }
//             }
//         }

//         if !successfulFATF {
//             foreach pacsIsoRecord:GenericOrganisationIdentification3 item in othrId {
//                 string mxCode = item.SchmeNm?.Cd ?: "";
//                 string mxIssuer = item.Issr ?: "";
//                 string mtIdentifier = item.Id ?: "";

//                 if mxIssuer.length() == 2 && isValidCountryCode(mxIssuer) {
//                     mtCountryCode = mxIssuer;
//                     mxIssuer = "";
//                 } else if mxIssuer.length() > 3 && isValidCountryCode(mxIssuer.substring(0, 2)) && mxIssuer.substring(2, 3) == "/" {
//                     mtCountryCode = mxIssuer.substring(0, 2);
//                     mxIssuer = mxIssuer.substring(3);   
//                 } 

//             }
//         }
        
//     }
// }

// This function determines if the MX address lines conform to the structured format.
isolated function mx_to_mtAddressLineType(pacsIsoRecord:PartyIdentification272? mxParty) returns boolean {

    boolean structuredIndicator = false;

    // Check if AddressLine is present and not empty.
    pacsIsoRecord:Max70Text[]? addressLinesArr = mxParty?.PstlAdr?.AdrLine;
    if addressLinesArr is pacsIsoRecord:Max70Text[] {
        string[] addressLines = [];
        foreach string line in addressLinesArr {
            addressLines.push(line);
        }
        if (addressLines.length() > 0) {
            structuredIndicator = true;

            // Check 1: Each line must start with "2/" or "3/".
            foreach var line in addressLines {
                if (!line.startsWith("2/") && !line.startsWith("3/")) {
                    structuredIndicator = false;
                    return structuredIndicator;
                }
            }

            // Check 2: "2/" cannot follow "3/".
            boolean found3 = false;
            foreach var line in addressLines {
                if (line.startsWith("3/")) {
                    found3 = true;
                } else if (line.startsWith("2/") && found3) {
                    structuredIndicator = false;
                    return structuredIndicator;
                }
            }

            // Check 3: At least one "3/" line is mandatory and must contain a valid country code.
            boolean has3Line = false;
            foreach var line in addressLines {
                if (line.startsWith("3/")) {
                    has3Line = true;
                    // Check if the country code is valid. Ballerina string starts with index 0.
                    // Substring(..., 3, 2) in the formal description is equivalent to line.substring(2, 4) in Ballerina.
                    if (line.length() >= 4) {
                        string countryCode = line.substring(2, 4);
                        if (!isValidCountryCode(countryCode)) {
                            structuredIndicator = false;
                            return structuredIndicator;
                        }
                    } else {
                        // The line is too short to contain a country code.
                        structuredIndicator = false;
                        return structuredIndicator;
                    }
                    // The formal description exits after the first "3/" is found and checked.
                    break;
                }
            }

            if (!has3Line) {
                // If no line starting with "3/" is found, it's not a structured address.
                structuredIndicator = false;
                return structuredIndicator;
            }

            // Check 4: Max 2 lines with "2/".
            int count2 = 0;
            foreach var line in addressLines {
                if (line.startsWith("2/")) {
                    count2 += 1;
                }
            }
            if (count2 > 2) {
                structuredIndicator = false;
                return structuredIndicator;
            }

            // Check 5: Max 2 lines with "3/".
            int count3 = 0;
            foreach var line in addressLines {
                if (line.startsWith("3/")) {
                    count3 += 1;
                }
            }
            if (count3 > 2) {
                structuredIndicator = false;
                return structuredIndicator;
            }
        }
    } else {
        // If address line is not an array of strings or is absent
        structuredIndicator = false;
    }

    return structuredIndicator;
}

isolated function isValidCountryCode(string countryCode) returns boolean {
    return COUNTRY_CODES.hasKey(countryCode.toUpperAscii());
}


// public function MX_To_MT72FullField(
//     pacsIsoRecord:BranchAndFinancialInstitutionIdentification8[] mxIntermediaryAgent,
//     pacsIsoRecord:BranchAndFinancialInstitutionIdentification8[] mxPreviousInstructingAgent,
//     pacsIsoRecord:InstructionForCreditorAgent3[] instructionForCreditorAgent,
//     string? instructionForNextAgent,
//     string? categoryPurpose,
//     string? serviceLevel,
//     string? localInstrument,
//     pacsIsoRecord:BranchAndFinancialInstitutionIdentification8 mxCreditorAgent) returns string[] {

//     string[] mt72 = [];
//     boolean flagMissingInformation = false;

//     // Priority 1: IntermediaryAgent2,3 (/INTA/)
//     foreach pacsIsoRecord:BranchAndFinancialInstitutionIdentification8 agent in mxIntermediaryAgent {
//         // Mocking the agent conversion logic
//         string? agentIdentifier = agent.FinInstnId.BICFI ?: agent.BrnchId?.Id;
//         if (agentIdentifier is string) {
//             string formattedAgent = "/INTA/" + agentIdentifier;
//             mt72 = appendComplexMT72(returnFirstLineEmpty(mt72, 6), formattedAgent, mt72);
//         }
//     }

//     // Priority 2: PaymentTypeInformation/ServiceLevel (/SVCLVL/)
//     if (serviceLevel is string) {
//         PaymentTypeInformation paymentType = {
//             serviceLevel: serviceLevel,
//             localInstrument: localInstrument,
//             categoryPurpose: categoryPurpose
//         };
//         mt72 = [...mt72, ...subfunctionServiceLevel2(paymentType)];
//     }

//     // Priority 3: PaymentTypeInformation/LocalInstrument (/LOCINS/)
//     if (localInstrument is string) {
//         // Excluded codes: CRED, CRTS, SPAY, SPRI, SSTD
//         if (localInstrument != "CRED" && localInstrument != "CRTS" && 
//             localInstrument != "SPAY" && localInstrument != "SPRI" && localInstrument != "SSTD") {
//             string formattedLocalInstrument = "/LOCINS/" + localInstrument;
//             mt72 = appendComplexMT72(returnFirstLineEmpty(mt72, 6), formattedLocalInstrument, mt72);
//         }
//     }

//     // Priority 4: PaymentTypeInformation/CategoryPurpose (/CATPURP/)
//     if (categoryPurpose is string) {
//         if (categoryPurpose != "INTC" && categoryPurpose != "CORT") {
//             string formattedCategoryPurpose = "/CATPURP/" + categoryPurpose;
//             mt72 = appendComplexMT72(returnFirstLineEmpty(mt72, 6), formattedCategoryPurpose, mt72);
//         }
//     }

//     // Priority 5: InstructionForCreditorAgent and Japan-specific rule
//     if (instructionForCreditorAgent.length() > 0 || mxCreditorAgent.BrnchId?.Id is string) {
//         mt72 = [...mt72, ...subfunctionInstructionforCreditorAgentAndJP(instructionForCreditorAgent, mxCreditorAgent)];
//     }

//     // Priority 6: InstructionForNextAgent
//     if (instructionForNextAgent is string) {
//         if (!instructionForNextAgent.startsWith("/FIN53/")) {
//             // Simplified logic as the subfunction is not provided
//             string formattedInstruction = "/REC/" + instructionForNextAgent;
//             mt72 = appendComplexMT72(returnFirstLineEmpty(mt72, 6), formattedInstruction, mt72);
//         }
//     }
    
//     // Priority 7: PreviousInstructingAgent
//     foreach var agent in mxPreviousInstructingAgent {
//         string? agentIdentifier = agent.FinInstnId.BICFI ?: agent.BrnchId?.Id;
//         if (agentIdentifier is string) {
//             string formattedAgent = "/INS/" + agentIdentifier;
//             mt72 = appendComplexMT72(returnFirstLineEmpty(mt72, 6), formattedAgent, mt72);
//         }
//     }

//     // Check for any missing information here if needed, based on the flag.
//     // The formal description indicates this should be handled inside the subfunctions.
    
//     return mt72;
// }

// function appendComplexMT72(int numberOfEmptyLines, string content, string[] mt72) returns string[] {
//     int maxLineLength = 35;
//     string[] newLines = [];
//     string remainingContent = content;

//     while (remainingContent.length() > 0 && newLines.length() < numberOfEmptyLines) {
//         string currentLine = remainingContent.substring(0, int:min(remainingContent.length(), maxLineLength));
//         remainingContent = remainingContent.substring(int:min(remainingContent.length(), maxLineLength));

//         if (remainingContent.length() > 0) {
//             currentLine = currentLine + "+";
//         }
//         newLines.push(currentLine);
//     }
    
//     return [...mt72, ...newLines];
// }


// // Subfunction for handling InstructionForCreditorAgent and Japan-specific rules
// function subfunctionInstructionforCreditorAgentAndJP(
//     pacsIsoRecord:InstructionForCreditorAgent3[] instructionForCreditorAgent,
//     pacsIsoRecord:BranchAndFinancialInstitutionIdentification8 mxCreditorAgent) returns string[] {
    
//     string? mxJPInstruction = "";
//     string? mtInstruction = "";
//     string[] mt72 = [];
//     string[] codeTable = ["/HOLD/", "/CHQB/", "/PHOB/", "/TELB/", "/TempAcc/"];
    
//     boolean isJPDomestic = false;
//     if (mxCreditorAgent.BrnchId?.Id is string) {
//         if ((mxCreditorAgent.FinInstnId.BICFI is string && mxCreditorAgent.FinInstnId.BICFI.toString().substring(4, 6) == "JP") ||
//             (mxCreditorAgent.FinInstnId.PstlAdr?.Ctry is string && mxCreditorAgent.FinInstnId.PstlAdr?.Ctry == "JP")) {
//                 isJPDomestic = true;
//         }
//     }

//     if (isJPDomestic && mxCreditorAgent.BrnchId?.Id is string) {
//         mxJPInstruction = mxCreditorAgent.BrnchId?.Id;
//     }

//     string[] accTable = [];
//     if (instructionForCreditorAgent.length() == 2 && instructionForCreditorAgent[0].code is () && instructionForCreditorAgent[1].code is ()) {
//         accTable = subfunctionAnalyse2OccurrencesNoCode(instructionForCreditorAgent[0], instructionForCreditorAgent[1], codeTable);
//     } else {
//         accTable = subfunctionAnalysePer1Occurrence(instructionForCreditorAgent, codeTable);
//     }

//     string mxInstruction = "";
//     if (accTable.length() > 0) {
//         mxInstruction = accTable[0];
//         foreach int m in 1..accTable.length()-1 {
//             mxInstruction = mxInstruction + " " + accTable[m];
//         }
//     }

//     if (mxInstruction.length() > 0) {
//         if (mxJPInstruction.length() > 0) {
//             mxInstruction = mxJPInstruction + " " + mxInstruction;
//         }
//     } else if (mxJPInstruction.length() > 0) {
//         mxInstruction = mxJPInstruction;
//     }

//     if (mxInstruction.length() > 0) {
//         mtInstruction = "/ACC/" + mxInstruction;
//         // Append to MT72 field
//         mt72 = appendComplexMT72(6, mtInstruction, mt72);
//     }

//     return mt72;
// }
