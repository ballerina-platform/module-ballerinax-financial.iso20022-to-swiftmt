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
import ballerinax/financial.swift.mt as swiftmt;

# Pacs 008 TR 026.
#
# + debtor - CreditTransferTransactionInformation.Debtor
# + debtorAcct - CreditTransferTransactionInformation.DebtorAccount
# + return - return field 50A or 50F
isolated function pacs008_tr026(pacsIsoRecord:PartyIdentification272? debtor, pacsIsoRecord:CashAccount40? debtorAcct)
    returns swiftmt:MT50A?|swiftmt:MT50F?|swiftmt:MT50K? {

    boolean debtorAcctPresent = debtorAcct is pacsIsoRecord:CashAccount40;
    boolean orgIdPresent = debtor?.Id?.OrgId?.Othr is pacsIsoRecord:GenericOrganisationIdentification3[];
    boolean prvtIdPresent = debtor?.Id?.PrvtId?.Othr is pacsIsoRecord:GenericPersonIdentification2[];
    string countryCode = debtor?.PstlAdr?.Ctry is string && isValidCountryCode(debtor?.PstlAdr?.Ctry.toString()) ?
        debtor?.PstlAdr?.Ctry.toString() : "CH";
    pacsIsoRecord:Max70Text[]? addressLines = debtor?.PstlAdr?.AdrLine;
    pacsIsoRecord:Max140Text? twnNm = debtor?.PstlAdr?.TwnNm;
    swiftmt:Nm[] names = [];
    names.push({content: debtor?.Nm.toString(), number: NUMBER2});

    if debtor?.Id?.OrgId?.AnyBIC is pacsIsoRecord:AnyBICDec2014Identifier {
        swiftmt:MT50A fieldMt50A = {
            name: MT50A_NAME,
            IdnCd: {content: mx_to_mtAnyBIC(debtor?.Id?.OrgId?.AnyBIC), number: NUMBER2}
        };
        if debtorAcct is pacsIsoRecord:CashAccount40 {
            fieldMt50A.Acc = {content: mx_to_mtAccount(debtorAcct?.Id, true), number: NUMBER1};
        }
        return fieldMt50A;
    }

    if debtor?.PstlAdr?.Ctry is string {
        swiftmt:MT50F fieldMt50F = {
            name: MT50F_NAME,
            CdTyp: getCodeType(debtor?.Nm.toString(), addressLines, twnNm, countryCode, debtor?.PstlAdr),
            PrtyIdn: {content: ""},
            Nm: [{content: getMandatoryField(debtor?.Nm), number: NUMBER3}],
            AdrsLine: getAddressLine(addressLines, 5, true, twnNm, countryCode, debtor?.PstlAdr)
        };
        if debtorAcctPresent {
            fieldMt50F.PrtyIdn = {content: mx_to_mtAccount(debtorAcct?.Id, true), number: NUMBER1};
        } else if orgIdPresent {
            pacsIsoRecord:GenericPersonIdentification2[]? orgId = debtor?.Id?.OrgId?.Othr;
            if orgId is pacsIsoRecord:GenericPersonIdentification2[] && orgId.length() > 0 {
                fieldMt50F.PrtyIdn = getPartyIdentifierForField50a(orgId[0], countryCode);
            }
        } else if prvtIdPresent {
            pacsIsoRecord:GenericPersonIdentification2[]? privateId = debtor?.Id?.PrvtId?.Othr;
            if privateId is pacsIsoRecord:GenericPersonIdentification2[] && privateId.length() > 0 {
                fieldMt50F.PrtyIdn = getPartyIdentifierForField50a(privateId[0], countryCode);
            }
        } else {
            fieldMt50F.PrtyIdn = {content: "/NOTPROVIDED", number: NUMBER1};
        }
        return fieldMt50F;
        
    }

    
    boolean addressLinesPresent = isAddressLinePresent(addressLines);
    if addressLinesPresent {
        boolean structuredAddressIndicator = mx_to_mtAddressLineType(debtor);
        if structuredAddressIndicator {

            swiftmt:MT50F fieldMt50F = {
                name: MT50F_NAME,
                CdTyp: getCodeType(debtor?.Nm.toString(), addressLines, twnNm, countryCode, debtor?.PstlAdr),
                PrtyIdn: {content: ""},
                Nm: [{content: getMandatoryField(debtor?.Nm), number: NUMBER3}],
                AdrsLine: getAddressLine(addressLines, 5, true, twnNm, countryCode, debtor?.PstlAdr)
            };

            if debtorAcctPresent {
                fieldMt50F.PrtyIdn = {content: mx_to_mtAccount(debtorAcct?.Id, true), number: NUMBER1};
            } else if orgIdPresent {
                pacsIsoRecord:GenericOrganisationIdentification3[]? othr = debtor?.Id?.OrgId?.Othr;
                if othr is pacsIsoRecord:GenericOrganisationIdentification3[] && othr.length() > 0 {

                    fieldMt50F.PrtyIdn = getPartyIdentifierForField50a(othr[0], countryCode);
                }
            } else if prvtIdPresent {
                pacsIsoRecord:GenericOrganisationIdentification3[]? othr = debtor?.Id?.PrvtId?.Othr;
                if othr is pacsIsoRecord:GenericOrganisationIdentification3[] && othr.length() > 0 {

                    fieldMt50F.PrtyIdn = getPartyIdentifierForField50a(othr[0], countryCode);
                }
            } else {
                fieldMt50F.PrtyIdn = {content: "/NOTPROVIDED", number: NUMBER1};
            }
            return fieldMt50F;
        } else {
            swiftmt:MT50K fieldMt50K = {name: MT50K_NAME, AdrsLine: [], Nm: []};
            fieldMt50K.Nm = names;

            fieldMt50K.AdrsLine = getAddressLine(addressLines, 3);
            if debtorAcctPresent {
                fieldMt50K.Acc = {content: mx_to_mtAccount(debtorAcct?.Id), number: NUMBER1};
            }
            return fieldMt50K;
        }

    }

    if debtor?.Nm is string {
        swiftmt:MT50K fieldMt50K = {name: MT50K_NAME, AdrsLine: [], Nm: []};
        fieldMt50K.AdrsLine = getAddressLine(addressLines, 3);
        fieldMt50K.Nm = names;

        if debtorAcctPresent {
            fieldMt50K.Acc = {content: mx_to_mtAccount(debtorAcct?.Id), number: NUMBER1};
        }
        return fieldMt50K;
    }
    return ();
}

