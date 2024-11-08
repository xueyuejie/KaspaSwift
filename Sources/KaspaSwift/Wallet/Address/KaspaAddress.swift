//
//  KaspaAddress.swift
//  KaspaSwift
//
//  Created by 薛跃杰 on 2024/11/4.
//

import Foundation

public class KaspaAddress {
    static let kAddressIdPubKey: UInt8 = 0x00;
    static let kAddressIdPubKeyECDSA: UInt8 = 0x01;
    static let kAddressIdScriptHash: UInt8 = 0x08;

    static let kPublicKeyLength = 32;
    static let kPublicKeySizeECDSA = 33;
    
    public let prefix: KaspaAddressPrefix
    public let payload: Data
    public let version: Int
    
    public init(prefix: KaspaAddressPrefix, payload: Data, version: Int) {
        self.prefix = prefix
        self.payload = payload
        self.version = version
    }
    
    static func publicKey(prefix: KaspaAddressPrefix, publicKey: Data) throws -> KaspaAddress {
        guard publicKey.count == 32 else {
            throw KaspaError.message("Unknown Address Type")
        }
        return KaspaAddress(prefix: prefix, payload: publicKey, version: 0x00)
    }

    static func pubKeyECDSA(prefix: KaspaAddressPrefix, publicKey: Data) throws -> KaspaAddress {
        guard publicKey.count == 33 else {
            throw KaspaError.message("Unknown Address Type")
        }
        return KaspaAddress(prefix: prefix, payload: publicKey, version: 0x01)
    }

    static func scriptHash(prefix: KaspaAddressPrefix, hash: Data) -> KaspaAddress {
        return KaspaAddress(prefix: prefix, payload: hash, version: 0x08)
    }
    
    public func encodeAddress() -> String {
        let words = Data([UInt8(version)] + payload)
        let address = CashAddrBech32.encode(words, prefix: prefix.rawValue)
        return address
    }

    
    public static func decodeAddress(address: String, expectedPrefix: KaspaAddressPrefix  = KaspaAddressPrefix.unknown) throws -> KaspaAddress {
        guard let (prefixStr, data) = CashAddrBech32.decode(address) else {
            throw KaspaError.message("address decode error")
        }
        guard let _prefix = KaspaAddressPrefix(rawValue: prefixStr),
           expectedPrefix == KaspaAddressPrefix.unknown && expectedPrefix == _prefix else {
            throw KaspaError.message("Invalid prefix")
        }
        
        let version = data.bytes.first
        let payload = data[1 ..< data.count]
        switch version {
        case kAddressIdPubKey:
            return try publicKey(prefix: _prefix , publicKey: payload)
        case kAddressIdPubKeyECDSA:
            return try pubKeyECDSA(prefix: _prefix, publicKey: payload)
        case kAddressIdScriptHash:
            return scriptHash(prefix: _prefix, hash: payload)
        default:
            throw KaspaError.message("Unknown Address Type")
        }
    }
    
    public func scriptAddress() -> Data {
        return payload
    }
    
    public func isForPrefix(_ prefix: KaspaAddressPrefix) -> Bool {
        return self.prefix == prefix
    }
    
    public static func tryParse(_ address: String, expectedPrefix: KaspaAddressPrefix) -> KaspaAddress? {
        do {
            return try decodeAddress(address: address, expectedPrefix: expectedPrefix)
        } catch {
            return nil
        }
    }
    
    public static func isValid(_ address: String, expectedPrefix: KaspaAddressPrefix) -> Bool {
        return tryParse(address, expectedPrefix: expectedPrefix) != nil
    }
}

public enum KaspaAddressPrefix: String {
    case unknown
    case kaspa
    case kaspaTest
    case kaspaDev
    case kaspaSim

    static func parseBech32Prefix(_ prefix: String) -> KaspaAddressPrefix {
        switch prefix {
        case "kaspa":
            return .kaspa
        case "kaspatest":
            return .kaspaTest
        case "kaspadev":
            return .kaspaDev
        case "kaspasim":
            return .kaspaSim
        default:
            return .unknown
        }
    }
}
