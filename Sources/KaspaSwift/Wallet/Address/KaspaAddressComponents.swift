//
//  KaspaAddressComponents.swift
//  KaspaSwift
//
//  Created by xgblin on 2024/10/28.
//

import Foundation
public struct KaspaAddressComponents {
    public let prefix: String
    public let type: KaspaAddressType
    public let hash: Data
}

extension KaspaAddressComponents {
    public enum KaspaAddressType: UInt8 {
        case P2PK_Schnorr = 0 // PubKey
        case P2PK_ECDSA = 1 // PubKeyECDSA
        case P2SH = 8 // ScriptHash
        
        public static func fromScript(scriptPublickey: KaspaScriptPublicKey) -> KaspaAddressType {
            let script = scriptPublickey.scriptPublicKey
            if scriptPublickey.version == 0 {
                if isPayToPubKey(scriptPublicKey: script.bytes) {
                    return KaspaAddressType.P2PK_Schnorr
                } else if isPayToPubKeyECDSA(scriptPublicKey: script.bytes) {
                    return KaspaAddressType.P2PK_ECDSA
                } else if isPayToScriptHash(scriptPublicKey: script.bytes) {
                    return KaspaAddressType.P2SH
                }
            }
            return KaspaAddressType.P2PK_Schnorr
        }
        
        static func isPayToPubKey(scriptPublicKey: [UInt8]) -> Bool {
            return scriptPublicKey.count == 34 && // 2 opcodes number + 32 data
            scriptPublicKey[0] == OpCode.OpData32.rawValue &&
                   scriptPublicKey[33] == OpCode.OpCheckSig.rawValue
        }

        static func isPayToPubKeyECDSA(scriptPublicKey: [UInt8]) -> Bool {
            return scriptPublicKey.count == 35 && // 2 opcodes number + 33 data
                   scriptPublicKey[0] == OpCode.OpData33.rawValue &&
                   scriptPublicKey[34] == OpCode.OpCheckSigECDSA.rawValue
        }

        static func isPayToScriptHash(scriptPublicKey: [UInt8]) -> Bool {
            return scriptPublicKey.count == 35 && // 3 opcodes number + 32 data
                   scriptPublicKey[0] == OpCode.OpBlake2b.rawValue &&
                   scriptPublicKey[1] == OpCode.OpData32.rawValue &&
                   scriptPublicKey[34] == OpCode.OpEqual.rawValue
        }
    }
}
