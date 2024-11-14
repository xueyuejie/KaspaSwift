//
//  KaspaOutpoint.swift
//  KaspaSwift
//
//  Created by 薛跃杰 on 2024/11/14.
//

import Foundation

struct KaspaOutpoint: Equatable, Decodable {
    let transactionId: String
    let index: UInt32

    init(transactionId: String, index: UInt32) {
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

    static func fromRpc(_ rpc: Kaspa_RpcOutpoint) -> KaspaOutpoint {
        return KaspaOutpoint(
            transactionId: rpc.transactionID,
            index: rpc.index
        )
    }

    func toRpc() -> Kaspa_RpcOutpoint {
        var rpcOutpoint = Kaspa_RpcOutpoint()
        rpcOutpoint.transactionID = transactionId
        rpcOutpoint.index = index
        return rpcOutpoint
    }
    
    static func == (lhs: KaspaOutpoint, rhs: KaspaOutpoint) -> Bool {
        return lhs.index == rhs.index && lhs.transactionId == rhs.transactionId
    }
}
