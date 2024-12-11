//
//  KaspaScriptPublicKey.swift
//  KaspaSwift
//
//  Created by xgblin on 2024/11/14.
//

import Foundation

public struct KaspaScriptPublicKey: Equatable, Decodable {
    public let scriptPublicKey: Data
    public let version: UInt32

    public init(scriptPublicKey: Data, version: UInt32) {
        self.scriptPublicKey = scriptPublicKey
        self.version = version
    }

//    static func fromJson(_ json: [String: Any]) -> KaspaScriptPublicKey? {
//        guard let scriptPublicKeyHex = json["scriptPublicKey"] as? String,
//              let scriptPublicKey = Data(hex: scriptPublicKeyHex),
//              let version = json["version"] as? UInt32 else {
//            return nil
//        }
//        return KaspaScriptPublicKey(scriptPublicKey: scriptPublicKey, version: version)
//    }

    public static func fromRpc(_ rpc: Protowire_RpcScriptPublicKey) -> KaspaScriptPublicKey {
        return KaspaScriptPublicKey(
            scriptPublicKey: Data(hex: rpc.scriptPublicKey),
            version: rpc.version
        )
    }

    public func toRpc() -> Protowire_RpcScriptPublicKey {
        var publicKey = Protowire_RpcScriptPublicKey()
        publicKey.scriptPublicKey = scriptPublicKey.hexEncodedString()
        publicKey.version = version
        return publicKey
    }
    
    public static func == (lhs: KaspaScriptPublicKey, rhs: KaspaScriptPublicKey) -> Bool {
        return lhs.scriptPublicKey == rhs.scriptPublicKey && lhs.version == rhs.version
    }
}
