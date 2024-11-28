//
//  TxOutput.swift
//  KaspaSwift
//
//  Created by xgblin on 2024/11/13.
//

import Foundation

public struct TxOutput {
    public let value: Int64
    public let scriptPublicKey: KaspaScriptPublicKey

    public init(value: Int64, scriptPublicKey: KaspaScriptPublicKey) {
        self.value = value
        self.scriptPublicKey = scriptPublicKey
    }

    public func toRpc() -> Protowire_RpcTransactionOutput {
        var output = Protowire_RpcTransactionOutput()
        output.amount = UInt64(value)
        output.scriptPublicKey = scriptPublicKey.toRpc()
        return output
    }
}
