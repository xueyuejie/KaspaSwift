//
//  KaspaKey.swift
//  KaspaSwift
//
//  Created by xgblin on 2024/10/31.
//

import Foundation
import BIP39swift
import BIP32Swift
import Secp256k1Swift

public let pubKeyPrefix = Data([0x03, 0x8f, 0x33, 0x2e])
public let privatePrefix = Data([0x03, 0x8f, 0x2e, 0xf4])

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
    
    public func serializePublicKeyString(version: HDNode.HDversion) -> String? {
        return node.serializeToString(serializePublic: true, version: version)
    }
    
    public func serializePrivateKeyString(version: HDNode.HDversion) -> String? {
        return node.serializeToString(serializePublic: false, version: version)
    }
    
    public func serializePublicKey(version: HDNode.HDversion) -> Data? {
        return node.serialize(serializePublic: true, version: version)
    }
    
    public func serializePrivateKey(version: HDNode.HDversion) -> Data? {
        return node.serialize(serializePublic: false, version: version)
    }
    
    public func derive(path: String) throws -> KaspaKey {
        guard let childNode = node.derive(path: path) else {
            throw KaspaError.invalidDerivePath
        }
        return KaspaKey(node: childNode)
    }
    
    public func derive(index: UInt32, hardened: Bool = false) throws -> KaspaKey {
        guard let childNode = node.derive(index: index, derivePrivateKey: true, hardened: hardened) else {
            throw KaspaError.invalidDerivePath
        }
        return KaspaKey(node: childNode)
    }
    
}
