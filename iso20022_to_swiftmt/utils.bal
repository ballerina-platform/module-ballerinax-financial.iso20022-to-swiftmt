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

import ballerina/log;
import ballerina/time;
import ballerinax/financial.iso20022.cash_management as camtIsoRecord;
import ballerinax/financial.iso20022.payment_initiation as painIsoRecord;
import ballerinax/financial.iso20022.payments_clearing_and_settlement as pacsIsoRecord;
import ballerinax/financial.swift.mt as swiftmt;

# Get the mandatory field from the content.
#
# + content - The content to be checked for null
# + return - return content if it is not null, else return an empty string
isolated function getMandatoryField(string? content) returns string {
    if content is string {
        return content;
    }
    return "";
}

# Converts the given decimal number to a Swift decimal number.
#
# + number - optional decimal number to be converted
# + return - return the converted decimal number as a string
isolated function convertDecimalToSwiftDecimal(decimal? number) returns string {
    if number == () {
        return "";
    }
    if !number.toString().includes(".") {
        return number.toString().concat(",");
    }
    string:RegExp regex = re `\.`;
    return regex.replace(number.toString(), ",");
}

# Converts the given date to a Swift standard date format.
#
# + date - optional date to be converted
# + return - return the converted date as a string
isolated function convertToSWIFTStandardDate(string? date) returns string {
    if date is string && date.length() > 9 {
        return date.substring(2, 4) + date.substring(5, 7) + date.substring(8, 10);
    }
    return "";
}

# Get the swift Address Line from the given address.
#
# + address1 - address line array
# + num - content number
# + isOptionF - option F flag
# + townName - town name
# + countryCode - country code
# + postalAddr - postal address
# + appendLineNoComponent - append line number component - boolean whether to append the line number component
# + appendInlineLineNo - append inline line number - boolean whether to append the line number inline
# + return - return the swift Address Line
isolated function getAddressLine(pacsIsoRecord:Max70Text[]? address1, int num = 4, boolean isOptionF = false,
        string? townName = (), string? countryCode = (), pacsIsoRecord:PostalAddress27? postalAddr = {},
        boolean appendLineNoComponent = false, boolean appendInlineLineNo = false) returns swiftmt:AdrsLine[] {
    swiftmt:AdrsLine[] address = [];
    int count = num;
    if address1 is pacsIsoRecord:Max70Text[] {
        foreach string adrsLine in address1 {
            address.push({content: adrsLine, number: count.toString()});
            if isOptionF {
                count += 2;
                continue;
            }
            count += 1;
        }
    }
    if isOptionF && (countryCode is string || townName is string) {
        // 2/StreetName, BuildingNumber, BuildingName, Floor, PostBox, Room, Department, SubDepartment
        string addressLine1Elements = getAddressLine1Elements(postalAddr);
        if (addressLine1Elements != "") {
            address.push({content: (appendInlineLineNo ? (count - 1).toString() + "/" : "") + addressLine1Elements, number: count.toString()}, {content: (count / 2).toString(), number: appendLineNoComponent ? (count - 1).toString() : ()});
            count = appendInlineLineNo ? count + 1 : count + 2;
        }
        address.push({content: (appendInlineLineNo ? (count - 1).toString() + "/" : "") + countryCode.toString() + "/" + townName.toString(), number: count.toString()}, {content: (count / 2).toString(), number: appendLineNoComponent ? (count - 1).toString() : ()});
    }
    return address;
}

# Constructs the Address Line 1 elements from the given postal address.
#
# + postalAddr - postal address
# + return - return the constructed Address Line 1 elements
isolated function getAddressLine1Elements(pacsIsoRecord:PostalAddress27? postalAddr = {}) returns string {
    string block2ContentString = "";
    if postalAddr?.StrtNm is string {
        block2ContentString += postalAddr?.StrtNm.toString() + ",";
    }
    if postalAddr?.BldgNb is string {
        block2ContentString += postalAddr?.BldgNb.toString() + ",";
    }
    if postalAddr?.BldgNm is string {
        block2ContentString += postalAddr?.BldgNm.toString() + ",";
    }
    if postalAddr?.Flr is string {
        block2ContentString += postalAddr?.Flr.toString() + ",";
    }
    if postalAddr?.PstBx is string {
        block2ContentString += postalAddr?.PstBx.toString() + ",";
    }
    if postalAddr?.Room is string {
        block2ContentString += postalAddr?.Room.toString() + ",";
    }
    if postalAddr?.Dept is string {
        block2ContentString += postalAddr?.Dept.toString() + ",";
    }
    if postalAddr?.SubDept is string {
        block2ContentString += postalAddr?.SubDept.toString() + ",";
    }
    return block2ContentString == "" ? block2ContentString :
        block2ContentString.substring(0, block2ContentString.length() - 1);
}

# Maps ServiceLevel, CategoryPurpose, and LocalInstrument fields to MT72.
#
# + serviceLevels - The service level from the ISO message
# + categoryPurpose - The category purpose from the ISO message
# + localInstrument - The local instrument from the ISO message
# + narration - The continuation of the sender to receiver information from agents.
# + lineCount - The number of lines which the sender to receiver information has.
# + return - Returns a swiftmt:MT72 structure containing mapped Sender to Receiver Information
isolated function getSndRcvrInfoFromMsclns(pacsIsoRecord:ServiceLevel8Choice[]? serviceLevels,
        pacsIsoRecord:CategoryPurpose1Choice? categoryPurpose,
        pacsIsoRecord:LocalInstrument2Choice? localInstrument, string narration, int lineCount) returns string {

    string content = narration;
    int count = lineCount;

    if serviceLevels is pacsIsoRecord:ServiceLevel8Choice[] {
        foreach pacsIsoRecord:ServiceLevel8Choice serviceLevel in serviceLevels {
            if serviceLevel?.Cd is string {
                string code = serviceLevel?.Cd.toString();
                string:RegExp regex = re `^G00[1-9]$`;

                if code != "SDVA" && !code.matches(regex) {
                    content += "/SVCLVL/" + code + " ";
                }
            }
            if serviceLevel?.Prtry is string {
                string proprietary = serviceLevel?.Prtry.toString();
                content += "/SVCLVL/" + proprietary + " ";
            }
        }
    }
    if categoryPurpose?.Cd is string {
        string code = categoryPurpose?.Cd.toString();
        if code != "INTC" && code != "CORT" {
            if count < 6 && (35 - ((narration.length() % 35) + 9)) <= code.length() {
                content += "/CATPURP/" + code;
            } else if count < 5 {
                content += "\n/CATPURP/" + code;
                count += 1;
            }
        }
    }
    if categoryPurpose?.Prtry is string {
        string proprietary = categoryPurpose?.Prtry.toString();

        if proprietary != "INTC CORT" {
            if count < 6 && (35 - ((narration.length() % 35) + 9)) <= proprietary.length() {
                content += "/CATPURP/" + proprietary;
            } else if count < 5 {
                content += "\n/CATPURP/" + proprietary;
                count += 1;
            }
        }
    }
    if localInstrument?.Cd is string {
        string code = localInstrument?.Cd.toString();
        if count < 6 && (35 - ((narration.length() % 35) + 8)) <= code.length() {
            content += "/LOCINS/" + code;
        } else if count < 5 {
            content += "\n/LOCINS/" + code;
            count += 1;
        }
    }
    if localInstrument?.Prtry is string {
        string proprietary = localInstrument?.Prtry.toString();
        if proprietary != "CRED" && proprietary != "CRTS" && proprietary != "SPAY" &&
            proprietary != "SPRI" && proprietary != "SSTD" {
            if count < 6 && (35 - ((narration.length() % 35) + 8)) <= proprietary.length() {
                content += "/LOCINS/" + proprietary;
            } else if count < 5 {
                content += "\n/LOCINS/" + proprietary;
                count += 1;
            }
        }
    }
    return content;
}

# Get the Sender and Receiver information from the agents.
#
# + instruction1 - instruction for creditor agent
# + instruction2 - instruction for next agent
# + prvsInstgAgt1 - previous instructing agent
# + dbtrAgt - debtor agent
# + prvsInstgAgt2 - previous instructing agent 2
# + prvsInstgAgt3 - previous instructing agent 3
# + intrmyAgt2 - intermediary agent 2
# + intrmyAgt3 - intermediary agent 3
# + remmitanceInfo - remittance information
# + return - return the narration and line count
isolated function getFieldSndRcvrInfoFromAgts(pacsIsoRecord:InstructionForCreditorAgent3[]? instruction1,
        pacsIsoRecord:InstructionForNextAgent1[]? instruction2,
        pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? prvsInstgAgt1,
        pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? dbtrAgt,
        pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? prvsInstgAgt2 = (),
        pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? prvsInstgAgt3 = (),
        pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? intrmyAgt2 = (),
        pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? intrmyAgt3 = (),
        pacsIsoRecord:Max140Text[]? remmitanceInfo = ()) returns [string, int] {
    string narration = "";
    int lineCount = 0;

    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8?[] institutionalArray =
        [prvsInstgAgt1, dbtrAgt, prvsInstgAgt2, prvsInstgAgt3];
    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8?[] intermediaryInstArray = [intrmyAgt2, intrmyAgt3];
    if instruction1 is pacsIsoRecord:InstructionForCreditorAgent3[] {
        foreach pacsIsoRecord:InstructionForCreditorAgent3 instruction in instruction1 {
            if instruction.Cd == "ACC" {
                string instrInf = instruction.InstrInf.toString();
                [string, int] [narrationLines, narrationLineCount] = generateNarration(instrInf, "/ACC/", lineCount);
                narration += narrationLines;
                lineCount = narrationLineCount;
            }
        }
    }
    if instruction2 is pacsIsoRecord:InstructionForNextAgent1[] {
        foreach pacsIsoRecord:InstructionForNextAgent1 instruction in instruction2 {
            string instrInf = instruction.InstrInf.toString();
            [string, int] [narrationLines, narrationLineCount] = generateNarration(instrInf, "/INT/", lineCount);
            narration += narrationLines;
            lineCount = narrationLineCount;
        }
    }
    foreach pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? institution in institutionalArray {
        if institution is pacsIsoRecord:BranchAndFinancialInstitutionIdentification8 {
            if institution.FinInstnId?.BICFI is string {
                string bicfi = institution.FinInstnId?.BICFI.toString();
                [string, int] [narrationLines, narrationLineCount] = generateNarration(bicfi, "/INS/", lineCount);
                narration += narrationLines;
                lineCount = narrationLineCount;
            } else if institution.FinInstnId?.Nm is string {
                string instIdNm = institution.FinInstnId?.Nm.toString();
                [string, int] [narrationLines, narrationLineCount] = generateNarration(instIdNm, "/INS/", lineCount);
                narration += narrationLines;
                lineCount = narrationLineCount;
            }
        }
    }
    foreach pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? institution in intermediaryInstArray {
        if institution is pacsIsoRecord:BranchAndFinancialInstitutionIdentification8 {
            if institution.FinInstnId?.BICFI is string {
                string bicfi = institution.FinInstnId?.BICFI.toString();
                [string, int] [narrationLines, narrationLineCount] = generateNarration(bicfi, "/INTA/", lineCount);
                narration += narrationLines;
                lineCount = narrationLineCount;
            } else if institution.FinInstnId?.Nm is string {
                string instIdNm = institution.FinInstnId?.Nm.toString();
                [string, int] [narrationLines, narrationLineCount] = generateNarration(instIdNm, "/INTA/", lineCount);
                narration += narrationLines;
                lineCount = narrationLineCount;
            }
        }
    }
    if remmitanceInfo is pacsIsoRecord:Max140Text[] {
        string unstructuredInfo = "";
        foreach int i in 0 ... remmitanceInfo.length() - 1 {
            if i == remmitanceInfo.length() - 1 {
                unstructuredInfo += remmitanceInfo[i];
                break;
            }
            unstructuredInfo += remmitanceInfo[i] + " ";
        }
        [string, int] [narrationLines, narrationLineCount] = generateNarration(unstructuredInfo, "/BNF/", lineCount);
        narration += narrationLines;
        lineCount = narrationLineCount;
    }
    return [narration, lineCount];
}

# Generation narration. This builds narration content splitting from line breaks and appending code as required.
#
# + narrationContent - narration content
# + code - code to be appended
# + lineCount - remaining line count
# + return - return the narration and final line count
isolated function generateNarration(string narrationContent, string code, int lineCount) returns [string, int] {
    string narration = "";
    int count = lineCount;
    if lineCount != 0 {
        narration += "\n"; // Add a new line if it is not the first line
    }
    if narrationContent.length() < 30 { // narration starts with `/{code}/` which accounts for 5 chars, max line length 35
        narration += code.concat(narrationContent);
        count += 1;
    } else {
        narration += code.concat(narrationContent.substring(0, 30)); // if narration doesn't fit in one line, add the first 30 chars 
        count += 1;
        int noOfSubstrings = narrationContent.length() / 33 + 1;
        int iteration = 0;
        while lineCount < 6 && iteration < noOfSubstrings {
            if narrationContent.length() < 30 + iteration * 33 + 33 {
                narration += "\n//".concat(narrationContent.substring(30 + iteration * 33));
                count += 1;
                break;
            }
            narration += "\n//".concat(narrationContent.substring(30 + iteration * 33, 30 + iteration * 33 + 33));
            count += 1;
            iteration += 1;
        }
    }
    return [narration, count];
}

# Get the party identifier or account.
#
# + partyIdentifier - party identifier 
# + account - account
# + num - content number
# + isOptionF - option F flag
# + return - return the party identifier or account
isolated function getPartyIdentifierOrAccount(string? partyIdentifier, string account, string num = NUMBER2, boolean isOptionF = false) returns swiftmt:PrtyIdn? {
    if partyIdentifier is string {
        return {content: partyIdentifier, number: num};
    }
    if !account.equalsIgnoreCaseAscii("") {
        if isOptionF {
            return {content: "/" + account, number: num};
        }
        return {content: account, number: num};
    }
    if isOptionF {
        return {content: "/NOTPROVIDED", number: num};
    }
    return ();
}

# Construct field 13C for Swift MT .
#
# + closeTime - close time 
# + creditTime - credit time
# + debitTime - debit time
# + return - return the field 13C
isolated function getFieldMt13C(string? closeTime, string? creditTime, string? debitTime) returns swiftmt:MT13C? {
    string isoTime = "";
    string swiftTime = "";
    string sign = "";
    string timeOffSet = "";
    string code = "";
    if closeTime is string {
        isoTime = closeTime;
        swiftTime = isoTime.substring(0, 2) + isoTime.substring(3, 5);
        code = "CLSTIME";
    } else if creditTime is string {
        isoTime = creditTime;
        swiftTime = isoTime.substring(11, 13) + isoTime.substring(14, 15);
        code = "RNCTIME";
    } else if debitTime is string {
        isoTime = debitTime;
        swiftTime = isoTime.substring(11, 13) + isoTime.substring(14, 15);
        code = "SNDTIME";
    } else {
        return ();
    }
    foreach int i in 0 ... isoTime.length() - 1 {
        if isoTime.substring(i, i + 1).equalsIgnoreCaseAscii("+") || isoTime.substring(i, i + 1).equalsIgnoreCaseAscii("-") {
            sign = isoTime.substring(i, i + 1);
            if i + 5 <= isoTime.length() - 1 {
                timeOffSet = isoTime.substring(i + 1, i + 3) + isoTime.substring(i + 4, i + 6);
            }
        }
    }
    return {
        name: MT13C_NAME,
        Cd: {content: code, number: NUMBER1},
        Tm: {content: swiftTime, number: NUMBER2},
        Sgn: {content: sign, number: NUMBER3},
        TmOfst: {content: timeOffSet, number: NUMBER4}
    };
}

# Convert settlement time information to a single MT13C field.
#
# + SttlmTmIndctn - The settlement date-time indication  
# + SttlmTmReq - The settlement time request  
# + return - The MT13C message or an error if the conversion fails
isolated function convertTimeToMT13C(
        painIsoRecord:SettlementDateTimeIndication1? SttlmTmIndctn,
        painIsoRecord:SettlementTimeRequest2? SttlmTmReq
) returns swiftmt:MT13C?|error {

    if SttlmTmIndctn?.DbtDtTm is painIsoRecord:ISODateTime {
        return check createMT13C("SNDTIME", SttlmTmIndctn?.DbtDtTm);
    }
    if SttlmTmIndctn?.CdtDtTm is painIsoRecord:ISODateTime {
        return check createMT13C("RNCTIME", SttlmTmIndctn?.CdtDtTm);
    }
    if SttlmTmReq?.CLSTm is painIsoRecord:ISOTime {
        return check createMT13C("CLSTIME", SttlmTmReq?.CLSTm);
    }
    if SttlmTmReq?.TillTm is painIsoRecord:ISOTime {
        return check createMT13C("TILTIME", SttlmTmReq?.TillTm);
    }
    if SttlmTmReq?.FrTm is painIsoRecord:ISOTime {
        return check createMT13C("FROTIME", SttlmTmReq?.FrTm);
    }
    if SttlmTmReq?.RjctTm is painIsoRecord:ISOTime {
        return check createMT13C("REJTIME", SttlmTmReq?.RjctTm);
    }

    return ();
}

