//
//  OpCode.swift
//  KaspaSwift
//
//  Created by 薛跃杰 on 2024/12/16.
//

import Foundation

enum OpcCode: UInt8 {
    case OpFalse = 0
    case OpData1 = 1
    case OpData2 = 2
    case OpData3 = 3
    case OpData4 = 4
    case OpData5 = 5
    case OpData6 = 6
    case OpData7 = 7
    case OpData8 = 8
    case OpData9 = 9
    case OpData10 = 10
    case OpData11 = 11
    case OpData12 = 12
    case OpData13 = 13
    case OpData14 = 14
    case OpData15 = 15
    case OpData16 = 16
    case OpData17 = 17
    case OpData18 = 18
    case OpData19 = 19
    case OpData20 = 20
    case OpData21 = 21
    case OpData22 = 22
    case OpData23 = 23
    case OpData24 = 24
    case OpData25 = 25
    case OpData26 = 26
    case OpData27 = 27
    case OpData28 = 28
    case OpData29 = 29
    case OpData30 = 30
    case OpData31 = 31
    case OpData32 = 32
    case OpData33 = 33
    case OpData34 = 34
    case OpData35 = 35
    case OpData36 = 36
    case OpData37 = 37
    case OpData38 = 38
    case OpData39 = 39
    case OpData40 = 40
    case OpData41 = 41
    case OpData42 = 42
    case OpData43 = 43
    case OpData44 = 44
    case OpData45 = 45
    case OpData46 = 46
    case OpData47 = 47
    case OpData48 = 48
    case OpData49 = 49
    case OpData50 = 50
    case OpData51 = 51
    case OpData52 = 52
    case OpData53 = 53
    case OpData54 = 54
    case OpData55 = 55
    case OpData56 = 56
    case OpData57 = 57
    case OpData58 = 58
    case OpData59 = 59
    case OpData60 = 60
    case OpData61 = 61
    case OpData62 = 62
    case OpData63 = 63
    case OpData64 = 64
    case OpData65 = 65
    case OpData66 = 66
    case OpData67 = 67
    case OpData68 = 68
    case OpData69 = 69
    case OpData70 = 70
    case OpData71 = 71
    case OpData72 = 72
    case OpData73 = 73
    case OpData74 = 74
    case OpData75 = 75
    case OpPushData1 = 76
    case OpPushData2 = 77
    case OpPushData4 = 78
    case Op1Negate = 79
    case OpReserved = 80
    case OpTrue = 81
    case Op2 = 82
    case Op3 = 83
    case Op4 = 84
    case Op5 = 85
    case Op6 = 86
    case Op7 = 87
    case Op8 = 88
    case Op9 = 89
    case Op10 = 90
    case Op11 = 91
    case Op12 = 92
    case Op13 = 93
    case Op14 = 94
    case Op15 = 95
    case Op16 = 96
    case OpNOp = 97
    case OpVer = 98
    case OpIf = 99
    case OpNotIf = 100
    case OpVerIf = 101
    case OpVerNotIf = 102
    case OpElse = 103
    case OpEndIf = 104
    case OpVerify = 105
    case OpReturn = 106
    case OpToAltStack = 107
    case OpFromAltStack = 108
    case Op2DrOp = 109
    case Op2Dup = 110
    case Op3Dup = 111
    case Op2Over = 112
    case Op2Rot = 113
    case Op2Swap = 114
    case OpIfDup = 115
    case OpDepth = 116
    case OpDrOp = 117
    case OpDup = 118
    case OpNip = 119
    case OpOver = 120
    case OpPick = 121
    case OpRoll = 122
    case OpRot = 123
    case OpSwap = 124
    case OpTuck = 125
    // Splice Opcodes
    case OpCat = 126
    case OpSubStr = 127
    case OpLeft = 128
    case OpRight = 129
    case OpSize = 130
    // Bitwise logic Opcodes
    case OpInvert = 131
    case OpAnd = 132
    case OpOr = 133
    case OpXor = 134
    case OpEqual = 135
    case OpEqualVerify = 136
    case OpReserved1 = 137
    case OpReserved2 = 138
    // Numeric related Opcodes
    case Op1Add = 139
    case Op1Sub = 140
    case Op2Mul = 141
    case Op2Div = 142
    case OpNegate = 143
    case OpAbs = 144
    case OpNot = 145
    case Op0NotEqual = 146
    case OpAdd = 147
    case OpSub = 148
    case OpMul = 149
    case OpDiv = 150
    case OpMod = 151
    case OpLShift = 152
    case OpRShift = 153
    case OpBoolAnd = 154
    case OpBoolOr = 155
    case OpNumEqual = 156
    case OpNumEqualVerify = 157
    case OpNumNotEqual = 158
    case OpLessThan = 159
    case OpGreaterThan = 160
    case OpLessThanOrEqual = 161
    case OpGreaterThanOrEqual = 162
    case OpMin = 163
    case OpMax = 164
    case OpWithin = 165
    // Undefined Opcodes
    case OpUnknown166 = 166
    case OpUnknown167 = 167
    // Crypto Opcodes
    case OpSHA256 = 168
    case OpCheckMultiSigECDSA = 169
    case OpBlake2b = 170
    case OpCheckSigECDSA = 171
    case OpCheckSig = 172
    case OpCheckSigVerify = 173
    case OpCheckMultiSig = 174
    case OpCheckMultiSigVerify = 175
    case OpCheckLockTimeVerify = 176
    case OpCheckSequenceVerify = 177
    // Undefined Opcodes
    case OpUnknown178 = 178
    case OpUnknown179 = 179
    case OpUnknown180 = 180
    case OpUnknown181 = 181
    case OpUnknown182 = 182
    case OpUnknown183 = 183
    case OpUnknown184 = 184
    case OpUnknown185 = 185
    case OpUnknown186 = 186
    case OpUnknown187 = 187
    case OpUnknown188 = 188
    case OpUnknown189 = 189
    case OpUnknown190 = 190
    case OpUnknown191 = 191
    case OpUnknown192 = 192
    case OpUnknown193 = 193
    case OpUnknown194 = 194
    case OpUnknown195 = 195
    case OpUnknown196 = 196
    case OpUnknown197 = 197
    case OpUnknown198 = 198
    case OpUnknown199 = 199
    case OpUnknown200 = 200
    case OpUnknown201 = 201
    case OpUnknown202 = 202
    case OpUnknown203 = 203
    case OpUnknown204 = 204
    case OpUnknown205 = 205
    case OpUnknown206 = 206
    case OpUnknown207 = 207
    case OpUnknown208 = 208
    case OpUnknown209 = 209
    case OpUnknown210 = 210
    case OpUnknown211 = 211
    case OpUnknown212 = 212
    case OpUnknown213 = 213
    case OpUnknown214 = 214
    case OpUnknown215 = 215
    case OpUnknown216 = 216
    case OpUnknown217 = 217
    case OpUnknown218 = 218
    case OpUnknown219 = 219
    case OpUnknown220 = 220
    case OpUnknown221 = 221
    case OpUnknown222 = 222
    case OpUnknown223 = 223
    case OpUnknown224 = 224
    case OpUnknown225 = 225
    case OpUnknown226 = 226
    case OpUnknown227 = 227
    case OpUnknown228 = 228
    case OpUnknown229 = 229
    case OpUnknown230 = 230
    case OpUnknown231 = 231
    case OpUnknown232 = 232
    case OpUnknown233 = 233
    case OpUnknown234 = 234
    case OpUnknown235 = 235
    case OpUnknown236 = 236
    case OpUnknown237 = 237
    case OpUnknown238 = 238
    case OpUnknown239 = 239
    case OpUnknown240 = 240
    case OpUnknown241 = 241
    case OpUnknown242 = 242
    case OpUnknown243 = 243
    case OpUnknown244 = 244
    case OpUnknown245 = 245
    case OpUnknown246 = 246
    case OpUnknown247 = 247
    case OpUnknown248 = 248
    case OpUnknown249 = 249
    case OpSmallInteger = 250
    case OpPubKeys = 251
    case OpUnknown252 = 252
    case OpPubKeyHash = 253
    case OpPubKey = 254
    case OpInvalidOpCode = 255
}
