// Copyright (c) 2025, WSO2 LLC. (https://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerinax/financial.iso20022.payments_clearing_and_settlement as pacsIsoRecord;
import ballerinax/financial.swift.mt as swiftmt;

# Transforms a PACS004 document to an MT103 RETN message
#
# + envelope - The PACS004 envelope containing the corresponding document to be transformed.
# + messageType - The SWIFT 103 RETN message type
# + return - The MT103RETN message or an error if the transformation fails
isolated function transformPacs004DocumentToMT103RETN(pacsIsoRecord:Pacs004Envelope envelope, string messageType) returns swiftmt:MT103Message|error => let
    pacsIsoRecord:PaymentTransaction159 transactionInfo = check getTransactionInfoForPacs004(envelope.Document.PmtRtr.TxInf) in {
        block1: generateBlock1(getSenderOrReceiver(envelope.Document.PmtRtr.GrpHdr.InstdAgt?.FinInstnId?.BICFI, envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)),
        block2: generateBlock2("103", getSenderOrReceiver(envelope.Document.PmtRtr.GrpHdr.InstgAgt?.FinInstnId?.BICFI,
                        envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI), envelope.Document.PmtRtr.GrpHdr.CreDtTm),
        block3: createMtBlock3(transactionInfo.OrgnlUETR),
        block4: check generateMT103RETNBlock4(envelope).ensureType(swiftmt:MT103Block4),
        block5: check generateMtBlock5FromSupplementaryData(envelope.Document.PmtRtr.SplmtryData)
    };

# Creates the block 4 of an MT103RETN message from a PACS004 document
#
# + envelope - The PACS004 envelope containing the corresponding document to be transformed.
# + return - The block 4 of the MT103RETN message or an error if the transformation fails
isolated function generateMT103RETNBlock4(pacsIsoRecord:Pacs004Envelope envelope) returns swiftmt:MT103Block4|error {
    pacsIsoRecord:GroupHeader123 grpHdr = envelope.Document.PmtRtr.GrpHdr;
    pacsIsoRecord:PaymentTransaction159 transactionInfo = check getTransactionInfoForPacs004(envelope.Document.PmtRtr.TxInf);
    swiftmt:MT50A?|swiftmt:MT50G?|swiftmt:MT50K?|swiftmt:MT50H?|swiftmt:MT50F? field50a = check getField50aForPacs004(transactionInfo.RtrChain?.Dbtr?.Pty, transactionInfo.RtrChain?.Dbtr?.Agt?.FinInstnId);
    swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT52D? field52 = check getField52(transactionInfo.RtrChain?.DbtrAgt?.FinInstnId, transactionInfo.RtrChain?.DbtrAgtAcct?.Id);
    swiftmt:MT56A?|swiftmt:MT56C?|swiftmt:MT56D? field56 = check getField56(transactionInfo.RtrChain?.IntrmyAgt1?.FinInstnId, transactionInfo.RtrChain?.IntrmyAgt1Acct?.Id, isOptionCPresent = true);
    swiftmt:MT57A?|swiftmt:MT57B?|swiftmt:MT57C?|swiftmt:MT57D? field57 = check getField57(transactionInfo.RtrChain?.CdtrAgt?.FinInstnId, transactionInfo.RtrChain?.CdtrAgtAcct?.Id, true, true);
    swiftmt:MT59?|swiftmt:MT59A?|swiftmt:MT59F? field59 = getField59aForPacs004(transactionInfo.RtrChain?.Cdtr?.Pty, transactionInfo.RtrChain?.Cdtr?.Agt?.FinInstnId);

    swiftmt:MT13C? MT13C = check convertTimeToMT13C(transactionInfo.SttlmTmIndctn, ());

    swiftmt:MT20 MT20 = {
        name: MT20_NAME,
        msgId: {
            content: getField20Content(envelope.Document.PmtRtr.GrpHdr.MsgId),
            number: NUMBER1
        }
    };

    swiftmt:MT23B MT23B = getField23B(transactionInfo.PmtTpInf?.LclInstrm?.Prtry);

    swiftmt:MT32A MT32A = {
        name: MT32A_NAME,
        Dt: {content: convertToSWIFTStandardDate(transactionInfo.IntrBkSttlmDt), number: NUMBER1},
        Ccy: {content: getMandatoryField(transactionInfo.RtrdIntrBkSttlmAmt?.Ccy), number: NUMBER2},
        Amnt: {content: check convertToString(transactionInfo.RtrdIntrBkSttlmAmt?.content), number: NUMBER3}
    };

    swiftmt:MT33B? MT33B = check getField33B(transactionInfo.RtrdInstdAmt, (), true);

    swiftmt:MT36? MT36 = check getField36(transactionInfo.XchgRate);

    swiftmt:MT50A? MT50A = field50a is swiftmt:MT50A ? field50a : ();
    swiftmt:MT50F? MT50F = field50a is swiftmt:MT50F ? field50a : ();
    swiftmt:MT50K? MT50K = field50a is swiftmt:MT50K ? field50a : ();

    swiftmt:MT52A? MT52A = field52 is swiftmt:MT52A ? field52 : ();
    swiftmt:MT52D? MT52D = field52 is swiftmt:MT52D ? field52 : ();

    swiftmt:MT53B? MT53B = getField53ForPacs004(grpHdr.SttlmInf.SttlmAcct);

    swiftmt:MT56A? MT56A = field56 is swiftmt:MT56A ? field56 : ();
    swiftmt:MT56C? MT56C = field56 is swiftmt:MT56C ? field56 : ();
    swiftmt:MT56D? MT56D = field56 is swiftmt:MT56D ? field56 : ();

    swiftmt:MT57A? MT57A = field57 is swiftmt:MT57A ? field57 : ();
    swiftmt:MT57B? MT57B = field57 is swiftmt:MT57B ? field57 : ();
    swiftmt:MT57C? MT57C = field57 is swiftmt:MT57C ? field57 : ();
    swiftmt:MT57D? MT57D = field57 is swiftmt:MT57D ? field57 : ();

    swiftmt:MT59? MT59 = field59 is swiftmt:MT59 ? field59 : ();
    swiftmt:MT59A? MT59A = field59 is swiftmt:MT59A ? field59 : ();
    swiftmt:MT59F? MT59F = field59 is swiftmt:MT59F ? field59 : ();

    swiftmt:MT71A MT71A = {
        name: MT71A_NAME,
        Cd: getDetailsOfChargesFromChargeBearerType1Code(transactionInfo.ChrgBr)
    };
    swiftmt:MT71F[]? MT71F = check convertCharges16toMT71F(transactionInfo.ChrgsInf, transactionInfo.ChrgBr);
    swiftmt:MT71G? MT71G = check convertCharges16toMT71G(transactionInfo.ChrgsInf, transactionInfo.ChrgBr);

    swiftmt:MT72? MT72 = getField72ForPacs004(transactionInfo.OrgnlInstrId, transactionInfo.OrgnlEndToEndId, transactionInfo.RtrRsnInf);
    swiftmt:MT77B? MT77B = getField77BForPacs004(transactionInfo.RtrChain?.Cdtr?.Pty, transactionInfo.RtrChain?.Dbtr?.Pty);

    swiftmt:MT103Block4 MT103Block4 = {
        MT20,
        MT13C,
        MT23B,
        MT32A,
        MT33B,
        MT36,
        MT50A,
        MT50F,
        MT50K,
        MT52A,
        MT52D,
        MT53B,
        MT56A,
        MT56C,
        MT56D,
        MT57A,
        MT57B,
        MT57C,
        MT57D,
        MT59,
        MT59A,
        MT59F,
        MT71A,
        MT71F,
        MT71G,
        MT72,
        MT77B
    };
    return MT103Block4;
}

