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

import ballerina/regex;
import ballerina/time;
import ballerinax/financial.iso20022.cash_management as camtIsoRecord;
import ballerinax/financial.iso20022.payment_initiation as painIsoRecord;
import ballerinax/financial.iso20022.payments_clearing_and_settlement as pacsIsoRecord;
import ballerinax/financial.swift.mt as swiftmt;

# Create the block 1 of the MT message from the supplementary data of the MX message.
# Currently, this function extracts logical terminal and sequence information from supplementary data.
#
# + supplementaryData - The supplementary data of the MX message
# + return - The block 1 of the MT message or an error if the block 1 cannot be created
isolated function createMtBlock1FromSupplementaryData(painIsoRecord:SupplementaryData1[]? supplementaryData) returns swiftmt:Block1?|error {
    if supplementaryData is painIsoRecord:SupplementaryData1[] {
        string? logicalTerminal = ();
        string? sessionNumber = ();
        string? sequenceNumber = ();

        foreach painIsoRecord:SupplementaryData1 data in supplementaryData {
            if data.Envlp.Nrtv is string {
                if data.Envlp.Nrtv.toString().startsWith("LT:") {
                    logicalTerminal = regex:split(data.Envlp.Nrtv.toString(), ":")[1].trim();
                }
                if data.Envlp.Nrtv.toString().startsWith("SN:") {
                    sessionNumber = regex:split(data.Envlp.Nrtv.toString(), ":")[1].trim();
                }
                if data.Envlp.Nrtv.toString().startsWith("SEQ:") {
                    sequenceNumber = regex:split(data.Envlp.Nrtv.toString(), ":")[1].trim();
                }
            }
        }
        if logicalTerminal is string || sessionNumber is string || sequenceNumber is string {
            return {
                logicalTerminal: logicalTerminal,
                sessionNumber: sessionNumber,
                sequenceNumber: sequenceNumber
            };
        }
    }
    return ();
}

# Create the block 2 of the MT message from the supplementary data of the MX message
# Currently, this function extracts the message type from the supplementary data if it is not provided directly.
#
# + mtMessageId - The message type of the MT message
# + supplementaryData - The supplementary data of the MX message
# + return - The block 2 of the MT message or an error if the block 2 cannot be created
isolated function createMtBlock2FromSupplementaryData(string? mtMessageId, painIsoRecord:SupplementaryData1[]? supplementaryData) returns swiftmt:Block2|error {
    string messageType = "";

    if (mtMessageId != ()) {
        messageType = mtMessageId.toString();
    } else if (supplementaryData != ()) {
        foreach var data in supplementaryData {
            if (data.Envlp.hasKey("MessageType")) {
                messageType = data.Envlp["MessageType"].toString();
                break;
            }
        }
    }

    if (messageType == "") {
        return error("Failed to identify the message type");
    }

    swiftmt:Block2 result = {
        messageType: messageType
    };

    return result;
}

# Create the block 2 of the MT message from the supplementary data of the MX message
# Currently, this function extracts the message type from the supplementary data if it is not provided directly.
#
# + mtMessageId - The message type of the MT message
# + supplementaryData - The supplementary data of the MX message
# + isoDateTime - The ISO date time of the MT message
# + return - The block 2 of the MT message or an error if the block 2 cannot be created
isolated function createMtBlock2(string? mtMessageId, painIsoRecord:SupplementaryData1[]? supplementaryData, painIsoRecord:ISODateTime? isoDateTime) returns swiftmt:Block2|error {
    string messageType = "";

    if (mtMessageId != ()) {
        messageType = mtMessageId.toString();
    } else if (supplementaryData != ()) {
        foreach var data in supplementaryData {
            if (data.Envlp.hasKey("MessageType")) {
                messageType = data.Envlp["MessageType"].toString();
                break;
            }
        }
    }

    if (messageType == "") {
        return error("Failed to identify the message type");
    }

    string?[] swiftMtDateTime = convertToSwiftMTDateTime(isoDateTime.toString());

    swiftmt:Block2 result = {
        messageType: messageType,
        MIRDate: {content: swiftMtDateTime[0] ?: "", number: "1"},
        senderInputTime: {content: swiftMtDateTime[1] ?: "", number: "1"}
    };

    return result;
}

