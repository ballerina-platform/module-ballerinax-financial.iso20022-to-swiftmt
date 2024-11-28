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

import ballerinax/financial.iso20022.payments_clearing_and_settlement as SwiftMxRecords;
import ballerinax/financial.swift.mt as swiftmt;

# Get the ordering customer from the Pacs008 document.
#
# + document - The Pacs008 document
# + return - The ordering customer or null record
isolated function getMT103OrderingCustomerFromPacs008Document(
        SwiftMxRecords:Pacs008Document document
) returns swiftmt:MT50A?|swiftmt:MT50F?|swiftmt:MT50K? {

    SwiftMxRecords:PartyIdentification272? debtor = document.FIToFICstmrCdtTrf.CdtTrfTxInf[0].Dbtr;
    SwiftMxRecords:CashAccount40? debtorAccount = document.FIToFICstmrCdtTrf.CdtTrfTxInf[0].DbtrAcct;

    if debtor is () {
        return ();
    }

    // MT50A: Ordering Customer with BIC
    if debtor.Id?.OrgId?.AnyBIC != () {
        string partyIdentifier = getEmptyStrIfNull(debtor.Id?.OrgId?.AnyBIC);

        if debtorAccount?.Id != () {
            return <swiftmt:MT50A>{
                name: "50A",
                IdnCd: {
                    content: partyIdentifier,
                    number: "1"
                },
                Acc: {
                    content: getEmptyStrIfNull(debtorAccount?.Id),
                    number: "2"
                }
            };
        }

        return <swiftmt:MT50A>{
            name: "50A",
            IdnCd: {
                content: partyIdentifier,
                number: "1"
            }
        };
    }

    // MT50F: Ordering Customer with FATF Name and Address
    if debtor.PstlAdr?.Ctry != () {
        string partyIdentifier = debtorAccount?.Id != ()
            ? getEmptyStrIfNull(debtorAccount?.Id)
            : "/NOTPROVIDED";

        return <swiftmt:MT50F>{
            name: "50F",
            PrtyIdn: {
                content: partyIdentifier,
                number: "1"
            },
            Nm: getNamesArrayFromNameString(getEmptyStrIfNull(debtor.Nm)),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>debtor.PstlAdr?.AdrLine),
            CntyNTw: [
                {
                    content: getEmptyStrIfNull(debtor.PstlAdr?.Ctry),
                    number: "3"
                }
            ]
        };
    }

    // Handle Structured vs Unstructured Address
    if debtor.PstlAdr?.AdrLine != () && debtor.PstlAdr?.AdrLine != ["NOTPROVIDED"] {
        boolean isStructured = (<string[]>debtor.PstlAdr?.AdrLine).length() > 0;

        if isStructured {
            string partyIdentifier = debtorAccount?.Id != ()
                ? getEmptyStrIfNull(debtorAccount?.Id)
                : "/NOTPROVIDED";

            return <swiftmt:MT50F>{
                name: "50F",
                PrtyIdn: {
                    content: partyIdentifier,
                    number: "1"
                },
                Nm: getNamesArrayFromNameString(getEmptyStrIfNull(debtor.Nm)),
                AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>debtor.PstlAdr?.AdrLine),
                CntyNTw: [
                    {
                        content: getEmptyStrIfNull(debtor.PstlAdr?.Ctry),
                        number: "3"
                    }
                ]
            };
        } else {
            // Unstructured Address Mapping to 50K
            return <swiftmt:MT50K>{
                name: "50K",
                Nm: getNamesArrayFromNameString(getEmptyStrIfNull(debtor.Nm)),
                AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>debtor.PstlAdr?.AdrLine)
            };
        }
    }

    // MT50K: If Name is present without Postal Address
    if debtor.Nm != () {
        // Use FATFNameAndAddress for 50F
        string partyIdentifier = debtorAccount?.Id != ()
            ? getEmptyStrIfNull(debtorAccount?.Id)
            : "/NOTPROVIDED";

        return <swiftmt:MT50F>{
            name: "50F",
            PrtyIdn: {
                content: partyIdentifier,
                number: "1"
            },
            Nm: getNamesArrayFromNameString(getEmptyStrIfNull(debtor.Nm)),
            AdrsLine: [],
            CntyNTw: [
                {
                    content: "/NOTPROVIDED",
                    number: "3"
                }
            ]
        };
    }

    return ();
}

