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


# The function checks if the address lines in the MX PartyIdentification are structured according to MT standards.
#
# + mxParty - The MX PartyIdentification to check
# + return - true if the address lines are structured according to MT standards, false otherwise
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
