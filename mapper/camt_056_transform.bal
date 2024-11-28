import ballerinax/financial.iso20022.cash_management as camtIsoRecord;
import ballerinax/financial.swift.mt as swiftmt;

# This function transforms a camt.056 ISO 20022 message into an MT192 SWIFT format message.
#
# + document - The camt.056 message to be transformed, in `camtIsoRecord:Camt056Document` format.
# + return - Returns an MT192 message in the `swiftmt:MTn92Message` format if successful, otherwise returns an error.
isolated function transformCamt056ToMT192(camtIsoRecord:Camt056Document document) returns swiftmt:MTn92Message|error {

    // Step 1: Create Block 1
    swiftmt:Block1? block1 = check createBlock1FromAssgnmt(document.FIToFIPmtCxlReq.Assgnmt);

    // Step 2: Create Block 2
    swiftmt:Block2 block2 = check createMtBlock2(
            "192",
            document.FIToFIPmtCxlReq.SplmtryData,
            document.FIToFIPmtCxlReq.Assgnmt.CreDtTm
    );

    // Step 3: Create Block 3
    swiftmt:Block3? block3 = check createMtBlock3(
            document.FIToFIPmtCxlReq.SplmtryData,
            (),
            ""
    );

    camtIsoRecord:UnderlyingTransaction34[] undrlyg = document.FIToFIPmtCxlReq.Undrlyg;
    camtIsoRecord:PaymentTransaction155[] txInf = undrlyg[0].TxInf ?: [];
    camtIsoRecord:PaymentTransaction155 txInf0 = txInf[0];

    // Step 4: Create Block 4
    swiftmt:MTn92Block4 block4 = {
        MT20: check deriveMT20(document.FIToFIPmtCxlReq.Case?.Id),
        MT21: {
            name: "21",
            Ref: {
                content: getOriginalInstructionOrUETR(document.FIToFIPmtCxlReq.Undrlyg),
                number: "1"
            }
        },
        MT11S: check deriveMT11S(
                document.FIToFIPmtCxlReq.Undrlyg[0].OrgnlGrpInfAndCxl,
                document.FIToFIPmtCxlReq.Undrlyg[0].OrgnlGrpInfAndCxl?.OrgnlCreDtTm
        ),
        MT79: {
            name: "79",
            Nrtv: getNarrativeFromCancellationReason(document.FIToFIPmtCxlReq.Undrlyg)
        },
        MessageCopy: {
            MT32A: check deriveMT32A(
                    txInf0.OrgnlIntrBkSttlmAmt,
                    txInf0.OrgnlIntrBkSttlmDt
            )
        }
    };

    // Step 5: Create Block 5
    swiftmt:Block5? block5 = check createMtBlock5FromSupplementaryData(
            document.FIToFIPmtCxlReq.SplmtryData
    );

    // Construct and return the MT192 message
    return {
        block1: block1,
        block2: block2,
        block3: block3,
        block4: block4,
        block5: block5
    };
}

# Derive the MT20 field for block 4.
#
# + caseId - The case identification from the camt.056 message
# + return - Returns the MT20 field or an error if the mapping fails
isolated function deriveMT20(string? caseId) returns swiftmt:MT20|error {
    // Local variable for the derived value
    string field20 = "NOTPROVIDED";

    if caseId is string {
        // Step 1: Check length and truncate if necessary
        if caseId.length() > 16 {
            field20 = caseId.substring(0, 15) + "+"; // Truncate and append "+"
        } else {
            field20 = caseId;
        }

        // Step 2: Validate the format
        if field20.startsWith("/") || field20.endsWith("/") || field20.matches(re `//`) {
            field20 = "NOTPROVIDED"; // Invalid format, set to "NOTPROVIDED"
        }
    }

    // Construct and return the MT20 field
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
    // Local variables
    string mtType = "202"; // Default value
    string date = "991231"; // Default fallback date in case of missing date

    string:RegExp pacs008 = re `pacs.008`;
    string:RegExp pacs003 = re `pacs.003`;
    string:RegExp pacs009 = re `pacs.009`;
    string:RegExp pacs010 = re `pacs.010`;
    string:RegExp mt10x = re `MT10[0-9]{1}`;
    string:RegExp mt20x = re `MT20[0-9]{1}`;

    // Determine MT type based on OriginalMessageNameIdentification
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

    // Determine date based on OriginalCreationDateTime
    if orgnlCreationDateTime is string && orgnlCreationDateTime.length() >= 10 {
        string mxDate = orgnlCreationDateTime.substring(0, 10); // Extract YYYY-MM-DD
        date = convertISODateToYYMMDD(mxDate, "991231");
    }

    // Construct MT11S field
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
        // Extract components
        string date = convertISODateToYYMMDD(orgnlIntrBkSttlmDt);
        string currency = orgnlIntrBkSttlmAmt.ActiveOrHistoricCurrencyAndAmount_SimpleType.Ccy;
        string amount = orgnlIntrBkSttlmAmt.ActiveOrHistoricCurrencyAndAmount_SimpleType.ActiveOrHistoricCurrencyAndAmount_SimpleType.toString();

        return {
            name: "32A",
            Dt: {content: date},
            Ccy: {content: currency},
            Amnt: {content: amount}
        };
    }
    return error("Failed to map MT32A from OriginalInterbankSettlement fields.");
}

# Get the Original Instruction Identification or UETR from the underlying transactions.
#
# + undrlyg - The underlying transaction details
# + return - Returns a valid reference for MT21 or "NOTPROVIDED" if invalid
isolated function getOriginalInstructionOrUETR(camtIsoRecord:UnderlyingTransaction34[]? undrlyg) returns string {
    // Local variable to store the reference
    string field21 = "NOTPROVIDED";

    if undrlyg is camtIsoRecord:UnderlyingTransaction34[] {
        foreach camtIsoRecord:UnderlyingTransaction34 trans in undrlyg {
            foreach camtIsoRecord:PaymentTransaction155 txInf in trans.TxInf ?: [] {
                // Step 1: Use OriginalInstructionIdentification if available
                if txInf.OrgnlInstrId is string {
                    field21 = txInf.OrgnlInstrId.toString();
                }
                // Step 2: Fallback to UETR if OriginalInstructionIdentification is absent
                else if txInf.OrgnlUETR is string {
                    field21 = txInf.OrgnlUETR.toString();
                }

                // Step 3: Truncate if necessary
                if field21.length() > 16 {
                    field21 = field21.substring(0, 15) + "+"; // Truncate and append "+"
                }

                // Step 4: Validate format
                if field21.startsWith("/") || field21.endsWith("/") || field21.matches(re `//`) {
                    field21 = "NOTPROVIDED"; // Set to "NOTPROVIDED" if format is invalid
                }

                return field21; // Return the first valid field
            }
        }
    }

    return field21; // Return default "NOTPROVIDED" if no valid reference found
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