# Get the ordering institution from the Pacs008 document.
#
# + document - The Pacs008 document
# + isSTP - A flag to indicate if the message is STP
# + return - The ordering institution or null record
isolated function getMT103OrderingInstitutionFromPacs008Document(
        SwiftMxRecords:Pacs008Document document,
        boolean isSTP
) returns swiftmt:MT52A?|swiftmt:MT52D? {

    SwiftMxRecords:BranchAndFinancialInstitutionIdentification8? debtorAgent =
        document.FIToFICstmrCdtTrf.CdtTrfTxInf[0].DbtrAgt;
    SwiftMxRecords:CashAccount40? debtorAgentAccount =
        document.FIToFICstmrCdtTrf.CdtTrfTxInf[0].DbtrAgtAcct;
    SwiftMxRecords:ClearingChannel2Code? clearingChannel =
        document.FIToFICstmrCdtTrf.CdtTrfTxInf[0]?.PmtTpInf?.ClrChanl;

    if debtorAgent is () {
        return ();
    }

    // MT52A: If BIC is present in Debtor Agent
    if debtorAgent.FinInstnId?.BICFI != () {
        string bic = getClearingPrefix(clearingChannel) + getEmptyStrIfNull(debtorAgent.FinInstnId.BICFI);

        // If Debtor Agent Account is present, add account details
        if debtorAgentAccount?.Id != () {
            return <swiftmt:MT52A>{
                name: "52A",
                IdnCd: {
                    content: bic,
                    number: "1"
                }
            };
        }

        // Without Debtor Agent Account
        return <swiftmt:MT52A>{
            name: "52A",
            IdnCd: {
                content: bic,
                number: "1"
            }
        };
    }

    // MT52D: If no BIC, use Name and Address
    if debtorAgent.FinInstnId?.PstlAdr != () {
        // Structured Address Handling
        boolean isStructured = (<string[]>debtorAgent.FinInstnId.PstlAdr?.AdrLine).length() > 0;

        if isStructured {
            return <swiftmt:MT52D>{
                name: "52D",
                Nm: getNamesArrayFromNameString(getEmptyStrIfNull(debtorAgent.FinInstnId.Nm)),
                AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>debtorAgent.FinInstnId.PstlAdr?.AdrLine)
            };
        } else {
            // Unstructured Address
            return <swiftmt:MT52D>{
                name: "52D",
                Nm: getNamesArrayFromNameString(getEmptyStrIfNull(debtorAgent.FinInstnId.Nm)),
                AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>debtorAgent.FinInstnId.PstlAdr?.AdrLine)
            };
        }
    }

    // If no structured address or BIC, fallback to general Name and Address
    if debtorAgent.FinInstnId?.Nm != () {
        return <swiftmt:MT52D>{
            name: "52D",
            Nm: getNamesArrayFromNameString(getEmptyStrIfNull(debtorAgent.FinInstnId.Nm)),
            AdrsLine: []
        };
    }

    return ();
}

# Get the senders correspondent from the Pacs008 document.
#
# + document - The Pacs008 document
# + return - The senders correspondent or null record
isolated function getMT103SendersCorrespondentFromPacs008Document(
        SwiftMxRecords:Pacs008Document document
) returns swiftmt:MT53A?|swiftmt:MT53B?|swiftmt:MT53D? {

    // Extract required fields from Pacs008Document
    SwiftMxRecords:BranchAndFinancialInstitutionIdentification8? PrvsInstgAgt1 =
        document.FIToFICstmrCdtTrf.CdtTrfTxInf[0]?.PrvsInstgAgt1;
    SwiftMxRecords:SettlementInstruction15? sttlmInf = document.FIToFICstmrCdtTrf.GrpHdr.SttlmInf;

    // Return empty if PrvsInstgAgt1 is not present
    if PrvsInstgAgt1 is () {
        return ();
    }

    // Extract BICFI values for comparison
    string? fromBIC = document.FIToFICstmrCdtTrf.GrpHdr.InstgAgt?.FinInstnId?.BICFI;
    string? toBIC = document.FIToFICstmrCdtTrf.GrpHdr.InstdAgt?.FinInstnId?.BICFI;

    // MT53A: Map if SettlementMethod is "INGA" or "INDA" and SettlementAccount is absent
    if (sttlmInf?.SttlmMtd == "INGA" || sttlmInf?.SttlmMtd == "INDA") && sttlmInf?.SttlmAcct is () {
        string mt53BIC = getEmptyStrIfNull(PrvsInstgAgt1.FinInstnId?.BICFI);

        if mt53BIC != "" && fromBIC is string && toBIC is string &&
            (mt53BIC.substring(0, 6) == fromBIC.substring(0, 6) ||
            mt53BIC.substring(0, 6) == toBIC.substring(0, 6)) {
            return <swiftmt:MT53A>{
                name: "53A",
                IdnCd: {
                    content: mt53BIC,
                    number: "1"
                }
            };
        }
    }

    // MT53B: Map if location name is available without address
    if PrvsInstgAgt1.FinInstnId?.Nm != () && PrvsInstgAgt1.FinInstnId?.PstlAdr == () {
        return <swiftmt:MT53B>{
            name: "53B",
            Lctn: {
                content: getEmptyStrIfNull(PrvsInstgAgt1.FinInstnId?.Nm),
                number: "1"
            }
        };
    }

    // MT53D: Map if name and address details are available
    if PrvsInstgAgt1.FinInstnId?.PstlAdr != () {
        return <swiftmt:MT53D>{
            name: "53D",
            Nm: getNamesArrayFromNameString(getEmptyStrIfNull(PrvsInstgAgt1.FinInstnId?.Nm)),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>PrvsInstgAgt1.FinInstnId?.PstlAdr?.AdrLine)
        };
    }

    // Return empty if no valid format is matched
    return ();
}

