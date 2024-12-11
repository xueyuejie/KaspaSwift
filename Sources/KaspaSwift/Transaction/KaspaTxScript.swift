//
//  KaspaTxScript.swift
//  KaspaSwift
//
//  Created by xgblin on 2024/11/15.
//

import Foundation

public struct KaspaTxScript {
    static let kOpEqual: UInt8 = 135
    static let kOpBlake2b: UInt8 = 170
    static let kOpCheckSigECDSA: UInt8 = 171
    static let kOpCheckSig: UInt8 = 172

    public static func payToPubKeyScript(_ publicKey: Data) -> Data {
        return Data([UInt8(publicKey.count)] + publicKey + [kOpCheckSig])
    }

    public static func payToPubKeyScriptECDSA(_ publicKey: Data) -> Data {
        return Data([UInt8(publicKey.count)] + publicKey + [kOpCheckSigECDSA])
    }

    public static func payToScriptHashScript(_ hash: Data) -> Data {
        return Data([kOpBlake2b, UInt8(hash.count)] + hash + [kOpEqual])
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