# generate the MT13C message from the given code and time
# + code - The code
# + time - The time
# + return - The MT13C message or an error if the conversion fails
isolated function createMT13C(string code, painIsoRecord:ISOTime?|painIsoRecord:ISODateTime? time)
    returns swiftmt:MT13C?|error {

    if time is painIsoRecord:ISOTime && time.length() > 13 {
        return {
            name: MT13C_NAME,
            Cd: {content: code, number: NUMBER1},
            Tm: {content: time.substring(0, 2) + time.substring(3, 5), number: NUMBER2},
            Sgn: {content: time.substring(8, 9), number: NUMBER3},
            TmOfst: {content: time.substring(9, 11) + time.substring(12, 14), number: NUMBER4}
        };
    }

    if time is painIsoRecord:ISODateTime && time.length() > 24 {
        return {
            name: MT13C_NAME,
            Cd: {content: code, number: NUMBER1},
            Tm: {content: time.substring(11, 13) + time.substring(14, 16), number: NUMBER2},
            Sgn: {content: time.substring(19, 20), number: NUMBER3},
            TmOfst: {content: time.substring(20, 22) + time.substring(23, 24), number: NUMBER4}
        };
    }

    return ();
}

# generate the MT13D message from the given code and time
# + dateTime - The date and time
# + return - The MT13D message or an error if the conversion fails
isolated function getField13D(painIsoRecord:ISODateTime? dateTime)
    returns swiftmt:MT13D? {

    if dateTime is painIsoRecord:ISODateTime && dateTime.length() > 24 {
        return {
            name: MT13D_NAME,
            Dt: {content: convertToSWIFTStandardDate(dateTime.substring(0, 10)), number: NUMBER1},
            Tm: {content: dateTime.substring(11, 13) + dateTime.substring(14, 16), number: NUMBER2},
            Sgn: {content: dateTime.substring(19, 20), number: NUMBER3},
            TmOfst: {content: dateTime.substring(20, 22) + dateTime.substring(23, 25), number: NUMBER4}
        };
    }
    return ();
}

# Construct field 19 for Swift MT .
#
# + controlSum - control sum
# + return - return the field 19
isolated function getField19(decimal? controlSum) returns swiftmt:MT19? {
    if controlSum is () {
        return ();
    }
    return {name: MT19_NAME, Amnt: {content: convertDecimalToSwiftDecimal(controlSum), number: NUMBER1}};
}

# Derive the MT20 field for block 4.
#
# + caseId - The case identification from the camt.056 message
# + return - Returns the MT20 field or an error if the mapping fails
isolated function getMT20(string? caseId) returns swiftmt:MT20|error {
    string field20 = "NOTPROVIDED";

    if caseId is string {
        if caseId.length() > 16 {
            field20 = caseId.substring(0, 15) + "+";
        } else {
            field20 = caseId;
        }

        if field20.startsWith("/") || field20.endsWith("/") || field20.matches(re `//`) {
            field20 = "NOTPROVIDED";
        }
    }

    return {
        name: MT20_NAME,
        msgId: {
            content: field20,
            number: NUMBER1
        }
    };
}

# Get the field 20 content.
#
# + msgId - message id
# + return - return the field 20 content
isolated function getField20Content(string? msgId) returns string {
    if msgId is string {
        if msgId.length() > 16 {
            return msgId.substring(0, 15).concat("+");
        }
        return msgId;
    }
    return "";
}

# Construct field 21 for Swift MT .
#
# + mandateId - mandate id
# + return - return the field 21C
isolated function getField21C(string? mandateId) returns swiftmt:MT21C? {
    if mandateId is string {
        return {
            name: "21C",
            Ref: {content: mandateId, number: NUMBER1}
        };
    }
    return ();
}

# Construct field 23 for Swift MT .
#
# + bankOpCd - bank operation code
# + optionB - option B flag
# + return - return the field 23 or field 23B
isolated function getField23(string? bankOpCd, boolean optionB = false) returns swiftmt:MT23|swiftmt:MT23B {
    string[] operationCodes = ["CREDIT", "SPAY", "CRTST"];
    string[] operationCodesOptionB = ["CRED", "SPAY", "CRTS", "SSTD", "SPRI"];
    if bankOpCd is string {
        if !optionB && operationCodes.indexOf(bankOpCd) !is () {
            return {
                name: MT23_NAME,
                Cd: {content: bankOpCd, number: NUMBER1}
            };
        }
        if optionB && operationCodesOptionB.indexOf(bankOpCd) !is () {
            return {
                name: MT23B_NAME,
                Typ: {content: bankOpCd, number: NUMBER1}
            };
        }
    }
    return optionB ? {name: MT23B_NAME, Typ: {content: "CRED", number: NUMBER1}} :
        {name: optionB ? MT23B_NAME : MT23_NAME, Cd: {content: "NOTPROVIDED", number: NUMBER1}};
}

# Construct field 23E[] for Swift MT 103 messages.
#
# + cdtrInstrctn - creditor instruction
# + dbtrInstrctn - debtor instruction
# + svcLvl - service level
# + ctgryPurp - category purpose
# + return - return the field 23E
isolated function getField23EForMt103(pacsIsoRecord:InstructionForCreditorAgent3[]? cdtrInstrctn, pacsIsoRecord:InstructionForNextAgent1[]? dbtrInstrctn, pacsIsoRecord:ServiceLevel8Choice[]? svcLvl, pacsIsoRecord:CategoryPurpose1Choice? ctgryPurp) returns swiftmt:MT23E[] {
    swiftmt:MT23E[] field23E = [];
    if cdtrInstrctn is pacsIsoRecord:InstructionForCreditorAgent3[] {
        string[] MT_103_INSTRC_CD = ["CHQB", "TELB", "PHOB", "HOLD"];
        foreach pacsIsoRecord:InstructionForCreditorAgent3 instruction in cdtrInstrctn {
            if MT_103_INSTRC_CD.indexOf(instruction.Cd.toString()) !is () {
                if instruction.InstrInf is string {
                    field23E.push({
                        name: MT23E_NAME,
                        InstrnCd: {
                            content:
                            instruction.Cd.toString() + "/" + instruction.InstrInf.toString(),
                            number: NUMBER1
                        }
                    });
                } else {
                    field23E.push({name: MT23E_NAME, InstrnCd: {content: instruction.Cd.toString(), number: NUMBER1}});
                }
            }
        }
    }

    if dbtrInstrctn is pacsIsoRecord:InstructionForNextAgent1[] {
        string[] MT_103_INSTRC_CD = ["PHON", "TELI", "TELE", "PHOI", "REPA"];
        foreach pacsIsoRecord:InstructionForNextAgent1 instruction in dbtrInstrctn {
            if MT_103_INSTRC_CD.indexOf(instruction.Cd.toString()) !is () {
                if instruction.InstrInf is string {
                    field23E.push({
                        name: MT23E_NAME,
                        InstrnCd: {
                            content:
                            instruction.Cd.toString() + "/" + instruction.InstrInf.toString(),
                            number: NUMBER1
                        }
                    });
                } else {
                    field23E.push({name: MT23E_NAME, InstrnCd: {content: instruction.Cd.toString(), number: NUMBER1}});
                }
            }
        }
    }

    if svcLvl is pacsIsoRecord:ServiceLevel8Choice[] {
        foreach pacsIsoRecord:ServiceLevel8Choice instruction in svcLvl {
            if instruction.Cd.toString().equalsIgnoreCaseAscii("SDVA") {
                field23E.push({name: MT23E_NAME, InstrnCd: {content: "SDVA", number: NUMBER1}});
            }
        }
    }

    if ctgryPurp is pacsIsoRecord:CategoryPurpose1Choice {
        if ctgryPurp.Cd.toString().equalsIgnoreCaseAscii("INTC") ||
            ctgryPurp.Cd.toString().equalsIgnoreCaseAscii("CORT") {
            field23E.push({name: MT23E_NAME, InstrnCd: {content: ctgryPurp.Cd.toString(), number: NUMBER1}});
            return field23E;
        }
        if ctgryPurp.Prtry.toString().equalsIgnoreCaseAscii("INTC CORT") {
            field23E.push({name: MT23E_NAME, InstrnCd: {content: "INTC", number: NUMBER1}});
            field23E.push({name: MT23E_NAME, InstrnCd: {content: "CORT", number: NUMBER1}});
            return field23E;
        }
    }
    return field23E;
}

# Construct field 23E for Swift MT .
#
# + instruction1 - instruction for creditor agent
# + instruction2 - instruction for next agent
# + instruction3 - instruction for service level
# + instruction4 - instruction for category purpose
# + return - return the field 23E
isolated function getfield23EForMt101(painIsoRecord:InstructionForCreditorAgent3[]? instruction1, painIsoRecord:InstructionForDebtorAgent1? instruction2, pacsIsoRecord:ServiceLevel8Choice[]? instruction3, painIsoRecord:CategoryPurpose1Choice? instruction4) returns swiftmt:MT23E[]? {
    swiftmt:MT23E[] field23E = [];
    string[] MT_101_INSTRC_CD = [
        "CHQB",
        "CMSW",
        "CMTO",
        "CMZB",
        "CORT",
        "EQUI",
        "INTC",
        "NETS",
        "OTHR",
        "PHON",
        "REPA",
        "RTGS",
        "URGP"
    ];

    if instruction1 !is painIsoRecord:InstructionForCreditorAgent3[] && instruction2 !is painIsoRecord:InstructionForDebtorAgent1
        && instruction3 !is pacsIsoRecord:ServiceLevel8Choice[] && instruction4 !is painIsoRecord:CategoryPurpose1Choice {
        return ();
    }

    if instruction1 is painIsoRecord:InstructionForCreditorAgent3[] {
        foreach painIsoRecord:InstructionForCreditorAgent3 instruction in instruction1 {
            if MT_101_INSTRC_CD.indexOf(instruction.Cd.toString()) == () {
                log:printWarn("Undefined SWIFT MT instruction code is present in the message.");
            }
            swiftmt:AddInfo? addInfo = ();
            if instruction.InstrInf is painIsoRecord:Max140Text {
                if instruction.InstrInf.toString().length() > 30 {
                    addInfo = {content: instruction.InstrInf.toString().substring(0, 30), number: NUMBER2};
                } else {
                    addInfo = {content: instruction.InstrInf.toString(), number: NUMBER2};
                }
            }
            field23E.push({
                name: MT23E_NAME,
                InstrnCd: {content: instruction.Cd.toString(), number: NUMBER1},
                AddInfo: addInfo
            });
        }
    }

    if instruction2 is painIsoRecord:InstructionForDebtorAgent1 {
        swiftmt:AddInfo? addInfo = ();
        if MT_101_INSTRC_CD.indexOf(instruction2.Cd.toString()) == () {
            log:printWarn("Undefined SWIFT MT instruction code is present in the message.");
        }
        if instruction2.InstrInf is painIsoRecord:Max140Text {
            if instruction2.InstrInf.toString().length() > 30 {
                addInfo = {content: instruction2.InstrInf.toString().substring(0, 30), number: NUMBER2};
            } else {
                addInfo = {content: instruction2.InstrInf.toString(), number: NUMBER2};
            }
        }
        field23E.push({
            name: MT23E_NAME,
            InstrnCd: {content: instruction2.Cd.toString(), number: NUMBER1},
            AddInfo: addInfo
        });
    }

    if instruction3 is pacsIsoRecord:ServiceLevel8Choice[] {
        foreach pacsIsoRecord:ServiceLevel8Choice instruction in instruction3 {
            if MT_101_INSTRC_CD.indexOf(instruction.Cd.toString()) == () {
                log:printWarn("Undefined SWIFT MT instruction code is present in the message.");
            }
            field23E.push({
                name: MT23E_NAME,
                InstrnCd: {content: instruction.Cd.toString(), number: NUMBER1}
            });
        }
    }

    if instruction4 is painIsoRecord:CategoryPurpose1Choice {
        if MT_101_INSTRC_CD.indexOf(instruction4.Cd.toString()) == () {
            log:printWarn("Undefined SWIFT MT instruction code is present in the message.");
        }
        field23E.push({
            name: MT23E_NAME,
            InstrnCd: {content: instruction4.Cd.toString(), number: NUMBER1}
        });
    }
    return field23E;
}

# Construct field 23E for pacs 003.
#
# + dbtTrfTx - direct debit transaction information
# + ctgryPurp - category purpose
# + isTransaction - transaction flag
# + return - return the field 23E
isolated function getRepeatingField23EForPacs003(pacsIsoRecord:DirectDebitTransactionInformation31[] dbtTrfTx, string? ctgryPurp = (), boolean isTransaction = false) returns swiftmt:MT23E? {
    string? purpose = dbtTrfTx[0].PmtTpInf?.CtgyPurp?.Cd;
    string[] ctgryPurpCode = ["OTHR", "NAUT", "AUTH"];
    foreach int i in 1 ... dbtTrfTx.length() - 1 {
        if purpose.toString() != dbtTrfTx[i].PmtTpInf?.CtgyPurp?.Cd.toString()
            && ctgryPurpCode.indexOf(ctgryPurp.toString()) !is () {
            return {
                name: MT23E_NAME,
                InstrnCd: {content: ctgryPurp.toString(), number: NUMBER1}
            };
        }
    }
    if isTransaction {
        return ();
    }
    if ctgryPurpCode.indexOf(purpose.toString()) !is () {
        return {
            name: MT23E_NAME,
            InstrnCd: {content: purpose.toString(), number: NUMBER1}
        };
    }
    return ();
}

# Construct field 25 for Swift MT .
#
# + acctId - account identification
# + itemId - item identification
# + return - return the field 25
isolated function getField25(camtIsoRecord:AccountIdentification4Choice? acctId, camtIsoRecord:AccountIdentification4Choice? itemId)
    returns swiftmt:MT25A? {

    string content = "";
    if acctId is camtIsoRecord:AccountIdentification4Choice {
        content += acctId.Othr?.Id.toString();
        content += acctId.IBAN.toString();
    }
    if itemId is camtIsoRecord:AccountIdentification4Choice {
        content += itemId.Othr?.Id.toString();
        content += itemId.IBAN.toString();
    }
    if content == EMPTY_STRING {
        content = "NOTPROVIDED";
    }
    return {name: "25", Acc: {content: truncate(content, 35), number: NUMBER1}};
}

# Construct field 25A for Swift MT .
#
# + chargesAcct - charges account
# + return - return the field 25A
isolated function getField25A(painIsoRecord:CashAccount40? chargesAcct) returns swiftmt:MT25A? {
    if chargesAcct?.Id?.IBAN is painIsoRecord:IBAN2007Identifier {
        return {
            name: MT25A_NAME,
            Acc: {content: chargesAcct?.Id?.IBAN.toString(), number: NUMBER1}
        };
    }
    if chargesAcct?.Id?.Othr?.Id is painIsoRecord:Max34Text {
        return {
            name: MT25A_NAME,
            Acc: {content: chargesAcct?.Id?.Othr?.Id.toString(), number: NUMBER1}
        };
    }
    return ();
}

# Get cash account for field 25
#
# + account - account identification
# + owner - owner identification
# + isField25Only - field 25 only flag
# + return - return the field 25A or field 25P
isolated function getCashAccount(camtIsoRecord:AccountIdentification4Choice? account, camtIsoRecord:PartyIdentification272? owner, boolean isField25Only = false) returns swiftmt:MT25A?|swiftmt:MT25P? {
    if owner?.Id?.OrgId?.AnyBIC is string && (account?.IBAN is string || account?.Othr?.Id is string) && !isField25Only {
        swiftmt:MT25P field25P = {
            name: MT25P_NAME,
            Acc: {content: getAccountId(account?.IBAN, account?.Othr?.Id), number: NUMBER1},
            IdnCd: {content: owner?.Id?.OrgId?.AnyBIC.toString(), number: NUMBER2}
        };
        return field25P;
    }
    if account?.IBAN is string || account?.Othr?.Id is string {
        swiftmt:MT25A field25 = {
            name: MT25_NAME,
            Acc: {content: getAccountId(account?.IBAN, account?.Othr?.Id), number: NUMBER1}
        };
        return field25;
    }
    return ();
}

# Construct field 26T for Swift MT .
#
# + code - code
# + return - return the field 26T
isolated function getField26T(string? code) returns swiftmt:MT26T? {
    if code is string && code.matches(re `[A-Z0-9]{3}`) {
        return {
            name: MT26T_NAME,
            Typ: {content: getMandatoryField(code), number: NUMBER1}
        };
    }
    return ();
}

# Construct repeating field 26T for Swift MT .
#
# + trfTx - credit/direct debit transaction information
# + purp - purpose
# + isTransaction - transaction flag
# + return - return the field 26T
isolated function getRepeatingField26T(pacsIsoRecord:DirectDebitTransactionInformation31[]|pacsIsoRecord:CreditTransferTransaction64[] trfTx,
        pacsIsoRecord:Purpose2Choice? purp = (), boolean isTransaction = false) returns swiftmt:MT26T? {

    string? purpose = trfTx[0].Purp?.Cd;
    foreach int i in 1 ... trfTx.length() - 1 {
        if purpose != trfTx[i].Purp?.Cd {
            return getField26T(purp?.Cd);
        }
    }
    if isTransaction {
        return ();
    }
    return getField26T(purpose);
}