# Get the receivers correspondent from the Pacs008 document.
#
# + document - The Pacs008 document
# + isSTP - A flag to indicate if the message is STP
# + return - The receivers correspondent or null record
isolated function getMT103ReceiversCorrespondentFromPacs008Document(SwiftMxRecords:Pacs008Document document, boolean isSTP)
returns swiftmt:MT54A?|swiftmt:MT54B?|swiftmt:MT54D? {

    // Extract necessary fields from the Pacs008Document
    SwiftMxRecords:BranchAndFinancialInstitutionIdentification8? InstdRmbrsmntAgt = document.FIToFICstmrCdtTrf.GrpHdr.SttlmInf.InstdRmbrsmntAgt;
    SwiftMxRecords:CashAccount40? InstdRmbrsmntAgtAcct = document.FIToFICstmrCdtTrf.GrpHdr.SttlmInf.InstdRmbrsmntAgtAcct;

    // Return empty if InstdRmbrsmntAgt is not present
    if InstdRmbrsmntAgt is () {
        return ();
    }

    // MT54A: If BIC (Identifier Code) is available
    if InstdRmbrsmntAgt.FinInstnId?.BICFI != () {
        return <swiftmt:MT54A>{
            name: "54A",
            PrtyIdnTyp: {
                content: getEmptyStrIfNull(InstdRmbrsmntAgtAcct?.Id?.Othr?.SchmeNm?.Cd),
                number: "1"
            },
            PrtyIdn: {
                content: getEmptyStrIfNull(InstdRmbrsmntAgtAcct?.Id?.IBAN),
                number: "1"
            },
            IdnCd: {
                content: getEmptyStrIfNull(InstdRmbrsmntAgt.FinInstnId?.BICFI),
                number: "1"
            }
        };
    }

    // MT54B: If only location (Lctn) is available without address details
    if InstdRmbrsmntAgt.FinInstnId?.Nm != () && InstdRmbrsmntAgt.FinInstnId?.PstlAdr == () {
        return <swiftmt:MT54B>{
            name: "54B",
            PrtyIdnTyp: (()),
            PrtyIdn: (()),
            Lctn: {
                content: getEmptyStrIfNull(InstdRmbrsmntAgt.FinInstnId?.Nm),
                number: "1"
            }
        };
    }

    // MT54D: If Name and Address are available
    if InstdRmbrsmntAgt.FinInstnId?.PstlAdr != () {
        return <swiftmt:MT54D>{
            name: "54D",
            PrtyIdnTyp: (()),
            PrtyIdn: (()),
            Nm: getNamesArrayFromNameString(getEmptyStrIfNull(InstdRmbrsmntAgt.FinInstnId?.Nm)),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>InstdRmbrsmntAgt.FinInstnId?.PstlAdr?.AdrLine)
        };
    }

    return ();
}