# Create the block 3 of the MT message from the supplementary data of the MX message
# Currently, this function is empty, but if we decide to add any logic to create the block 3 from the supplementary data,
#
# + supplementaryData - The supplementary data of the MX message
# + uetr - The unique end-to-end transaction reference
# + validationFlag - The validation flag
# + return - The block 3 of the MT message or an error if the block 3 cannot be created
isolated function createMtBlock3(painIsoRecord:SupplementaryData1[]? supplementaryData, painIsoRecord:UUIDv4Identifier? uetr, string validationFlag) returns swiftmt:Block3?|error {

    if uetr == () {
        return ();
    }

    swiftmt:Block3 result = {
        NdToNdTxRef: {value: uetr.toString()},
        ValidationFlag: {
            name: "ValidationFlag",
            value: validationFlag
        }
    };

    return result;
}

# Create the block 5 of the MT message from the supplementary data of the MX message
# Currently, this function is empty, but if we decide to add any logic to create the block 5 from the supplementary data,
#
# + supplementaryData - The supplementary data of the MX message
# + return - The block 5 of the MT message or an error if the block 5 cannot be created
isolated function createMtBlock5FromSupplementaryData(painIsoRecord:SupplementaryData1[]? supplementaryData) returns swiftmt:Block5?|error {
    return ();
}

isolated function getActiveOrHistoricCurrencyAndAmountCcy(painIsoRecord:ActiveOrHistoricCurrencyAndAmount? ccyAndAmount) returns string {
    if (ccyAndAmount == ()) {
        return "";
    }

    return ccyAndAmount.ActiveOrHistoricCurrencyAndAmount_SimpleType.Ccy.toString();
}

isolated function getActiveOrHistoricCurrencyAndAmountValue(painIsoRecord:ActiveOrHistoricCurrencyAndAmount? ccyAndAmount) returns string {
    if (ccyAndAmount == ()) {
        return "";
    }

    return ccyAndAmount.ActiveOrHistoricCurrencyAndAmount_SimpleType.ActiveOrHistoricCurrencyAndAmount_SimpleType.toString();
}

# Convert an ISO date string to a Swift MT date record
#
# + date - The ISO date string
# + number - The number of the date record
# + return - The Swift MT date record or an error if the date cannot be converted
isolated function convertISODateStringToSwiftMtDate(string date, string number = "1") returns swiftmt:Dt|error {

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
    if (value == ()) {
        return "";
    }

    return value.toString();
}