# Construct field 33B for Swift MT .
#
# + instdAmt - instructed amount
# + intrBkSttlmAmt - interbank settlement amount
# + senderCountry - sender country
# + receiverCountry - receiver country
# + isUnderlyingTransaction - underlying transaction flag
# + return - return the field 33B
isolated function getField33B(pacsIsoRecord:ActiveOrHistoricCurrencyAndAmount? instdAmt,
        pacsIsoRecord:ActiveCurrencyAndAmount? intrBkSttlmAmt, string senderCountry, string receiverCountry,
        boolean isUnderlyingTransaction = false) returns swiftmt:MT33B? {

    if instdAmt is pacsIsoRecord:ActiveOrHistoricCurrencyAndAmount {
        return {
            name: MT33B_NAME,
            Ccy: {content: instdAmt.Ccy, number: NUMBER1},
            Amnt: {content: convertDecimalToSwiftDecimal(instdAmt.content), number: NUMBER2}
        };
    }
    if (intrBkSttlmAmt is pacsIsoRecord:ActiveCurrencyAndAmount && euCountryList.indexOf(senderCountry) >= 0 
        && euCountryList.indexOf(receiverCountry) >= 0) { 
        return {
            name: MT33B_NAME,
            Ccy: {content: intrBkSttlmAmt.Ccy, number: NUMBER1},
            Amnt: {content: convertDecimalToSwiftDecimal(intrBkSttlmAmt.content), number: NUMBER2}
        };
    }
    return;
}

# Construct the field 34F.
#
# + limitArray - limit array
# + return - return the field 34F array
isolated function getField34F(camtIsoRecord:Limit2[]? limitArray) returns swiftmt:MT34F[]? {
    if limitArray !is camtIsoRecord:Limit2[] {
        return ();
    }
    swiftmt:MT34F[] field34F = [];
    if limitArray.length() > 1 {
        foreach int i in 0 ... 1 {
            if limitArray[i].CdtDbtInd is camtIsoRecord:DEBT {
                field34F.push({
                    name: MT34F_NAME,
                    Ccy: {content: getMandatoryField(limitArray[i].Amt?.Ccy), number: NUMBER1},
                    Cd: {content: "D", number: NUMBER2},
                    Amnt: {content: convertDecimalToSwiftDecimal(limitArray[i].Amt?.content), number: NUMBER3}
                });
                continue;
            }
            field34F.push({
                name: MT34F_NAME,
                Ccy: {content: getMandatoryField(limitArray[i].Amt?.Ccy), number: NUMBER1},
                Cd: {content: "C", number: NUMBER2},
                Amnt: {content: convertDecimalToSwiftDecimal(limitArray[i].Amt?.content), number: NUMBER3}
            });
        }
        return field34F;
    }
    field34F.push({
        name: MT34F_NAME,
        Ccy: {content: getMandatoryField(limitArray[0].Amt?.Ccy), number: NUMBER1},
        Cd: {content: "D", number: NUMBER2},
        Amnt: {content: convertDecimalToSwiftDecimal(limitArray[0].Amt?.content), number: NUMBER3}
    });
    return field34F;
}

# Construct field 36 for Swift MT .
#
# + exchangeRate - exchange rate
# + return - return the field 36
isolated function getField36(pacsIsoRecord:BaseOneRate? exchangeRate) returns swiftmt:MT36? {
    if exchangeRate is pacsIsoRecord:BaseOneRate {
        return {
            name: MT36_NAME,
            Rt: {content: convertDecimalToSwiftDecimal(exchangeRate), number: NUMBER1}
        };
    }
    return ();
}

# Construct repeating field 36 for Swift MT .
#
# + crdtTrfTx - credit transfer transaction information
# + rate - exchange rate
# + isTransaction - transaction flag
# + return - return the field 36
isolated function getRepeatingField36(pacsIsoRecord:CreditTransferTransaction64[] crdtTrfTx, pacsIsoRecord:BaseOneRate? rate = (), boolean isTransaction = false) returns swiftmt:MT36?|error {
    pacsIsoRecord:BaseOneRate? xchgRate = crdtTrfTx[0].XchgRate;
    foreach int i in 1 ... crdtTrfTx.length() - 1 {
        if xchgRate != crdtTrfTx[i].XchgRate {
            return getField36(rate);
        }
    }
    if isTransaction {
        return ();
    }
    return getField36(xchgRate);
}

# Construct field 50A for Swift MT .
#
# + debtor - debtor party identification
# + account - account identification
# + isSecondType - second type flag  
# + isOptionFPresent - option F flag
# + return - return the field 50A
isolated function getField50a(pacsIsoRecord:PartyIdentification272? debtor,
        pacsIsoRecord:AccountIdentification4Choice? account = (), boolean isSecondType = false,
        boolean isOptionFPresent = true)
    returns swiftmt:MT50A?|swiftmt:MT50G?|swiftmt:MT50K?|swiftmt:MT50H?|swiftmt:MT50F?|error {
    [string?, string?, pacsIsoRecord:Max70Text[]?, string?, string?, pacsIsoRecord:GenericPersonIdentification2[]?,
    pacsIsoRecord:GenericOrganisationIdentification3[]?, string?, string?]
        [identifierCode, name, address, iban, bban, prvtOthrId, orgOthrId, townName, countryCode] = [
        debtor?.Id?.OrgId?.AnyBIC,
        debtor?.Nm,
        debtor?.PstlAdr?.AdrLine,
        account?.IBAN,
        account?.Othr?.Id,
        debtor?.Id?.PrvtId?.Othr,
        debtor?.Id?.OrgId?.Othr,
        debtor?.PstlAdr?.TwnNm,
        debtor?.PstlAdr?.Ctry
    ];
    if identifierCode is string && isSecondType {
        swiftmt:MT50G fieldMt50G = {
            name: MT50G_NAME,
            Acc: {content: getAccountId(iban, bban), number: NUMBER1},
            IdnCd: {content: getMandatoryField(identifierCode), number: NUMBER2}
        };
        return fieldMt50G;
    }
    if identifierCode is string {
        swiftmt:MT50A fieldMt50A = {
            name: MT50A_NAME,
            Acc: getAccount(getAccountId(iban, bban)),
            IdnCd: {content: getMandatoryField(identifierCode), number: NUMBER2}
        };
        return fieldMt50A;
    }
    if prvtOthrId is pacsIsoRecord:GenericPersonIdentification2[] && prvtOthrId[0].Id is string && isOptionFPresent {
        swiftmt:MT50F fieldMt50F = {
            name: MT50F_NAME,
            CdTyp: getCodeType(name, address, townName, countryCode, debtor?.PstlAdr),
            PrtyIdn: getPartyIdentifierForField50a(prvtOthrId[0], countryCode),
            Nm: [{content: getMandatoryField(name), number: NUMBER3}],
            AdrsLine: getAddressLine(address, 5, true, townName, countryCode, debtor?.PstlAdr)
        };
        return fieldMt50F;
    }
    if orgOthrId is pacsIsoRecord:GenericOrganisationIdentification3[] && orgOthrId[0].Id is string && isOptionFPresent {
        swiftmt:MT50F fieldMt50F = {
            name: MT50F_NAME,
            CdTyp: getCodeType(name, address, townName, countryCode, debtor?.PstlAdr),
            PrtyIdn: getPartyIdentifierForField50a(orgOthrId[0], countryCode),
            Nm: [{content: getMandatoryField(name), number: NUMBER3}],
            AdrsLine: getAddressLine(address, 5, true, townName, countryCode, debtor?.PstlAdr)
        };
        return fieldMt50F;
    }
    if ((!getAccountId(iban, bban).equalsIgnoreCaseAscii("") && address is pacsIsoRecord:Max70Text[]) || (townName is string || countryCode is string)) && isOptionFPresent {
        swiftmt:MT50F fieldMt50F = {
            name: MT50F_NAME,
            CdTyp: getCodeType(name, address, townName, countryCode, debtor?.PstlAdr),
            PrtyIdn: check getPartyIdentifierOrAccount((), getAccountId(iban, bban), NUMBER1, true).ensureType(),
            Nm: [{content: getMandatoryField(name), number: NUMBER3}],
            AdrsLine: getAddressLine(address, 5, true, townName, countryCode, debtor?.PstlAdr)
        };
        return fieldMt50F;
    }
    if (name is string || address is pacsIsoRecord:Max70Text[] || !getAccountId(iban, bban).equalsIgnoreCaseAscii("")) && isSecondType {
        swiftmt:MT50H fieldMt50H = {
            name: MT50H_NAME,
            Acc: {content: getAccountId(iban, bban), number: NUMBER1},
            Nm: [{content: getMandatoryField(name), number: NUMBER2}],
            AdrsLine: getAddressLine(address, 3)
        };
        return fieldMt50H;
    }
    if name is string || address is pacsIsoRecord:Max70Text[] || !getAccountId(iban, bban).equalsIgnoreCaseAscii("") {
        swiftmt:MT50K fieldMt50K = {
            name: MT50K_NAME,
            Acc: getAccount(getAccountId(iban, bban)),
            Nm: [{content: getMandatoryField(name), number: NUMBER2}],
            AdrsLine: getAddressLine(address)
        };
        return fieldMt50K;
    }
    return ();
}

isolated function getField50(pacsIsoRecord:Party50Choice? dbtr, pacsIsoRecord:Party50Choice? itmDbtr, boolean appendLineNo = false) returns swiftmt:MT50?|swiftmt:MT50C?|swiftmt:MT50F? {

    pacsIsoRecord:PartyIdentification272? dbtrParty = dbtr?.Pty is pacsIsoRecord:PartyIdentification272 ? dbtr?.Pty : itmDbtr?.Pty;
    pacsIsoRecord:GenericOrganisationIdentification3[]? othr =
        dbtrParty?.Id?.OrgId?.Othr is pacsIsoRecord:GenericOrganisationIdentification3[] ? dbtrParty?.Id?.OrgId?.Othr : dbtrParty?.Id?.PrvtId?.Othr;
    string partyid = othr is pacsIsoRecord:GenericOrganisationIdentification3[] ? othr[0].Id.toString() : "/NOTPROVIDED";

    if dbtr?.Pty?.Id?.OrgId?.AnyBIC is string {
        return {
            name: MT50C_NAME,
            IdnCd: {content: dbtr?.Pty?.Id?.OrgId?.AnyBIC.toString(), number: NUMBER1}
        };
    } else if dbtrParty?.PstlAdr?.Ctry is string || dbtrParty?.PstlAdr?.AdrLine is pacsIsoRecord:Max70Text[] {
        return {
            name: MT50F_NAME,
            PrtyIdn: {content: partyid, number: NUMBER1},
            Nm: [{content: getMandatoryField(dbtrParty?.Nm), number: NUMBER3}, {content: NUMBER1, number: appendLineNo ? NUMBER2 : ()}],
            AdrsLine: getAddressLine(dbtrParty?.PstlAdr?.AdrLine, 5, true, dbtrParty?.PstlAdr?.TwnNm, dbtrParty?.PstlAdr?.Ctry, dbtrParty?.PstlAdr, appendLineNo)
        };
    } else if dbtrParty?.Nm is string {
        return {
            name: MT50_NAME,
            PrtyIdn: {content: partyid, number: NUMBER1},
            Nm: [{content: getMandatoryField(dbtrParty?.Nm), number: NUMBER3}],
            AdrsLine: []
        };
    } else {
        return ();
    }
}

# Get the party identifier for field 50a.
#
# + otherId - generic person identification
# + countryCode - country code
# + return - return the party identifier
isolated function getPartyIdentifierForField50a(pacsIsoRecord:GenericPersonIdentification2 otherId, string? countryCode) returns swiftmt:PrtyIdn {
    if otherId.Issr is string {
        return {content: otherId.SchmeNm?.Cd.toString() + "/" + countryCode.toString() + "/" + otherId.Issr.toString() + "/" + otherId.Id.toString(), number: NUMBER1};
    }
    return {content: otherId.SchmeNm?.Cd.toString() + "/" + countryCode.toString() + "/" + otherId.Id.toString(), number: NUMBER1};
}

# Construct field 50 option O,C or L for Swift MT .
#
# + agent - party identification
# + return - return the field 50 option O,C or L
isolated function getField50Or50COr50L(pacsIsoRecord:PartyIdentification272? agent) returns swiftmt:MT50?|swiftmt:MT50C?|swiftmt:MT50L? {
    [string?, string?, pacsIsoRecord:Max70Text[]?, pacsIsoRecord:GenericPersonIdentification2[]?]
    [identifierCode, name, address, otherId] = [agent?.Id?.OrgId?.AnyBIC, agent?.Nm, agent?.PstlAdr?.AdrLine, agent?.Id?.PrvtId?.Othr];
    if identifierCode is string {
        swiftmt:MT50C fieldMt50C = {name: MT50C_NAME, IdnCd: {content: identifierCode, number: NUMBER1}};
        return fieldMt50C;
    }
    if otherId is pacsIsoRecord:GenericPersonIdentification2[] && otherId[0].Id is string {
        swiftmt:MT50L fieldMt50L = {name: MT50L_NAME, PrtyIdn: {content: getMandatoryField(otherId[0].Id), number: NUMBER1}};
        return fieldMt50L;
    }
    if name is string || address is pacsIsoRecord:Max70Text[] {
        swiftmt:MT50 fieldMt50 = {
            name: MT50_NAME,
            Nm: [{content: getMandatoryField(name), number: NUMBER1}],
            AdrsLine: getAddressLine(address)
        };
        return fieldMt50;
    }
    return ();
}

# Get the field 50a for the PACS004 message.
#
# + debtor - debtor information
# + institution - financial institution information
# + isOptionFPresent - flag to check if the option F is present
# + return - return the field 50a
isolated function getField50aForPacs004(pacsIsoRecord:PartyIdentification272? debtor,
        pacsIsoRecord:FinancialInstitutionIdentification23? institution, boolean isOptionFPresent = true)
    returns swiftmt:MT50A?|swiftmt:MT50K?|swiftmt:MT50F?|error {
    [string?, string?, pacsIsoRecord:Max70Text[]?, pacsIsoRecord:GenericPersonIdentification2[]?,
    pacsIsoRecord:GenericOrganisationIdentification3[]?, string?, string?, string?]
        [identifierCode, name, address, prvtOthrId, orgOthrId, townName, countryCode, instnPrtyIdn] = [];
    if debtor is pacsIsoRecord:PartyIdentification272 {
        [identifierCode, name, address, prvtOthrId, orgOthrId, townName, countryCode] = [
            debtor?.Id?.OrgId?.AnyBIC,
            debtor?.Nm,
            debtor?.PstlAdr?.AdrLine,
            debtor?.Id?.PrvtId?.Othr,
            debtor?.Id?.OrgId?.Othr,
            debtor?.PstlAdr?.TwnNm,
            debtor?.PstlAdr?.Ctry
        ];
    } else {
        [identifierCode, name, address, instnPrtyIdn, townName, countryCode] = [
            institution?.BICFI,
            institution?.Nm,
            institution?.PstlAdr?.AdrLine,
            institution?.ClrSysMmbId?.ClrSysId?.Cd,
            institution?.PstlAdr?.TwnNm,
            institution?.PstlAdr?.Ctry
        ];
    }
    swiftmt:PrtyIdn? partyIdentifier = ();

    if identifierCode is string {
        swiftmt:MT50A fieldMt50A = {
            name: MT50A_NAME,
            IdnCd: {content: getMandatoryField(identifierCode), number: NUMBER2}
        };
        return fieldMt50A;
    }
    if prvtOthrId is pacsIsoRecord:GenericPersonIdentification2[] && prvtOthrId[0].Id is string && isOptionFPresent {
        partyIdentifier = getPartyIdentifierForField50a(prvtOthrId[0], countryCode);
    }
    if orgOthrId is pacsIsoRecord:GenericOrganisationIdentification3[] && orgOthrId[0].Id is string && isOptionFPresent {
        partyIdentifier = getPartyIdentifierForField50a(orgOthrId[0], countryCode);
    }
    if (address is pacsIsoRecord:Max70Text[] || countryCode is string ||
        (name is string && institution is pacsIsoRecord:FinancialInstitutionIdentification23)) && isOptionFPresent {
        swiftmt:MT50F fieldMt50F = {
            name: MT50F_NAME,
            CdTyp: getCodeType(name, address, townName, countryCode, debtor?.PstlAdr),
            PrtyIdn: partyIdentifier is () ? {content: "/NOTPROVIDED", number: NUMBER1} : partyIdentifier,
            Nm: [{content: getMandatoryField(name), number: NUMBER3}],
            AdrsLine: getAddressLine(address, 5, true, townName, countryCode, debtor?.PstlAdr)
        };
        return fieldMt50F;
    }
    if name is string || instnPrtyIdn is string {
        swiftmt:MT50K fieldMt50K = {
            name: MT50K_NAME,
            Acc: instnPrtyIdn is string ? {content: "/NOTPROVIDED", number: NUMBER1} : (),
            Nm: [{content: instnPrtyIdn is string ? instnPrtyIdn : getMandatoryField(name), number: NUMBER2}],
            AdrsLine: getAddressLine(address)
        };
        return fieldMt50K;
    }
    return ();
}

