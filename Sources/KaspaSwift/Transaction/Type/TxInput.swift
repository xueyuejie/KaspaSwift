//
//  TxInput.swift
//  KaspaSwift
//
//  Created by 薛跃杰 on 2024/11/13.
//

import Foundation

public struct TxInput {
    let address: KaspaAddress
    let previousOutpoint: KaspaOutpoint
    let signatureScript: Data
    let sequence: Int64
    let sigOpCount: Int
    let utxoEntry: KaspaUtxoEntry

    init(address: KaspaAddress, previousOutpoint: KaspaOutpoint, signatureScript: Data, sequence: Int64, sigOpCount: Int, utxoEntry: KaspaUtxoEntry) {
        self.address = address
        self.previousOutpoint = previousOutpoint
        self.signatureScript = signatureScript
        self.sequence = sequence
        self.sigOpCount = sigOpCount
        self.utxoEntry = utxoEntry
    }

    func toRpc() -> Kaspa_RpcTransactionInput {
        var input = Kaspa_RpcTransactionInput()
        input.previousOutpoint = previousOutpoint.toRpc()
        input.signatureScript = signatureScript.hexEncodedString()
        input.sequence = UInt64(sequence)
        input.sigOpCount = UInt32(sigOpCount)
        return input
    }
}
