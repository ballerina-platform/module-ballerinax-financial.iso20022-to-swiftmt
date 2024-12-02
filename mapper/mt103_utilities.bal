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
isolated function getOrderingCustomerFromPacs008Document(
        SwiftMxRecords:Pacs008Document document
) returns swiftmt:MT50A?|swiftmt:MT50F?|swiftmt:MT50K? {
    SwiftMxRecords:PartyIdentification272? debtor = document.FIToFICstmrCdtTrf.CdtTrfTxInf[0].Dbtr;
    SwiftMxRecords:CashAccount40? debtorAccount = document.FIToFICstmrCdtTrf.CdtTrfTxInf[0].DbtrAcct;

    if debtor is () {
        return ();
    }

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
            return <swiftmt:MT50K>{
                name: "50K",
                Nm: getNamesArrayFromNameString(getEmptyStrIfNull(debtor.Nm)),
                AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>debtor.PstlAdr?.AdrLine)
            };
        }
    }

    if debtor.Nm != () {
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

    if debtorAgent.FinInstnId?.BICFI != () {
        string bic = getClearingPrefix(clearingChannel) + getEmptyStrIfNull(debtorAgent.FinInstnId.BICFI);

        if debtorAgentAccount?.Id != () {
            return <swiftmt:MT52A>{
                name: "52A",
                IdnCd: {
                    content: bic,
                    number: "1"
                }
            };
        }

        return <swiftmt:MT52A>{
            name: "52A",
            IdnCd: {
                content: bic,
                number: "1"
            }
        };
    }
    if debtorAgent.FinInstnId?.PstlAdr != () {
        boolean isStructured = (<string[]>debtorAgent.FinInstnId.PstlAdr?.AdrLine).length() > 0;

        if isStructured {
            return <swiftmt:MT52D>{
                name: "52D",
                Nm: getNamesArrayFromNameString(getEmptyStrIfNull(debtorAgent.FinInstnId.Nm)),
                AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>debtorAgent.FinInstnId.PstlAdr?.AdrLine)
            };
        } else {
            return <swiftmt:MT52D>{
                name: "52D",
                Nm: getNamesArrayFromNameString(getEmptyStrIfNull(debtorAgent.FinInstnId.Nm)),
                AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>debtorAgent.FinInstnId.PstlAdr?.AdrLine)
            };
        }
    }
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
    SwiftMxRecords:BranchAndFinancialInstitutionIdentification8? PrvsInstgAgt1 =
        document.FIToFICstmrCdtTrf.CdtTrfTxInf[0]?.PrvsInstgAgt1;
    SwiftMxRecords:SettlementInstruction15? sttlmInf = document.FIToFICstmrCdtTrf.GrpHdr.SttlmInf;

    if PrvsInstgAgt1 is () {
        return ();
    }

    string? fromBIC = document.FIToFICstmrCdtTrf.GrpHdr.InstgAgt?.FinInstnId?.BICFI;
    string? toBIC = document.FIToFICstmrCdtTrf.GrpHdr.InstdAgt?.FinInstnId?.BICFI;

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
    if PrvsInstgAgt1.FinInstnId?.Nm != () && PrvsInstgAgt1.FinInstnId?.PstlAdr == () {
        return <swiftmt:MT53B>{
            name: "53B",
            Lctn: {
                content: getEmptyStrIfNull(PrvsInstgAgt1.FinInstnId?.Nm),
                number: "1"
            }
        };
    }
    if PrvsInstgAgt1.FinInstnId?.PstlAdr != () {
        return <swiftmt:MT53D>{
            name: "53D",
            Nm: getNamesArrayFromNameString(getEmptyStrIfNull(PrvsInstgAgt1.FinInstnId?.Nm)),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>PrvsInstgAgt1.FinInstnId?.PstlAdr?.AdrLine)
        };
    }

    return ();
}

# Get the receivers correspondent from the Pacs008 document.
#
# + document - The Pacs008 document
# + isSTP - A flag to indicate if the message is STP
# + return - The receivers correspondent or null record
isolated function getMT103ReceiversCorrespondentFromPacs008Document(SwiftMxRecords:Pacs008Document document, boolean isSTP)
returns swiftmt:MT54A?|swiftmt:MT54B?|swiftmt:MT54D? {
    SwiftMxRecords:BranchAndFinancialInstitutionIdentification8? InstdRmbrsmntAgt = document.FIToFICstmrCdtTrf.GrpHdr.SttlmInf.InstdRmbrsmntAgt;
    SwiftMxRecords:CashAccount40? InstdRmbrsmntAgtAcct = document.FIToFICstmrCdtTrf.GrpHdr.SttlmInf.InstdRmbrsmntAgtAcct;

    if InstdRmbrsmntAgt is () {
        return ();
    }

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
    SwiftMxRecords:BranchAndFinancialInstitutionIdentification8? ThirdRmbrsmntAgt =
        document.FIToFICstmrCdtTrf.GrpHdr.SttlmInf?.ThrdRmbrsmntAgt;
    SwiftMxRecords:CashAccount40? ThirdRmbrsmntAgtAcct =
        document.FIToFICstmrCdtTrf.GrpHdr.SttlmInf.ThrdRmbrsmntAgtAcct;

    if ThirdRmbrsmntAgt is () {
        return ();
    }
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
    if creditorAgent.FinInstnId?.Nm != () && creditorAgent.FinInstnId?.PstlAdr == () {
        return <swiftmt:MT57B>{
            name: "57B",
            Lctn: {
                content: getEmptyStrIfNull(creditorAgent.FinInstnId?.Nm),
                number: "1"
            }
        };
    }
    if creditorAgent.FinInstnId?.Othr?.Id != () {
        return <swiftmt:MT57C>{
            name: "57C",
            PrtyIdn: {
                content: getEmptyStrIfNull(creditorAgent.FinInstnId?.Othr?.Id),
                number: "1"
            }
        };
    }

    if creditorAgent.FinInstnId?.PstlAdr != () {
        return <swiftmt:MT57D>{
            name: "57D",
            Nm: getNamesArrayFromNameString(getEmptyStrIfNull(creditorAgent.FinInstnId?.Nm)),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>creditorAgent.FinInstnId?.PstlAdr?.AdrLine)
        };
    }

    return ();
}