# Construct field 51A for Swift MT .
#
# + institution - financial institution identification
# + return - return the field 51A
isolated function getField51A(pacsIsoRecord:FinancialInstitutionIdentification23? institution) returns swiftmt:MT51A? {
    [string?, string?] [identifierCode, partyIdentifier] = [institution?.BICFI, institution?.ClrSysMmbId?.ClrSysId?.Cd];
    if identifierCode is string {
        swiftmt:MT51A fieldMt51A = {
            name: MT51A_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, ""),
            IdnCd: {content: identifierCode, number: NUMBER3}
        };
        return fieldMt51A;
    }
    return ();
}

# Construct field 52 for Swift MT .
#
# + institution - financial institution identification
# + account - account identification
# + isOptionBPresent - option B flag
# + isOptionCPresent - option C flag
# + return - return the field 52
isolated function getField52(pacsIsoRecord:FinancialInstitutionIdentification23? institution,
        pacsIsoRecord:AccountIdentification4Choice? account = (), boolean isOptionBPresent = false,
        boolean isOptionCPresent = false) returns swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT52D?|error {
    [string?, string?, pacsIsoRecord:Max70Text[]?, string?, string?, string?] [identifierCode, name,
        address, partyIdentifier, iban, bban] = [
        institution?.BICFI,
        institution?.Nm,
        institution?.PstlAdr?.AdrLine,
        institution?.ClrSysMmbId?.ClrSysId?.Cd,
        account?.IBAN,
        account?.Othr?.Id
    ];
    if identifierCode is string {
        swiftmt:MT52A fieldMt52A = {
            name: "52A",
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            IdnCd: {content: identifierCode, number: NUMBER3}
        };
        return fieldMt52A;
    }
    if name is string || (address is pacsIsoRecord:Max70Text[] && !isOptionBPresent) {
        swiftmt:MT52D fieldMt52D = {
            name: "52D",
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            AdrsLine: getAddressLine(address),
            Nm: [{content: getMandatoryField(name), number: NUMBER3}]
        };
        return fieldMt52D;
    }
    if (partyIdentifier is string || !getAccountId(iban, bban).equalsIgnoreCaseAscii("")) && isOptionCPresent {
        swiftmt:MT52C fieldMt52C = {
            name: "52C",
            PrtyIdn: check getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban), NUMBER1).ensureType()
        };
        return fieldMt52C;
    }
    if (partyIdentifier is string || !getAccountId(iban, bban).equalsIgnoreCaseAscii("")) && isOptionBPresent {
        swiftmt:MT52B fieldMt52B = {
            name: "52B",
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            Lctn: getLocation(getAddressLine(address))
        };
        return fieldMt52B;
    }
    if partyIdentifier is string {
        swiftmt:MT52A fieldMt52A = {
            name: "52A",
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            IdnCd: {content: "", number: NUMBER3}
        };
        return fieldMt52A;
    }
    return ();
}

# Construct field 53 for Swift MT .
#
# + institution - financial institution identification
# + account - account identification
# + isOptionBPresent - option B flag
# + isOptionCPresent - option C flag
# + return - return the field 53
isolated function getField53(pacsIsoRecord:FinancialInstitutionIdentification23? institution,
        pacsIsoRecord:AccountIdentification4Choice? account, boolean isOptionBPresent = false, boolean isOptionCPresent = false)
    returns swiftmt:MT53A?|swiftmt:MT53B?|swiftmt:MT53C?|swiftmt:MT53D? {
    [string?, string?, pacsIsoRecord:Max70Text[]?, string?, string?, string?] [identifierCode, name,
        address, partyIdentifier, iban, bban] = [
        institution?.BICFI,
        institution?.Nm,
        institution?.PstlAdr?.AdrLine,
        institution?.ClrSysMmbId?.ClrSysId?.Cd,
        account?.IBAN,
        account?.Othr?.Id
    ];
    if identifierCode is string {
        swiftmt:MT53A fieldMt53A = {
            name: MT53A_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            IdnCd: {content: identifierCode, number: NUMBER3}
        };
        return fieldMt53A;
    }
    if name is string || (address is pacsIsoRecord:Max70Text[] && !isOptionBPresent) {
        swiftmt:MT53D fieldMt53D = {
            name: MT53D_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            AdrsLine: getAddressLine(address),
            Nm: [{content: getMandatoryField(name), number: NUMBER3}]
        };
        return fieldMt53D;
    }
    if !getAccountId(iban, bban).equalsIgnoreCaseAscii("") && isOptionCPresent {
        swiftmt:MT53C fieldMt53C = {
            name: MT53C_NAME,
            Acc: {content: getAccountId(iban, bban), number: NUMBER1}
        };
        return fieldMt53C;
    }
    if (partyIdentifier is string || !getAccountId(iban, bban).equalsIgnoreCaseAscii("")) && isOptionBPresent {
        swiftmt:MT53B fieldMt53B = {
            name: MT53B_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            Lctn: getLocation(getAddressLine(address))
        };
        return fieldMt53B;
    }
    if partyIdentifier is string {
        swiftmt:MT53A fieldMt53A = {
            name: MT53A_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            IdnCd: {content: "", number: NUMBER3}
        };
        return fieldMt53A;
    }
    return ();
}

# Construct field 53 for pacs 004
#
# + settlementAcct - settlement account
# + return - return the field 53
isolated function getField53ForPacs004(pacsIsoRecord:CashAccount40? settlementAcct) returns swiftmt:MT53B? {
    string? iban = settlementAcct?.Id?.IBAN;
    string? bban = settlementAcct?.Id?.Othr?.Id;
    if iban is string {
        return {
            name: MT53B_NAME,
            PrtyIdn: {content: iban, number: NUMBER2}
        };
    }
    if bban is string {
        return {
            name: MT53B_NAME,
            PrtyIdn: {content: bban, number: NUMBER2}
        };
    }
    return ();
}

# Construct field 54 for Swift MT .
#
# + institution - financial institution identification
# + account - account identification
# + isOptionBPresent - option B flag
# + return - return the field 54
isolated function getField54(pacsIsoRecord:FinancialInstitutionIdentification23? institution, pacsIsoRecord:AccountIdentification4Choice? account, boolean isOptionBPresent = false) returns swiftmt:MT54A?|swiftmt:MT54B?|swiftmt:MT54D? {
    [string?, string?, pacsIsoRecord:Max70Text[]?, string?, string?, string?] [identifierCode, name,
        address, partyIdentifier, iban, bban] = [
        institution?.BICFI,
        institution?.Nm,
        institution?.PstlAdr?.AdrLine,
        institution?.ClrSysMmbId?.ClrSysId?.Cd,
        account?.IBAN,
        account?.Othr?.Id
    ];
    if identifierCode is string {
        swiftmt:MT54A fieldMt54A = {
            name: MT54A_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            IdnCd: {content: identifierCode, number: NUMBER3}
        };
        return fieldMt54A;
    }
    if name is string || (address is pacsIsoRecord:Max70Text[] && !isOptionBPresent) {
        swiftmt:MT54D fieldMt54D = {
            name: MT54D_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            AdrsLine: getAddressLine(address),
            Nm: [{content: getMandatoryField(name), number: NUMBER3}]
        };
        return fieldMt54D;
    }
    if (partyIdentifier is string || !getAccountId(iban, bban).equalsIgnoreCaseAscii("")) && isOptionBPresent {
        swiftmt:MT54B fieldMt54B = {
            name: MT54B_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            Lctn: getLocation(getAddressLine(address))
        };
        return fieldMt54B;
    }
    if partyIdentifier is string {
        swiftmt:MT54A fieldMt54A = {
            name: MT54A_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            IdnCd: {content: "", number: NUMBER3}
        };
        return fieldMt54A;
    }
    return ();
}

# Construct field 55 for Swift MT .
#
# + institution - financial institution identification
# + account - account identification
# + isOptionBPresent - option B flag
# + return - return the field 55
isolated function getField55(pacsIsoRecord:FinancialInstitutionIdentification23? institution, pacsIsoRecord:AccountIdentification4Choice? account, boolean isOptionBPresent = false) returns swiftmt:MT55A?|swiftmt:MT55B?|swiftmt:MT55D? {
    [string?, string?, pacsIsoRecord:Max70Text[]?, string?, string?, string?] [identifierCode, name,
        address, partyIdentifier, iban, bban] = [institution?.BICFI, institution?.Nm, institution?.PstlAdr?.AdrLine, institution?.ClrSysMmbId?.ClrSysId?.Cd, account?.IBAN, account?.Othr?.Id];
    if identifierCode is string {
        swiftmt:MT55A fieldMt55A = {
            name: MT55A_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            IdnCd: {content: identifierCode, number: NUMBER3}
        };
        return fieldMt55A;
    }
    if name is string || (address is pacsIsoRecord:Max70Text[] && !isOptionBPresent) {
        swiftmt:MT55D fieldMt55D = {
            name: MT55D_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            AdrsLine: getAddressLine(address),
            Nm: [{content: getMandatoryField(name), number: NUMBER3}]
        };
        return fieldMt55D;
    }
    if (partyIdentifier is string || !getAccountId(iban, bban).equalsIgnoreCaseAscii("")) && isOptionBPresent {
        swiftmt:MT55B fieldMt55B = {
            name: MT55B_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            Lctn: getLocation(getAddressLine(address))
        };
        return fieldMt55B;
    }
    if partyIdentifier is string {
        swiftmt:MT55A fieldMt55A = {
            name: MT55A_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            IdnCd: {content: "", number: NUMBER3}
        };
        return fieldMt55A;
    }
    return ();
}

# Generates the MT56 field.
#
# + institution - financial institution identification
# + account - account identification
# + isOptionCPresent - option C flag
# + return - return the MT56 field
isolated function getField56(pacsIsoRecord:FinancialInstitutionIdentification23? institution,
        pacsIsoRecord:AccountIdentification4Choice? account = (), boolean isOptionCPresent = false)
    returns swiftmt:MT56A?|swiftmt:MT56C?|swiftmt:MT56D?|error {
    [string?, string?, pacsIsoRecord:Max70Text[]?, string?, string?, string?] [identifierCode, name,
        address, partyIdentifier, iban, bban] = [
        institution?.BICFI,
        institution?.Nm,
        institution?.PstlAdr?.AdrLine,
        institution?.ClrSysMmbId?.ClrSysId?.Cd,
        account?.IBAN,
        account?.Othr?.Id
    ];
    if identifierCode is string {
        swiftmt:MT56A fieldMt56A = {
            name: MT56A_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            IdnCd: {content: identifierCode, number: NUMBER3}
        };
        return fieldMt56A;
    }
    if name is string || address is pacsIsoRecord:Max70Text[] {
        swiftmt:MT56D fieldMt56D = {
            name: MT56D_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            AdrsLine: getAddressLine(address),
            Nm: [{content: getMandatoryField(name), number: NUMBER3}]
        };
        return fieldMt56D;
    }
    if (partyIdentifier is string || !getAccountId(iban, bban).equalsIgnoreCaseAscii("")) && isOptionCPresent {
        swiftmt:MT56C fieldMt56C = {
            name: MT56C_NAME,
            PrtyIdn: check getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban), NUMBER1).ensureType()
        };
        return fieldMt56C;
    }
    if partyIdentifier is string {
        swiftmt:MT56A fieldMt56A = {
            name: MT56A_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            IdnCd: {content: "", number: NUMBER3}
        };
        return fieldMt56A;
    }
    return ();
}

# Generates the MT57 field.
#
# + institution - financial institution identification
# + account - account identification 
# + isOptionBPresent - option B flag
# + isOptionCPresent - option C flag
# + return - return the MT57 field
isolated function getField57(pacsIsoRecord:FinancialInstitutionIdentification23? institution,
        pacsIsoRecord:AccountIdentification4Choice? account, boolean isOptionBPresent = false, boolean isOptionCPresent = false)
    returns swiftmt:MT57A?|swiftmt:MT57B?|swiftmt:MT57C?|swiftmt:MT57D?|error {
    [string?, string?, pacsIsoRecord:Max70Text[]?, string?, string?, string?] [identifierCode, name,
        address, partyIdentifier, iban, bban] = [
        institution?.BICFI,
        institution?.Nm,
        institution?.PstlAdr?.AdrLine,
        institution?.ClrSysMmbId?.ClrSysId?.Cd,
        account?.IBAN,
        account?.Othr?.Id
    ];
    if identifierCode is string {
        swiftmt:MT57A fieldMt57A = {
            name: MT57A_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            IdnCd: {content: identifierCode, number: NUMBER3}
        };
        return fieldMt57A;
    }
    if name is string || (address is pacsIsoRecord:Max70Text[] && !isOptionBPresent) {
        swiftmt:MT57D fieldMt57D = {
            name: MT57D_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            AdrsLine: getAddressLine(address),
            Nm: [{content: getMandatoryField(name), number: NUMBER3}]
        };
        return fieldMt57D;
    }
    if (partyIdentifier is string || !getAccountId(iban, bban).equalsIgnoreCaseAscii("")) && isOptionCPresent {
        swiftmt:MT57C fieldMt57C = {
            name: MT57C_NAME,
            PrtyIdn: check getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban), NUMBER1).ensureType()
        };
        return fieldMt57C;
    }
    if (partyIdentifier is string || !getAccountId(iban, bban).equalsIgnoreCaseAscii("")) && isOptionBPresent {
        swiftmt:MT57B fieldMt57B = {
            name: MT57B_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            Lctn: getLocation(getAddressLine(address))
        };
        return fieldMt57B;
    }
    if partyIdentifier is string {
        swiftmt:MT57A fieldMt57A = {
            name: MT57A_NAME,
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            IdnCd: {content: "", number: NUMBER3}
        };
        return fieldMt57A;
    }
    return ();
}

# Construct field 58 for Swift MT .
#
# + institution - financial institution identification
# + account - account identification
# + return - return the field 58
isolated function getField58(pacsIsoRecord:FinancialInstitutionIdentification23? institution, pacsIsoRecord:AccountIdentification4Choice? account) returns swiftmt:MT58A?|swiftmt:MT58D?|error {
    [string?, string?, pacsIsoRecord:Max70Text[]?, string?, string?, string?] [identifierCode, name,
        address, partyIdentifier, iban, bban] = [
        institution?.BICFI,
        institution?.Nm,
        institution?.PstlAdr?.AdrLine,
        institution?.ClrSysMmbId?.ClrSysId?.Cd,
        account?.IBAN,
        account?.Othr?.Id
    ];
    if identifierCode is string {
        swiftmt:MT58A fieldMt58A = {
            name: "58A",
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            IdnCd: {content: identifierCode, number: NUMBER3}
        };
        return fieldMt58A;
    }
    if name is string || address is pacsIsoRecord:Max70Text[] {
        swiftmt:MT58D fieldMt58D = {
            name: "58D",
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            AdrsLine: getAddressLine(address),
            Nm: [{content: getMandatoryField(name), number: NUMBER3}]
        };
        return fieldMt58D;
    }
    if partyIdentifier is string {
        swiftmt:MT58A fieldMt58A = {
            name: "58A",
            PrtyIdn: getPartyIdentifierOrAccount(partyIdentifier, getAccountId(iban, bban)),
            IdnCd: {content: "", number: NUMBER3}
        };
        return fieldMt58A;
    }
    return ();
}