# Get details of charges from the charge bearer type
#
# + chargeBearer - The charge bearer type
# + number - The number of the charge record
# + return - The charge record
isolated function getDetailsOfChargesFromChargeBearerType1Code(painIsoRecord:ChargeBearerType1Code? chargeBearer = (), string number = "1") returns swiftmt:Cd {
    string chargeBearerType = "";

    if (chargeBearer != ()) {
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

# Convert a decimal number to a Swift Mt decimal number string
#
# + number - The decimal number
# + return - The Swift Mt decimal number string
isolated function convertDecimalNumberToSwiftDecimal(decimal? number) returns string {
    if (number == ()) {
        return "";
    }

    return regex:replace(number.toString(), "\\.", ",");
}

# Convert the charges from the MX message to the MT71F or MT71G message
#
# + charges - The charges from the MX message
# + return - The MT71F or MT71G message or an error if the conversion fails
isolated function convertCharges16toMT71a(painIsoRecord:Charges16[]? charges) returns (swiftmt:MT71F|swiftmt:MT71G)[] {
    (swiftmt:MT71F|swiftmt:MT71G)[] result = [];

    if (charges == ()) {
        return result;
    }

    foreach painIsoRecord:Charges16 charge in charges {
        match charge.Tp?.Cd {
            "CRED" => {
                swiftmt:MT71F mt71f = {
                    name: "71F",
                    Ccy: {content: charge.Amt.ActiveOrHistoricCurrencyAndAmount_SimpleType.Ccy, number: "1"},
                    Amnt: {content: convertDecimalNumberToSwiftDecimal(charge.Amt.ActiveOrHistoricCurrencyAndAmount_SimpleType.ActiveOrHistoricCurrencyAndAmount_SimpleType), number: "1"}
                };

                result.push(mt71f);
            }

            "DEBT" => {
                swiftmt:MT71G mt71g = {
                    name: "71G",
                    Ccy: {content: charge.Amt.ActiveOrHistoricCurrencyAndAmount_SimpleType.Ccy, number: "1"},
                    Amnt: {content: convertDecimalNumberToSwiftDecimal(charge.Amt.ActiveOrHistoricCurrencyAndAmount_SimpleType.ActiveOrHistoricCurrencyAndAmount_SimpleType), number: "1"}
                };

                result.push(mt71g);
            }
        }
    }

    return result;
}

# Convert the charges from the MX message to the MT71F message.
#
# + charges - The charges from the MX message.
# + chargeBearer - The charge bearer from the MX message.
# + return - The MT71F message or an error if the conversion fails.
isolated function convertCharges16toMT71F(painIsoRecord:Charges16[]? charges, string? chargeBearer) returns swiftmt:MT71F?|error {
    (swiftmt:MT71F|swiftmt:MT71G)[] mt71a = [];

    if chargeBearer == "CRED" || chargeBearer == "SHAR" {
        mt71a = convertCharges16toMT71a(charges);
    }

    foreach (swiftmt:MT71F|swiftmt:MT71G) e in mt71a {
        if e is swiftmt:MT71F {
            return check e.ensureType(swiftmt:MT71F);
        }
    }

    return {
        name: "71F",
        Ccy: {content: "NOTPROVIDED", number: "1"},
        Amnt: {content: "0", number: "1"}
    };
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
    string? mtCurrency = ();
    string mtAmount = "";

    foreach painIsoRecord:Charges16 charge in charges {
        string currentCurrency = charge.Amt.ActiveOrHistoricCurrencyAndAmount_SimpleType.Ccy;
        if mtCurrency is () {
            mtCurrency = currentCurrency;
        } else if mtCurrency != currentCurrency {
            return error("All charges must have the same currency (Error Code: T20045).");
        }

        mxTotalAmount += check charge.Amt.ActiveOrHistoricCurrencyAndAmount_SimpleType.ActiveOrHistoricCurrencyAndAmount_SimpleType.ensureType(decimal);
    }

    mtAmount = convertDecimalNumberToSwiftDecimal(mxTotalAmount);
    if mtAmount.length() > 15 {
        return error("Amount exceeds maximum length of 15 characters (Error Codes: T20039, T13005).");
    }

    if mtAmount == "0" {
        return error("Amount cannot be zero (Error Code: T13009).");
    }

    swiftmt:MT71G mt71g = {
        name: "71G",
        Ccy: {content: mtCurrency ?: "NOTPROVIDED", number: "1"},
        Amnt: {content: mtAmount, number: "1"}
    };

    return mt71g;
}

# Create the MT13C message from the given code and time
# + code - The code
# + time - The time
# + return - The MT13C message or an error if the conversion fails
isolated function createMT13C(string code, painIsoRecord:ISOTime?|painIsoRecord:ISODateTime? time)
    returns swiftmt:MT13C|error {

    if time is () {
        return error("No valid time provided to map MT13C.");
    }

    time:Utc isoTime = check time:utcFromString(time.toString());
    time:Civil civilTime = time:utcToCivil(isoTime);
    string hour = civilTime.hour < 10 ? "0" + civilTime.hour.toString() : civilTime.hour.toString();
    string minute = civilTime.minute < 10 ? "0" + civilTime.minute.toString() : civilTime.minute.toString();
    string convertedTime = hour + minute;

    return {
        name: "13C",
        Cd: {content: code, number: "1"},
        Tm: {content: convertedTime, number: "2"},
        Sgn: {content: "+", number: "3"},
        TmOfst: {content: "0000", number: "4"}
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
        return check createMT13C("/SNDTIME/", SttlmTmIndctn?.DbtDtTm);
    } else if SttlmTmIndctn?.CdtDtTm is painIsoRecord:ISODateTime {
        return check createMT13C("/RNCTIME/", SttlmTmIndctn?.CdtDtTm);
    } else if SttlmTmReq?.CLSTm is painIsoRecord:ISOTime {
        return check createMT13C("/CLSTIME/", SttlmTmReq?.CLSTm);
    } else if SttlmTmReq?.TillTm is painIsoRecord:ISOTime {
        return check createMT13C("/TILTIME/", SttlmTmReq?.TillTm);
    } else if SttlmTmReq?.FrTm is painIsoRecord:ISOTime {
        return check createMT13C("/FROTIME/", SttlmTmReq?.FrTm);
    } else if SttlmTmReq?.RjctTm is painIsoRecord:ISOTime {
        return check createMT13C("/REJTIME/", SttlmTmReq?.RjctTm);
    }

    return ();
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
        painIsoRecord:Purpose2Choice? Prps) returns swiftmt:MT70 {

    string name = "70";
    string content = "";
    string number = "1";

    string:RegExp regExp = re `:26T:[A-Z0-9]{3}`;
    if (Prps?.Prtry != ()) {
        string? proprietary = Prps?.Prtry;
        if proprietary is string && proprietary.matches(regExp) {
            name = "26T";
            content = proprietary.substring(5, 8);
            return {name, Nrtv: {content, number}};
        }
    }

    if (PmtId?.EndToEndId != ()) {
        content = getEmptyStrIfNull(PmtId?.EndToEndId);
    }
    else if (RmtInf?.Ustrd != ()) {
        string[] unstructured = RmtInf?.Ustrd ?: [];
        content = joinStringArray(unstructured, "\n");
    }

    return {name, Nrtv: {content, number}};
}

# Get the bank operation code from the payment type information
#
# + PmtTpInf - The payment type information
# + return - The bank operation code
isolated function getBankOperationCodeFromPaymentTypeInformation22(painIsoRecord:PaymentTypeInformation28? PmtTpInf) returns string {
    if (PmtTpInf == ()) {
        return "";
    }

    painIsoRecord:ServiceLevel8Choice[]? svcLvl = PmtTpInf.SvcLvl;

    if (svcLvl == ()) {
        return "";
    }

    if (svcLvl.length() > 0) {
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
    string[] names = regex:split(nameString, " ");

    swiftmt:Nm[] result = [];

    foreach int i in 0 ... names.length() - 1 {
        result.push({
            content: names[i],
            number: (i + 1).toString()
        });
    }

    return result;
}

# Get the address lines from the addresses
#
# + addresses - The addresses
# + return - The address lines
isolated function getMtAddressLinesFromMxAddresses(string[] addresses) returns swiftmt:AdrsLine[] {
    swiftmt:AdrsLine[] result = [];

    foreach int i in 0 ... addresses.length() - 1 {
        result.push({
            content: addresses[i],
            number: (i + 1).toString()
        });
    }

    return result;
}

# Get the country and town from the country and town
#
# + country - The country
# + town - The town
# + return - The country and town
isolated function getMtCountryAndTownFromMxCountryAndTown(string country, string town) returns swiftmt:CntyNTw[] {
    swiftmt:CntyNTw[] result = [];

    string countryAndTown = country + "/" + town;

    if (countryAndTown != "") {
        result.push({
            content: countryAndTown,
            number: "1"
        });
    }

    return result;
}

# Retrieves the charge code from the given `ChargeBearerType1Code`.
#
# + chargeCode - The charge code in ISO 20022 format.
# + return - Returns the corresponding charge code as a string or an empty string if not valid.
function getChargeCode(painIsoRecord:ChargeBearerType1Code? chargeCode) returns string {
    if chargeCode is () {
        return "";
    }

    string code = "";
    match chargeCode {
        painIsoRecord:CRED => {
            code = "CRED";
        }
        painIsoRecord:DEBT => {
            code = "DEBT";
        }
        painIsoRecord:SHAR => {
            code = "SHAR";
        }
        painIsoRecord:SLEV => {
            code = "SLEV";
        }
        _ => {
            code = "";
        }
    }

    return code;
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
    if (array == ()) {
        return ();
    }
    if (array.length() > 0) {
        return array[0];
    }
    return ();
}

# Retrieves the last element of an array or returns null if the array is empty.
#
# + array - The array to process.
# + return - The last element of the array or null if the array is empty.
function getLastElementFromArray(any[]? array) returns any? {
    if (array == ()) {
        return ();
    }
    if (array.length() > 0) {
        return array[array.length() - 1];
    }
    return ();
}

# Extracts narrative (Nrtv) information from a Pacs.003 document's payment cancellation data.
#
# + document - The ISO 20022 `CustomerPaymentCancellationRequestV12` document.
# + return - Array of `Nrtv` records or an empty array if no narrative is found.
isolated function extractNarrativeFromCancellationReason(camtIsoRecord:CustomerPaymentCancellationRequestV12 document) returns swiftmt:Nrtv[] {
    swiftmt:Nrtv[] narratives = [];
    camtIsoRecord:OriginalPaymentInstruction49? originalPaymentInstruction = <camtIsoRecord:OriginalPaymentInstruction49>getFirstElementFromArray(document.Undrlyg[0].OrgnlPmtInfAndCxl);
    if originalPaymentInstruction is () {
        return narratives;
    }
    camtIsoRecord:PaymentCancellationReason6? cancellationReason = <camtIsoRecord:PaymentCancellationReason6>getFirstElementFromArray(originalPaymentInstruction.CxlRsnInf);
    if cancellationReason is () {
        return narratives;
    }
    if !(cancellationReason.AddtlInf is ()) {
        int number = 1;
        foreach string narrative in <string[]>cancellationReason.AddtlInf {
            narratives.push({
                content: narrative,
                number: number.toString()
            });
            number += 1;
        }
    }
    return narratives;
}

# Creates Block 1 of an MT message using the instructing agent and instructed agent fields.
#
# + InstgAgt - The instructing agent details.
# + InstdAgt - The instructed agent details.
# + return - Returns the constructed Block 1 of the MT message or null if it cannot be created.
isolated function createBlock1FromInstgAgtAndInstdAgt(camtIsoRecord:BranchAndFinancialInstitutionIdentification8? InstgAgt, camtIsoRecord:BranchAndFinancialInstitutionIdentification8? InstdAgt) returns swiftmt:Block1?|error {
    if (InstgAgt == () && InstdAgt == ()) || InstgAgt?.FinInstnId?.BICFI.toString().length() < 8 || InstdAgt?.FinInstnId?.BICFI.toString().length() < 8 {
        return ();
    }
    string? instgAgtLogicalTerminal = InstgAgt?.FinInstnId?.BICFI.toString().substring(0, 8);
    string? instdAgtLogicalTerminal = InstdAgt?.FinInstnId?.BICFI.toString().substring(0, 8);
    string logicalTerminal = instgAgtLogicalTerminal ?: instdAgtLogicalTerminal ?: "DEFAULTLT";
    string applicationId = "F";
    string serviceId = "01";
    string sessionNumber = "0000";
    string sequenceNumber = "000000";
    return {
        applicationId: applicationId,
        serviceId: serviceId,
        logicalTerminal: logicalTerminal,
        sessionNumber: sessionNumber,
        sequenceNumber: sequenceNumber
    };
}

# Creates Block 1 of an MT message using the Assgne and Assgnr fields in a Camt055Document.
#
# + Assgnmt - The assignment details containing Assgne and Assgnr fields.
# + return - Returns the constructed Block 1 of the MT message or null if it cannot be created.
isolated function createBlock1FromAssgnmt(camtIsoRecord:CaseAssignment6? Assgnmt) returns swiftmt:Block1?|error {
    if (Assgnmt == ()) {
        return ();
    }
    string? assgneBIC = Assgnmt?.Assgne?.Agt?.FinInstnId?.BICFI;
    string? assgnrBIC = Assgnmt?.Assgnr?.Agt?.FinInstnId?.BICFI;
    string logicalTerminal = assgnrBIC ?: assgneBIC ?: "DEFAULTLT";
    string applicationId = "F";
    string serviceId = "01";
    string sessionNumber = "0000";
    string sequenceNumber = "000000";
    return {
        applicationId: applicationId,
        serviceId: serviceId,
        logicalTerminal: logicalTerminal.substring(0, 8),
        sessionNumber: sessionNumber,
        sequenceNumber: sequenceNumber
    };
}

# Converts an ISO 20022 date-time format to SWIFT MT date and time.
#
# + isoDateTime - The ISO 20022 date-time string in the format YYYY-MM-DDTHH:MM:SS.
# + return - A tuple containing the SWIFT MT date in YYMMDD format and time in HHMM format.
isolated function convertToSwiftMTDateTime(string? isoDateTime) returns [string?, string?] {
    if isoDateTime is string {
        if isoDateTime.length() >= 16 && isoDateTime.includes("T") {
            string[] dateTimeParts = regex:split(isoDateTime, "T");
            string datePart = dateTimeParts[0];
            string timePart = dateTimeParts[1];
            string swiftDate = datePart.substring(2, 4) + datePart.substring(5, 7) + datePart.substring(8, 10);
            string swiftTime = timePart.substring(0, 2) + timePart.substring(3, 5);
            return [swiftDate, swiftTime];
        }
    }
    return [(), ()];
}

# Get narrative information from the RegulatoryReporting3
#
# + rgltryRptg - The credit transfer transaction information
# + return - The narrative information
isolated function getNarrativeFromRegulatoryCreditTransferTransaction61(painIsoRecord:RegulatoryReporting3[]? rgltryRptg) returns swiftmt:Nrtv {
    string narratives = "";

    if rgltryRptg == () {
        return {
            content: getEmptyStrIfNull(narratives),
            number: "1"
        };
    }

    painIsoRecord:StructuredRegulatoryReporting3[]? Dtls = rgltryRptg[0].Dtls;

    if Dtls == () {
        return {
            content: getEmptyStrIfNull(narratives),
            number: "1"
        };
    }

    painIsoRecord:StructuredRegulatoryReporting3? r = Dtls[0];

    if r is () {
        return {
            content: getEmptyStrIfNull(narratives),
            number: "1"
        };
    }

    narratives = "/" + r.Cd.toString() + "/" + r.Ctry.toString() + "//" + joinStringArray(<string[]>(r.Inf), " ");

    return {
        content: getEmptyStrIfNull(narratives),
        number: "1"
    };
}

# Determines the currency code from instructed or interbank settlement amount.
#
# + instructedAmount - The instructed amount (InstdAmt) from the transaction.
# + interbankAmount - The interbank settlement amount (IntrBkSttlmAmt) from the transaction.
# + return - Returns the currency code or an error if unavailable.
isolated function getCurrencyCodeFromInterbankOrInstructedAmount(
        painIsoRecord:ActiveOrHistoricCurrencyAndAmount? instructedAmount,
        painIsoRecord:ActiveCurrencyAndAmount interbankAmount
) returns string|error {
    if instructedAmount?.ActiveOrHistoricCurrencyAndAmount_SimpleType?.Ccy is string {
        return instructedAmount?.ActiveOrHistoricCurrencyAndAmount_SimpleType?.Ccy.toString();
    } else if interbankAmount.ActiveCurrencyAndAmount_SimpleType?.Ccy is string {
        return interbankAmount.ActiveCurrencyAndAmount_SimpleType.Ccy;
    }

}

# Extracts the amount value from instructed or interbank settlement amount.
#
# + instructedAmount - The instructed amount (InstdAmt) from the transaction.
# + interbankAmount - The interbank settlement amount (IntrBkSttlmAmt) from the transaction.
# + return - Returns the amount value or an error if unavailable.
isolated function getAmountValueFromInterbankOrInstructedAmount(
        painIsoRecord:ActiveOrHistoricCurrencyAndAmount? instructedAmount,
        painIsoRecord:ActiveCurrencyAndAmount interbankAmount
) returns string|error {
    if instructedAmount?.ActiveOrHistoricCurrencyAndAmount_SimpleType?.ActiveOrHistoricCurrencyAndAmount_SimpleType is decimal {
        return instructedAmount?.ActiveOrHistoricCurrencyAndAmount_SimpleType?.ActiveOrHistoricCurrencyAndAmount_SimpleType.toString();
    } else if interbankAmount.ActiveCurrencyAndAmount_SimpleType?.ActiveCurrencyAndAmount_SimpleType is decimal {
        return interbankAmount.ActiveCurrencyAndAmount_SimpleType.ActiveCurrencyAndAmount_SimpleType.toString();
    }
}

# Converts an ISO date to Swift MT YYMMDD format and returns the substring (3rd to 6th characters).
#
# + mxDate - The MX ISO date string to be converted.
# + return - The converted YYMMDD format string.
isolated function extractSwiftMtDateFromMXDate(string mxDate) returns string|error {
    swiftmt:Dt|error convertedDate = check convertISODateStringToSwiftMtDate(mxDate, "2");

    if (convertedDate is error) {
        return "";
    }
    return convertedDate.content.substring(2, 6);
}

isolated function isStructuredAddress(painIsoRecord:PartyIdentification272 creditor) returns boolean {
    if creditor.PstlAdr?.Ctry != () && creditor.PstlAdr?.AdrLine != () {
        return true;
    }
    return false;
}

# Maps ServiceLevel, CategoryPurpose, and LocalInstrument fields to MT72.
#
# + serviceLevels - The service level from the ISO message
# + categoryPurpose - The category purpose from the ISO message
# + localInstrument - The local instrument from the ISO message
# + return - Returns a swiftmt:MT72 structure containing mapped Sender to Receiver Information
isolated function mapToMT72(pacsIsoRecord:ServiceLevel8Choice[]? serviceLevels,
        pacsIsoRecord:CategoryPurpose1Choice? categoryPurpose,
        pacsIsoRecord:LocalInstrument2Choice? localInstrument) returns swiftmt:MT72 {

    string name = "72";
    string content = "";
    string number = "1";

    if serviceLevels == () {
        return {
            name: name,
            Cd: {
                content: content,
                number: number
            }
        };
    }

    pacsIsoRecord:ServiceLevel8Choice? serviceLevel = serviceLevels[0];

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

    if categoryPurpose?.Cd is string {
        string code = categoryPurpose?.Cd.toString();

        if code != "INTC" && code != "CORT" {
            content += "/CATPURP/" + code + " ";
        }
    }

    if categoryPurpose?.Prtry is string {
        string proprietary = categoryPurpose?.Prtry.toString();

        if proprietary != "INTC CORT" {
            content += "/CATPURP/" + proprietary + " ";
        }
    }

    if localInstrument?.Cd is string {
        string code = localInstrument?.Cd.toString();
        content += "/LOCINS/" + code + " ";
    }

    if localInstrument?.Prtry is string {
        string proprietary = localInstrument?.Prtry.toString();

        if proprietary != "CRED" && proprietary != "CRTS" && proprietary != "SPAY" &&
            proprietary != "SPRI" && proprietary != "SSTD" {
            content += "/LOCINS/" + proprietary + " ";
        }
    }

    content = content.trim();
    if content == "" {
        return {
            name: name,
            Cd: {
                content: content,
                number: number
            }
        };
    }

    return {
        name: name,
        Cd: {
            content: content,
            number: number
        }
    };
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

# Derive the MT20 field for block 4.
#
# + caseId - The case identification from the camt.056 message
# + return - Returns the MT20 field or an error if the mapping fails
isolated function deriveMT20(string? caseId) returns swiftmt:MT20|error {
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
        name: "20",
        msgId: {
            content: field20,
            number: "1"
        }
    };
}

# Derive the MT11S field for block 4.
#
# + orgnlGrpInfo - Original group information from the camt.056 message
# + orgnlCreationDateTime - Original creation date-time from the camt.056 message
# + return - Returns the MT11S field or an error if the mapping fails
isolated function deriveMT11S(
        camtIsoRecord:OriginalGroupHeader21? orgnlGrpInfo,
        string? orgnlCreationDateTime
) returns swiftmt:MT11S|error {
    string mtType = "202";
    string date = "991231";

    string:RegExp pacs008 = re `pacs.008`;
    string:RegExp pacs003 = re `pacs.003`;
    string:RegExp pacs009 = re `pacs.009`;
    string:RegExp pacs010 = re `pacs.010`;
    string:RegExp mt10x = re `MT10[0-9]{1}`;
    string:RegExp mt20x = re `MT20[0-9]{1}`;

    if orgnlGrpInfo?.OrgnlMsgNmId is string {
        string orgnlMsgNmId = orgnlGrpInfo?.OrgnlMsgNmId.toString();
        if orgnlMsgNmId.matches(pacs008) {
            mtType = "103";
        } else if orgnlMsgNmId.matches(pacs003) {
            mtType = "104";
        } else if orgnlMsgNmId.matches(pacs009) {
            mtType = "202";
        } else if orgnlMsgNmId.matches(pacs010) {
            mtType = "204";
        } else if orgnlMsgNmId.matches(mt10x) || orgnlMsgNmId.matches(mt20x) {
            mtType = orgnlMsgNmId.substring(2, 3);
        }
    }

    if orgnlCreationDateTime is string && orgnlCreationDateTime.length() >= 10 {
        string mxDate = orgnlCreationDateTime.substring(0, 10);
        date = convertISODateToYYMMDD(mxDate, "991231");
    }

    return {
        name: "11S",
        MtNum: {
            content: mtType,
            number: "1"
        },
        Dt: {
            content: date,
            number: "1"
        }
    };
}

# Derive the MT32A field from OriginalInterbankSettlementAmount and OriginalInterbankSettlementDate.
#
# + orgnlIntrBkSttlmAmt - The original interbank settlement amount
# + orgnlIntrBkSttlmDt - The original interbank settlement date
# + return - Returns the MT32A record or an error if the mapping fails
isolated function deriveMT32A(
        camtIsoRecord:ActiveOrHistoricCurrencyAndAmount? orgnlIntrBkSttlmAmt,
        camtIsoRecord:ISODate? orgnlIntrBkSttlmDt
) returns swiftmt:MT32A|error {
    if orgnlIntrBkSttlmAmt is camtIsoRecord:ActiveOrHistoricCurrencyAndAmount && orgnlIntrBkSttlmDt is camtIsoRecord:ISODate {
        string date = convertISODateToYYMMDD(orgnlIntrBkSttlmDt);
        string currency = orgnlIntrBkSttlmAmt.ActiveOrHistoricCurrencyAndAmount_SimpleType.Ccy;
        string amount = orgnlIntrBkSttlmAmt.ActiveOrHistoricCurrencyAndAmount_SimpleType.ActiveOrHistoricCurrencyAndAmount_SimpleType.toString();

        return {
            name: "32A",
            Dt: {content: date, number: "2"},
            Ccy: {content: currency, number: "1"},
            Amnt: {content: amount, number: "3"}
        };
    }
    return error("Failed to map MT32A from OriginalInterbankSettlement fields.");
}

# Get the Original Instruction Identification or UETR from the underlying transactions.
#
# + undrlyg - The underlying transaction details
# + return - Returns a valid reference for MT21 or "NOTPROVIDED" if invalid
isolated function getOriginalInstructionOrUETR(camtIsoRecord:UnderlyingTransaction34[]? undrlyg) returns string {
    string field21 = "NOTPROVIDED";

    if undrlyg is camtIsoRecord:UnderlyingTransaction34[] {
        foreach camtIsoRecord:UnderlyingTransaction34 trans in undrlyg {
            foreach camtIsoRecord:PaymentTransaction155 txInf in trans.TxInf ?: [] {
                if txInf.OrgnlInstrId is string {
                    field21 = txInf.OrgnlInstrId.toString();
                }
                else if txInf.OrgnlUETR is string {
                    field21 = txInf.OrgnlUETR.toString();
                }

                if field21.length() > 16 {
                    field21 = field21.substring(0, 15) + "+";
                }

                if field21.startsWith("/") || field21.endsWith("/") || field21.matches(re `//`) {
                    field21 = "NOTPROVIDED";
                }

                return field21;
            }
        }
    }

    return field21;
}

# Get the Original Instruction Identification or UETR from the underlying transactions.
#
# + undrlyg - The underlying transaction details
# + return - Returns a valid reference for MT21 or "NOTPROVIDED" if invalid
isolated function getOriginalInstructionOrUETRFromCamt055(camtIsoRecord:UnderlyingTransaction33[]? undrlyg) returns string {
    string field21 = "NOTPROVIDED";

    if undrlyg is camtIsoRecord:UnderlyingTransaction33[] {
        foreach camtIsoRecord:UnderlyingTransaction33 trans in undrlyg {
            camtIsoRecord:OriginalPaymentInstruction49[]? OrgnlPmtInfAndCxl = trans.OrgnlPmtInfAndCxl;
            if OrgnlPmtInfAndCxl is camtIsoRecord:OriginalPaymentInstruction49[] {
                foreach camtIsoRecord:OriginalPaymentInstruction49 orgnlPmtInf in OrgnlPmtInfAndCxl {
                    foreach camtIsoRecord:PaymentTransaction154 txInf in orgnlPmtInf.TxInf ?: [] {
                        if txInf.OrgnlInstrId is string {
                            field21 = txInf.OrgnlInstrId.toString();
                        }
                        else if txInf.OrgnlUETR is string {
                            field21 = txInf.OrgnlUETR.toString();
                        }

                        if field21.length() > 16 {
                            field21 = field21.substring(0, 15) + "+";
                        }

                        if field21.startsWith("/") || field21.endsWith("/") || field21.matches(re `//`) {
                            field21 = "NOTPROVIDED";
                        }

                        return field21;
                    }
                }

            }

        }
    }

    return field21;
}

# Extracts narrative information from cancellation reasons in the camt.056 message.
# + undrlyg - The underlying transaction details from the camt.056 document.
# + return - Returns an array of narrative strings extracted from the cancellation reasons.
isolated function getNarrativeFromCancellationReason(camtIsoRecord:UnderlyingTransaction34[]? undrlyg) returns swiftmt:Nrtv[] {
    swiftmt:Nrtv[] narratives = [];
    if undrlyg is camtIsoRecord:UnderlyingTransaction34[] {
        foreach camtIsoRecord:UnderlyingTransaction34 trans in undrlyg {
            foreach camtIsoRecord:PaymentTransaction155 txInf in trans.TxInf ?: [] {
                foreach camtIsoRecord:PaymentCancellationReason6 cxlRsn in txInf.CxlRsnInf ?: [] {
                    if cxlRsn.AddtlInf is camtIsoRecord:Max105Text[] {
                        foreach string info in <string[]>cxlRsn.AddtlInf {
                            narratives.push({
                                content: info,
                                number: "1"
                            });
                        }
                    }
                }
            }
        }
    }
    return narratives;
}