# Transforms a PACS004 document to an MT202 RETN message
#
# + envelope - The PACS004 envelope containing the corresponding document to be transformed.
# + messageType - The SWIFT 202 RETN message type
# + return - The MT202RETN message or an error if the transformation fails
isolated function transformPacs004ToMt202RETN(pacsIsoRecord:Pacs004Envelope envelope, string messageType) returns swiftmt:MT202Message|error => let
    pacsIsoRecord:PaymentTransaction159 transactionInfo = check getTransactionInfoForPacs004(envelope.Document.PmtRtr.TxInf) in {
        block1: generateBlock1(getSenderOrReceiver(envelope.Document.PmtRtr.GrpHdr.InstdAgt?.FinInstnId?.BICFI, envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)),
        block2: generateBlock2("202", getSenderOrReceiver(envelope.Document.PmtRtr.GrpHdr.InstgAgt?.FinInstnId?.BICFI,
                        envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI), envelope.Document.PmtRtr.GrpHdr.CreDtTm),
        block3: createMtBlock3(transactionInfo.OrgnlUETR),
        block4: check generateMT202RETNBlock4(envelope),
        block5: check generateMtBlock5FromSupplementaryData(envelope.Document.PmtRtr.SplmtryData)
    };

# Transforms a PACS004 document to an MT205 RETN message
#
# + envelope - The PACS004 envelope containing the corresponding document to be transformed.
# + messageType - The SWIFT 205 RETN message type
# + return - The MT202RETN message or an error if the transformation fails
isolated function transformPacs004ToMt205RETN(pacsIsoRecord:Pacs004Envelope envelope, string messageType) returns swiftmt:MT202Message|error => let
    pacsIsoRecord:PaymentTransaction159 transactionInfo = check getTransactionInfoForPacs004(envelope.Document.PmtRtr.TxInf) in {
        block1: generateBlock1(getSenderOrReceiver(envelope.Document.PmtRtr.GrpHdr.InstdAgt?.FinInstnId?.BICFI, envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)),
        block2: generateBlock2("205", getSenderOrReceiver(envelope.Document.PmtRtr.GrpHdr.InstgAgt?.FinInstnId?.BICFI,
                        envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI), envelope.Document.PmtRtr.GrpHdr.CreDtTm),
        block3: createMtBlock3(transactionInfo.OrgnlUETR),
        block4: check generateMT202RETNBlock4(envelope),
        block5: check generateMtBlock5FromSupplementaryData(envelope.Document.PmtRtr.SplmtryData)
    };

