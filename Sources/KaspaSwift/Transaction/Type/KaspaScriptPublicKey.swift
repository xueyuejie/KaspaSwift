//
//  KaspaScriptPublicKey.swift
//  KaspaSwift
//
//  Created by 薛跃杰 on 2024/11/14.
//

import Foundation

public struct KaspaScriptPublicKey: Equatable, Decodable {
    let scriptPublicKey: Data
    let version: UInt32

    init(scriptPublicKey: Data, version: UInt32) {
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

    static func fromRpc(_ rpc: Kaspa_RpcScriptPublicKey) -> KaspaScriptPublicKey {
        return KaspaScriptPublicKey(
            scriptPublicKey: Data(hex: rpc.scriptPublicKey),
            version: rpc.version
        )
    }

    func toRpc() -> Kaspa_RpcScriptPublicKey {
        var publicKey = Kaspa_RpcScriptPublicKey()
        publicKey.scriptPublicKey = scriptPublicKey.hexEncodedString()
        publicKey.version = version
        return publicKey
    }
    
    public static func == (lhs: KaspaScriptPublicKey, rhs: KaspaScriptPublicKey) -> Bool {
        return lhs.scriptPublicKey == rhs.scriptPublicKey && lhs.version == rhs.version
    }
}
