//
//  TxOutput.swift
//  KaspaSwift
//
//  Created by xgblin on 2024/11/13.
//

import Foundation

public struct TxOutput {
    public let value: UInt64
    public let scriptPublicKey: KaspaScriptPublicKey

    public init(value: UInt64, scriptPublicKey: KaspaScriptPublicKey) {
        self.value = value
        self.scriptPublicKey = scriptPublicKey
    }

    public func toRpc() -> Protowire_RpcTransactionOutput {
        var output = Protowire_RpcTransactionOutput()
        output.amount = value
        output.scriptPublicKey = scriptPublicKey.toRpc()
        return output
    }
}
