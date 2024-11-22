import ballerinax/financial.iso20022.cash_management as camtIsoRecord;
import ballerinax/financial.swift.mt as swiftmt;

# This function transforms a camt.028 ISO 20022 message into an MT196 SWIFT format message.
#
# + document - The camt.028 message to be transformed, in `camtIsoRecord:Camt028Document` format.
# + return - Returns an MT196 message in the `swiftmt:MTn96Message` format if successful, otherwise returns an error.
isolated function transformCamt028ToMT196(camtIsoRecord:Camt028Document document) returns swiftmt:MTn96Message|error => {

    // Step 1: Extract and build the MT196 Block 1
    block1: check createBlock1FromAssgnmt(document.AddtlPmtInf.Assgnmt),

    // Step 2: Create Block 2 with mandatory fields
    block2: check createMtBlock2("196", document.AddtlPmtInf.SplmtryData, document.AddtlPmtInf.Assgnmt.CreDtTm),

    // Step 3: Create Block 3 (if supplementary data exists)
    block3: check createMtBlock3(document.AddtlPmtInf.SplmtryData, ()),
    // Step 4: Build Block 4
    block4: {
        MT20: {
            name: "20",
            msgId: {
                content: document.AddtlPmtInf.Case?.Id ?: "",
                number: "1"
            }
        },
        MT21: {
            name: "21",
            Ref: {
                content: document.AddtlPmtInf.Undrlyg?.Initn?.OrgnlInstrId ?: "",
                number: "1"
            }
        },
        MT11S: {
            name: "11S",
            MtNum: {
                content: "028", // Origin message type number
                number: "1"
            },
            Dt: check convertISODateStringToSwiftMtDate(document.AddtlPmtInf.Assgnmt.CreDtTm.toString())
        }
,
        MT76: {
            name: "76",
            Nrtv: {
                content: extractNarrativeFromSupplementaryData(document.AddtlPmtInf.SplmtryData),
                number: "1"
            }
        },
        MT79: document.AddtlPmtInf.SplmtryData is camtIsoRecord:SupplementaryData1[] ? {
                name: "79",
                Nrtv: getAdditionalNarrativeInfo(document.AddtlPmtInf.SplmtryData)
            } : (),
        MessageCopy: ()
    },

    // Step 5: Optional Block 5 (if supplementary data exists)
    block5: check createMtBlock5FromSupplementaryData(document.AddtlPmtInf.SplmtryData)

};

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
                    number: "1"
                });
            }
        }
    }
    return narratives;
}
