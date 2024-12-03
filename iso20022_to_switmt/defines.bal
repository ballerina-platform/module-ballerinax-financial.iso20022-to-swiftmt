// Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com).
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

const string PAIN001 = "pain.001";
const string PACS008 = "pacs.008";
const string PAIN008 = "pain.008";
const string PACS003 = "pacs.003";
const string CAMT050 = "camt.050";
const string PACS009 = "pacs.009";
const string PACS010 = "pacs.010";
const string CAMT057 = "camt.057";
const string CAMT054 = "camt.054";
const string CAMT060 = "camt.060";
const string CAMT053 = "camt.053";
const string CAMT052 = "camt.052";

const string MT101 = "MT101";
const string MT102 = "MT102";
const string MT102_STP = "MT102_STP";
const string MT103 = "MT103";
const string MT103_STP = "MT103_STP";
const string MT103_REMIT = "MT103_REMIT";
const string MT104 = "MT104";
const string MT107 = "MT107";
const string MT192 = "MT192";
const string MT195 = "MT195";
const string MT196 = "MT196";

const string MT200 = "MT200";
const string MT201 = "MT201";
const string MT202 = "MT202";
const string MT202_COV = "MT202_COV";
const string MT203 = "MT203";
const string MT204 = "MT204";
const string MT205 = "MT205";
const string MT205_COV = "MT205_COV";
const string MT210 = "MT210";
const string MT292 = "MT292";
const string MT295 = "MT295";

const string MESSAGETYPE_101 = "101";
const string MESSAGETYPE_102 = "102";
const string MESSAGETYPE_103 = "103";
const string MESSAGETYPE_103_STP = "103STP";
const string MESSAGETYPE_103_REMIT = "103REMIT";
const string MESSAGETYPE_104 = "104";
const string MESSAGETYPE_102_STP = "102STP";
const string MESSAGETYPE_107 = "107";
const string MESSAGETYPE_192 = "192";
const string MESSAGETYPE_195 = "195";
const string MESSAGETYPE_196 = "196";
const string MESSAGETYPE_200 = "200";
const string MESSAGETYPE_201 = "201";
const string MESSAGETYPE_202 = "202";
const string MESSAGETYPE_203 = "203";
const string MESSAGETYPE_204 = "204";

const string NUMBER1 = "1";
const string NUMBER2 = "2";
const string NUMBER3 = "3";
const string NUMBER4 = "4";

const string EMPTY_STRING = "";

const string MT19_NAME = "19";
const string MT20_NAME = "20";
const string MT21_NAME = "21";
const string MT21R_NAME = "21R";
const string MT23E_NAME = "23E";
const string MT21E_NAME = "21E";
const string MT30_NAME = "30";
const string MT51A_NAME = "51A";
const string MT26T_NAME = "26T";
const string MT77B_NAME = "77B";
const string MT71A_NAME = "71A";
const string MT72_NAME = "72";
const string MT32B_NAME = "32B";
const string MT71F_NAME = "71F";
const string MT71G_NAME = "71G";
const string MT36_NAME = "36";
const string MT21D_NAME = "21D";
const string MT33B_NAME = "33B";
const string MT28D_NAME = "28D";
const string MT70_NAME = "70";
const string MT25A_NAME = "25A";
const string MT23_NAME = "23";
const string MT77T_NAME = "77T";
const string MT23B_NAME = "23B";
const string MT79_NAME = "79";
const string MT11S_NAME = "11S";
const string MT76_NAME = "76";
const string MT75_NAME = "75";
const string MT77A_NAME = "77A";
const string MT50C_NAME = "50C";
const string MT50L_NAME = "50L";
const string MT50F_NAME = "50F";
const string MT50G_NAME = "50G";
const string MT52A_NAME = "50A";
const string MT52C_NAME = "50C";
const string MT56A_NAME = "56A";
const string MT56D_NAME = "56D";
const string MT56C_NAME = "56C";
const string MT57A_NAME = "57A";
const string MT57C_NAME = "57C";
const string MT57D_NAME = "57D";
const string MT59A_NAME = "59A";
const string MT59F_NAME = "59F";
const string MT59_NAME = "59";
const string MT52B_NAME = "52B";
const string MT56F_NAME = "56F";
const string MT53A_NAME = "53A";
const string MT53B_NAME = "53B";
const string MT53C_NAME = "53C";
const string MT53D_NAME = "53D";
const string MT50A_NAME = "50A";
const string MT50K_NAME = "50K";
const string MT52D_NAME = "52D";
const string MT54A_NAME = "54A";
const string MT54B_NAME = "54B";
const string MT54D_NAME = "54D";
const string MT55A_NAME = "55A";
const string MT55B_NAME = "55B";
const string MT55D_NAME = "55D";
const string MT57B_NAME = "57B";
const string MT13C_NAME = "13C";
const string MT32A_NAME = "32A";

# This record is used to store any type of MT message record and the type name
#
# + mtTypeName - The MT record type name
# + mtData - The MT record
type MtMessage record {|
    // The MT record type name
    string mtTypeName;
    // The MT record
    record {} mtData;
|};

# This record is used to store any type of MX message record and the type name
#
# + mxTypeName - The MX record type name
# + mxData - The MX record
type MxMessage record {|
    // The MX record type name
    string mxTypeName;
    // The MX record
    record {} mxData;
|};
