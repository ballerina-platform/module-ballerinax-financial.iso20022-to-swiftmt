import ballerina/io;
import ballerina/time;
import ballerina/uuid;
import ballerinax/financial.iso20022.payment_initiation as SwiftMxRecords;
import ballerinax/swiftmt as SwiftMtRecords;

isolated function transformPain001DocumentToMT101(SwiftMxRecords:Pain001Document document) returns SwiftMtRecords:MT101Message|error {

    SwiftMxRecords:CustomerCreditTransferInitiationV12 cstmrCdtTrfInitn = document.CstmrCdtTrfInitn;

    // Create the Metadata blocks of the MT message
    SwiftMtRecords:Block1? block1 = check createMtBlock1FromSupplementaryData(cstmrCdtTrfInitn.SplmtryData);
    SwiftMtRecords:Block2 block2 = check createMtBlock2FromSupplementaryData("101", cstmrCdtTrfInitn.SplmtryData);
    SwiftMtRecords:Block3? block3 = check createMtBlock3FromSupplementaryData(cstmrCdtTrfInitn.SplmtryData);
    SwiftMtRecords:Block5? block5 = check createMtBlock5FromSupplementaryData(cstmrCdtTrfInitn.SplmtryData);

    SwiftMtRecords:MT50C?|SwiftMtRecords:MT50L? instructingParty = getMT101InstructingPartyFromPain001Document(document);
    SwiftMtRecords:MT50F?|SwiftMtRecords:MT50G?|SwiftMtRecords:MT50H? orderingCustomer = getMT101OrderingCustomerFromPain001Document(document);
    SwiftMtRecords:MT52A?|SwiftMtRecords:MT52C? accountServicingInstitution = getMT101AccountServicingInstitutionFromPain001Document(document);

    // Create the data block of the MT message
    SwiftMtRecords:MT101Block4 block4 = {

        MT20: {
            name: "20",
            msgId: {
                \#content: getEmptyStrIfNull(cstmrCdtTrfInitn.PmtInf[0].CdtTrfTxInf[0].PmtId.InstrId),
                number: "1"
            }
        },

        MT21R: {
            name: "21R",
            Ref: {
                \#content: cstmrCdtTrfInitn.GrpHdr.MsgId,
                number: "1"
            }
        },

        // Setting this to empty string as the value is not available in the input
        MT28D: {
            name: "28D",
            MsgIdx: {
                \#content: "",
                number: "1"
            },
            Ttl: {
                \#content: "",
                number: "2"
            }
        },

        MT50C: instructingParty is SwiftMtRecords:MT50C ? instructingParty : (),
        MT50L: instructingParty is SwiftMtRecords:MT50L ? instructingParty : (),

        MT50F: orderingCustomer is SwiftMtRecords:MT50F ? orderingCustomer : (),
        MT50G: orderingCustomer is SwiftMtRecords:MT50G ? orderingCustomer : (),
        MT50H: orderingCustomer is SwiftMtRecords:MT50H ? orderingCustomer : (),

        MT52A: accountServicingInstitution is SwiftMtRecords:MT52A ? accountServicingInstitution : (),
        MT52C: accountServicingInstitution is SwiftMtRecords:MT52C ? accountServicingInstitution : (),

        MT30: {
            name: "30",
            Dt: check convertISODateStringToSwiftMtDate(cstmrCdtTrfInitn.PmtInf[0].ReqdExctnDt.Dt.toString(), "1")
        },
        MT25: {
            name: "25",
            Auth: {
                \#content: "",
                number: "1"
            }
        },
        Transaction: check createMT101Transactions(cstmrCdtTrfInitn.PmtInf, instructingParty, orderingCustomer, accountServicingInstitution)
    };

    SwiftMtRecords:MT101Message message = {
        block1: block1,
        block2: block2,
        block3: block3,
        block4: block4,
        block5: block5
    };

    return message;
}

public function main() {

    SwiftMxRecords:Pain001Document document = {
        CstmrCdtTrfInitn: {
            GrpHdr: {
                CreDtTm: time:utcToString(time:utcNow()),
                InitgPty: {},
                NbOfTxs: "1",
                MsgId: uuid:createType4AsString().substring(0, 11)
            },
            PmtInf: []
        }
};

    io:println(document);

}
