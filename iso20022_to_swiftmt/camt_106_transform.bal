// // Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com).
// //
// // WSO2 LLC. licenses this file to you under the Apache License,
// // Version 2.0 (the "License"); you may not use this file except
// // in compliance with the License.
// // You may obtain a copy of the License at
// //
// //    http://www.apache.org/licenses/LICENSE-2.0
// //
// // Unless required by applicable law or agreed to in writing,
// // software distributed under the License is distributed on an
// // "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// // KIND, either express or implied. See the License for the
// // specific language governing permissions and limitations
// // under the License.

// import ballerina/log;
// import ballerinax/financial.iso20022.cash_management as camtIsoRecord;
// import ballerinax/financial.swift.mt as swiftmt;

// # Transforms a camt.106 ISO 20022 document to its corresponding SWIFT MTn91 format.
// #
// # + envelope - The camt.106 envelope containing the corresponding document to be transformed.
// # + messageType - The SWIFT MTn91 message type to be transformed.
// # + return - The transformed SWIFT MTn91 message or an error.
// isolated function transformCamt106ToMtn91(camtIsoRecord:Camt106Envelope envelope, string messageType) returns swiftmt:MTn91Message|error =>  let 
//     camtIsoRecord:ChargesPerTransaction3? charges = envelope.Document.ChrgsPmtReq.Chrgs.PerTx,
//     camtIsoRecord:ChargesPerTransactionRecord3? rcrd = getRecord(charges),
//     camtIsoRecord:TransactionReferences7? tranx = rcrd is camtIsoRecord:ChargesPerTransactionRecord3 ? rcrd.UndrlygTx : (),
//     swiftmt:MT52A?|swiftmt:MT52B?|swiftmt:MT52D? field52a = check getField52(envelope.Document.ChrgsPmtReq.GrpHdr.ChrgsAcctAgt?.FinInstnId, rcrd is camtIsoRecord:ChargesPerTransactionRecord3 ? rcrd.DbtrAgtAcct?.Id : ()) in {
//         block1: generateBlock1(getSenderOrReceiver(envelope.AppHdr?.To?.FIId?.FinInstnId?.BICFI)),
//         block2: generateBlock2(messageType, getSenderOrReceiver(envelope.AppHdr?.Fr?.FIId?.FinInstnId?.BICFI), 
//             envelope.Document.ChrgsPmtReq.GrpHdr.CreDtTm),
//         block3: createMtBlock3(getBlock3ContentForCamt(charges?.Rcrd)),
//         block4: {
//             MT20: {name: MT20_NAME, msgId: {content: getMxToMTReference(charges?.ChrgsId.toString()), number: NUMBER1}},
//             MT21: {name:MT21_NAME, Ref: {content: getField21(tranx), number: NUMBER1}},
//             MT32B: check getField32B(charges),
//             MT52A: field52a is swiftmt:MT52A? field52a : (), 
//             MT52D: field52a is swiftmt:MT52D? field52a : (),
//             MT71B: getField71B(getChargesBreakdown(charges?.Rcrd)),
//             MT72: getField72ForCamt105(envelope.Document.ChrgsPmtReq.GrpHdr.ChrgsRqstr?.FinInstnId?.BICFI)
//         }
// };

// isolated function getField21(camtIsoRecord:TransactionReferences7? tranx) returns string {
//     if tranx?.InstrId is string {
//         return getMxToMTReference(tranx?.InstrId.toString());
//     } else if tranx?.EndToEndId is string {
//         return getMxToMTReference(tranx?.EndToEndId.toString());
//     } else if tranx?.MsgId is string {
//         return getMxToMTReference(tranx?.MsgId.toString());
//     } else if tranx?.AcctSvcrRef is string {
//         return getMxToMTReference(tranx?.AcctSvcrRef.toString());
//     }
//     return "NOTPROVIDED";
// }

// isolated function getRecord(camtIsoRecord:ChargesPerTransaction3? charges) returns camtIsoRecord:ChargesPerTransactionRecord3? {
//     if charges is camtIsoRecord:ChargesPerTransaction3 {
//         return charges?.Rcrd[0];
//     }
//     return;
// }

// isolated function getField32B(camtIsoRecord:ChargesPerTransaction3? charges) returns swiftmt:MT32B|error{
//     if charges is camtIsoRecord:ChargesPerTransaction3 {
//         return {name:MT32B_NAME, 
//             Ccy: {content: charges?.Rcrd[0].TtlChrgsPerRcrd?.TtlChrgsAmt?.Ccy.toString(), number: NUMBER1}, 
//             Amnt: {content: check convertToString(charges?.Rcrd[0].TtlChrgsPerRcrd?.TtlChrgsAmt?.content), number: NUMBER2}
//         };
//     }
//     log:printError(getSwiftLogMessage(FAILURE, "T13001"));
//     return error(getSwiftLogMessage(FAILURE, "T13001"));
// }