# Pacs 008 TR 025.
#
# + creditor - CreditTransferTransactionInformation.Creditor
# + creditorAcct - CreditTransferTransactionInformation.CreditorAccount
# + return - return field 59, 59A or 59F
isolated function pacs008_tr025(pacsIsoRecord:PartyIdentification272? creditor, pacsIsoRecord:CashAccount40? creditorAcct)
    returns swiftmt:MT59?|swiftmt:MT59A?|swiftmt:MT59F? {

    boolean creditorAcctPresent = creditorAcct is pacsIsoRecord:CashAccount40;
    string countryCode = creditor?.PstlAdr?.Ctry is string && isValidCountryCode(creditor?.PstlAdr?.Ctry.toString()) ?
        creditor?.PstlAdr?.Ctry.toString() : "CH";
    pacsIsoRecord:Max70Text[]? addressLines = creditor?.PstlAdr?.AdrLine;
    pacsIsoRecord:Max140Text? twnNm = creditor?.PstlAdr?.TwnNm;
    boolean addressLinesPresent = isAddressLinePresent(addressLines);

    if creditor?.Id?.OrgId?.AnyBIC is pacsIsoRecord:AnyBICDec2014Identifier {
        swiftmt:MT59A fieldMt59A = {name: MT59A_NAME, IdnCd: {content: mx_to_mtAnyBIC(creditor?.Id?.OrgId?.AnyBIC), number: NUMBER2}};
        if creditorAcctPresent {
            fieldMt59A.Acc = {content: mx_to_mtAccount(creditorAcct?.Id), number: NUMBER1};
        }
        return fieldMt59A;
    }
    swiftmt:Nm[] names = [];
    names.push({content: creditor?.Nm.toString(), number: NUMBER2});
    if creditor?.PstlAdr?.Ctry is string {
        swiftmt:MT59F fieldMt59F = {name: MT59F_NAME, CdTyp: []};
        fieldMt59F.AdrsLine = getAddressLine(addressLines, 5, true, twnNm, countryCode, creditor?.PstlAdr, appendLineNoComponent = true);
        fieldMt59F.Nm = [{content: "1", number: NUMBER2}, {content: getMandatoryField(creditor?.Nm), number: NUMBER3}];

        if creditorAcctPresent {
            fieldMt59F.Acc = {content: mx_to_mtAccount(creditorAcct?.Id), number: NUMBER1};
        }
        return fieldMt59F;
    }
    
    
    if addressLinesPresent {
        boolean structuredAddressIndicator = mx_to_mtAddressLineType(creditor);
        if structuredAddressIndicator {
            swiftmt:MT59F fieldMt59F = {name: MT59F_NAME, CdTyp: []};
            fieldMt59F.AdrsLine =getAddressLine(addressLines, 5, true, twnNm, countryCode, creditor?.PstlAdr, appendLineNoComponent = true);
            fieldMt59F.Nm = [{content: "1", number: NUMBER2}, {content: getMandatoryField(creditor?.Nm), number: NUMBER3}];
            if creditorAcctPresent {
                fieldMt59F.Acc = {content: mx_to_mtAccount(creditorAcct?.Id), number: NUMBER1};
            }
            return fieldMt59F;
        } else {
            swiftmt:MT59 fieldMt59 = {name: MT59_NAME, AdrsLine: [], Nm: []};
            fieldMt59.AdrsLine = getAddressLine(addressLines, 3);
            fieldMt59.Nm = names;
            if creditorAcctPresent {
                fieldMt59.Acc = {content: mx_to_mtAccount(creditorAcct?.Id), number: NUMBER1};
            }
            return fieldMt59;
        }
    }
    if creditor?.Nm is string {
        swiftmt:MT59 fieldMt59 = {name: MT59_NAME, AdrsLine: [], Nm: []};
        fieldMt59.Nm = names;
        fieldMt59.AdrsLine = getAddressLine(addressLines, 3);
        if creditorAcctPresent {
            fieldMt59.Acc = {content: mx_to_mtAccount(creditorAcct?.Id), number: NUMBER1};
        }
        return fieldMt59;
    }
    return ();

}