# Construct field 59 for Swift MT .
#
# + creditor - creditor party identification
# + account - account identification
# + isOptionFPresent - option F flag
# + return - return the field 59
isolated function getField59a(pacsIsoRecord:PartyIdentification272? creditor, pacsIsoRecord:AccountIdentification4Choice? account, boolean isOptionFPresent = true) returns swiftmt:MT59?|swiftmt:MT59A?|swiftmt:MT59F? {
    [string?, string?, pacsIsoRecord:Max70Text[]?, string?, string?, string?, string?]
        [identifierCode, name, address, iban, bban, townName, countryCode] = [
        creditor?.Id?.OrgId?.AnyBIC,
        creditor?.Nm,
        creditor?.PstlAdr?.AdrLine,
        account?.IBAN,
        account?.Othr?.Id,
        creditor?.PstlAdr?.TwnNm,
        creditor?.PstlAdr?.Ctry
    ];
    if identifierCode is string {
        swiftmt:MT59A fieldMt59A = {
            name: MT59A_NAME,
            Acc: getAccount(getAccountId(iban, bban)),
            IdnCd: {content: identifierCode, number: NUMBER2}
        };
        return fieldMt59A;
    }
    if ((name is string && address is pacsIsoRecord:Max70Text[]) || (townName is string || countryCode is string)) && isOptionFPresent {
        swiftmt:MT59F fieldMt59F = {
            name: MT59F_NAME,
            CdTyp: getCodeType(name, address, townName, countryCode, creditor?.PstlAdr),
            Acc: getAccount(getAccountId(iban, bban)),
            Nm: [{content: getMandatoryField(name), number: NUMBER3}],
            AdrsLine: getAddressLine(address, 5, true, townName, countryCode, creditor?.PstlAdr)
        };
        return fieldMt59F;
    }
    if name is string || address is pacsIsoRecord:Max70Text[] || !(getAccountId(iban, bban).equalsIgnoreCaseAscii("")) {
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

# Get the field 59a for the PACS004 message.
#
# + creditor - creditor information
# + institution - financial institution information
# + isOptionFPresent - flag to check if the option F is present
# + return - return the field 59a
isolated function getField59aForPacs004(pacsIsoRecord:PartyIdentification272? creditor,
        pacsIsoRecord:FinancialInstitutionIdentification23? institution, boolean isOptionFPresent = true)
    returns swiftmt:MT59?|swiftmt:MT59A?|swiftmt:MT59F? {
    [string?, string?, pacsIsoRecord:Max70Text[]?, string?, string?, string?]
        [identifierCode, name, address, townName, countryCode, partyIdentifier] = [];
    if creditor is pacsIsoRecord:PartyIdentification272 {
        [identifierCode, name, address, townName, countryCode, partyIdentifier] = [
            creditor?.Id?.OrgId?.AnyBIC,
            creditor?.Nm,
            creditor?.PstlAdr?.AdrLine,
            creditor?.PstlAdr?.TwnNm,
            creditor?.PstlAdr?.Ctry
        ];
    } else {
        [identifierCode, name, address, townName, countryCode, partyIdentifier] = [
            institution?.BICFI,
            institution?.Nm,
            institution?.PstlAdr?.AdrLine,
            institution?.PstlAdr?.TwnNm,
            institution?.PstlAdr?.Ctry,
            institution?.ClrSysMmbId?.ClrSysId?.Cd
        ];
    }
    if identifierCode is string {
        swiftmt:MT59A fieldMt59A = {
            name: MT59A_NAME,
            IdnCd: {content: identifierCode, number: NUMBER2}
        };
        return fieldMt59A;
    }
    if (address is pacsIsoRecord:Max70Text[] || countryCode is string ||
        (name is string && institution is pacsIsoRecord:FinancialInstitutionIdentification23)) && isOptionFPresent {
        swiftmt:MT59F fieldMt59F = {
            name: MT59F_NAME,
            CdTyp: getCodeType(name, address, townName, countryCode,
                        creditor?.PstlAdr is () ? institution?.PstlAdr : creditor?.PstlAdr),
            Nm: [{content: getMandatoryField(name), number: NUMBER3}],
            AdrsLine: getAddressLine(address, 5, true, townName, countryCode,
                        creditor?.PstlAdr is () ? institution?.PstlAdr : creditor?.PstlAdr)
        };
        return fieldMt59F;
    }
    if name is string || partyIdentifier is string {
        swiftmt:MT59 fieldMt59 = {
            name: MT59_NAME,
            Acc: partyIdentifier is string ? {content: "/NOTPROVIDED", number: NUMBER1} : (),
            Nm: [{content: partyIdentifier is string ? partyIdentifier : getMandatoryField(name), number: NUMBER2}],
            AdrsLine: getAddressLine(address)
        };
        return fieldMt59;
    }
    return ();
}

# Construct balance information for Swift MT .
#
# + balanceArray - balance array
# + return - return the balance information 
isolated function getBalanceInformation(camtIsoRecord:CashBalance8[]? balanceArray) returns [swiftmt:MT60F, swiftmt:MT60M[], swiftmt:MT62F, swiftmt:MT62M[], swiftmt:MT64[], swiftmt:MT65[]]|error {
    [swiftmt:MT60F, swiftmt:MT60M[], swiftmt:MT62F, swiftmt:MT62M[], swiftmt:MT64[], swiftmt:MT65[]]
        [field60F, field60M, field62F, field62M, field64, field65] = [
        {
            Cd: {content: "NOTPROVIDED", number: NUMBER1},
            Dt: {content: ""},
            Ccy: {content: ""},
            Amnt: {content: ""}
        },
        [],
        {
            Cd: {content: "NOTPROVIDED", number: NUMBER1},
            Dt: {content: ""},
            Ccy: {content: ""},
            Amnt: {content: ""}
        },
        [],
        [],
        []
    ];
    if balanceArray is camtIsoRecord:CashBalance8[] {
        foreach camtIsoRecord:CashBalance8 balance in balanceArray {
            if balance.Tp.CdOrPrtry?.Cd == "OPBD" {
                field60F = {
                    name: MT60F_NAME,
                    Cd: {content: getCrdtOrDbtCode(balance.CdtDbtInd), number: NUMBER1},
                    Dt: {content: convertToSWIFTStandardDate(balance.Dt.Dt), number: NUMBER2},
                    Ccy: {content: balance.Amt.Ccy, number: NUMBER3},
                    Amnt: {content: convertDecimalToSwiftDecimal(balance.Amt.content), number: NUMBER4}
                };
                continue;
            }
            if balance.Tp.CdOrPrtry?.Cd == "OPBD/INTM" {
                field60M.push({
                    name: MT60M_NAME,
                    Cd: {content: getCrdtOrDbtCode(balance.CdtDbtInd), number: NUMBER1},
                    Dt: {content: convertToSWIFTStandardDate(balance.Dt.Dt), number: NUMBER2},
                    Ccy: {content: balance.Amt.Ccy, number: NUMBER3},
                    Amnt: {content: convertDecimalToSwiftDecimal(balance.Amt.content), number: NUMBER4}
                });
                continue;
            }
            if balance.Tp.CdOrPrtry?.Cd == "CLBD" {
                field62F = {
                    name: MT62F_NAME,
                    Cd: {content: getCrdtOrDbtCode(balance.CdtDbtInd), number: NUMBER1},
                    Dt: {content: convertToSWIFTStandardDate(balance.Dt.Dt), number: NUMBER2},
                    Ccy: {content: balance.Amt.Ccy, number: NUMBER3},
                    Amnt: {content: convertDecimalToSwiftDecimal(balance.Amt.content), number: NUMBER4}
                };
                continue;
            }
            if balance.Tp.CdOrPrtry?.Cd == "CLBD/INTM" {
                field62M.push({
                    name: MT62M_NAME,
                    Cd: {content: getCrdtOrDbtCode(balance.CdtDbtInd), number: NUMBER1},
                    Dt: {content: convertToSWIFTStandardDate(balance.Dt.Dt), number: NUMBER2},
                    Ccy: {content: balance.Amt.Ccy, number: NUMBER3},
                    Amnt: {content: convertDecimalToSwiftDecimal(balance.Amt.content), number: NUMBER4}
                });
                continue;
            }
            if balance.Tp.CdOrPrtry?.Cd == "CLAV" {
                field64.push({
                    name: MT64_NAME,
                    Cd: {content: getCrdtOrDbtCode(balance.CdtDbtInd), number: NUMBER1},
                    Dt: {content: convertToSWIFTStandardDate(balance.Dt.Dt), number: NUMBER2},
                    Ccy: {content: balance.Amt.Ccy, number: NUMBER3},
                    Amnt: {content: convertDecimalToSwiftDecimal(balance.Amt.content), number: NUMBER4}
                });
                continue;
            }
            if balance.Tp.CdOrPrtry?.Cd == "FWAV" {
                field65.push({
                    name: MT65_NAME,
                    Cd: {content: getCrdtOrDbtCode(balance.CdtDbtInd), number: NUMBER1},
                    Dt: {content: convertToSWIFTStandardDate(balance.Dt.Dt), number: NUMBER2},
                    Ccy: {content: balance.Amt.Ccy, number: NUMBER3},
                    Amnt: {content: convertDecimalToSwiftDecimal(balance.Amt.content), number: NUMBER4}
                });
                continue;
            }
        }
    }
    return [field60F, field60M, field62F, field62M, field64, field65];
}

# Construct field 61 for Swift MT .
#
# + entries - report entry array
# + return - return the field 61
isolated function getField61(camtIsoRecord:ReportEntry14[]? entries) returns swiftmt:MT61[] {
    swiftmt:MT61[] field61 = [];
    if entries is camtIsoRecord:ReportEntry14[] {
        foreach camtIsoRecord:ReportEntry14 entry in entries {
            string date = entry.ValDt?.Dt ?: entry.ValDt?.DtTm ?: "";
            string ntryDt = entry.BookgDt?.Dt ?: entry.BookgDt?.DtTm ?: "";
            string debitCreditMark = getCrdtOrDbtCode(entry.CdtDbtInd, entry.RvslInd ?: false);
            string amount = convertDecimalToSwiftDecimal(entry.Amt.content);
            string txnType = "N";
            string idnCd = "TRF";
            string refForAccOwner = "NONREF";
            string endToEndId = "";
            string instrId = "";
            camtIsoRecord:EntryDetails13[]? ntryDtls = entry.NtryDtls;
            if ntryDtls is camtIsoRecord:EntryDetails13[] {
                camtIsoRecord:EntryTransaction14[]? txDtls = ntryDtls[0].TxDtls;
                if txDtls is camtIsoRecord:EntryTransaction14[] {
                    endToEndId = txDtls[0].Refs?.EndToEndId ?: "";
                    instrId = txDtls[0].Refs?.InstrId ?: "";
                }
            }
            if entry.CdtDbtInd == "CRDT" {
                if endToEndId != "" {
                    if !endToEndId.matches(re `/.*|.*/|.*//.*`) {
                        if endToEndId.length() > 16 {
                            log:printWarn(getSwiftLogMessage(TRUNC_X, "T0000M"));
                            refForAccOwner = truncate(endToEndId, 16);
                        } else {
                            refForAccOwner = endToEndId;
                        }
                    } else if endToEndId.matches(re `/.*|.*/|.*//.*`) {
                        log:printWarn(getSwiftLogMessage(WARNING, "T14001"));
                    }
                }
            } else {
                if instrId != "" {
                    if !instrId.matches(re `/.*|.*/|.*//.*`) {
                        if instrId.length() > 16 {
                            log:printWarn(getSwiftLogMessage(TRUNC_X, "T0000M"));
                            refForAccOwner = truncate(instrId, 16);
                        } else {
                            refForAccOwner = instrId;
                        }
                    }
                    else if instrId.matches(re `/.*|.*/|.*//.*`) {
                        log:printWarn(getSwiftLogMessage(WARNING, "T14001"));
                    }
                }
            }
            field61.push({
                name: MT61_NAME,
                ValDt: {content: convertToSWIFTStandardDate(date), number: NUMBER1},
                NtryDt: ntryDt is "" ? () : {content: convertToSWIFTStandardDate(ntryDt), number: NUMBER2},
                Cd: {content: debitCreditMark, number: NUMBER3},
                Amnt: {content: amount, number: NUMBER5},
                TranTyp: {content: txnType, number: NUMBER6},
                IdnCd: {content: idnCd, number: NUMBER7},
                RefAccOwn: {content: refForAccOwner, number: NUMBER8}
                //not mapped in translation portal but has mappings in pdf.
                //RefAccSerInst: {content: getField21Content(entry.AcctSvcrRef), number:NUMBER9},
                //SpmtDtls: transaxion?.AddtlTxInf is () ? () : { content: transaxion?.AddtlTxInf.toString(), number: NUMBER10} 
            });
        }
    }
    return field61;
}

# Construct field 70 for Swift MT .
#
# + remmitanceInfoArray - remmitance information array
# + return - return the field 70
isolated function getField70(pacsIsoRecord:Max140Text[]? remmitanceInfoArray) returns swiftmt:MT70? {
    string information = "";
    int count = 1;
    if remmitanceInfoArray is pacsIsoRecord:Max140Text[] {
        if remmitanceInfoArray.length() == 0 {
            return ();
        }
        foreach int i in 0 ... remmitanceInfoArray.length() - 1 {
            if i == remmitanceInfoArray.length() - 1 || count == 4 {
                information += remmitanceInfoArray[i];
                break;
            }
            information += remmitanceInfoArray[i] + "\n";
            count += 1;
        }
        return {
            name: "70",
            Nrtv: {content: information, number: NUMBER1}
        };
    }
    return ();
}

# Construct field 71A for Swift MT .
#
# + trfTx - credit/direct debit transfer transaction
# + chrgBr - charge bearer type 
# + isTransaction - transaction flag
# + return - return the field 71A
isolated function getRepeatingField71A(pacsIsoRecord:CreditTransferTransaction64[]|pacsIsoRecord:DirectDebitTransactionInformation31[] trfTx,
        pacsIsoRecord:ChargeBearerType1Code? chrgBr = (), boolean isTransaction = false) returns swiftmt:MT71A? {
    pacsIsoRecord:ChargeBearerType1Code? chargeBearer = trfTx[0].ChrgBr;
    foreach int i in 1 ... trfTx.length() - 1 {
        if chargeBearer != trfTx[i].ChrgBr {
            return {
                name: MT71A_NAME,
                Cd: getDetailsOfChargesFromChargeBearerType1Code(chrgBr)
            };
        }
    }
    if isTransaction {
        return ();
    }
    return {
        name: MT71A_NAME,
        Cd: getDetailsOfChargesFromChargeBearerType1Code(chargeBearer)
    };
}

# Construct field 71B for Swift MT .
#
# + chrgsBrkdwnArray - charges breakdown array
# + return - return the field 71B
isolated function getField71B(camtIsoRecord:ChargesBreakdown1[]? chrgsBrkdwnArray) returns swiftmt:MT71B {
    if chrgsBrkdwnArray is camtIsoRecord:ChargesBreakdown1[] {
        string output = "";
        foreach camtIsoRecord:ChargesBreakdown1 chrgsBrkdwn in chrgsBrkdwnArray {
            string code = chrgsBrkdwn.Tp?.Cd is string ? mapChrgBreakdownCdToMt(chrgsBrkdwn.Tp?.Cd.toString()) : "NOTPROVIDED";
            string currency = chrgsBrkdwn.Amt.Ccy;
            string amount = convertDecimalToSwiftDecimal(chrgsBrkdwn.Amt.content);
            string creditDebitIndicator = chrgsBrkdwn.CdtDbtInd == "DBIT" ? "D" : chrgsBrkdwn.CdtDbtInd == "CRDT" ? "C" : "";
            output = output + "/" + code + "/" + currency + amount + "/" + creditDebitIndicator;
        }

        return {name: MT71B_NAME, Nrtv: {content: appendSubFieldToTextField(output), number: NUMBER1}};
    }
    return {name: MT71B_NAME, Nrtv: {content: "/NOTPROVIDED/", number: NUMBER1}};
}

# Convert the charges from the MX message to the MT71F message.
#
# + charges - The charges from the MX message.
# + chargeBearer - The charge bearer from the MX message.
# + return - The MT71F message or an error if the conversion fails.
isolated function convertCharges16toMT71F(painIsoRecord:Charges16[]? charges, string? chargeBearer) returns swiftmt:MT71F[]?|error {

    if chargeBearer == "CRED" || chargeBearer == "SHAR" {
        if charges is pacsIsoRecord:Charges16[] {
            swiftmt:MT71F[] result = [];
            foreach painIsoRecord:Charges16 charge in charges {
                swiftmt:MT71F mt71f = {
                    name: MT71F_NAME,
                    Ccy: {content: charge.Amt.Ccy, number: NUMBER1},
                    Amnt: {content: convertDecimalToSwiftDecimal(charge.Amt.content), number: NUMBER2}
                };

                result.push(mt71f);
            }
            return result;
        }
    }
    return ();
}

# Convert the charges from the MX message to the MT71G message.
#
# + charges - The charges from the MX message.
# + chargeBearer - The charge bearer from the MX message.
# + return - The MT71G message or an error if the conversion fails.
isolated function convertCharges16toMT71G(painIsoRecord:Charges16[]? charges, string? chargeBearer) returns swiftmt:MT71G?|error {
    if charges == () || charges.length() == 0 {
        return ();
    }

    if chargeBearer != "DEBT" {
        return ();
    }

    decimal mxTotalAmount = 0.0;
    string mtCurrency = "";
    string mtAmount = "";

    foreach painIsoRecord:Charges16 charge in charges {
        string currentCurrency = charge.Amt.Ccy;
        if mtCurrency.equalsIgnoreCaseAscii("") {
            mtCurrency = currentCurrency;
        }
        if mtCurrency != currentCurrency {
            return error("All charges must have the same currency (Error Code: T20045).");
        }

        mxTotalAmount += check charge.Amt.content.ensureType(decimal);
    }

    mtAmount = convertDecimalToSwiftDecimal(mxTotalAmount);
    if mtAmount.length() > 15 {
        return error("Amount exceeds maximum length of 15 characters (Error Codes: T20039, T13005).");
    }

    if mtAmount == "0" {
        return error("Amount cannot be zero (Error Code: T13009).");
    }

    swiftmt:MT71G mt71g = {
        name: MT71G_NAME,
        Ccy: {content: mtCurrency, number: NUMBER1},
        Amnt: {content: mtAmount, number: NUMBER2}
    };

    return mt71g;
}

# Generates the MT72 field.
#
# + instruction1 - instruction for creditor agent
# + instruction2 - instruction for next agent
# + prvsInstgAgt1 - previous instructing agent
# + dbtrAgt - debtor agent
# + paymentTypeInfo - payment type information
# + prvsInstgAgt2 - previous instructing agent 2
# + prvsInstgAgt3 - previous instructing agent 3
# + intrmyAgt2 - intermediary agent 2
# + intrmyAgt3 - intermediary agent 3
# + remmitanceInfo - remittance information
# + return - return the MT72 field
isolated function getField72(pacsIsoRecord:InstructionForCreditorAgent3[]? instruction1,
        pacsIsoRecord:InstructionForNextAgent1[]? instruction2, pacsIsoRecord:BranchAndFinancialInstitutionIdentification8?
        prvsInstgAgt1 = (), pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? dbtrAgt = (),
        pacsIsoRecord:PaymentTypeInformation28? paymentTypeInfo = (), pacsIsoRecord:BranchAndFinancialInstitutionIdentification8?
        prvsInstgAgt2 = (), pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? prvsInstgAgt3 = (),
        pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? intrmyAgt2 = (),
        pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? intrmyAgt3 = (),
        pacsIsoRecord:Max140Text[]? remmitanceInfo = ()) returns swiftmt:MT72? {
    [string, int] [narration, lineCount] = getFieldSndRcvrInfoFromAgts(instruction1, instruction2, prvsInstgAgt1,
            dbtrAgt, prvsInstgAgt2, prvsInstgAgt3, intrmyAgt2, intrmyAgt3, remmitanceInfo);
    narration = getSndRcvrInfoFromMsclns(paymentTypeInfo?.SvcLvl, paymentTypeInfo?.CtgyPurp, paymentTypeInfo?.LclInstrm,
            narration, lineCount);
    if narration.equalsIgnoreCaseAscii("") {
        return ();
    }
    return {
        name: MT72_NAME,
        Cd: {content: narration, number: NUMBER1}
    };
}

# Construct field 72 for pacs 004
#
# + instructionId - instruction id
# + endToEndId - end to end id
# + returnReasonArray - return reason array
# + chargesInfoArray - charges information array
# + return - return the field 72
isolated function getField72ForPacs004(string? instructionId, string? endToEndId, pacsIsoRecord:PaymentReturnReason7[]? returnReasonArray, pacsIsoRecord:Charges16[]? chargesInfoArray = ()) returns swiftmt:MT72? {
    string narration = "";
    int lineCount = 0;
    int count = 0;

    if returnReasonArray is pacsIsoRecord:PaymentReturnReason7[] {
        string? reasonCode = returnReasonArray[0].Rsn?.Cd;
        if reasonCode is string && reasonCode.matches(re `[A-Z]{2}[0-9]{2}`) {
            narration = "/" + reasonCode + "/";
            pacsIsoRecord:Max105Text[]? additionalInfo = returnReasonArray[0].AddtlInf;
            if additionalInfo is pacsIsoRecord:Max105Text[] {
                foreach string information in additionalInfo {
                    [narration, lineCount] = appendContentToNarration(information, narration, lineCount);
                }
            }
            count += 1;
        }
    }
    if instructionId is string && lineCount < 4 {
        if count == 0 {
            narration += "/MREF/";
        } else {
            narration += "\n/MREF/";
            lineCount += 1;
        }
        [narration, lineCount] = appendContentToNarration(instructionId, narration, lineCount);
        count += 1;
    }
    if endToEndId is string && lineCount < 4 {
        if count == 0 {
            narration += "/TREF/";
        } else {
            narration += "\n/TREF/";
            lineCount += 1;
        }
        [narration, lineCount] = appendContentToNarration(truncate(endToEndId, 16), narration, lineCount);
        count += 1;
    }
    if chargesInfoArray is pacsIsoRecord:Charges16[] && lineCount < 4 {
        foreach pacsIsoRecord:Charges16 chargeInfo in chargesInfoArray {
            if lineCount < 4 {
                if count == 0 {
                    narration += "/CHGS/";
                } else {
                    narration += "\n/CHGS/";
                    lineCount += 1;
                }
                [narration, lineCount] = appendContentToNarration(convertDecimalToSwiftDecimal(chargeInfo.Amt?.content), narration, lineCount);
                count += 1;
            }
        }
    }

    if count == 0 {
        return ();
    }

    return {
        name: MT72_NAME,
        Cd: {content: "/RETN/99\n" + narration, number: NUMBER1}
    };
}

# Construct field 72 for pacs 009
#
# + cdtTrfTxInf - credit transfer transaction information
# + return - return the field 72
isolated function getField72ForPacs009(pacsIsoRecord:CreditTransferTransaction62 cdtTrfTxInf) returns swiftmt:MT72? {
    string output = "";
    int currentLine = 1;

    // IntermryAgt2, 3
    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? intrmyAgt2 = cdtTrfTxInf.IntrmyAgt2;
    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? intrmyAgt3 = cdtTrfTxInf.IntrmyAgt3;
    string intermryAgts = getIntrmyAgtsForPacs009Field72(intrmyAgt2, intrmyAgt3);
    [output, currentLine] = addGroupToField72(intermryAgts, output, currentLine);

    // Service Level
    pacsIsoRecord:ServiceLevel8Choice[] svcLvl = cdtTrfTxInf.PmtTpInf?.SvcLvl ?: [];
    string svcl = "";
    foreach pacsIsoRecord:ServiceLevel8Choice svc in svcLvl {
        string code = svc.Cd ?: "";
        if code != "" && !code.matches(re `G00[1-9]`) {
            svcl += "/SVCL/" + svc.Cd.toString();
        } else if svc.Prtry is string {
            svcl += "/SVCL/" + svc.Prtry.toString();
        }
    }
    [output, currentLine] = addGroupToField72(svcl, output, currentLine);

    // Local Instrments
    string locins = "";
    if cdtTrfTxInf.PmtTpInf?.LclInstrm?.Cd is string {
        locins += "/LOCINS/" + cdtTrfTxInf.PmtTpInf?.LclInstrm?.Cd.toString();
    } else if cdtTrfTxInf.PmtTpInf?.LclInstrm?.Prtry is string {
        locins += "/LOCINS/" + cdtTrfTxInf.PmtTpInf?.LclInstrm?.Prtry.toString();
    }
    [output, currentLine] = addGroupToField72(locins, output, currentLine);

    // Purpose
    string purpose = "";
    if cdtTrfTxInf.Purp?.Cd is string {
        purpose += cdtTrfTxInf.Purp?.Cd.toString();
    } else if cdtTrfTxInf.Purp?.Prtry is string {
        purpose += cdtTrfTxInf.Purp?.Prtry.toString();
    }
    [output, currentLine] = addGroupToField72(purpose, output, currentLine);

    // Category Purpose
    string cp = "";
    if currentLine != 1 {
        output += "\r\n";
    }
    if cdtTrfTxInf.PmtTpInf?.CtgyPurp?.Cd is string {
        cp += "/CtgyPurp/" + cdtTrfTxInf.PmtTpInf?.CtgyPurp?.Cd.toString();
    } else if cdtTrfTxInf.PmtTpInf?.CtgyPurp?.Prtry is string {
        cp += "/CtgyPurp/" + cdtTrfTxInf.PmtTpInf?.CtgyPurp?.Prtry.toString();
    }
    [output, currentLine] = addGroupToField72(cp, output, currentLine);

    // Instruction for Creditor Agent
    [string, string, string, string] [udlc, acc, phob, telb] = getInstructionAgentforPacs009Field72(cdtTrfTxInf);
    [output, currentLine] = addGroupToField72(udlc, output, currentLine);
    [output, currentLine] = addGroupToField72(acc, output, currentLine);
    [output, currentLine] = addGroupToField72(phob, output, currentLine);
    [output, currentLine] = addGroupToField72(telb, output, currentLine);

    // Purpose
    if cdtTrfTxInf.Purp is pacsIsoRecord:Purpose2Choice {
        string purp = "";
        if cdtTrfTxInf.Purp?.Cd is string {
            purp = cdtTrfTxInf.Purp?.Cd.toString();
        } else if cdtTrfTxInf.Purp?.Prtry is string {
            purp = cdtTrfTxInf.Purp?.Prtry.toString();
        }
        if purp != "" {
            purp = "/PURP/" + purp;
        }
        [output, currentLine] = addGroupToField72(purp, output, currentLine);
    }

    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8?[] agents = [
        cdtTrfTxInf.DbtrAgt,
        cdtTrfTxInf.PrvsInstgAgt1,
        cdtTrfTxInf.PrvsInstgAgt2,
        cdtTrfTxInf.PrvsInstgAgt3
    ];
    // Debtor Agent & Previous Instructing Agent 1,2,3
    foreach pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? agent in agents {
        string agt = "";
        if agent?.FinInstnId?.BICFI is string {
            agt = agent?.FinInstnId?.BICFI.toString();
        } else if agent?.FinInstnId?.Nm is string {
            agt = agent?.FinInstnId?.Nm.toString();
        } else if agent?.FinInstnId?.ClrSysMmbId is pacsIsoRecord:ClearingSystemMemberIdentification2 {
            agt = agent?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd ?: "";
            agt += agent?.FinInstnId?.ClrSysMmbId?.MmbId ?: "";
        }
        if agt != "" {
            agt = "/INS/" + agt;
            [output, currentLine] = addGroupToField72(agt, output, currentLine);
        }
    }

    // Remittance Information
    [string, string] [bnfString, tsuString] = getRemittanceInfoForField72(cdtTrfTxInf.RmtInf?.Ustrd);
    if bnfString != "" {
        [output, currentLine] = addGroupToField72("/BNF/" + bnfString, output, currentLine);
    }
    if tsuString != "" {
        [output, currentLine] = addGroupToField72("/TSU/" + tsuString, output, currentLine);
    }
    if output != "" {
        return {
            name: MT72_NAME,
            Cd: {content: output, number: NUMBER1}
        };
    }
    return ();
}

# Construct field 72 for Swift MT .
#
# + groupContent - group content
# + filed72Content - field 72 content
# + currentLine - current line
# + maxlines - maximum lines
# + maxlineLength - maximum line length
# + return - return the field 72 content and the current line
isolated function addGroupToField72(string groupContent, string filed72Content, int currentLine, int maxlines = 6, int maxlineLength = 35) returns [string, int] {
    string content = filed72Content;
    int line = currentLine;
    if groupContent == "" {
        return [content, line];
    }
    if currentLine != 1 {
        content += "\r\n";
    }
    content += appendSubFieldToTextField(groupContent, currentLine, maxlines, maxlineLength);
    line += 1;
    return [content, line];
}

# Get the intermediary agent for field 72.
#
# + intrmyAgt2 - intermediary agent 2 
# + intrmyAgt3 - intermediary agent 3
# + return - return the intermediary agent
isolated function getIntrmyAgtsForPacs009Field72(pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? intrmyAgt2,
        pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? intrmyAgt3) returns string {

    string field72 = "";
    pacsIsoRecord:BranchAndFinancialInstitutionIdentification8?[] agents = [intrmyAgt2, intrmyAgt3];
    foreach pacsIsoRecord:BranchAndFinancialInstitutionIdentification8? agent in agents {
        if agent?.FinInstnId?.BICFI is string && agent?.FinInstnId?.BICFI != EMPTY_STRING {
            field72 = "/INTA/" + agent?.FinInstnId?.BICFI.toString();
        } else if agent?.FinInstnId?.Nm is string {
            string text = "";
            string name = agent?.FinInstnId?.Nm ?: "";
            if agent?.FinInstnId?.PstlAdr?.Ctry is string {
                string twnName = agent?.FinInstnId?.PstlAdr?.TwnNm ?: "";
                text += truncate(name, 58);
                text += "(" + agent?.FinInstnId?.PstlAdr?.Ctry.toString();
                text += "(" + twnName;
            } else {
                text += truncate(name, 62);
            }
            field72 = "/INTA/" + text;
        } else if agent?.FinInstnId?.ClrSysMmbId is pacsIsoRecord:ClearingSystemMemberIdentification2 {
            string text = agent?.FinInstnId?.ClrSysMmbId?.ClrSysId?.Cd ?: "";
            text += agent?.FinInstnId?.ClrSysMmbId?.MmbId ?: "";
            field72 = "/INTA/" + text;
        }
    }
    return field72;
}

# Get the instruction agent for field 72.
#
# + cdtTrfTxInf - credit transfer transaction
# + return - return the instruction agent
isolated function getInstructionAgentforPacs009Field72(pacsIsoRecord:CreditTransferTransaction62 cdtTrfTxInf) returns [string, string, string, string] {
    string instruction = "\r\n";
    string:RegExp newLine = re `\r\n`;
    pacsIsoRecord:InstructionForCreditorAgent3[]? instrForCdtrAgt = cdtTrfTxInf.InstrForCdtrAgt;
    if instrForCdtrAgt is pacsIsoRecord:InstructionForCreditorAgent3[] {
        int maxAgentCount = instrForCdtrAgt.length() > 2 ? 1 : instrForCdtrAgt.length() - 1;
        foreach int i in 0 ... maxAgentCount {
            pacsIsoRecord:InstructionForCreditorAgent3 agt = instrForCdtrAgt[i];
            if agt.Cd is string {
                instruction += "/" + agt.Cd.toString() + "/";
            }
            instruction += agt.InstrInf ?: "";
        }
    }
    string:RegExp doubleNewLine = re `\r\n\r\n`;
    instruction = doubleNewLine.replaceAll(instruction, "\r\n");
    string[] elements = newLine.split(instruction);
    string udlc = "";
    string phob = "";
    string telb = "";
    string acc = "";
    foreach string ele in elements {
        if ele.startsWith("/UDLC/") {
            udlc += ele.substring(6);
        } else if ele.startsWith("/PHOB/") {
            phob += ele.substring(6);
        } else if ele.startsWith("/TELB/") {
            telb += ele.substring(6);
        } else {
            string temp = ele;
            if acc == "" {
                acc = temp;
            } else {
                acc += temp;
            }
        }
    }
    return [
            udlc != "" ? "/UDLC/" + udlc : "",
            acc != "" ? "/ACC/" + acc : "",
            phob != "" ? "/PHOB/" + phob : "",
            telb != "" ? "/TELB/" + telb : ""
    ];
}

# Get remittance information for field 72.
#
# + rmtInf - remittance information
# + return - return the remittance information
isolated function getRemittanceInfoForField72(pacsIsoRecord:Max140Text[]? rmtInf) returns [string, string] {

    string bnfCode = "/BNF/";
    string tsuCode = "/TSU/";
    string bnfString = "";
    string tsuString = "";
    if rmtInf is pacsIsoRecord:Max140Text[] {
        foreach string info in rmtInf {
            string rmtInfString = info;
            if rmtInfString.includes(bnfCode) {
                // extract between pattern /BNF/ and /TSU/
                int startIndx = rmtInfString.indexOf(bnfCode) + 5 ?: rmtInfString.length();
                int endIndx = rmtInfString.substring(startIndx).indexOf(tsuCode) ?: rmtInfString.length();
                bnfString += rmtInfString.substring(startIndx, endIndx);
                // Delete the extracted string from the original string
                rmtInfString = rmtInfString.substring(0, startIndx - 5) +
                    rmtInfString.substring(rmtInfString.length().min(endIndx + 5), rmtInfString.length());
            }
            if rmtInfString.includes(tsuCode) {
                // extract between pattern /TSU/ and /BNF/
                int startIndx = rmtInfString.indexOf(tsuCode) + 5 ?: rmtInfString.length();
                int endIndx = rmtInfString.substring(startIndx).indexOf(bnfCode) ?: rmtInfString.length();
                tsuString += rmtInfString.substring(startIndx, endIndx);
                // Delete the extracted string from the original string
                rmtInfString = rmtInfString.substring(0, startIndx - 5) +
                    rmtInfString.substring(rmtInfString.length().min(endIndx + 5), rmtInfString.length());
            }
            if rmtInfString != "" {
                bnfString += rmtInfString;
            }
        }
    }
    return [bnfString, tsuString];

}

# Construct field 72 from naraative.
#
# + narrative - narrative
# + return - return the field 72
isolated function getField72FromNarrative(string? narrative) returns swiftmt:MT72? {
    if narrative !is string {
        return ();
    }
    int count = 0;
    string narration = "";
    foreach int i in 0 ... narrative.length() - 1 {
        if count == 210 {
            break;
        }
        if count % 35 == 0 {
            narration += "\n";
        }
        narration = narrative.substring(i, i + 1);
        count += 1;
    }
    return {
        name: MT72_NAME,
        Cd: {content: narration, number: NUMBER1}
    };
}

# Construct field 76 for Swift MT .
#
# + status - status of resolution of investigation
# + return - return the field 76
isolated function getCamtField76(string status) returns swiftmt:MT76 {

    if status.length() <= 200 {
        return {Nrtv: {content: appendSubFieldToTextField(status), number: NUMBER1}, name: MT76_NAME};
    }
    return {Nrtv: {content: appendSubFieldToTextField(status.substring(0, 200)), number: NUMBER1}, name: MT76_NAME};
}

# Generates the MT77A field.
#
# + status - status of resolution of investigation
# + rsltnOfInvstgtn - resolution of investigation
# + return - return the MT77A field
isolated function getCamtField77A(string status, camtIsoRecord:ResolutionOfInvestigationV13 rsltnOfInvstgtn) returns swiftmt:MT77A {
    string narrative = "";
    string orgnlUetr = "";

    camtIsoRecord:UnderlyingTransaction32[]? cxldtls = rsltnOfInvstgtn.CxlDtls;
    if cxldtls is camtIsoRecord:UnderlyingTransaction32[] {
        camtIsoRecord:PaymentTransaction152[]? txInfAndSts = cxldtls[0].TxInfAndSts;
        if txInfAndSts is camtIsoRecord:PaymentTransaction152[] {
            orgnlUetr = txInfAndSts[0].OrgnlUETR ?: "";
        }
    }
    if orgnlUetr.length() > 0 {
        orgnlUetr = "/UETR/" + orgnlUetr;
    }

    if status.length() > 200 {
        narrative = status.substring(200);
    }
    narrative = narrative.concat(orgnlUetr);

    return {Nrtv: {content: appendSubFieldToTextField(narrative, maxLineCount = 20), number: NUMBER1}, name: MT77A_NAME};
}

# Construct field 77B for Swift MT .
#
# + rgltryRptg - regulatory reporting
# + return - return the field 77B
isolated function getField77B(pacsIsoRecord:RegulatoryReporting3[]? rgltryRptg) returns swiftmt:MT77B? {
    if rgltryRptg is pacsIsoRecord:RegulatoryReporting3[] {
        pacsIsoRecord:StructuredRegulatoryReporting3[]? details = rgltryRptg[0].Dtls;
        if details is pacsIsoRecord:StructuredRegulatoryReporting3[] {
            pacsIsoRecord:Max10Text? code = details[0].Cd;
            pacsIsoRecord:Max10Text? country = details[0].Ctry;
            pacsIsoRecord:Max35Text[]? infoArray = details[0].Inf;
            if code is pacsIsoRecord:Max10Text && country is pacsIsoRecord:Max10Text {
                string narration = "//";
                int lineCount = 1;
                int charCount = 0;
                if infoArray is pacsIsoRecord:Max35Text[] {
                    foreach pacsIsoRecord:Max35Text information in infoArray {
                        if lineCount > 3 {
                            break;
                        }
                        foreach int i in 0 ... information.length() - 1 {
                            if lineCount > 3 {
                                break;
                            }
                            if (lineCount == 1 && narration.length() == 23) || charCount == 35 {
                                narration += "\n//".concat(information.substring(i, i + 1));
                                lineCount += 1;
                                charCount = 3;
                                continue;
                            }
                            narration += information.substring(i, i + 1);
                            charCount += 1;
                        }
                    }
                    return {name: MT77B_NAME, Nrtv: {content: "/" + code + "/" + country + narration, number: NUMBER1}};
                }
                return {name: MT77B_NAME, Nrtv: {content: "/" + code + "/" + country, number: NUMBER1}};
            }
            return ();
        }
        return ();
    }
    return ();
}

# Constructs MT77B field
#
# + creditor - creditor information
# + debtor - debtor information
# + return - return the MT77B field
isolated function getField77BForPacs004(pacsIsoRecord:PartyIdentification272? creditor, pacsIsoRecord:PartyIdentification272? debtor) returns swiftmt:MT77B? {
    if creditor?.CtryOfRes !is () {
        return {
            name: MT77B_NAME,
            Nrtv: {content: "/BENEFRES/" + creditor?.CtryOfRes.toString(), number: NUMBER1}
        };
    }
    if debtor?.CtryOfRes !is () {
        return {
            name: MT77B_NAME,
            Nrtv: {content: "/ORDERRES/" + debtor?.CtryOfRes.toString(), number: NUMBER1}
        };
    }
    return ();
}

# Construct field 77T for Swift MT .
#
# + supplementaryData - supplementary data
# + remmitanceInfo - remmitance information
# + return - return the field 77T
isolated function getField77T(pacsIsoRecord:SupplementaryData1[]? supplementaryData, string[]? remmitanceInfo) returns swiftmt:MT77T {
    if supplementaryData is pacsIsoRecord:SupplementaryData1[] {
        if supplementaryData[0].Envlp?.Nrtv is string {
            return {
                name: MT77T_NAME,
                EnvCntnt: {content: "/NARR/" + supplementaryData[0].Envlp?.Nrtv.toString(), number: NUMBER1}
            };
        }
        if supplementaryData[0].Envlp?.XmlContent is string {
            return {
                name: MT77T_NAME,
                EnvCntnt: {content: "/IXML/" + supplementaryData[0].Envlp?.XmlContent.toString(), number: NUMBER1}
            };
        }
    }
    if remmitanceInfo is string[] {
        string narration = "";
        foreach int i in 0 ... remmitanceInfo.length() - 1 {
            if i == remmitanceInfo.length() - 1 {
                narration += remmitanceInfo[i];
                break;
            }
            narration += remmitanceInfo[i];
        }
        return {
            name: MT77T_NAME,
            EnvCntnt: {content: "/SWIF/" + narration, number: NUMBER1}
        };
    }
    return {
        name: MT77T_NAME,
        EnvCntnt: {content: "", number: NUMBER1}
    };
}

# Construct field 79 for Swift MT .
#
# + txnInfo - payment transaction information
# + return - return the field 79
isolated function getField79(camtIsoRecord:PaymentTransaction155 txnInfo) returns swiftmt:MT79? {
    string info = "";
    string cd = "";
    camtIsoRecord:PaymentCancellationReason6[]? cancelReason = txnInfo.CxlRsnInf;
    if cancelReason is camtIsoRecord:PaymentCancellationReason6[] {
        camtIsoRecord:Max105Text[]? additionalInfoArray = cancelReason[0].AddtlInf;
        cd = cancelReason[0].Rsn?.Cd ?: "";
        if additionalInfoArray is camtIsoRecord:Max105Text[] {
            foreach string additionalInfo in additionalInfoArray {
                info = info.length() < 150 ? info.'join(EMPTY_STRING, additionalInfo) : info.concat(additionalInfo);
            }
        }
    }
    info = "/".concat(cd).concat("/").concat(info);
    // group UETR
    info = info.concat("\r\n/UETR/");
    if txnInfo.OrgnlUETR is string {
        info = info.concat(txnInfo.OrgnlUETR.toString());
    }
    return {name: MT79_NAME, Nrtv: [{content: appendSubFieldToTextField(info, 1, 35, 50), number: NUMBER1}]};

}

# Construct field 79 for camt 055.
#
# + cancelReason - payment cancellation reason
# + return - return the field 79
isolated function getCamt055Field79(camtIsoRecord:PaymentCancellationReason6[]? cancelReason) returns swiftmt:MT79? {
    if cancelReason is camtIsoRecord:PaymentCancellationReason6[] && cancelReason[0].Rsn?.Cd is camtIsoRecord:ExternalCancellationReason1Code {
        swiftmt:Nrtv[] narration = [];
        string reasonInfo = "/" + getMandatoryField(cancelReason[0].Rsn?.Cd) + "/";
        camtIsoRecord:Max105Text[]? additionalInfoArray = cancelReason[0].AddtlInf;
        if additionalInfoArray is camtIsoRecord:Max105Text[] {
            int count = 1;
            foreach string additionalInfo in additionalInfoArray {
                foreach int i in 0 ... additionalInfo.length() - 1 {
                    if reasonInfo.length() == 35 {
                        narration.push({content: reasonInfo, number: count.toString()});
                        reasonInfo = "//";
                        count += 1;
                    }
                    reasonInfo += additionalInfo.substring(i, i + 1);
                }
                reasonInfo += " ";
            }
            return {name: MT79_NAME, Nrtv: narration};
        }
        return {name: MT79_NAME, Nrtv: [{content: reasonInfo, number: NUMBER1}]};
    }
    return ();
}

# Construct field 90 option C or D
#
# + txSummary - transaction summary
# + optionC - boolean option C (consider option D if false)
# + return - return the field 90
isolated function getField90(camtIsoRecord:NumberAndSumOfTransactions1? txSummary, boolean optionC = true) returns swiftmt:MT90C|swiftmt:MT90D|error? {
    if txSummary is camtIsoRecord:NumberAndSumOfTransactions1 {
        swiftmt:MT90C MT90c = {
            name: optionC ? MT90C_NAME : MT90D_NAME,
            TtlNum: {content: txSummary.NbOfNtries.toString(), number: NUMBER1},
            Ccy: {content: "NPV", number: NUMBER2},
            Amnt: {content: convertDecimalToSwiftDecimal(txSummary.Sum), number: NUMBER3}
        };
        return optionC ? MT90c : MT90c.cloneWithType(swiftmt:MT90D);
    }
    return ();
}

# Construct Swift MT Location field.
#
# + address - address line array
# + return - return the location filed
isolated function getLocation(swiftmt:AdrsLine[]? address) returns swiftmt:Lctn? {
    if address is swiftmt:AdrsLine[] {
        return {content: address[0].content, number: NUMBER3};
    }
    return ();
}

# Get account id.
#
# + iban - optional IBAN
# + bban - optional BBAN
# + return - return the account id
isolated function getAccountId(string? iban, string? bban) returns string {
    if iban is string {
        return iban;
    } else if bban is string {
        return bban;
    }
    return "";
}

# Get code type.
#
# + name - name
# + address - address
# + townName - town name
# + countryCode - country code
# + postalAddr - postal address
# + return - return the code type
isolated function getCodeType(string? name, pacsIsoRecord:Max70Text[]? address, string? townName = (),
        string? countryCode = (), pacsIsoRecord:PostalAddress27? postalAddr = {}) returns swiftmt:CdTyp[] {
    swiftmt:CdTyp[] codeType = [];
    int count = 2;
    if name is string {
        codeType.push({content: NUMBER1, number: count.toString()});
        count += 2;
    }
    if address is pacsIsoRecord:Max70Text[] && address.length() < 3 && (townName is string || countryCode is string) {
        foreach int i in 0 ... address.length() - 1 {
            codeType.push({content: NUMBER2, number: count.toString()});
            count += 2;
        }
        codeType.push({content: NUMBER3, number: count.toString()});
        return codeType;
    }

    if address is pacsIsoRecord:Max70Text[] && address.length() < 4 {
        foreach int i in 0 ... address.length() - 1 {
            codeType.push({content: NUMBER2, number: count.toString()});
            count += 2;
        }
        return codeType;
    }
    // 2/StreetName, BuildingNumber, BuildingName, Floor, PostBox, Room, Department, SubDepartment
    if (postalAddr?.StrtNm is string || postalAddr?.BldgNb is string || postalAddr?.BldgNm is string ||
        postalAddr?.Flr is string || postalAddr?.PstBx is string || postalAddr?.Room is string ||
        postalAddr?.Dept is string || postalAddr?.SubDept is string) {
        codeType.push({content: NUMBER2, number: count.toString()});
        count += 2;
    }
    if (townName is string || countryCode is string) && address !is pacsIsoRecord:Max70Text[] {
        codeType.push({content: NUMBER3, number: count.toString()});
    }
    return codeType;
}

# Get Swift MT Account.
#
# + account - account
# + return - return swiftmt:Acc
isolated function getAccount(string account) returns swiftmt:Acc? {
    if !account.equalsIgnoreCaseAscii("") {
        return {content: account, number: NUMBER1};
    }
    return ();
}

# Get orignal message name.
#
# + messageName - message name
# + return - return the orignal message name
isolated function getOrignalMessageName(string? messageName) returns string {
    if messageName !is string {
        log:printWarn(getSwiftLogMessage(WARNING, "T20083"));
        return MESSAGETYPE_202;
    }
    if messageName.includes(PACS008) {
        return MESSAGETYPE_103;
    }
    if messageName.includes(PACS003) {
        return MESSAGETYPE_104;
    }
    if messageName.includes(PACS009) {
        return MESSAGETYPE_202;
    }
    if messageName.includes(PACS010) {
        return MESSAGETYPE_204;
    }
    if re `[1-2]0[0-9]{1}`.isFullMatch(messageName) {
        return messageName;
    }
    log:printWarn(getSwiftLogMessage(WARNING, "T20083"));
    return MESSAGETYPE_202;
}

# Append a subfield to a text field with a continuation pattern and line breaks.
#
# + text - text to append
# + startline - start line number
# + maxLineCount - maximum line count
# + maxLineLength - maximum line length  
# + continuatuionPattern - continuation pattern
# + return - return the appended text
isolated function appendSubFieldToTextField(string text, int startline = 1, int maxLineCount = 6,
        int maxLineLength = 35, string continuatuionPattern = "\r\n//") returns string {

    string result = "";
    int line = startline;
    string[] lines = [];
    if text.length() <= maxLineLength {
        return text;
    }
    lines.push(text.substring(0, maxLineLength));
    while line <= maxLineCount {
        if text.length() <= maxLineLength + (maxLineLength - 2 * line) {
            lines.push(text.substring(maxLineLength + (maxLineLength - 2) * (line - 1)));
            foreach string lineText in lines {
                result += lineText.concat(continuatuionPattern);
            }
            return result.substring(0, result.length() - continuatuionPattern.length());
        } else {
            lines.push(text.substring(maxLineLength + (maxLineLength - 2) * (line - 1), maxLineLength + (maxLineLength - 2) * line));
            line += 1;
        }
    }
    foreach string lineText in lines {
        result += lineText.concat(continuatuionPattern);
    }
    return result.substring(0, result.length() - continuatuionPattern.length());
}

# Generate status of the resolution of investigation.
#
# + rsltnOfInvstgtn - resolution of investigation
# + return - return the status
isolated function generateStatus(camtIsoRecord:ResolutionOfInvestigationV13 rsltnOfInvstgtn) returns string {
    string status = "/";
    string conf = rsltnOfInvstgtn.Sts.Conf ?: "";
    string cd = "";
    string addtlInf = "";
    camtIsoRecord:UnderlyingTransaction32[]? cxldtls = rsltnOfInvstgtn.CxlDtls;
    if cxldtls is camtIsoRecord:UnderlyingTransaction32[] {
        camtIsoRecord:PaymentTransaction152[]? txInfAndSts = cxldtls[0].TxInfAndSts;
        if txInfAndSts is camtIsoRecord:PaymentTransaction152[] {
            camtIsoRecord:CancellationStatusReason5[]? cxlStsRsnInf = txInfAndSts[0].CxlStsRsnInf;
            if cxlStsRsnInf is camtIsoRecord:CancellationStatusReason5[] {
                cd = cxlStsRsnInf[0].Rsn?.Cd ?: "";
                camtIsoRecord:Max105Text[]? addtlInfArray = cxlStsRsnInf[0].AddtlInf;
                if addtlInfArray is camtIsoRecord:Max105Text[] {
                    foreach camtIsoRecord:Max105Text addtl in addtlInfArray {
                        addtlInf = addtlInf.length() < 105 ? addtlInf.'join(EMPTY_STRING, addtl) : addtlInf.concat(addtl);
                    }
                }
            }

        }
    }

    status = status.concat(conf).concat("/");
    if cd.length() > 0 {
        status = status.concat(cd);
    }
    if addtlInf.length() > 0 {
        if cd.length() > 0 {
            status = status.concat("/").concat(addtlInf);
        } else {
            status = status.concat(addtlInf);
        }
    }
    return status;
}

# Get the sender or receiver from the BICFI.
#
# + identifierCode - identifier code 1
# + identifierCode2 - identifier code 2
# + return - return the sender or receiver
isolated function getSenderOrReceiver(string? identifierCode, string? identifierCode2 = ()) returns string {
    string bicfi = "XXXXXXXX";
    if identifierCode is string {
        bicfi = identifierCode;
    } else if identifierCode2 is string {
        bicfi = identifierCode2;
    }
    string idCode = bicfi.substring(0, 8);
    string lt = bicfi.length() >= 12 ? bicfi.substring(8, 9) : "X";
    string branch = bicfi.length() >= 12 ? bicfi.substring(9, 12) : "XXX";
    return idCode + lt + branch;
}

# Convert time to Swift time format.
#
# + content - parameter description
# + return - return value description
isolated function convertToSwiftTimeFormat(string? content) returns string|error {
    if content is () || !content.matches(re `^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{3})?[+-]\d{2}:\d{2}$`) {
        return "0000";
    }

    time:Civil civilTime = check time:civilFromString(content);
    time:Utc utc = check time:utcFromCivil(civilTime);
    string utcString = time:utcToString(utc);
    return utcString.substring(11, 13) + utcString.substring(14, 16);

}

// TODO Add the necessary functions to map the MX messages to the MT messages.
// Need to map the required fields from the MX message to the MT message.
# generate the block 3 of the MT message from the supplementary data of the MX message
# Currently, this function is empty, but if we decide to add any logic to generate the block 3 from the supplementary data,
#
# + uetr - The unique end-to-end transaction reference
# + validationFlag - The validation flag
# + return - The block 3 of the MT message or an error if the block 3 cannot be created
isolated function createMtBlock3(painIsoRecord:UUIDv4Identifier? uetr, string? validationFlag = ()) returns swiftmt:Block3? {
    if uetr !is string && validationFlag !is string {
        return ();
    }
    if uetr is string && validationFlag is string {
        return {
            ValidationFlag: {name: "119", value: validationFlag},
            NdToNdTxRef: {name: "121", value: uetr}
        };
    }
    if validationFlag is string {
        return {
            ValidationFlag: {name: "119", value: validationFlag}
        };
    }
    return {
        NdToNdTxRef: {name: "121", value: uetr}
    };
}

// TODO Add the necessary functions to map the MX messages to the MT messages.
// If nessary, add the logic to generate the block 5 from the supplementary data.
# generate the block 5 of the MT message from the supplementary data of the MX message
# Currently, this function is empty, but if we decide to add any logic to generate the block 5 from the supplementary data,
#
# + supplementaryData - The supplementary data of the MX message
# + return - The block 5 of the MT message or an error if the block 5 cannot be created
isolated function generateMtBlock5FromSupplementaryData(painIsoRecord:SupplementaryData1[]? supplementaryData) returns swiftmt:Block5?|error {
    return ();
}

# Convert an ISO date string to a Swift MT date record
#
# + date - The ISO date string
# + number - The number of the date record
# + return - The Swift MT date record or an error if the date cannot be converted
isolated function convertISODateStringToSwiftMtDate(string date, string number = NUMBER1) returns swiftmt:Dt|error {

    string isoDate = date;
    if !isoDate.includes("T") {
        isoDate = isoDate + "T00:00:00Z";
    }

    time:Utc isoTime = check time:utcFromString(isoDate);
    time:Civil civilTime = time:utcToCivil(isoTime);
    string year = civilTime.year % 100 < 10 ? "0" + (civilTime.year % 100).toString() : (civilTime.year % 100).toString();
    string month = civilTime.month < 10 ? "0" + civilTime.month.toString() : civilTime.month.toString();
    string day = civilTime.day < 10 ? "0" + civilTime.day.toString() : civilTime.day.toString();
    string swiftMtDate = year + month + day;

    swiftmt:Dt result = {
        content: swiftMtDate,
        number: number
    };

    return result;
}

# Get the empty string if the value is null
#
# + value - The value
# + return - The value or an empty string if the value is null
isolated function getEmptyStrIfNull(anydata? value) returns string {
    if value == () {
        return "";
    }

    return value.toString();
}

# Get details of charges from the charge bearer type
#
# + chargeBearer - The charge bearer type
# + number - The number of the charge record
# + return - The charge record
isolated function getDetailsOfChargesFromChargeBearerType1Code(painIsoRecord:ChargeBearerType1Code? chargeBearer = (), string number = NUMBER1) returns swiftmt:Cd {
    string chargeBearerType = "";

    if chargeBearer != () {
        match chargeBearer {
            painIsoRecord:CRED => {
                chargeBearerType = "BEN";
            }

            painIsoRecord:DEBT => {
                chargeBearerType = "OUR";
            }

            painIsoRecord:SHAR => {
                chargeBearerType = "SHA";
            }
        }
    }

    swiftmt:Cd result = {
        content: chargeBearerType,
        number: number
    };

    return result;
}

# Get the remittance information from the payment identification or remittance information.
#
# If the Proprietary field in Purpose contains the pattern ":26T:[A-Z0-9]{3}", 
# it will be mapped to field 26T. Otherwise, the remaining cases are handled 
# as remittance information (field 70).
#
# + PmtId - The payment identification
# + RmtInf - The remittance information
# + Prps - The purpose of the payment
# + return - The MT70 message
isolated function getRemittanceInformation(painIsoRecord:PaymentIdentification13? PmtId,
        painIsoRecord:RemittanceInformation22? RmtInf,
        painIsoRecord:Purpose2Choice? Prps) returns swiftmt:MT70? {

    string name = MT70_NAME;
    string content = "";
    string number = NUMBER1;

    string:RegExp regExp = re `:26T:[A-Z0-9]{3}`;
    if Prps?.Prtry != () {
        string? proprietary = Prps?.Prtry;
        if proprietary is string && proprietary.matches(regExp) {
            name = MT26T_NAME;
            content = proprietary.substring(5, 8);
            return {name, Nrtv: {content, number}};
        }
    }

    if PmtId?.EndToEndId != () {
        string code = "ROC";
        content = "/" + code + "/" + getEmptyStrIfNull(PmtId?.EndToEndId);
    }
    if RmtInf?.Ustrd != () {
        return getField70(RmtInf?.Ustrd);
    }
    return {name, Nrtv: {content, number}};
}

# Get the bank operation code from the payment type information
#
# + PmtTpInf - The payment type information
# + return - The bank operation code
isolated function getBankOperationCodeFromPaymentTypeInformation22(painIsoRecord:PaymentTypeInformation28? PmtTpInf) returns string {
    if PmtTpInf == () {
        return "";
    }

    painIsoRecord:ServiceLevel8Choice[]? svcLvl = PmtTpInf.SvcLvl;

    if svcLvl == () {
        return "";
    }

    if svcLvl.length() > 0 {
        painIsoRecord:ServiceLevel8Choice svcLvl0 = svcLvl[0];
        if (svcLvl0.Cd != ()) {
            return svcLvl0.Cd.toString();
        }
    }

    return "";

}

# Get the names array from the name string
#
# + nameString - The name string
# + return - The names array
isolated function getNamesArrayFromNameString(string nameString) returns swiftmt:Nm[] {
    string:RegExp regex = re ` `;
    string[] names = regex.split(nameString);
    swiftmt:Nm[] result = [];

    foreach int i in 0 ... names.length() - 1 {
        result.push({
            content: names[i],
            number: (i + 1).toString()
        });
    }

    return result;
}

# Joins an array of strings with a specified separator.
#
# + strings - The array of strings to join.
# + separator - The separator to use between strings.
# + return - The joined string.
isolated function joinStringArray(string[] strings, string separator) returns string {
    string result = "";
    foreach string s in strings {
        result = result + s + separator;
    }
    return result;
}

# Retrieves the first element of an array or returns null if the array is empty.
#
# + array - The array to process.
# + return - The first element of the array or null if the array is empty.
isolated function getFirstElementFromArray(any[]? array) returns any? {
    if array == () {
        return ();
    }
    if array.length() > 0 {
        return array[0];
    }
    return ();
}

# Converts ISO date format (YYYY-MM-DD) to SWIFT date format (YYMMDD).
#
# + isoDate - The ISO date string
# + Default - The default value to return if the conversion fails
# + return - The SWIFT date string in YYMMDD format
isolated function convertISODateToYYMMDD(string isoDate, string Default = "") returns string {
    if isoDate.length() == 10 {
        return isoDate.substring(2, 4) + isoDate.substring(5, 7) + isoDate.substring(8, 10);
    }
    return Default;
}

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
            number: NUMBER1
        };
    }

    foreach int i in 0 ... narrative.length() / lineLength {
        string line = narrative.substring(i * lineLength, int:min((i + 1) * lineLength, narrative.length()));
        formattedNarrative += line + (i == narrative.length() / lineLength ? "" : "\n");
    }

    return {
        content: formattedNarrative,
        number: NUMBER1
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
            }
            if missing.Tp.Prtry is string {
                queryContent += missing.Tp.Prtry.toString();
            }
            queryContent += "Unknown Type";
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
            }
            if incorrect.Tp.Prtry is string {
                queryContent += incorrect.Tp.Prtry.toString();
            }
            queryContent += "Unknown Type";

            if incorrect.AddtlIncrrctInf is string {
                queryContent += " " + incorrect.AddtlIncrrctInf.toString();
            }

            queriesContent += queryContent + "\n";
            queryNumber += 1;
        }
    }

    return queriesContent.substring(0, queriesContent.length() - 1);
}

