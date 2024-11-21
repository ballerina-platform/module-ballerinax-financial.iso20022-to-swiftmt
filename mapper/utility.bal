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

// import ballerina/io;

import ballerina/regex;
import ballerina/time;
import ballerinax/financial.iso20022.cash_management as camtIsoRecord;
import ballerinax/financial.iso20022.payment_initiation as painIsoRecord;
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
                // Extract logical terminal from narrative content if present
                if data.Envlp.Nrtv.toString().startsWith("LT:") {
                    logicalTerminal = regex:split(data.Envlp.Nrtv.toString(), ":")[1].trim();
                }
                // Extract session number from narrative content if present
                if data.Envlp.Nrtv.toString().startsWith("SN:") {
                    sessionNumber = regex:split(data.Envlp.Nrtv.toString(), ":")[1].trim();
                }
                // Extract sequence number from narrative content if present
                if data.Envlp.Nrtv.toString().startsWith("SEQ:") {
                    sequenceNumber = regex:split(data.Envlp.Nrtv.toString(), ":")[1].trim();
                }
            }
        }

        // Return Block1 if any of the fields were extracted
        if logicalTerminal is string || sessionNumber is string || sequenceNumber is string {
            return {
                logicalTerminal: logicalTerminal,
                sessionNumber: sessionNumber,
                sequenceNumber: sequenceNumber
            };
        }
    }
    // Return () if no relevant data was found
    return ();
}

