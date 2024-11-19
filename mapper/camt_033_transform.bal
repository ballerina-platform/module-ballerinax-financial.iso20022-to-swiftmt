import ballerinax/financial.iso20022.cash_management as camtIsoRecord;
import ballerinax/financial.swift.mt as swiftmt;

# This function transforms a camt.033 ISO 20022 message into an MT196 SWIFT format message.
#
# + document - The camt.033 message to be transformed, in `camtIsoRecord:Camt033Document` format.
# + return - Returns an MT196 message in the `swiftmt:MTn96Message` format if successful, otherwise returns an error.
isolated function transformCamt033ToMT196(camtIsoRecord:Camt033Document document) returns swiftmt:MTn96Message|error => {

    // Step 1: Extract and build the MT196 Block 1
    block1: check createMtBlock1FromSupplementaryData(document.ReqForDplct.SplmtryData),

    // Step 2: Create Block 2 with mandatory fields
    block2: check createMtBlock2FromSupplementaryData("196", document.ReqForDplct.SplmtryData),

    // Step 3: Create Block 3 (if supplementary data exists)
    block3: check createMtBlock3FromSupplementaryData(document.ReqForDplct.SplmtryData),

    // Step 4: Build Block 4
    block4: {
        MT20: {
            name: "20",
            msgId: {
                content: document.ReqForDplct.Case?.Id ?: "",
                number: "1"
            }
        },
        MT21: {
            name: "21",
            Ref: {
                content: document.ReqForDplct.Assgnmt.Id,
                number: "1"
            }
        },
        MT11R: {
            name: "11R",
            MtNum: {
                content: "033",
                number: "1"
            },
            Dt: check convertISODateStringToSwiftMtDate(document.ReqForDplct.Assgnmt.CreDtTm.toString())
        }
,
        MT76: {
            name: "76",
            Nrtv: {
                content: "Request for duplicate message received.",
                number: "1"
            }
        },
        MT79: {
            name: "79",
            Nrtv: extractNarrativeFromSupplementaryData(document.ReqForDplct.SplmtryData)
        },
        MessageCopy: ()
    },

    // Step 5: Optional Block 5 (if supplementary data exists)
    block5: check createMtBlock5FromSupplementaryData(document.ReqForDplct.SplmtryData)

};

# Extracts narratives from the supplementary data.
# + supplData - Array of supplementary data from the document.
# + return - Returns an array of narratives extracted from the supplementary data.
isolated function extractNarrativeFromSupplementaryData(camtIsoRecord:SupplementaryData1[]? supplData) returns swiftmt:Nrtv[] {
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
