//
//  KaspaUtxoEntry.swift
//  KaspaSwift
//
//  Created by xgblin on 2024/11/14.
//

import Foundation
import BigInt

public struct KaspaUtxoEntry: Equatable, Decodable{
    public let amount: BigInt
    public let scriptPublicKey: KaspaScriptPublicKey
    public let blockDaaScore: BigInt
    public let isCoinbase: Bool

    public init(amount: BigInt, scriptPublicKey: KaspaScriptPublicKey, blockDaaScore: BigInt, isCoinbase: Bool) {
        self.amount = amount
        self.scriptPublicKey = scriptPublicKey
        self.blockDaaScore = blockDaaScore
        self.isCoinbase = isCoinbase
    }

//    static func fromJson(_ json: [String: Any]) -> KaspaUtxoEntry? {
//        guard let amountValue = json["amount"] as? Int,
//              let scriptPublicKeyJson = json["scriptPublicKey"] as? [String: Any],
//              let blockDaaScoreValue = json["blockDaaScore"] as? Int,
//              let isCoinbase = json["isCoinbase"] as? Bool,
//              let scriptPublicKey = KaspaScriptPublicKey.fromJson(scriptPublicKeyJson) else {
//            return nil
//        }
//        return KaspaUtxoEntry(
//            amount: BigInt(amountValue),
//            scriptPublicKey: scriptPublicKey,
//            blockDaaScore: BigInt(blockDaaScoreValue),
//            isCoinbase: isCoinbase
//        )
//    }

    public static func fromRpc(_ rpc: Protowire_RpcUtxoEntry) -> KaspaUtxoEntry {
        return KaspaUtxoEntry(
            amount: BigInt(rpc.amount),
            scriptPublicKey: KaspaScriptPublicKey.fromRpc(rpc.scriptPublicKey),
            blockDaaScore: BigInt(rpc.blockDaaScore),
            isCoinbase: rpc.isCoinbase
        )
    }

    public func toRpc() -> Protowire_RpcUtxoEntry {
        var rpcUtxoEntry = Protowire_RpcUtxoEntry()
        rpcUtxoEntry.amount = UInt64(amount.description) ?? 0
        rpcUtxoEntry.scriptPublicKey = scriptPublicKey.toRpc()
        rpcUtxoEntry.blockDaaScore = UInt64(blockDaaScore.description) ?? 0
        rpcUtxoEntry.isCoinbase = isCoinbase
        return rpcUtxoEntry
    }
    
    public func copyWith(
        amount: BigInt? = nil,
        scriptPublicKey: KaspaScriptPublicKey? = nil,
        blockDaaScore: BigInt? = nil,
        isCoinbase: Bool? = nil
    ) -> KaspaUtxoEntry {
        return KaspaUtxoEntry(
            amount: amount ?? self.amount,
            scriptPublicKey: scriptPublicKey ?? self.scriptPublicKey,
            blockDaaScore: blockDaaScore ?? self.blockDaaScore,
            isCoinbase: isCoinbase ?? self.isCoinbase
        )
    }
    
    public static func == (lhs: KaspaUtxoEntry, rhs: KaspaUtxoEntry) -> Bool {
        return lhs.amount == rhs.amount &&
               lhs.scriptPublicKey == rhs.scriptPublicKey &&
               lhs.isCoinbase == rhs.isCoinbase
    }
}
