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

isolated function convertCharges16toMT71F(SwiftMxRecords:Charges16[]? charges) returns SwiftMtRecords:MT71F | error {
    (SwiftMtRecords:MT71F | SwiftMtRecords:MT71G)[] mt71a = convertCharges16toMT71a(charges);

    foreach (SwiftMtRecords:MT71F | SwiftMtRecords:MT71G) e in mt71a {
        if (e is SwiftMtRecords:MT71F) {
            return check e.ensureType(SwiftMtRecords:MT71F);
        }
    }

    return error("Failed to convert Charges16 to MT71F");
}

isolated function convertCharges16toMT71G(SwiftMxRecords:Charges16[]? charges) returns SwiftMtRecords:MT71G | error {
    (SwiftMtRecords:MT71F | SwiftMtRecords:MT71G)[] mt71a = convertCharges16toMT71a(charges);

    foreach (SwiftMtRecords:MT71F | SwiftMtRecords:MT71G) e in mt71a {
        if (e is SwiftMtRecords:MT71G) {
            return check e.ensureType(SwiftMtRecords:MT71G);
        }
    }

    return error("Failed to convert Charges16 to MT71G");
}

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