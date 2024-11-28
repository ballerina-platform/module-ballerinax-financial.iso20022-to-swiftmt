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