# Extracts narrative information from supplementary data.
# + supplData - Array of supplementary data from the camt.028 document.
# + return - Returns a narrative string extracted from the supplementary data.
isolated function extractNarrativeFromSupplementaryData(camtIsoRecord:SupplementaryData1[]? supplData) returns string {
    if supplData is camtIsoRecord:SupplementaryData1[] {
        foreach camtIsoRecord:SupplementaryData1 data in supplData {
            if data.Envlp.Nrtv is string {
                return data.Envlp.Nrtv.toString();
            }
        }
    }
    return "";
}

# Extracts additional narrative information from supplementary data.
# + supplData - Array of supplementary data from the camt.028 document.
# + return - Returns an array of narrative lines extracted from the supplementary data. 
isolated function getAdditionalNarrativeInfo(camtIsoRecord:SupplementaryData1[]? supplData) returns swiftmt:Nrtv[] {
    swiftmt:Nrtv[] narratives = [];
    if supplData is camtIsoRecord:SupplementaryData1[] {
        foreach camtIsoRecord:SupplementaryData1 data in supplData {
            if data.Envlp.Nrtv is string {
                narratives.push({
                    content: data.Envlp.Nrtv.toString(),
                    number: NUMBER1
                });
            }
        }
    }
    return narratives;
}

