//
//  KaspaKey.swift
//  KaspaSwift
//
//  Created by 薛跃杰 on 2024/10/31.
//

import Foundation
import BIP39swift
import BIP32Swift
import Secp256k1Swift

public struct KaspaKey {
    private var node: HDNode
    
    public var publicKey: Data {
        return node.publicKey
    }
    
    public var pubKeyHash: Data {
        return publicKey.hash160()!
    }
    
    public var privateKey: Data? {
        return node.privateKey
    }
    
    public static func fromMnemonics(_ mnemonics: String) -> Self? {
        guard let seed = BIP39.seedFromMmemonics(mnemonics) else {
            return nil
        }
        guard let rootNode = HDNode(seed: seed) else {
            return nil
        }
       return KaspaKey(node: rootNode)
    }
    
    public func serializePublicKey(version: HDNode.HDversion) -> String? {
        return node.serializeToString(serializePublic: true, version: version)
    }
    
    public func serializePrivateKey(version: HDNode.HDversion) -> String? {
        return node.serializeToString(serializePublic: false, version: version)
    }
    
    public func derive(path: String) throws -> KaspaKey {
        guard let childNode = node.derive(path: path) else {
            throw Error.invalidDerivePath
        }
        return KaspaKey(node: childNode)
    }
    
    public func derive(index: UInt32, hardened: Bool = false) throws -> KaspaKey {
        guard let childNode = node.derive(index: index, derivePrivateKey: true, hardened: hardened) else {
            throw Error.invalidDerivePath
        }
        return KaspaKey(node: childNode)
    }
    
}

public extension KaspaKey {
    func signMessage(_ message: String, compressed: Bool = true) -> Data? {
        guard let priKey = self.privateKey else { return nil }
        
        let prefix = "\u{18}Bitcoin Signed Message:\n"
        guard let prefixData = prefix.data(using: .utf8) else {return nil}
        guard let mesasgeData = message.data(using: .utf8) else { return nil }

        var data = Data()
        data.append(prefixData)
        data.appendVarInt(UInt64(message.count))
        data.append(mesasgeData)
        
        let (serializedSignature, _) = SECP256K1.signForRecovery(hash: data.hash256(), privateKey: priKey, useExtraEntropy: true, useExtraVer: false)
        
        guard let sig = serializedSignature else { return nil }
        guard let unmarshalSig = SECP256K1.unmarshalSignature(signatureData: sig) else { return nil }
        
        var v = unmarshalSig.v
        v +=  0x1b
        v += compressed ? 0x04 : 0x00
        
        return Data([v]) + unmarshalSig.r + unmarshalSig.s
    }
}

public extension KaspaKey {
    enum Error: String, LocalizedError {
        case invalidDerivePath
    }
}
