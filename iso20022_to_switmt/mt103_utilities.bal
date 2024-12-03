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
                name: MT50A_NAME,
                IdnCd: {
                    content: partyIdentifier,
                    number: NUMBER1
                },
                Acc: {
                    content: getEmptyStrIfNull(debtorAccount?.Id),
                    number: NUMBER2
                }
            };
        }

        return <swiftmt:MT50A>{
            name: MT50A_NAME,
            IdnCd: {
                content: partyIdentifier,
                number: NUMBER1
            }
        };
    }

    if debtor.PstlAdr?.Ctry != () {
        string partyIdentifier = debtorAccount?.Id != ()
            ? getEmptyStrIfNull(debtorAccount?.Id)
            : "/NOTPROVIDED";

        return <swiftmt:MT50F>{
            name: MT50F_NAME,
            PrtyIdn: {
                content: partyIdentifier,
                number: NUMBER1
            },
            Nm: getNamesArrayFromNameString(getEmptyStrIfNull(debtor.Nm)),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>debtor.PstlAdr?.AdrLine),
            CntyNTw: [
                {
                    content: getEmptyStrIfNull(debtor.PstlAdr?.Ctry),
                    number: NUMBER3
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
                name: MT50F_NAME,
                PrtyIdn: {
                    content: partyIdentifier,
                    number: NUMBER1
                },
                Nm: getNamesArrayFromNameString(getEmptyStrIfNull(debtor.Nm)),
                AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>debtor.PstlAdr?.AdrLine),
                CntyNTw: [
                    {
                        content: getEmptyStrIfNull(debtor.PstlAdr?.Ctry),
                        number: NUMBER3
                    }
                ]
            };
        }
        return <swiftmt:MT50K>{
            name: MT50K_NAME,
            Nm: getNamesArrayFromNameString(getEmptyStrIfNull(debtor.Nm)),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>debtor.PstlAdr?.AdrLine)
        };
    }

    if debtor.Nm != () {
        string partyIdentifier = debtorAccount?.Id != ()
            ? getEmptyStrIfNull(debtorAccount?.Id)
            : "/NOTPROVIDED";

        return <swiftmt:MT50F>{
            name: MT50F_NAME,
            PrtyIdn: {
                content: partyIdentifier,
                number: NUMBER1
            },
            Nm: getNamesArrayFromNameString(getEmptyStrIfNull(debtor.Nm)),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>debtor.PstlAdr?.AdrLine),
            CntyNTw: [
                {
                    content: "/NOTPROVIDED",
                    number: NUMBER3
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
                name: MT52A_NAME,
                IdnCd: {
                    content: bic,
                    number: NUMBER1
                }
            };
        }

        return <swiftmt:MT52A>{
            name: MT52A_NAME,
            IdnCd: {
                content: bic,
                number: NUMBER1
            }
        };
    }
    if debtorAgent.FinInstnId?.PstlAdr != () {
        boolean isStructured = (<string[]>debtorAgent.FinInstnId.PstlAdr?.AdrLine).length() > 0;

        if isStructured {
            return <swiftmt:MT52D>{
                name: MT52D_NAME,
                Nm: getNamesArrayFromNameString(getEmptyStrIfNull(debtorAgent.FinInstnId.Nm)),
                AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>debtorAgent.FinInstnId.PstlAdr?.AdrLine)
            };
        }
        return <swiftmt:MT52D>{
            name: MT52D_NAME,
            Nm: getNamesArrayFromNameString(getEmptyStrIfNull(debtorAgent.FinInstnId.Nm)),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>debtorAgent.FinInstnId.PstlAdr?.AdrLine)
        };

    }
    if debtorAgent.FinInstnId?.Nm != () {
        return <swiftmt:MT52D>{
            name: MT52D_NAME,
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
                name: MT53A_NAME,
                IdnCd: {
                    content: mt53BIC,
                    number: NUMBER1
                }
            };
        }
    }
    if PrvsInstgAgt1.FinInstnId?.Nm != () && PrvsInstgAgt1.FinInstnId?.PstlAdr == () {
        return <swiftmt:MT53B>{
            name: MT53B_NAME,
            Lctn: {
                content: getEmptyStrIfNull(PrvsInstgAgt1.FinInstnId?.Nm),
                number: NUMBER1
            }
        };
    }
    if PrvsInstgAgt1.FinInstnId?.PstlAdr != () {
        return <swiftmt:MT53D>{
            name: MT53D_NAME,
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
            name: MT54A_NAME,
            PrtyIdnTyp: {
                content: getEmptyStrIfNull(InstdRmbrsmntAgtAcct?.Id?.Othr?.SchmeNm?.Cd),
                number: NUMBER1
            },
            PrtyIdn: {
                content: getEmptyStrIfNull(InstdRmbrsmntAgtAcct?.Id?.IBAN),
                number: NUMBER1
            },
            IdnCd: {
                content: getEmptyStrIfNull(InstdRmbrsmntAgt.FinInstnId?.BICFI),
                number: NUMBER1
            }
        };
    }
    if InstdRmbrsmntAgt.FinInstnId?.Nm != () && InstdRmbrsmntAgt.FinInstnId?.PstlAdr == () {
        return <swiftmt:MT54B>{
            name: MT54B_NAME,
            PrtyIdnTyp: (()),
            PrtyIdn: (()),
            Lctn: {
                content: getEmptyStrIfNull(InstdRmbrsmntAgt.FinInstnId?.Nm),
                number: NUMBER1
            }
        };
    }
    if InstdRmbrsmntAgt.FinInstnId?.PstlAdr != () {
        return <swiftmt:MT54D>{
            name: MT54D_NAME,
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
            name: MT55A_NAME,
            PrtyIdnTyp: {
                content: getEmptyStrIfNull(ThirdRmbrsmntAgtAcct?.Id?.Othr?.SchmeNm?.Cd),
                number: NUMBER1
            },
            PrtyIdn: {
                content: getEmptyStrIfNull(ThirdRmbrsmntAgtAcct?.Id?.IBAN),
                number: NUMBER1
            },
            IdnCd: {
                content: getEmptyStrIfNull(ThirdRmbrsmntAgt.FinInstnId?.BICFI),
                number: NUMBER1
            }
        };
    }
    if ThirdRmbrsmntAgt.FinInstnId?.Nm != () && ThirdRmbrsmntAgt.FinInstnId?.PstlAdr == () {
        return <swiftmt:MT55B>{
            name: MT55B_NAME,
            PrtyIdnTyp: (),
            PrtyIdn: (),
            Lctn: {
                content: getEmptyStrIfNull(ThirdRmbrsmntAgt.FinInstnId?.Nm),
                number: NUMBER1
            }
        };
    }
    if ThirdRmbrsmntAgt.FinInstnId?.PstlAdr != () {
        return <swiftmt:MT55D>{
            name: MT55D_NAME,
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
            name: MT57A_NAME,
            IdnCd: {
                content: bicfi,
                number: NUMBER1
            }
        };
    }
    if creditorAgent.FinInstnId?.Nm != () && creditorAgent.FinInstnId?.PstlAdr == () {
        return <swiftmt:MT57B>{
            name: MT57B_NAME,
            Lctn: {
                content: getEmptyStrIfNull(creditorAgent.FinInstnId?.Nm),
                number: NUMBER1
            }
        };
    }
    if creditorAgent.FinInstnId?.Othr?.Id != () {
        return <swiftmt:MT57C>{
            name: MT57C_NAME,
            PrtyIdn: {
                content: getEmptyStrIfNull(creditorAgent.FinInstnId?.Othr?.Id),
                number: NUMBER1
            }
        };
    }

    if creditorAgent.FinInstnId?.PstlAdr != () {
        return <swiftmt:MT57D>{
            name: MT57D_NAME,
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
                name: MT56A_NAME,
                IdnCd: {
                    content: identifier,
                    number: NUMBER1
                }
            };
        }

        return <swiftmt:MT56A>{
            name: MT56A_NAME,
            IdnCd: {
                content: identifier,
                number: NUMBER1
            }
        };
    }
    if intrmyAgt.FinInstnId?.ClrSysMmbId?.MmbId != () {
        string identifier = getClearingPrefix(clearingChannel) + getEmptyStrIfNull(intrmyAgt.FinInstnId?.ClrSysMmbId?.MmbId);

        return <swiftmt:MT56C>{
            name: MT56C_NAME,
            PrtyIdn: {
                content: identifier,
                number: NUMBER1
            }
        };
    }
    if intrmyAgt.FinInstnId?.Othr?.Id != () {
        return <swiftmt:MT56D>{
            name: MT56D_NAME,
            PrtyIdn: {
                content: getEmptyStrIfNull(intrmyAgt.FinInstnId.Othr?.Id),
                number: NUMBER1
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
                name: MT56A_NAME,
                IdnCd: {
                    content: anyBIC,
                    number: NUMBER1
                },
                Acc: {
                    content: getEmptyStrIfNull(creditorAccount?.Id),
                    number: NUMBER2
                }
            };
        }

        return <swiftmt:MT59A>{
            name: MT56A_NAME,
            IdnCd: {
                content: anyBIC,
                number: NUMBER1
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
                name: MT56F_NAME,
                Acc: {
                    content: partyIdentifier,
                    number: NUMBER1
                },
                CdTyp: [],
                Nm: [
                    {
                        content: getEmptyStrIfNull(creditor.Nm),
                        number: NUMBER2
                    }
                ],
                AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>creditor.PstlAdr?.AdrLine),
                CntyNTw: getMtCountryAndTownFromMxCountryAndTown(
                        getEmptyStrIfNull(creditor.PstlAdr?.Ctry),
                        getEmptyStrIfNull(creditor.PstlAdr?.TwnNm)
                )
            };
        }
        return <swiftmt:MT59>{
            name: MT59_NAME,
            Nm: getNamesArrayFromNameString(getEmptyStrIfNull(creditor.Nm)),
            AdrsLine: getMtAddressLinesFromMxAddresses(<string[]>creditor.PstlAdr?.AdrLine)
        };

    }
    if creditor.Nm != () {
        return <swiftmt:MT59>{
            name: MT59_NAME,
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
                name: MT59_NAME,
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
                name: MT59_NAME,
                InstrnCd: {
                    content: "CHQB",
                    number: instructionCodes.length().toString()
                }
            });
        }
        if proprietary.includes("HOLD") {
            instructionCodes.push({
                name: MT59_NAME,
                InstrnCd: {
                    content: "HOLD",
                    number: instructionCodes.length().toString()
                }
            });
        }
        if proprietary.includes("PHOB") {
            instructionCodes.push({
                name: MT59_NAME,
                InstrnCd: {
                    content: "PHOB",
                    number: instructionCodes.length().toString()
                }
            });
        }
        if proprietary.includes("TELB") {
            instructionCodes.push({
                name: MT59_NAME,
                InstrnCd: {
                    content: "TELB",
                    number: instructionCodes.length().toString()
                }
            });
        }
    }

    return instructionCodes;
}