# Maps an investigation rejection code to a narrative string.
# + rejectionCode - The rejection code from the camt.031 document.
# + return - The corresponding narrative string for the rejection code.
isolated function getRejectionReasonNarrative(camtIsoRecord:InvestigationRejection1Code rejectionCode) returns string {
    if rejectionCode == camtIsoRecord:NFND {
        return "Investigation rejected: Not found.";
    }
    if (rejectionCode == camtIsoRecord:NAUT) {
        return "Investigation rejected: Not authorized.";
    }
    if (rejectionCode == camtIsoRecord:UKNW) {
        return "Investigation rejected: Unknown.";
    }
    if (rejectionCode == camtIsoRecord:PCOR) {
        return "Investigation rejected: Pending correction.";
    }
    if (rejectionCode == camtIsoRecord:WMSG) {
        return "Investigation rejected: Wrong message.";
    }
    if (rejectionCode == camtIsoRecord:RNCR) {
        return "Investigation rejected: Reason not clear.";
    }
    if (rejectionCode == camtIsoRecord:MROI) {
        return "Investigation rejected: Message received out of scope.";
    }
}

# Appends content to the narrative, adding line breaks if necessary.
#
# + information - The information to append to the narrative.
# + narrative - The existing narrative.
# + line - The current line number.
# + return - return the updated narrative and line number
isolated function appendContentToNarration(string information, string narrative, int line) returns [string, int] {
    string narration = narrative;
    int lineCount = line;
    int lastIndex = narration.lastIndexOf("\n") ?: narration.length() - 1;
    foreach int i in 0 ... information.length() - 1 {
        if lastIndex != narration.length() - 1 && narration.substring(lastIndex + 1).length() % 35 == 0 {
            lineCount += 1;
            if lineCount > 5 {
                break;
            }
            narration += "\n//".concat(information.substring(i, i + 1));
            continue;
        }
        narration += information.substring(i, i + 1);
    }
    return [narration, lineCount];
}

