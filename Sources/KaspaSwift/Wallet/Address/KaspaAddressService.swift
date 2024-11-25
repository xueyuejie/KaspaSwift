//
//  KaspaAddressService.swift
//  KaspaSwift
//
//  Created by xgblin on 2024/10/28.
//

import Foundation
import Bech32

public struct KaspaAddressService {
    private let isTestnet: Bool
    private let prefix: String
    private let version: KaspaAddressComponents.KaspaAddressType = .P2PK_Schnorr
    
    public init(isTestnet: Bool) {
        self.isTestnet = isTestnet
        // TODO: Does testnet support ecdsa type addresses? If not, then we are not ready to work with different curves (secp256k1/schnorr) for now
        self.prefix = isTestnet ? "kaspatest" : "kaspa"
    }
    
    public func parse(_ address: String) -> KaspaAddressComponents? {
        guard
            let (prefix, data) = CashAddrBech32.decode(address),
            !data.isEmpty,
            let firstByte = data.first,
            let type = KaspaAddressComponents.KaspaAddressType(rawValue: firstByte)
        else {
            return nil
        }

        return KaspaAddressComponents(
            prefix: prefix,
            type: type,
            hash: data.dropFirst()
        )
    }
}

// MARK: - AddressProvider

@available(iOS 13.0, *)
extension KaspaAddressService {
    public func makeAddress(for publicKey: Data) throws -> String {
        if publicKey.count != 33 {
            throw KaspaError.invaildPublicKey
        }
        let address = CashAddrBech32.encode(Data([UInt8(version.rawValue)]) + publicKey[1..<33], prefix: self.prefix)
        return address
    }
}

// MARK: - AddressValidator

@available(iOS 13.0, *)
extension KaspaAddressService {
    public func validate(_ address: String) -> Bool {
        guard
            let components = parse(address),
            components.prefix == self.prefix
        else {
            return false
        }

        let validStartLetters = ["q", "p"]
        guard
            let firstAddressLetter = address.dropFirst(prefix.count + 1).first,
            validStartLetters.contains(String(firstAddressLetter))
        else {
            return false
        }

        return true
    }
}
