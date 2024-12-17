//
//  TxInput.swift
//  KaspaSwift
//
//  Created by xgblin on 2024/11/13.
//

import Foundation

public class TxInput {
    public let address: KaspaAddress
    public let previousOutpoint: KaspaOutpoint
    public var signatureScript: Data
    public let sequence: Int64
    public let sigOpCount: Int
    public let utxoEntry: KaspaUtxoEntry

    public init(address: KaspaAddress, previousOutpoint: KaspaOutpoint, signatureScript: Data = Data() , sequence: Int64, sigOpCount: Int, utxoEntry: KaspaUtxoEntry) {
        self.address = address
        self.previousOutpoint = previousOutpoint
        self.signatureScript = signatureScript
        self.sequence = sequence
        self.sigOpCount = sigOpCount
        self.utxoEntry = utxoEntry
    }
    
    @MainActor
    public func signedInput(transaction: Transaction, inputIndex: Int, key: KaspaKey) -> TxInput? {
        var sighashReusedValues = SighashReusedValues()
        guard let serializedTransaction = TransactionUtil.calculateSignatureHashSchnorr(tx: transaction, inputIndex: inputIndex, hashType: SigHashType.sigHashAll, sighashReusedValues: &sighashReusedValues), let privateKey = key.privateKey else {
            return nil
        }
        guard let signature = try? TransactionUtil.signSchnorr(hash: serializedTransaction, privateKey: privateKey) else {
            return nil
        }
        var signatureScript = [UInt8]()
        signatureScript.append(UInt8(signature.count + 1))
        signatureScript.append(contentsOf: signature)
        signatureScript.append(UInt8(SigHashType.sigHashAll.rawValue))
        self.signatureScript.replaceSubrange(0..<signatureScript.count, with: signatureScript)
        return self
    }

    public func toRpc() -> Protowire_RpcTransactionInput {
        var input = Protowire_RpcTransactionInput()
        input.previousOutpoint = previousOutpoint.toRpc()
        input.signatureScript = signatureScript.hexEncodedString()
        input.sequence = UInt64(sequence)
        input.sigOpCount = UInt32(sigOpCount)
        return input
    }
}
