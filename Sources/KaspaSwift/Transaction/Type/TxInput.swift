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
    public let sequence: UInt64
    public let sigOpCount: Int
    public let utxoEntry: KaspaUtxoEntry
    public let redeemScript: Data?

    public init(address: KaspaAddress, previousOutpoint: KaspaOutpoint, signatureScript: Data = Data() , sequence: UInt64, sigOpCount: Int, utxoEntry: KaspaUtxoEntry, redeemScript: Data? = nil) {
        self.address = address
        self.previousOutpoint = previousOutpoint
        self.signatureScript = signatureScript
        self.sequence = sequence
        self.sigOpCount = sigOpCount
        self.utxoEntry = utxoEntry
        self.redeemScript = redeemScript
    }
    
    public func signedInput(transaction: Transaction, inputIndex: Int, key: KaspaKey) throws -> TxInput {
        do {
            var sighashReusedValues = SighashReusedValues()
            guard let serializedTransaction = TransactionUtil.calculateSignatureHashSchnorr(tx: transaction, inputIndex: inputIndex, hashType: SigHashType.sigHashAll, sighashReusedValues: &sighashReusedValues), let privateKey = key.privateKey else {
                throw KaspaError.signError
            }
            let signature = try TransactionUtil.signSchnorr(hash: serializedTransaction, privateKey: privateKey)
            var signatureData = [UInt8]()
            signatureData.append(contentsOf: signature)
            signatureData.append(UInt8(SigHashType.sigHashAll.rawValue))
            var scriptBuilder = try ScriptBuilder().addData(signatureData)
            if let _redeemScript = self.redeemScript {
                scriptBuilder = try scriptBuilder.addData(_redeemScript.bytes)
            }
            self.signatureScript = scriptBuilder.scriptData()
            return self
        } catch let error {
            throw error
        }
    }

    public func toRpc() -> Protowire_RpcTransactionInput {
        var input = Protowire_RpcTransactionInput()
        input.previousOutpoint = previousOutpoint.toRpc()
        input.signatureScript = signatureScript.hexEncodedString()
        input.sequence = sequence
        input.sigOpCount = UInt32(sigOpCount)
        return input
    }
}
