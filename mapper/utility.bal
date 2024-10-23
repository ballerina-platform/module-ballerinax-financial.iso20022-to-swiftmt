import ballerinax/iso20022records as SwiftMxRecords;
import ballerinax/swiftmt as SwiftMtRecords;
import ballerina/regex;
import ballerina/time;

isolated function createMtBlock1FromSupplementaryData(SwiftMxRecords:SupplementaryData1[]? supplementaryData) returns SwiftMtRecords:Block1? | error {
    return ();
}

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

isolated function createMtBlock3FromSupplementaryData(SwiftMxRecords:SupplementaryData1[]? supplementaryData) returns SwiftMtRecords:Block3? | error {
    return ();
}

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

enum RemittanceInformationCode {
    INVOICE = "INV",
    INTERNATIONAL_PAYMENT_INSTRUCTION = "IPI",
    REFERENCE_FOR_BENEFICIARY = "RFB",
    REFERENCE_OF_CUSTOMER = "ROC",
    TRADE_SERVICES_UTILITY_TRANSACTION = "TSU"
};

isolated function getEmptyStrIfNull(anydata? value) returns string {
    if (value == ()) {
        return "";
    }

    return value.toString();
}


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

isolated function convertDecimalNumberToSwiftDecimal(decimal? number) returns string {
    if (number == ()) {
        return "";
    }

    return regex:replace(number.toString(), "\\.", ",");
}