# Get the intermediary institution from the Pacs008 document.
# + clearingChannel - The clearing channel
# + return - The clearing prefix or an empty string
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
    SwiftMxRecords:BranchAndFinancialInstitutionIdentification8? intrmyAgt = document.FIToFICstmrCdtTrf.CdtTrfTxInf[0]?.IntrmyAgt1;
    SwiftMxRecords:CashAccount40? intrmyAgtAccount = document.FIToFICstmrCdtTrf.CdtTrfTxInf[0]?.IntrmyAgt1Acct;
    SwiftMxRecords:ClearingChannel2Code? clearingChannel = document.FIToFICstmrCdtTrf.CdtTrfTxInf[0]?.PmtTpInf?.ClrChanl;

    if intrmyAgt is () {
        return ();
    }

    if intrmyAgt.FinInstnId?.BICFI != () {
        string identifier = getClearingPrefix(clearingChannel) + getEmptyStrIfNull(intrmyAgt.FinInstnId.BICFI);

        if intrmyAgtAccount?.Id != () {
            return <swiftmt:MT56A>{
                name: "56A",
                IdnCd: {
                    content: identifier,
                    number: "1"
                }
            };
        }

        return <swiftmt:MT56A>{
            name: "56A",
            IdnCd: {
                content: identifier,
                number: "1"
            }
        };
    }
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

    return ();
}

# Get the beneficiary customer from the Pacs008 document.
#
# + document - The Pacs008 document
# + return - The beneficiary customer or null record
isolated function getBeneficiaryCustomerFromPacs008Document(
        SwiftMxRecords:Pacs008Document document
) returns swiftmt:MT59?|swiftmt:MT59A?|swiftmt:MT59F? {
    SwiftMxRecords:PartyIdentification272? creditor =
        document.FIToFICstmrCdtTrf.CdtTrfTxInf[0]?.Cdtr;
    SwiftMxRecords:CashAccount40? creditorAccount =
        document.FIToFICstmrCdtTrf.CdtTrfTxInf[0]?.CdtrAcct;

    if creditor is () {
        return ();
    }

    if creditor.Id?.OrgId?.AnyBIC != () {
        string anyBIC = getEmptyStrIfNull(creditor.Id?.OrgId?.AnyBIC);

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

        return <swiftmt:MT59A>{
            name: "59A",
            IdnCd: {
                content: anyBIC,
                number: "1"
            }
        };
    }
    if creditor.PstlAdr?.Ctry != () || creditor.PstlAdr?.AdrLine != () {
        boolean structuredAddressIndicator = isStructuredAddress(creditor);

        if structuredAddressIndicator {
            string partyIdentifier = creditorAccount?.Id != ()
                ? getEmptyStrIfNull(creditorAccount?.Id)
                : "/NOTPROVIDED";

            return <swiftmt:MT59F>{
                name: "59F",
                Acc: {
                    content: partyIdentifier,
                    number: "1"
                },
                CdTyp: [],
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
            return <swiftmt:MT59>{
                name: "59",
                Nm: getNamesArrayFromNameString(getEmptyStrIfNull(creditor.Nm)),
                AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>creditor.PstlAdr?.AdrLine)
            };
        }
    }
    if creditor.Nm != () {
        return <swiftmt:MT59>{
            name: "59",
            Nm: getNamesArrayFromNameString(getEmptyStrIfNull(creditor.Nm)),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>creditor.PstlAdr?.AdrLine)
        };
    }

    return ();
}

# Map the category purpose to MT23E.
# + categoryPurpose - The category purpose
# + return - The MT23E records
isolated function mapCategoryPurposeToMT23E(
        SwiftMxRecords:CategoryPurpose1Choice? categoryPurpose
) returns swiftmt:MT23E[] {
    swiftmt:MT23E[] instructionCodes = [];

    if categoryPurpose is () {
        return instructionCodes;
    }

    if categoryPurpose?.Cd is string {
        string code = categoryPurpose.Cd.toString();
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
    if categoryPurpose?.Prtry is string {
        string proprietary = categoryPurpose.Prtry.toString();
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
