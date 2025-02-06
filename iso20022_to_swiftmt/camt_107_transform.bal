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

import ballerinax/financial.iso20022.cash_management as camtIsoRecord;
import ballerinax/financial.swift.mt as swiftmt;

# Transforms a camt.107 ISO 20022 document to its corresponding SWIFT MT110 format.
#
# + envelope - The camt.107 envelope containing the corresponding document to be transformed.
# + messageType - The SWIFT MT110 message type to be transformed.
# + return - The transformed SWIFT MT110 message or an error.
isolated function transformCamt107ToMt110(camtIsoRecord:Camt107Envelope envelope, string messageType) returns swiftmt:MT110Message|error => let
    string account = getAccountId(envelope.Document.ChqPresntmntNtfctn.Chq[0].DrwrAgtAcct?.Id?.IBAN,
            envelope.Document.ChqPresntmntNtfctn.Chq[0].DrwrAgtAcct?.Id?.Othr?.Id)
    in {
        block1: generateBlock1(getSenderOrReceiver(envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)),
        block2: generateBlock2(messageType, getSenderOrReceiver(envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI),
                envelope.Document.ChqPresntmntNtfctn.GrpHdr.CreDtTm),
        block4: {
            MT20: {name: MT20_NAME, msgId: {content: getMxToMTReference(envelope.Document.ChqPresntmntNtfctn.GrpHdr.MsgId), number: NUMBER1}},
            MT53B: account != "" ? {name: MT53B_NAME, PrtyIdn: {content: account, number: NUMBER2}} : (),
            Cheques: check getAdvicesOfCheque(envelope.Document.ChqPresntmntNtfctn.Chq)
        }
    };

# Get advice of cheques.
#
# + cheques - The list of cheques to be transformed.
# + return - The transformed SWIFT Cheques message or an error.
isolated function getAdvicesOfCheque(camtIsoRecord:Cheque17[] cheques) returns swiftmt:Cheques[]|error {
    swiftmt:Cheques[] chequeArray = [];
    foreach camtIsoRecord:Cheque17 cheque in cheques {
        swiftmt:MT50A?|swiftmt:MT50F?|swiftmt:MT50K? field50a = check getField50a(cheque.Pyer, cheque.PyerAcct?.Id);
        swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52D? field52a = check getField52(cheque.DrwrAgt?.FinInstnId, cheque.DrwrAgtAcct?.Id, isOptionBPresent = true);
        swiftmt:MT59?|swiftmt:MT59F? field59a = getField59aForCamt107(cheque.Pyee, cheque.PyeeAcct?.Id);
        chequeArray.push({
            MT21: {name: MT21_NAME, Ref: {content: cheque.ChqNb, number: NUMBER1}},
            MT30: {name: MT30_NAME, Dt: {content: convertToSWIFTStandardDate(cheque.IsseDt), number: NUMBER1}},
            MT32A: cheque.ValDt?.Dt is string ? {
                    name: MT32A_NAME,
                    Dt: {content: convertToSWIFTStandardDate(cheque.ValDt?.Dt), number: NUMBER1},
                    Ccy: {content: cheque.Amt.Ccy, number: NUMBER2},
                    Amnt: {content: convertDecimalNumberToSwiftDecimal(cheque.Amt.content), number: NUMBER3}
                } : (),
            MT32B: cheque.ValDt?.Dt !is string ? {
                    name: MT32B_NAME,
                    Ccy: {content: cheque.Amt.Ccy, number: NUMBER1},
                    Amnt: {content: convertDecimalNumberToSwiftDecimal(cheque.Amt.content), number: NUMBER2}
                } : (),
            MT50A: field50a is swiftmt:MT50A ? field50a : (),
            MT50F: field50a is swiftmt:MT50F ? field50a : (),
            MT50K: field50a is swiftmt:MT50K ? field50a : (),
            MT52A: field52a is swiftmt:MT52A ? field52a : (),
            MT52B: field52a is swiftmt:MT52B ? field52a : (),
            MT52D: field52a is swiftmt:MT52D ? field52a : (),
            MT59: field59a is swiftmt:MT59 ? field59a : (),
            MT59F: field59a is swiftmt:MT59F ? field59a : ()
        });
    }
    return chequeArray;
}

# Get field 59a for camt.107.
#
# + creditor - The creditor details.
# + account - The account details.
# + return - return field 59 or field 59F.
isolated function getField59aForCamt107(camtIsoRecord:PartyIdentification272? creditor, camtIsoRecord:AccountIdentification4Choice? account) returns swiftmt:MT59?|swiftmt:MT59F? {
    [string?, camtIsoRecord:Max70Text[]?, string?, string?, string?, string?]
        [name, address, iban, bban, townName, countryCode] = [
        creditor?.Nm,
        creditor?.PstlAdr?.AdrLine,
        account?.IBAN,
        account?.Othr?.Id,
        creditor?.PstlAdr?.TwnNm,
        creditor?.PstlAdr?.Ctry
    ];
    if ((name is string && address is camtIsoRecord:Max70Text[]) || (townName is string || countryCode is string)) {
        swiftmt:MT59F fieldMt59F = {
            name: MT59F_NAME,
            CdTyp: getCodeType(name, address, townName, countryCode, creditor?.PstlAdr),
            Acc: getAccount(getAccountId(iban, bban)),
            Nm: [{content: getMandatoryField(name), number: NUMBER3}],
            AdrsLine: getAddressLine(address, 5, true, townName, countryCode, creditor?.PstlAdr)
        };
        return fieldMt59F;
    }
    if name is string || address is camtIsoRecord:Max70Text[] || !(getAccountId(iban, bban).equalsIgnoreCaseAscii("")) {
        swiftmt:MT59 fieldMt59 = {
            name: MT59_NAME,
            Acc: getAccount(getAccountId(iban, bban)),
            Nm: [{content: getMandatoryField(name), number: NUMBER2}],
            AdrsLine: getAddressLine(address)
        };
        return fieldMt59;
    }
    return ();
}