# Get the third reimbursement institution from the Pacs008 document.
#
# + document - The Pacs008 document
# + isSTP - A flag to indicate if the message is STP
# + return - The third reimbursement institution or null record
isolated function getMT103ThirdReimbursementInstitutionFromPacs008Document(SwiftMxRecords:Pacs008Document document, boolean isSTP)
returns swiftmt:MT55A?|swiftmt:MT55B?|swiftmt:MT55D? {

    // Extract Third Reimbursement Agent and Account information
    SwiftMxRecords:BranchAndFinancialInstitutionIdentification8? ThirdRmbrsmntAgt =
        document.FIToFICstmrCdtTrf.GrpHdr.SttlmInf?.ThrdRmbrsmntAgt;
    SwiftMxRecords:CashAccount40? ThirdRmbrsmntAgtAcct =
        document.FIToFICstmrCdtTrf.GrpHdr.SttlmInf.ThrdRmbrsmntAgtAcct;

    // Return empty if ThirdRmbrsmntAgt is not present
    if ThirdRmbrsmntAgt is () {
        return ();
    }

    // MT55A format: If BIC (Identifier Code) is available
    if ThirdRmbrsmntAgt.FinInstnId?.BICFI != () {
        return <swiftmt:MT55A>{
            name: "55A",
            PrtyIdnTyp: {
                content: getEmptyStrIfNull(ThirdRmbrsmntAgtAcct?.Id?.Othr?.SchmeNm?.Cd),
                number: "1"
            },
            PrtyIdn: {
                content: getEmptyStrIfNull(ThirdRmbrsmntAgtAcct?.Id?.IBAN),
                number: "1"
            },
            IdnCd: {
                content: getEmptyStrIfNull(ThirdRmbrsmntAgt.FinInstnId?.BICFI),
                number: "1"
            }
        };
    }

    // MT55B format: If only location (Lctn) is available without address details
    if ThirdRmbrsmntAgt.FinInstnId?.Nm != () && ThirdRmbrsmntAgt.FinInstnId?.PstlAdr == () {
        return <swiftmt:MT55B>{
            name: "55B",
            PrtyIdnTyp: (),
            PrtyIdn: (),
            Lctn: {
                content: getEmptyStrIfNull(ThirdRmbrsmntAgt.FinInstnId?.Nm),
                number: "1"
            }
        };
    }

    // MT55D format: If Name and Address are available
    if ThirdRmbrsmntAgt.FinInstnId?.PstlAdr != () {
        return <swiftmt:MT55D>{
            name: "55D",
            PrtyIdnTyp: (),
            PrtyIdn: (),
            Nm: getNamesArrayFromNameString(getEmptyStrIfNull(ThirdRmbrsmntAgt.FinInstnId?.Nm)),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>ThirdRmbrsmntAgt.FinInstnId?.PstlAdr?.AdrLine)
        };
    }

    return ();
}

# Get the account with institution from the Pacs008 document.
#
# + document - The Pacs008 document
# + isSTP - A flag to indicate if the message is STP
# + return - The account with institution or null record
isolated function getMT103AccountWithInstitutionFromPacs008Document(
        SwiftMxRecords:Pacs008Document document, boolean isSTP
) returns swiftmt:MT57A?|swiftmt:MT57B?|swiftmt:MT57C?|swiftmt:MT57D? {

    SwiftMxRecords:BranchAndFinancialInstitutionIdentification8? creditorAgent =
        document.FIToFICstmrCdtTrf.CdtTrfTxInf[0]?.CdtrAgt;

    if creditorAgent is () {
        return ();
    }

    // MT57A: BICFI (Identifier Code) present in CreditorAgent
    if creditorAgent.FinInstnId?.BICFI != () {
        string bicfi = getEmptyStrIfNull(creditorAgent.FinInstnId?.BICFI);

        return <swiftmt:MT57A>{
            name: "57A",
            IdnCd: {
                content: bicfi,
                number: "1"
            }
        };
    }

    // MT57B: Location (Name) is present but no address details
    if creditorAgent.FinInstnId?.Nm != () && creditorAgent.FinInstnId?.PstlAdr == () {
        return <swiftmt:MT57B>{
            name: "57B",
            Lctn: {
                content: getEmptyStrIfNull(creditorAgent.FinInstnId?.Nm),
                number: "1"
            }
        };
    }

    // MT57C: Party Identifier (Other ID) is available
    if creditorAgent.FinInstnId?.Othr?.Id != () {
        return <swiftmt:MT57C>{
            name: "57C",
            PrtyIdn: {
                content: getEmptyStrIfNull(creditorAgent.FinInstnId?.Othr?.Id),
                number: "1"
            }
        };
    }

    // MT57D: Name and Address are present
    if creditorAgent.FinInstnId?.PstlAdr != () {
        return <swiftmt:MT57D>{
            name: "57D",
            Nm: getNamesArrayFromNameString(getEmptyStrIfNull(creditorAgent.FinInstnId?.Nm)),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>creditorAgent.FinInstnId?.PstlAdr?.AdrLine)
        };
    }

    return ();
}

