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

import ballerinax/iso20022records as SwiftMxRecords;
import ballerinax/swiftmt as SwiftMtRecords;
import ballerina/regex;
import ballerina/time;

# Create the block 1 of the MT message from the supplementary data of the MX message
# Currently, this function is empty, but if we decide to add any logic to create the block 1 from the supplementary data,
# we can add it here.
# 
# + supplementaryData - The supplementary data of the MX message
# + return - The block 1 of the MT message or an error if the block 1 cannot be created
isolated function createMtBlock1FromSupplementaryData(SwiftMxRecords:SupplementaryData1[]? supplementaryData) returns SwiftMtRecords:Block1? | error {
    return ();
}

# Create the block 2 of the MT message from the supplementary data of the MX message
# Currently, this function extracts the message type from the supplementary data if it is not provided directly.
# 
# + mtMessageId - The message type of the MT message
# + supplementaryData - The supplementary data of the MX message
# + return - The block 2 of the MT message or an error if the block 2 cannot be created
isolated function createMtBlock2FromSupplementaryData(string? mtMessageId, SwiftMxRecords:SupplementaryData1[]? supplementaryData) returns SwiftMtRecords:Block2 | error {
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

    SwiftMtRecords:Block2 result = {
        messageType: messageType
    };

    return result;
}

# Create the block 3 of the MT message from the supplementary data of the MX message
# Currently, this function is empty, but if we decide to add any logic to create the block 3 from the supplementary data,
# 
# + supplementaryData - The supplementary data of the MX message
# + return - The block 3 of the MT message or an error if the block 3 cannot be created
isolated function createMtBlock3FromSupplementaryData(SwiftMxRecords:SupplementaryData1[]? supplementaryData) returns SwiftMtRecords:Block3? | error {
    return ();
}

# Create the block 5 of the MT message from the supplementary data of the MX message
# Currently, this function is empty, but if we decide to add any logic to create the block 5 from the supplementary data,
# 
# + supplementaryData - The supplementary data of the MX message
# + return - The block 5 of the MT message or an error if the block 5 cannot be created
isolated function createMtBlock5FromSupplementaryData(SwiftMxRecords:SupplementaryData1[]? supplementaryData) returns SwiftMtRecords:Block5? | error {
    return ();
}

isolated function getActiveOrHistoricCurrencyAndAmountCcy(SwiftMxRecords:ActiveOrHistoricCurrencyAndAmount? ccyAndAmount) returns string {
    if (ccyAndAmount == ()) {
        return "";
    }

    return ccyAndAmount.ActiveOrHistoricCurrencyAndAmount_SimpleType.Ccy.toString();
}

isolated function getActiveOrHistoricCurrencyAndAmountValue(SwiftMxRecords:ActiveOrHistoricCurrencyAndAmount? ccyAndAmount) returns string {
    if (ccyAndAmount == ()) {
        return "";
    }

    return ccyAndAmount.ActiveOrHistoricCurrencyAndAmount_SimpleType.ActiveOrHistoricCurrencyAndAmount_SimpleType.toString();
}

