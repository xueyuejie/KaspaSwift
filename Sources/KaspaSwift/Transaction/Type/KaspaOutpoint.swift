//
//  KaspaOutpoint.swift
//  KaspaSwift
//
//  Created by xgblin on 2024/11/14.
//

import Foundation

public struct KaspaOutpoint: Equatable, Decodable {
    public let transactionId: String
    public let index: UInt32

    public init(transactionId: String, index: UInt32) {
        self.transactionId = transactionId
        self.index = index
    }

//    static func fromJson(_ json: [String: Any]) -> KaspaOutpoint? {
//        guard let transactionId = json["transactionId"] as? String,
//              let index = json["index"] as? UInt32 else {
//            return nil
//        }
//        return KaspaOutpoint(transactionId: transactionId, index: index)
//    }

    public static func fromRpc(_ rpc: Protowire_RpcOutpoint) -> KaspaOutpoint {
        return KaspaOutpoint(
            transactionId: rpc.transactionID,
            index: rpc.index
        )
    }

    public func toRpc() -> Protowire_RpcOutpoint {
        var rpcOutpoint = Protowire_RpcOutpoint()
        rpcOutpoint.transactionID = transactionId
        rpcOutpoint.index = UInt32(index)
        return rpcOutpoint
    }
    
    public static func == (lhs: KaspaOutpoint, rhs: KaspaOutpoint) -> Bool {
        return lhs.index == rhs.index && lhs.transactionId == rhs.transactionId
    }
}