# Create the block 2 of the MT message from the supplementary data of the MX message
# Currently, this function extracts the message type from the supplementary data if it is not provided directly.
#
# + mtMessageId - The message type of the MT message
# + supplementaryData - The supplementary data of the MX message
# + return - The block 2 of the MT message or an error if the block 2 cannot be created
isolated function createMtBlock2FromSupplementaryData(string? mtMessageId, painIsoRecord:SupplementaryData1[]? supplementaryData) returns swiftmt:Block2|error {
    // TODO : Implement the function to create Block2 from SupplementaryData1

    string messageType = "";

    if (mtMessageId != ()) {
        messageType = mtMessageId.toString();
    } else if (supplementaryData != ()) {
        // If the message type isn't provided directly through mtMessageId, try to find it in the supplementary data
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
# + return - The block 2 of the MT message or an error if the block 2 cannot be created
isolated function createMtBlock2(string? mtMessageId, painIsoRecord:SupplementaryData1[]? supplementaryData, painIsoRecord:ISODateTime? isoDateTime) returns swiftmt:Block2|error {
    // TODO : Implement the function to create Block2 from SupplementaryData1

    string messageType = "";

    if (mtMessageId != ()) {
        messageType = mtMessageId.toString();
    } else if (supplementaryData != ()) {
        // If the message type isn't provided directly through mtMessageId, try to find it in the supplementary data
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
# + return - The block 3 of the MT message or an error if the block 3 cannot be created
isolated function createMtBlock3FromSupplementaryData(painIsoRecord:SupplementaryData1[]? supplementaryData) returns swiftmt:Block3?|error {
    return ();
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

# Convert the charges from the MX message to the MT71F message
#
# + charges - The charges from the MX message
# + return - The MT71F message or an error if the conversion fails
isolated function convertCharges16toMT71F(painIsoRecord:Charges16[]? charges) returns swiftmt:MT71F|error {
    (swiftmt:MT71F|swiftmt:MT71G)[] mt71a = convertCharges16toMT71a(charges);

    foreach (swiftmt:MT71F|swiftmt:MT71G) e in mt71a {
        if (e is swiftmt:MT71F) {
            return check e.ensureType(swiftmt:MT71F);
        }
    }

    return error("Failed to convert Charges16 to MT71F");
}

# Convert the charges from the MX message to the MT71G message
#
# + charges - The charges from the MX message
# + return - The MT71G message or an error if the conversion fails
isolated function convertCharges16toMT71G(painIsoRecord:Charges16[]? charges) returns swiftmt:MT71G|error {
    (swiftmt:MT71F|swiftmt:MT71G)[] mt71a = convertCharges16toMT71a(charges);

    foreach (swiftmt:MT71F|swiftmt:MT71G) e in mt71a {
        if (e is swiftmt:MT71G) {
            return check e.ensureType(swiftmt:MT71G);
        }
    }

    return error("Failed to convert Charges16 to MT71G");
}

# Convert swiftmx time to MT13C time
#
# + SttlmTmIndctn - The settlement date time indication
# + SttlmTmReq - The settlement time request
# + return - The MT13C message or an error if the conversion fails
isolated function convertTimeToMT13C(painIsoRecord:SettlementDateTimeIndication1? SttlmTmIndctn, painIsoRecord:SettlementTimeRequest2? SttlmTmReq)
returns swiftmt:MT13C?|error {
    string cd = "";
    string tm = "";
    string sgn = "";
    string tmOfst = "";

    isolated function (painIsoRecord:ISOTime?|painIsoRecord:ISODateTime?) returns (string|error) getTime =
    isolated function(painIsoRecord:ISOTime?|painIsoRecord:ISODateTime? time) returns (string|error) {
        if (time == ()) {
            return "";
        }

        time:Utc isoTime = check time:utcFromString(time.toString());
        time:Civil civilTime = time:utcToCivil(isoTime);

        string hour = civilTime.hour < 10 ? "0" + civilTime.hour.toString() : civilTime.hour.toString();
        string minute = civilTime.minute < 10 ? "0" + civilTime.minute.toString() : civilTime.minute.toString();

        return hour + minute;
    };

    if (SttlmTmReq is painIsoRecord:SettlementTimeRequest2 && SttlmTmReq.CLSTm is painIsoRecord:ISOTime) {
        cd = "CLSTIME";
        tm = check getTime(SttlmTmReq.CLSTm);
    } else if (SttlmTmIndctn is painIsoRecord:SettlementDateTimeIndication1) {
        if (SttlmTmIndctn.CdtDtTm is painIsoRecord:ISODateTime) {
            cd = "RNCTIME";
            tm = check getTime(SttlmTmIndctn.CdtDtTm);
        } else if (SttlmTmIndctn.DbtDtTm is painIsoRecord:ISODateTime) {
            cd = "SNDTIME";
            tm = check getTime(SttlmTmIndctn.DbtDtTm);
        }
    }

    return {
        name: "13C",
        Cd: {content: cd, number: "1"},
        Tm: {content: tm, number: "1"},
        Sgn: {content: sgn, number: "1"},
        TmOfst: {content: tmOfst, number: "1"}
    };
}

# Get the remittance information from the payment identification or remittance information
#
# + PmtId - The payment identification
# + RmtInf - The remittance information
# + return - The MT70 message
isolated function getRemitenceInformationFromPmtIdOrRmtInf(painIsoRecord:PaymentIdentification13? PmtId, painIsoRecord:RemittanceInformation22? RmtInf) returns swiftmt:MT70 {

    string name = "70";
    string content = "";
    string number = "1";

    if (RmtInf != ()) {
        content = getEmptyStrIfNull(RmtInf.Ustrd);
    } else if (PmtId != ()) {
        content = getEmptyStrIfNull(PmtId.InstrId);
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

    string countryAndTown = country + town;

    if (countryAndTown != "") {
        result.push({
            content: countryAndTown,
            number: "1"
        });
    }

    return result;
}

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

# Join an array of strings with a separator
# + strings - The array of strings
# + separator - The separator
# + return - The joined string
function joinStringArray(string[] strings, string separator) returns string {
    string result = "";

    foreach string s in strings {
        result = result + s + separator;
    }

    return result;
}

# Get the first element of a Array or return an null
# + array - The array
# + return - The first element of the array or null
isolated function getFirstElementFromArray(any[]? array) returns any? {

    if (array == ()) {
        return ();
    }

    if (array.length() > 0) {
        return array[0];
    }

    return ();
}

# Get the last element of an array or return null
# + array - The array
# + return - The last element of the array or null
function getLastElementFromArray(any[]? array) returns any? {

    if (array == ()) {
        return ();
    }

    if (array.length() > 0) {
        return array[array.length() - 1];
    }

    return ();
}

# Extracts the narrative (Nrtv) information from the Pacs.003 document's payment cancellation data.
#
# + document - The ISO 20022 Pacs.003 document
# + return - Array of `Nrtv` records or an empty array if no information is found
isolated function extractNarrativeFromCancellationReason(camtIsoRecord:CustomerPaymentCancellationRequestV12 document) returns swiftmt:Nrtv[] {
    swiftmt:Nrtv[] narratives = [];

    // Retrieve the first OriginalPaymentInstruction49 element.
    camtIsoRecord:OriginalPaymentInstruction49? originalPaymentInstruction = <camtIsoRecord:OriginalPaymentInstruction49>getFirstElementFromArray(document.Undrlyg[0].OrgnlPmtInfAndCxl);

    if originalPaymentInstruction is () {
        // Return an empty array if no payment instruction is found.
        return narratives;
    }

    // Retrieve the first PaymentCancellationReason6 element.
    camtIsoRecord:PaymentCancellationReason6? cancellationReason = <camtIsoRecord:PaymentCancellationReason6>getFirstElementFromArray(originalPaymentInstruction.CxlRsnInf);

    if cancellationReason is () {
        // Return an empty array if no cancellation reason is found.
        return narratives;
    }

    // Extract narrative details if available.
    if !(cancellationReason.AddtlInf is ()) {
        int number = 1; // Initialize the number attribute
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

# Create the block 1 of the MT message from the instructing agent and instructed agent fields.
#
# + groupHeader - The `GroupHeader113` structure containing InstgAgt and InstdAgt details.
# + return - Returns the block 1 of the MT message or an error if the block 1 cannot be created.
isolated function createBlock1FromInstgAgtAndInstdAgt(camtIsoRecord:BranchAndFinancialInstitutionIdentification8? InstgAgt, camtIsoRecord:BranchAndFinancialInstitutionIdentification8? InstdAgt) returns swiftmt:Block1?|error {

    if (InstgAgt == () && InstdAgt == ()) {
        return ();
    }

    // Extract logical terminals from instructing and instructed agents
    string? instgAgtLogicalTerminal = InstgAgt?.FinInstnId?.BICFI.toString().substring(0, 8);
    string? instdAgtLogicalTerminal = InstdAgt?.FinInstnId?.BICFI.toString().substring(0, 8);

    // Default logical terminal (fallback if none are found)
    string logicalTerminal = instgAgtLogicalTerminal ?: instdAgtLogicalTerminal ?: "DEFAULTLT";

    // Assign default values for other Block1 fields
    string applicationId = "F"; // Default for application ID
    string serviceId = "01"; // Default for service ID
    string sessionNumber = "0000"; // Default session number
    string sequenceNumber = "000000"; // Default sequence number

    return {
        applicationId: applicationId,
        serviceId: serviceId,
        logicalTerminal: logicalTerminal,
        sessionNumber: sessionNumber,
        sequenceNumber: sequenceNumber
    };
}

# Create the block 1 of the MT message from the Assgne and Assgnr fields in the Camt055Document.
#
# + document - The `Camt055Document` containing the Assgne and Assgnr fields.
# + return - Returns the block 1 of the MT message or an error if the block 1 cannot be created.
isolated function createBlock1FromAssgnmt(camtIsoRecord:CaseAssignment6? Assgnmt) returns swiftmt:Block1?|error {

    if (Assgnmt == ()) {
        return ();
    }

    // Extract logical terminal IDs from Assgne and Assgnr fields
    string? assgneBIC = Assgnmt?.Assgne?.Agt?.FinInstnId?.BICFI;
    string? assgnrBIC = Assgnmt?.Assgnr?.Agt?.FinInstnId?.BICFI;

    // Default logical terminal (fallback if none are found)
    string logicalTerminal = assgnrBIC ?: assgneBIC ?: "DEFAULTLT";

    // Assign default values for other Block1 fields
    string applicationId = "F"; // Default for application ID
    string serviceId = "01"; // Default for service ID
    string sessionNumber = "0000"; // Default session number
    string sequenceNumber = "000000"; // Default sequence number

    // Construct Block1 with extracted or default values
    return {
        applicationId: applicationId,
        serviceId: serviceId,
        logicalTerminal: logicalTerminal.substring(0, 8), // Use only the first 8 characters
        sessionNumber: sessionNumber,
        sequenceNumber: sequenceNumber
    };
}

# Converts an ISO 20022 standard date-time format to SWIFT MT date and time.
#
# + isoDateTime - The ISO 20022 date-time string in the format YYYY-MM-DDTHH:MM:SS.
# + return - A tuple containing the SWIFT MT date in the format YYMMDD and time in the format HHMM, or null if the input is not valid.
isolated function convertToSwiftMTDateTime(string? isoDateTime) returns [string?, string?] {
    if isoDateTime is string {
        // Validate the format of the ISO 20022 date-time string
        if isoDateTime.length() >= 16 && isoDateTime.includes("T") {
            // Split the ISO 20022 string into date and time parts
            // string[] dateTimeParts = isoDateTime.split("T");
            string[] dateTimeParts = regex:split(isoDateTime, "T");

            string datePart = dateTimeParts[0]; // YYYY-MM-DD
            string timePart = dateTimeParts[1]; // HH:MM:SS

            // Convert date to SWIFT MT format (YYMMDD)
            string swiftDate = datePart.substring(2, 4) + datePart.substring(5, 7) + datePart.substring(8, 10);

            // Convert time to SWIFT MT format (HHMM)
            string swiftTime = timePart.substring(0, 2) + timePart.substring(3, 5);

            return [swiftDate, swiftTime];
        }
    }
    return [(), ()];
}