# Get Instg and Instd Agts from the related header
#
# + relatedHeader - related header
# + return - return the Instg and Instd Agts
isolated function getInstgAndInstdAgts(pacsIsoRecord:BusinessApplicationHeader8[]? relatedHeader) returns [string?, string?] {
    if relatedHeader is pacsIsoRecord:BusinessApplicationHeader8[] {
        return [relatedHeader[0].To?.FIId?.FinInstnId?.BICFI, relatedHeader[0].Fr?.FIId?.FinInstnId?.BICFI];
    }
    return [];
}

# Extract the transaction information for the PACS002 message.
#
# + transactionInfo - transaction information
# + return - return the transaction information
isolated function getTransactionInfoForPacs002(pacsIsoRecord:PaymentTransaction161[]? transactionInfo) returns pacsIsoRecord:PaymentTransaction161|error {
    if transactionInfo is pacsIsoRecord:PaymentTransaction161[] {
        return transactionInfo[0];
    }
    return error("Cannot be mapped to SWIFT MT 103 message: transaction information is not preset.");
}

# Get the field 79 for the PACS002 message.
#
# + messageId - message id
# + endToEndId - end to end id
# + orgnlUETR - original UETR
# + returnReasonArray - return reason array
# + return - return the field 79 narrative
isolated function getField79ForPacs002(string? messageId, string? endToEndId, string? orgnlUETR, pacsIsoRecord:StatusReasonInformation14[]? returnReasonArray) returns swiftmt:Nrtv[] {
    swiftmt:Nrtv[] narrationArray = [{content: "/REJT/99", number: NUMBER1}];
    string narration = "";
    int index = 2;

    if returnReasonArray is pacsIsoRecord:StatusReasonInformation14[] {
        string? reasonCode = returnReasonArray[0].Rsn?.Cd;
        if reasonCode is string && reasonCode.matches(re `[A-Z]{2}[0-9]{2}`) {
            if RETURN_REASON_CODES.indexOf(reasonCode) >= 0 {
                narration = "/" + reasonCode + "/";
            } else {
                narration = "/XT99/" + reasonCode + "/";
            }
            pacsIsoRecord:Max105Text[]? additionalInfo = returnReasonArray[0].AddtlInf;
            if additionalInfo is pacsIsoRecord:Max105Text[] {
                foreach string information in additionalInfo {
                    foreach int i in 0 ... information.length() - 1 {
                        if narration.length() % 50 != 0 {
                            narration += information.substring(i, i + 1);
                        }
                        if narrationArray.length() < 35 {
                            narrationArray.push({content: narration, number: index.toString()});
                            narration = "//";
                            index += 1;
                            continue;
                        }
                        break;
                    }
                }
            } else {
                narrationArray.push({content: narration, number: index.toString()});
                index += 1;
            }
        }
    }
    if messageId is string && narrationArray.length() < 35 {
        narrationArray.push({content: "/MREF/" + messageId, number: index.toString()});
        index += 1;
    }
    if endToEndId is string && narrationArray.length() < 35 {
        narrationArray.push({content: "/TREF/" + truncate(endToEndId, 16), number: index.toString()});
        index += 1;
    }
    if orgnlUETR is string && narrationArray.length() < 35 {
        narrationArray.push({content: "/TEXT//UETR/" + orgnlUETR, number: index.toString()});
    }
    return narrationArray;
}

# Copy a reference from MX to field 20 or 21 in MT.
# Those reference fields cannot start or end with "/" and they cannot contain "//".
# In case the output would start or end with "/" or contain "//", "NOTPROVIDED" will be written out instead and
# a warning will be logged.
#
# + mxfield - mx input reference
# + return - return mt reference
isolated function getMxToMTReference(string mxfield) returns string {
    string:RegExp re = re `^/.*|^.{0,15}/$|^.{0,14}//|^.{0,13}//.+`;
    if mxfield.matches(re) {
        log:printWarn(getSwiftLogMessage(WARNING, "T14001"));
        return "NOTPROVIDED";
    }
    if mxfield.length() > 16 {
        log:printWarn("Message Id in field 20 is truncated due to length constraints");
        return truncate(mxfield, 16);
    }
    return mxfield;
}

# Truncate the text if it exceeds the specified length. If truncated, append a '+' at the end.
#
# + text - The text to truncate
# + length - The maximum length of the text
# + return - return the truncated text
isolated function truncate(string? text, int length) returns string {
    if text is () {
        return "";
    }
    if text.length() > length {
        return text.substring(0, length - 1) + "+";
    }
    return text;
}

# Get credit or debit code.
#
# + code - credit or debit code
# + rvslInd - reversal indicator
# + return - return the credit or debit code
isolated function getCrdtOrDbtCode(camtIsoRecord:CreditDebitCode code, boolean rvslInd = false) returns string {
    if rvslInd {
        if code.toString() == "DBIT" {
            return "RC";
        }
        return "RD";
    }
    if code.toString() == "DBIT" {
        return "D";
    }
    return "C";
}

# Generate MT block 1
#
# + bicfi - BICFI
# + return - return block 1
isolated function generateBlock1(string bicfi) returns swiftmt:Block1 {
    return {
        applicationId: "F",
        serviceId: "01",
        logicalTerminal: bicfi
    };
}

# Generate block 2
#
# + messageType - message type
# + bicfi - BICFI
# + dateTime - date time
# + sessionNo - session number
# + seqNo - sequence number
# + return - return block 2
isolated function generateBlock2(string messageType, string bicfi, string dateTime, string sessionNo = "0000",
        string seqNo = "000000") returns swiftmt:Block2|error {
    return {
        'type: "output",
        messageType: messageType,
        MIRLogicalTerminal: bicfi,
        senderInputTime: {content: check convertToSwiftTimeFormat(dateTime)},
        MIRDate: {content: convertToSWIFTStandardDate(dateTime.substring(0, 10))},
        MIRSessionNumber: sessionNo,
        MIRSequenceNumber: seqNo,
        receiverOutputDate: {content: convertToSWIFTStandardDate(dateTime.substring(0, 10))},
        receiverOutputTime: {content: check convertToSwiftTimeFormat(dateTime)},
        messagePriority: "N"
    };
}

# Get statement number.
#
# + lglSeqNb - legal sequence number
# + elctrncSeqNb - electronic sequence number
# + return - return the statement number
isolated function getStatementNumber(decimal? lglSeqNb, decimal? elctrncSeqNb) returns swiftmt:StmtNo {
    if lglSeqNb is decimal && lglSeqNb.toString().length() < 6 {
        return {content: lglSeqNb.floor(), number: NUMBER1};
    }
    if elctrncSeqNb is decimal {
        return {content: elctrncSeqNb.floor(), number: NUMBER1};
    }
    return {content: 1, number: NUMBER1};
}

# Map the charge breakdown code to the MT code.
#
# + mxCode - charge breakdown code in mx
# + return - return the MT code
isolated function mapChrgBreakdownCdToMt(string mxCode) returns string {
    // todo: add more mappings. no enough information to complete this.
    map<string> codeMap = {
        "CFEE": "CANF",
        "DEBT": "OURC"
    };
    return codeMap[mxCode] ?: mxCode;

}
