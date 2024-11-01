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