// Helper function to determine if "//RT" prefix is needed
isolated function getClearingPrefix(SwiftMxRecords:ClearingChannel2Code? clearingChannel) returns string {
    if clearingChannel is SwiftMxRecords:ClearingChannel2Code && clearingChannel == "RTGS" {
        return "//RT";
    }
    return "";
}

# Get the intermediary institution from the Pacs008 document.
#
# + document - The Pacs008 document
# + isSTP - A flag to indicate if the message is STP
# + return - The intermediary institution or null record
isolated function getMT103IntermediaryInstitutionFromPacs008Document(
        SwiftMxRecords:Pacs008Document document,
        boolean isSTP
) returns swiftmt:MT56A?|swiftmt:MT56C?|swiftmt:MT56D? {

    // Extract intermediary agent details
    SwiftMxRecords:BranchAndFinancialInstitutionIdentification8? intrmyAgt = document.FIToFICstmrCdtTrf.CdtTrfTxInf[0]?.IntrmyAgt1;
    SwiftMxRecords:CashAccount40? intrmyAgtAccount = document.FIToFICstmrCdtTrf.CdtTrfTxInf[0]?.IntrmyAgt1Acct;
    SwiftMxRecords:ClearingChannel2Code? clearingChannel = document.FIToFICstmrCdtTrf.CdtTrfTxInf[0]?.PmtTpInf?.ClrChanl;

    if intrmyAgt is () {
        return ();
    }

    // MT56A: Use this if the intermediary institution's BIC (Identifier Code) is available
    if intrmyAgt.FinInstnId?.BICFI != () {
        string identifier = getClearingPrefix(clearingChannel) + getEmptyStrIfNull(intrmyAgt.FinInstnId.BICFI);

        // Include account information if available
        if intrmyAgtAccount?.Id != () {
            return <swiftmt:MT56A>{
                name: "56A",
                IdnCd: {
                    content: identifier,
                    number: "1"
                }
            };
        }

        // Without account information
        return <swiftmt:MT56A>{
            name: "56A",
            IdnCd: {
                content: identifier,
                number: "1"
            }
        };
    }

    // MT56C: Use this if the Clearing System Member ID is available
    if intrmyAgt.FinInstnId?.ClrSysMmbId?.MmbId != () {
        string identifier = getClearingPrefix(clearingChannel) + getEmptyStrIfNull(intrmyAgt.FinInstnId?.ClrSysMmbId?.MmbId);

        return <swiftmt:MT56C>{
            name: "56C",
            PrtyIdn: {
                content: identifier,
                number: "1"
            }
        };
    }

    // MT56D: Use this if "Other" identification (like local codes) is available, with name and address
    if intrmyAgt.FinInstnId?.Othr?.Id != () {
        return <swiftmt:MT56D>{
            name: "56D",
            PrtyIdn: {
                content: getEmptyStrIfNull(intrmyAgt.FinInstnId.Othr?.Id),
                number: "1"
            },
            Nm: getNamesArrayFromNameString(getEmptyStrIfNull(intrmyAgt.FinInstnId.Nm)),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>intrmyAgt.FinInstnId.PstlAdr?.AdrLine)
        };
    }

    // Fallback: No valid mapping
    return ();
}

