import ballerina/io;
import ballerina/test;
import ballerina/regex;

// @test:Config {
// }
// function testConvertToMTFinMessage() returns error? {
//     xml pain001Document = xml `
//         <?xml version="1.0" encoding="UTF-8" ?>
//         <Document xmlns="urn:iso:std:iso:20022:tech:xsd:pain.001.001.03">
//             <CstmrCdtTrfInitn>
//                 <GrpHdr>
//                     <MsgId>Message-Id</MsgId>
//                     <CreDtTm>2024-05-10T16:10:02.017+00:00</CreDtTm>
//                     <NbOfTxs>1</NbOfTxs>
//                     <CtrlSum>510.24</CtrlSum>
//                     <InitgPty>
//                         <Id>
//                             <OrgId>
//                                 <Othr>
//                                     <Id>Client-Id</Id>
//                                 </Othr>
//                             </OrgId>
//                         </Id>
//                     </InitgPty>
//                 </GrpHdr>
//                 <PmtInf>
//                     <PmtInfId>Batch-Id</PmtInfId>
//                     <PmtMtd>TRF</PmtMtd>
//                     <ReqdExctnDt>YYYY-MM-DD</ReqdExctnDt>
//                     <Dbtr>
//                         <Nm>Debtor Account Holder Name</Nm>
//                     </Dbtr>
//                     <DbtrAcct>
//                         <Id>
//                             <Othr>
//                                 <Id>Debtor Account Id</Id>
//                             </Othr>
//                         </Id>
//                     </DbtrAcct>
//                     <DbtrAgt>
//                         <FinInstnId>
//                             <BIC>BANK BIC</BIC>
//                         </FinInstnId>
//                     </DbtrAgt>
//                     <CdtTrfTxInf>
//                         <PmtId>
//                             <EndToEndId>End-to-End-Id</EndToEndId>
//                         </PmtId>
//                         <Amt>
//                             <InstdAmt Ccy="USD">510.24</InstdAmt>
//                         </Amt>
//                         <CdtrAgt>
//                             <FinInstnId>
//                                 <BIC>BANK BIC</BIC>
//                             </FinInstnId>
//                         </CdtrAgt>
//                         <Cdtr>
//                             <Nm>Creditor Account Holder Name</Nm>
//                         </Cdtr>
//                         <CdtrAcct>
//                             <Id>
//                                 <Othr>
//                                     <Id>Creditor Account ID</Id>
//                                 </Othr>
//                             </Id>
//                         </CdtrAcct>
//                     </CdtTrfTxInf>
//                 </PmtInf>
//             </CstmrCdtTrfInitn>
//         </Document>
//     `;

//     string result = check convertToMTFinMessage(pain001Document);
//     io:println(result);
// };


@test:Config {

}
function test2() returns error? {
    decimal a = 0.0654654999999999999999999d;
    io:println(regex:replace(a.toString(), "\\.", ","));
}