# Convert an ISO date string to a Swift MT date record
# 
# + isoDate - The ISO date string
# + number - The number of the date record
# + return - The Swift MT date record or an error if the date cannot be converted
isolated function convertISODateStringToSwiftMtDate(string isoDate, string number = "1") returns SwiftMtRecords:Dt | error {
    time:Utc isoTime = check time:utcFromString(isoDate);
    time:Civil civilTime = time:utcToCivil(isoTime);
    
    string year = civilTime.year % 100 < 10 ? "0" + (civilTime.year % 100).toString() : (civilTime.year % 100).toString();
    string month = civilTime.month < 10 ? "0" + civilTime.month.toString() : civilTime.month.toString();
    string day = civilTime.day < 10 ? "0" + civilTime.day.toString() : civilTime.day.toString();
    
    string swiftMtDate = year + month + day;

    SwiftMtRecords:Dt result = {
        \#content: swiftMtDate,
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
isolated function getDetailsOfChargesFromChargeBearerType1Code(SwiftMxRecords:ChargeBearerType1Code? chargeBearer = (), string number = "1") returns SwiftMtRecords:Cd {
    string chargeBearerType = "";

    if (chargeBearer != ()) {
        match chargeBearer {
            SwiftMxRecords:CRED => {
                chargeBearerType = "BEN";
            }

            SwiftMxRecords:DEBT => {
                chargeBearerType = "OUR";
            }

            SwiftMxRecords:SHAR => {
                chargeBearerType = "SHA";
            }
        }
    }

    SwiftMtRecords:Cd result = {
        \#content: chargeBearerType,
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
isolated function convertCharges16toMT71a(SwiftMxRecords:Charges16[]? charges) returns (SwiftMtRecords:MT71F | SwiftMtRecords:MT71G)[] {
    (SwiftMtRecords:MT71F | SwiftMtRecords:MT71G)[] result = [];

    if (charges == ()) {
        return result;
    }

    foreach SwiftMxRecords:Charges16 charge in charges {
        match charge.Tp?.Cd {
            "CRED" => {
                SwiftMtRecords:MT71F mt71f = {
                    name: "71F",
                    Ccy: {\#content: charge.Amt.ActiveOrHistoricCurrencyAndAmount_SimpleType.Ccy, number: "1"},
                    Amnt: {\#content: convertDecimalNumberToSwiftDecimal(charge.Amt.ActiveOrHistoricCurrencyAndAmount_SimpleType.ActiveOrHistoricCurrencyAndAmount_SimpleType), number: "1"}
                };

                result.push(mt71f);
            }

            "DEBT" => {
                SwiftMtRecords:MT71G mt71g = {
                    name: "71G",
                    Ccy: {\#content: charge.Amt.ActiveOrHistoricCurrencyAndAmount_SimpleType.Ccy, number: "1"},
                    Amnt: {\#content: convertDecimalNumberToSwiftDecimal(charge.Amt.ActiveOrHistoricCurrencyAndAmount_SimpleType.ActiveOrHistoricCurrencyAndAmount_SimpleType), number: "1"}
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
isolated function convertCharges16toMT71F(SwiftMxRecords:Charges16[]? charges) returns SwiftMtRecords:MT71F | error {
    (SwiftMtRecords:MT71F | SwiftMtRecords:MT71G)[] mt71a = convertCharges16toMT71a(charges);

    foreach (SwiftMtRecords:MT71F | SwiftMtRecords:MT71G) e in mt71a {
        if (e is SwiftMtRecords:MT71F) {
            return check e.ensureType(SwiftMtRecords:MT71F);
        }
    }

    return error("Failed to convert Charges16 to MT71F");
}

# Convert the charges from the MX message to the MT71G message
# 
# + charges - The charges from the MX message
# + return - The MT71G message or an error if the conversion fails
isolated function convertCharges16toMT71G(SwiftMxRecords:Charges16[]? charges) returns SwiftMtRecords:MT71G | error {
    (SwiftMtRecords:MT71F | SwiftMtRecords:MT71G)[] mt71a = convertCharges16toMT71a(charges);

    foreach (SwiftMtRecords:MT71F | SwiftMtRecords:MT71G) e in mt71a {
        if (e is SwiftMtRecords:MT71G) {
            return check e.ensureType(SwiftMtRecords:MT71G);
        }
    }

    return error("Failed to convert Charges16 to MT71G");
}

# Convert SwiftMx time to MT13C time
# 
# + SttlmTmIndctn - The settlement date time indication
# + SttlmTmReq - The settlement time request
# + return - The MT13C message or an error if the conversion fails
isolated function convertTimeToMT13C(SwiftMxRecords:SettlementDateTimeIndication1? SttlmTmIndctn, SwiftMxRecords:SettlementTimeRequest2? SttlmTmReq) 
returns SwiftMtRecords:MT13C? | error {
    string cd = "";
    string tm = "";
    string sgn = "";
    string tmOfst = "";

    isolated function (SwiftMxRecords:ISOTime? | SwiftMxRecords:ISODateTime?) returns (string | error) getTime = 
    isolated function (SwiftMxRecords:ISOTime? | SwiftMxRecords:ISODateTime? time) returns (string | error) {
        if (time == ()) {
            return "";
        }

        time:Utc isoTime = check time:utcFromString(time.toString());
        time:Civil civilTime = time:utcToCivil(isoTime);

        string hour = civilTime.hour < 10 ? "0" + civilTime.hour.toString() : civilTime.hour.toString();
        string minute = civilTime.minute < 10 ? "0" + civilTime.minute.toString() : civilTime.minute.toString();

        return hour + minute;
    };


    if (SttlmTmReq is SwiftMxRecords:SettlementTimeRequest2 && SttlmTmReq.CLSTm is SwiftMxRecords:ISOTime) {
        cd = "CLSTIME";
        tm = check getTime(SttlmTmReq.CLSTm);
    } else if (SttlmTmIndctn is SwiftMxRecords:SettlementDateTimeIndication1) {
        if (SttlmTmIndctn.CdtDtTm is SwiftMxRecords:ISODateTime) {
            cd = "RNCTIME";
            tm = check getTime(SttlmTmIndctn.CdtDtTm);
        } else if (SttlmTmIndctn.DbtDtTm is SwiftMxRecords:ISODateTime) {
            cd = "SNDTIME";
            tm = check getTime(SttlmTmIndctn.DbtDtTm);
        }
    }

    return {
        name: "13C",
        Cd: {\#content: cd, number: "1"},
        Tm: {\#content: tm, number: "1"},
        Sgn: {\#content: sgn, number: "1"},
        TmOfst: {\#content: tmOfst, number: "1"}
    };
}

# Get the remittance information from the payment identification or remittance information
# 
# + PmtId - The payment identification
# + RmtInf - The remittance information
# + return - The MT70 message
isolated function getRemitenceInformationFromPmtIdOrRmtInf(SwiftMxRecords:PaymentIdentification13? PmtId, SwiftMxRecords:RemittanceInformation22? RmtInf) returns SwiftMtRecords:MT70 {

    string name = "70";
    string \#content = "";
    string number = "1";

    if (RmtInf != ()) {
        \#content = getEmptyStrIfNull(RmtInf.Ustrd);
    } else if (PmtId != ()) {
        \#content = getEmptyStrIfNull(PmtId.InstrId);
    }
    
    return { name, Nrtv: {\#content, number} };
}

# Get the bank operation code from the payment type information
# 
# + PmtTpInf - The payment type information
# + return - The bank operation code
isolated function getBankOperationCodeFromPaymentTypeInformation22(SwiftMxRecords:PaymentTypeInformation28? PmtTpInf) returns string {
    if (PmtTpInf == ()) {
        return "";
    }

    SwiftMxRecords:ServiceLevel8Choice[]? svcLvl = PmtTpInf.SvcLvl;

    if (svcLvl == ()) {
        return "";
    }

    if (svcLvl.length() > 0) {
        SwiftMxRecords:ServiceLevel8Choice svcLvl0 = svcLvl[0];

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
isolated function getNamesArrayFromNameString(string nameString) returns SwiftMtRecords:Nm[] {
    string[] names = regex:split(nameString, " ");

    SwiftMtRecords:Nm[] result = [];

    foreach int i in 0...names.length() - 1 {
        result.push({
            \#content: names[i],
            number: (i + 1).toString()
        });
    }

    return result;
}


# Get the address lines from the addresses
# 
# + addresses - The addresses
# + return - The address lines
isolated function getMtAddressLinesFromMxAddresses(string[] addresses) returns SwiftMtRecords:AdrsLine[] {
    SwiftMtRecords:AdrsLine[] result = [];

    foreach int i in 0...addresses.length() - 1 {
        result.push({
            \#content: addresses[i],
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
isolated function getMtCountryAndTownFromMxCountryAndTown(string country, string town) returns SwiftMtRecords:CntyNTw[] {
    SwiftMtRecords:CntyNTw[] result = [];

    string countryAndTown = country + town;

    if (countryAndTown != "") {
        result.push({
            \#content: countryAndTown,
            number: "1"
        });
    }

    return result;
}
