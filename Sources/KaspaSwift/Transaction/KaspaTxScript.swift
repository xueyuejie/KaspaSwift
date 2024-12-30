//
//  KaspaTxScript.swift
//  KaspaSwift
//
//  Created by xgblin on 2024/11/15.
//

import Foundation

public struct KaspaTxScript {
    public static func payToPubKeyScript(_ publicKey: Data) -> Data {
        return Data([UInt8(publicKey.count)] + publicKey + [kOpCheckSig])
    }

    public static func payToPubKeyScriptECDSA(_ publicKey: Data) -> Data {
        return Data([UInt8(publicKey.count)] + publicKey + [kOpCheckSigECDSA])
    }

    public static func payToScriptHashScript(_ hash: Data) -> Data {
        return Data([kOpBlake2b, UInt8(hash.count)] + hash + [kOpEqual])
    }
    
    public static func createPayToScriptHashScript(scriptBuilder: ScriptBuilder) -> KaspaScriptPublicKey {
        // 使用 CryptoKit 进行 Blake2b 哈希计算
        let hash = Data(scriptBuilder.script).blake2bDigest(size: 32)!
        let script = payToScriptHashScript(hash)
        return KaspaScriptPublicKey(scriptPublicKey: script, version: UInt32(kAddressScriptHashScriptPublicKeyVersion))
    }
    
    public static func addressFromScriptPublicKey(scriptPublicKey: KaspaScriptPublicKey, networkType: KaspaAddressPrefix) throws -> KaspaAddress {
        let addressType = KaspaAddressComponents.KaspaAddressType.fromScript(scriptPublickey: scriptPublicKey)
        
        let script = scriptPublicKey.scriptPublicKey
        do {
            switch addressType {
            case .P2PK_Schnorr:
                return try KaspaAddress.publicKey(prefix: networkType , publicKey: script[1..<33])
            case .P2PK_ECDSA:
                return try KaspaAddress.pubKeyECDSA(prefix: networkType, publicKey: script[1..<34])
            case .P2SH:
                return KaspaAddress.scriptHash(prefix: networkType, hash: script[2..<34])
            }
        } catch let error {
            throw error
        }
    }
    
    public static func payToAddressScript(address: KaspaAddress) -> KaspaScriptPublicKey {
        switch address.type {
        case .P2PK_Schnorr:
            return KaspaScriptPublicKey(
                scriptPublicKey: payToPubKeyScript(address.scriptAddress()),
                version: UInt32(kAddressPublicKeyScriptPublicKeyVersion)
            )
        case .P2PK_ECDSA:
            return KaspaScriptPublicKey(
                scriptPublicKey: payToPubKeyScriptECDSA(address.scriptAddress()),
                version: UInt32(kAddressPublicKeyECDSAScriptPublicKeyVersion)
            )
        default:
            return KaspaScriptPublicKey(
                scriptPublicKey: payToScriptHashScript(address.scriptAddress()),
                version: UInt32(kAddressScriptHashScriptPublicKeyVersion)
            )
        }
    }
}