# Creates the block 4 of an MT202RETN message from a PACS004 document
#
# + envelope - The PACS004 envelope containing the corresponding document to be transformed.
# + return - The block 4 of the MT202RETN message or an error if the transformation fails
isolated function generateMT202RETNBlock4(pacsIsoRecord:Pacs004Envelope envelope) returns swiftmt:MT202Block4|error {
    pacsIsoRecord:GroupHeader123 grpHdr = envelope.Document.PmtRtr.GrpHdr;
    pacsIsoRecord:PaymentTransaction159 transactionInfo = check getTransactionInfoForPacs004(envelope.Document.PmtRtr.TxInf);
    swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52C?|swiftmt:MT52D? field52 = check getField52(transactionInfo.RtrChain?.Dbtr?.Agt?.FinInstnId);
    swiftmt:MT56A?|swiftmt:MT56C?|swiftmt:MT56D? field56 = check getField56(transactionInfo.RtrChain?.IntrmyAgt1?.FinInstnId, transactionInfo.RtrChain?.IntrmyAgt1Acct?.Id, isOptionCPresent = true);
    swiftmt:MT57A?|swiftmt:MT57B?|swiftmt:MT57C?|swiftmt:MT57D? field57 = check getField57(transactionInfo.RtrChain?.CdtrAgt?.FinInstnId, transactionInfo.RtrChain?.CdtrAgtAcct?.Id, true, true);
    swiftmt:MT58A?|swiftmt:MT58D? field58 = check getField58(transactionInfo.RtrChain?.Cdtr?.Agt?.FinInstnId, ());

    swiftmt:MT13C? MT13C = check convertTimeToMT13C(transactionInfo.SttlmTmIndctn, ());

    swiftmt:MT20 MT20 = {
        name: MT20_NAME,
        msgId: {
            content: getField20Content(envelope.Document.PmtRtr.GrpHdr.MsgId),
            number: NUMBER1
        }
    };

    swiftmt:MT21 MT21 = {
        name: MT21_NAME,
        Ref: {content: getField21Content(transactionInfo.OrgnlEndToEndId), number: NUMBER1}
    };

    swiftmt:MT32A MT32A = {
        name: MT32A_NAME,
        Dt: {content: convertToSWIFTStandardDate(transactionInfo.IntrBkSttlmDt), number: NUMBER1},
        Ccy: {content: getMandatoryField(transactionInfo.RtrdIntrBkSttlmAmt?.Ccy), number: NUMBER2},
        Amnt: {content: check convertToString(transactionInfo.RtrdIntrBkSttlmAmt?.content), number: NUMBER3}
    };

    swiftmt:MT52A? MT52A = field52 is swiftmt:MT52A ? field52 : ();
    swiftmt:MT52D? MT52D = field52 is swiftmt:MT52D ? field52 : ();

    swiftmt:MT53B? MT53B = getField53ForPacs004(grpHdr.SttlmInf.SttlmAcct);

    swiftmt:MT56A? MT56A = field56 is swiftmt:MT56A ? field56 : ();
    swiftmt:MT56D? MT56D = field56 is swiftmt:MT56D ? field56 : ();

    swiftmt:MT57A? MT57A = field57 is swiftmt:MT57A ? field57 : ();
    swiftmt:MT57B? MT57B = field57 is swiftmt:MT57B ? field57 : ();
    swiftmt:MT57D? MT57D = field57 is swiftmt:MT57D ? field57 : ();

    swiftmt:MT58A? MT58A = field58 is swiftmt:MT58A ? field58 : ();
    swiftmt:MT58D? MT58D = field58 is swiftmt:MT58D ? field58 : ();

    swiftmt:MT72? MT72 = getField72ForPacs004(transactionInfo.OrgnlInstrId, transactionInfo.OrgnlEndToEndId, transactionInfo.RtrRsnInf, transactionInfo.ChrgsInf);

    swiftmt:MT202Block4 MT202Block4 = {
        MT20,
        MT21,
        MT13C,
        MT32A,
        MT52A,
        MT52D,
        MT53B,
        MT56A,
        MT56D,
        MT57A,
        MT57B,
        MT57D,
        MT58A,
        MT58D,
        MT72
    };
    return MT202Block4;
}