# Get the beneficiary customer from the Pacs008 document.
#
# + document - The Pacs008 document
# + return - The beneficiary customer or null record
isolated function getMT103BeneficiaryCustomerFromPacs008Document(
        SwiftMxRecords:Pacs008Document document
) returns swiftmt:MT59?|swiftmt:MT59A?|swiftmt:MT59F? {
    SwiftMxRecords:PartyIdentification272? creditor =
        document.FIToFICstmrCdtTrf.CdtTrfTxInf[0]?.Cdtr;
    SwiftMxRecords:CashAccount40? creditorAccount =
        document.FIToFICstmrCdtTrf.CdtTrfTxInf[0]?.CdtrAcct;

    if creditor is () {
        return ();
    }

    // MT59A: Use if the creditor's BIC (AnyBIC) is available.
    if creditor.Id?.OrgId?.AnyBIC != () {
        string anyBIC = getEmptyStrIfNull(creditor.Id?.OrgId?.AnyBIC);

        // Include account information if available
        if creditorAccount?.Id != () {
            return <swiftmt:MT59A>{
                name: "59A",
                IdnCd: {
                    content: anyBIC,
                    number: "1"
                },
                Acc: {
                    content: getEmptyStrIfNull(creditorAccount?.Id),
                    number: "2"
                }
            };
        }

        // Without account information
        return <swiftmt:MT59A>{
            name: "59A",
            IdnCd: {
                content: anyBIC,
                number: "1"
            }
        };
    }

    // MT59F: Use if structured name, address, or country fields are available.
    if creditor.PstlAdr?.Ctry != () || creditor.PstlAdr?.AdrLine != () {
        boolean structuredAddressIndicator = isStructuredAddress(creditor);

        if structuredAddressIndicator {
            // MT59F with structured name and address
            string partyIdentifier = creditorAccount?.Id != ()
                ? getEmptyStrIfNull(creditorAccount?.Id)
                : "/NOTPROVIDED";

            return <swiftmt:MT59F>{
                name: "59F",
                Acc: {
                    content: partyIdentifier,
                    number: "1"
                },
                CdTyp: [], // Include code types as required
                Nm: [
                    {
                        content: getEmptyStrIfNull(creditor.Nm),
                        number: "2"
                    }
                ],
                AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>creditor.PstlAdr?.AdrLine),
                CntyNTw: getMtCountryAndTownFromMxCountryAndTown(
                        getEmptyStrIfNull(creditor.PstlAdr?.Ctry),
                        getEmptyStrIfNull(creditor.PstlAdr?.TwnNm)
                )
            };
        } else {
            // MT59 without a structured address
            return <swiftmt:MT59>{
                name: "59",
                Nm: getNamesArrayFromNameString(getEmptyStrIfNull(creditor.Nm)),
                AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>creditor.PstlAdr?.AdrLine)
            };
        }
    }

    // If only Name is present
    if creditor.Nm != () {
        return <swiftmt:MT59>{
            name: "59",
            Nm: getNamesArrayFromNameString(getEmptyStrIfNull(creditor.Nm)),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>creditor.PstlAdr?.AdrLine)
        };
    }

    return ();
}

isolated function mapCategoryPurposeToMT23E(
        SwiftMxRecords:CategoryPurpose1Choice? categoryPurpose
) returns swiftmt:MT23E[] {
    swiftmt:MT23E[] instructionCodes = [];

    // Validate if CategoryPurpose is present
    if categoryPurpose is () {
        return instructionCodes;
    }

    // Handle the `Code` field in CategoryPurpose
    if categoryPurpose?.Cd is string {
        string code = categoryPurpose.Cd.toString();

        // Check for specific codes that need to be mapped
        if code == "CHQB" || code == "HOLD" || code == "PHOB" || code == "TELB" {
            instructionCodes.push({
                name: "23E",
                InstrnCd: {
                    content: code,
                    number: instructionCodes.length().toString()
                }
            });
        }
    }

    // Handle the `Proprietary` field in CategoryPurpose
    if categoryPurpose?.Prtry is string {
        string proprietary = categoryPurpose.Prtry.toString();

        // If the proprietary field contains specific instruction codes
        if proprietary.includes("CHQB") {
            instructionCodes.push({
                name: "23E",
                InstrnCd: {
                    content: "CHQB",
                    number: instructionCodes.length().toString()
                }
            });
        }
        if proprietary.includes("HOLD") {
            instructionCodes.push({
                name: "23E",
                InstrnCd: {
                    content: "HOLD",
                    number: instructionCodes.length().toString()
                }
            });
        }
        if proprietary.includes("PHOB") {
            instructionCodes.push({
                name: "23E",
                InstrnCd: {
                    content: "PHOB",
                    number: instructionCodes.length().toString()
                }
            });
        }
        if proprietary.includes("TELB") {
            instructionCodes.push({
                name: "23E",
                InstrnCd: {
                    content: "TELB",
                    number: instructionCodes.length().toString()
                }
            });
        }
    }

    return instructionCodes;
}

