import ballerinax/financial.iso20022.cash_management as camtIsoRecord;
import ballerinax/financial.swift.mt as swiftmt;

# This function transforms a camt.031 ISO 20022 message into an MT196 SWIFT format message.
#
# + document - The camt.031 message to be transformed, in `camtIsoRecord:Camt031Document` format.
# + return - Returns an MT196 message in the `swiftmt:MTn96Message` format if successful, otherwise returns an error.
isolated function transformCamt031ToMT196(camtIsoRecord:Camt031Document document) returns swiftmt:MTn96Message|error => {

    // Step 1: Extract and build the MT196 Block 1
    block1: check createBlock1FromAssgnmt(document.RjctInvstgtn.Assgnmt),

    // Step 2: Create Block 2 with mandatory fields
    block2: check createMtBlock2("196", document.RjctInvstgtn.SplmtryData, document.RjctInvstgtn.Assgnmt.CreDtTm),

    // Step 3: Create Block 3 (if supplementary data exists)
    block3: check createMtBlock3(document.RjctInvstgtn.SplmtryData, ()),

    // Step 4: Build Block 4
    block4:
        {
        MT20: {
            name: "20",
            msgId: {
                content: document.RjctInvstgtn.Case?.Id ?: "",
                number: "1"
            }
        },
        MT21: {
            name: "21",
            Ref: {
                content: document.RjctInvstgtn.Assgnmt.Id,
                number: "1"
            }
        },
        MT11S: {
            name: "11S",
            MtNum: {
                content: "031", // Original message type number
                number: "1"
            },
            Dt: check convertISODateStringToSwiftMtDate(document.RjctInvstgtn.Assgnmt.CreDtTm.toString())
        }
,
        MT76: {
            name: "76",
            Nrtv: {
                content: getRejectionReasonNarrative(document.RjctInvstgtn.Justfn.RjctnRsn),
                number: "1"
            }
        },
        MT79: document.RjctInvstgtn.SplmtryData is camtIsoRecord:SupplementaryData1[] ? {
                name: "79",
                Nrtv: getAdditionalNarrativeInfo(document.RjctInvstgtn.SplmtryData)
            } : (),
        MessageCopy: ()
    },

    // Step 5: Optional Block 5 (if supplementary data exists)
    block5: check createMtBlock5FromSupplementaryData(document.RjctInvstgtn.SplmtryData)
};

# Maps an investigation rejection code to a narrative string.
# + rejectionCode - The rejection code from the camt.031 document.
# + return - The corresponding narrative string for the rejection code.
isolated function getRejectionReasonNarrative(camtIsoRecord:InvestigationRejection1Code rejectionCode) returns string {
    if rejectionCode == camtIsoRecord:NFND {
        return "Investigation rejected: Not found.";
    } else if (rejectionCode == camtIsoRecord:NAUT) {
        return "Investigation rejected: Not authorized.";
    } else if (rejectionCode == camtIsoRecord:UKNW) {
        return "Investigation rejected: Unknown.";
    } else if (rejectionCode == camtIsoRecord:PCOR) {
        return "Investigation rejected: Pending correction.";
    } else if (rejectionCode == camtIsoRecord:WMSG) {
        return "Investigation rejected: Wrong message.";
    } else if (rejectionCode == camtIsoRecord:RNCR) {
        return "Investigation rejected: Reason not clear.";
    } else if (rejectionCode == camtIsoRecord:MROI) {
        return "Investigation rejected: Message received out of scope.";
    }
}

