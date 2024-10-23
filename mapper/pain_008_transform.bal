import ballerinax/swiftmt as SwiftMtRecords;
import ballerinax/iso20022records as SwiftMxRecords;

isolated function transformPain008DocumentToMT104(SwiftMxRecords:Pain008Document document) returns SwiftMtRecords:MT104Message | error {
    SwiftMxRecords:CustomerDirectDebitInitiationV11 cstmrDrctDbtInitn = document.CstmrDrctDbtInitn;

    SwiftMtRecords:Block1? block1 = check createMtBlock1FromSupplementaryData(cstmrDrctDbtInitn.SplmtryData);
    SwiftMtRecords:Block2 block2 = check createMtBlock2FromSupplementaryData("104", cstmrDrctDbtInitn.SplmtryData);
    SwiftMtRecords:Block3? block3 = check createMtBlock3FromSupplementaryData(cstmrDrctDbtInitn.SplmtryData);
    SwiftMtRecords:Block5? block5 = check createMtBlock5FromSupplementaryData(cstmrDrctDbtInitn.SplmtryData);

    SwiftMtRecords:MT104Block4 block4 = {
        MT20: {
            name: "20", 
            msgId: {
                \#content: getEmptyStrIfNull(cstmrDrctDbtInitn.PmtInf[0].DrctDbtTxInf[0].PmtId.InstrId),
                number: "1"
            }
        },
        MT21R: {
            name: "20R", 
            Ref: {
                \#content: cstmrDrctDbtInitn.GrpHdr.MsgId,
                number: "1"
            }
        },
        MT30: {
            name: "30", 
            Dt: check convertISODateStringToSwiftMtDate(cstmrDrctDbtInitn.GrpHdr.CreDtTm, "1")
        },
        MT32B: {
            name: "32B", 
            Ccy: {
                \#content: cstmrDrctDbtInitn.GrpHdr.CreDtTm.toString(),
                number: "1"
            }, 
            Amnt: {
                \#content: cstmrDrctDbtInitn.GrpHdr.NbOfTxs.toString(),
                number: "2"
            }
        },
        Transaction: check createMT104Transactions(cstmrDrctDbtInitn.PmtInf)
    };

    SwiftMtRecords:MT104Message mtMessage = {
        block1: block1,
        block2: block2,
        block3: block3,
        block4: block4,
        block5: block5
    };

    return mtMessage;
}

isolated function createMT104Transactions(SwiftMxRecords:PaymentInstruction45[] mxTransactions) returns SwiftMtRecords:MT104Transaction[] | error {
    return error("Not implemented");
}


