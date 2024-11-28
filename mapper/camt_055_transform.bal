import ballerinax/financial.iso20022.cash_management as camtIsoRecord;
import ballerinax/financial.swift.mt as swiftmt;

# This function transforms a camt.055 ISO 20022 message into an MT192 SWIFT format message.
#
# + document - The camt.055 message to be transformed, in `camtIsoRecord:Camt055Document` format.
# + return - Returns an MT192 message in the `swiftmt:MTn92Message` format if successful, otherwise returns an error.
isolated function transformCamt055ToMT192(camtIsoRecord:Camt055Document document) returns swiftmt:MTn92Message|error => {
    block1: check createBlock1FromAssgnmt(document.CstmrPmtCxlReq.Assgnmt),
    block2: check createMtBlock2("192", document.CstmrPmtCxlReq.SplmtryData, document.CstmrPmtCxlReq.Assgnmt.CreDtTm),
    block3: check createMtBlock3(document.CstmrPmtCxlReq.SplmtryData, (), ""),
    block4: {
        MT20: {
            name: "20",
            msgId: {
                content: document.CstmrPmtCxlReq.Case?.Id ?: "",
                number: "1"
            }
        },
        MT21: {
            name: "21",
            Ref: {
                content: (<camtIsoRecord:OriginalPaymentInstruction49>getFirstElementFromArray(
                                document.CstmrPmtCxlReq.Undrlyg[0].OrgnlPmtInfAndCxl))?.OrgnlPmtInfId,
                number: "1"
            }
        },
        MT11S: {
            name: "11S",
            MtNum: {
                content: document.CstmrPmtCxlReq.Undrlyg[0]?.OrgnlGrpInfAndCxl?.OrgnlMsgNmId ?: "",
                number: "1"
            },
            Dt: check convertISODateStringToSwiftMtDate(document.CstmrPmtCxlReq.Assgnmt.CreDtTm.toString())
        },
        MT79: {
            name: "79",
            Nrtv: extractNarrativeFromCancellationReason(document.CstmrPmtCxlReq)
        },
        MessageCopy: ()
    }
};
