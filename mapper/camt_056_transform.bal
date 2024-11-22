import ballerinax/financial.iso20022.cash_management as camtIsoRecord;
import ballerinax/financial.swift.mt as swiftmt;

# This function transforms a camt.056 ISO 20022 message into an MT192 SWIFT format message.
#
# + document - The camt.056 message to be transformed, in `camtIsoRecord:Camt056Document` format.
# + return - Returns an MT192 message in the `swiftmt:MTn92Message` format if successful, otherwise returns an error.
isolated function transformCamt056ToMT192(camtIsoRecord:Camt056Document document) returns swiftmt:MTn92Message|error => {
    block1: check createBlock1FromAssgnmt(document.FIToFIPmtCxlReq.Assgnmt),
    block2: check createMtBlock2("192", document.FIToFIPmtCxlReq.SplmtryData, document.FIToFIPmtCxlReq.Assgnmt.CreDtTm),
    block3: check createMtBlock3(document.FIToFIPmtCxlReq.SplmtryData, ()),
    block4: {
        MT20: {
            name: "20",
            msgId: {
                content: document.FIToFIPmtCxlReq.Case?.Id ?: "",
                number: "1"
            }
        },
        MT21: {
            name: "21",
            Ref: {
                content: (<camtIsoRecord:PaymentTransaction155>getFirstElementFromArray(
                        document.FIToFIPmtCxlReq.Undrlyg[0]?.TxInf))?.OrgnlInstrId ?: "",
                number: "1"
            }
        },
        MT11S: {
            name: "11S",
            MtNum: {
                content: "056",
                number: "1"
            },
            Dt: check convertISODateStringToSwiftMtDate(document.FIToFIPmtCxlReq.Assgnmt.CreDtTm.toString())
        },
        MT79: {
            name: "79",
            Nrtv: getNarrativeFromCancellationReason(document.FIToFIPmtCxlReq.Undrlyg)
        },
        MessageCopy: ()

    },
    block5: check createMtBlock5FromSupplementaryData(document.FIToFIPmtCxlReq.SplmtryData)
};

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

