//
//  KaspaUtxo.swift
//  KaspaSwift
//
//  Created by 薛跃杰 on 2024/11/14.
//

import Foundation

public struct KaspaUtxo: Equatable, Decodable {
    
    let address: String
    let outpoint: KaspaOutpoint
    let utxoEntry: KaspaUtxoEntry

    init(address: String, outpoint: KaspaOutpoint, utxoEntry: KaspaUtxoEntry) {
        self.address = address
        self.outpoint = outpoint
        self.utxoEntry = utxoEntry
    }

//    static func fromJson(_ json: [String: Any]) -> KaspaUtxo? {
//        guard let address = json["address"] as? String,
//              let outpointJson = json["outpoint"] as? [String: Any],
//              let utxoEntryJson = json["utxoEntry"] as? [String: Any],
//              let outpoint = KaspaOutpoint.fromJson(outpointJson),
//              let utxoEntry = KaspaUtxoEntry.fromJson(utxoEntryJson) else {
//            return nil
//        }
//        return KaspaUtxo(address: address, outpoint: outpoint, utxoEntry: utxoEntry)
//    }

    static func fromRpc(_ rpc: Kaspa_RpcUtxosByAddressesEntry) -> KaspaUtxo {
        return KaspaUtxo(
            address: rpc.address,
            outpoint: KaspaOutpoint.fromRpc(rpc.outpoint),
            utxoEntry: KaspaUtxoEntry.fromRpc(rpc.utxoEntry)
        )
    }

    func toRpc() -> Kaspa_RpcUtxosByAddressesEntry {
        var rpcUtxosByAddressesEntry = Kaspa_RpcUtxosByAddressesEntry()
        rpcUtxosByAddressesEntry.address = address
        rpcUtxosByAddressesEntry.outpoint = outpoint.toRpc()
        rpcUtxosByAddressesEntry.utxoEntry = utxoEntry.toRpc()
        return rpcUtxosByAddressesEntry
    }
    
    public static func == (lhs: KaspaUtxo, rhs: KaspaUtxo) -> Bool {
        return lhs.address == rhs.address && lhs.outpoint == rhs.outpoint && lhs.utxoEntry == rhs.utxoEntry
    }
}
