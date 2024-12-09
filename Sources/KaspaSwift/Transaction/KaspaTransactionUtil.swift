//
//  KaspaTransactionUtil.swift
//  KaspaSwift
//
//  Created by xgblin on 2024/11/14.
//

import Foundation
import Blake2

public struct KaspaTransactionUtil {
    public static let kTransactionHashDomain = "TransactionHash"
    public static let kTransactionIdDomain = "TransactionID"
    public static let blake2bDigestKey = "TransactionSigningHash".data(using: .utf8)?.bytes ?? []

    public static func hashPrevouts(_ outpoint: KaspaOutpoint) -> Data {
        var data = Data()
        data.append(Data(hex: outpoint.transactionId))
        data.appendUInt32(UInt32(outpoint.index))
        return data
    }
    
    public static func addOutpoint(_ outpoint: KaspaOutpoint, builder: inout Data) {
        builder.append(Data(hex: outpoint.transactionId))
        builder.appendUInt32(UInt32(outpoint.index))
    }

    public static func getPreviousOutputsHash(tx: KaspaTransaction, hashType: SigHashType, reusedValues: inout SighashReusedValues) -> Data {
        if reusedValues.previousOutputsHash == nil {
            var data = Data()
            for txInput in tx.inputs {
                let hash = hashPrevouts(txInput.previousOutpoint)
                data.append(hash)
            }
            let hash = data.blake2bDigest(size: 32, key: blake2bDigestKey)
            reusedValues.previousOutputsHash = hash
        }

        return reusedValues.previousOutputsHash!
    }

    public static func getSequencesHash(tx: KaspaTransaction, hashType: SigHashType, reusedValues: inout SighashReusedValues) -> Data {
        var data = Data()
        if reusedValues.sequencesHash == nil {
            for _ in tx.inputs {
                data.appendUInt64(UInt64(0))
            }
            let hash = data.blake2bDigest(size: 32, key: blake2bDigestKey)
            reusedValues.sequencesHash = hash
        }
        return reusedValues.sequencesHash!
    }

    public static func getSigOpCountsHash(tx: KaspaTransaction, hashType: SigHashType, reusedValues: inout SighashReusedValues) -> Data {
        if reusedValues.sigOpCountsHash == nil {
            let data = Data(repeating: UInt8(1), count: tx.inputs.count)
            let hash = data.blake2bDigest(size: 32, key: blake2bDigestKey)
            reusedValues.sigOpCountsHash = hash
        }
        return reusedValues.sigOpCountsHash!
    }

    public static func getOutputsHash(tx: KaspaTransaction, inputIndex: Int, hashType: SigHashType, reusedValues: inout SighashReusedValues) -> Data {
        assert(hashType == .sigHashAll)

        if reusedValues.outputsHash == nil {
            var data = Data()
            for txOutput in tx.outputs {
                data.appendUInt64(UInt64(txOutput.value))
                data.appendUInt16(UInt16(txOutput.scriptPublicKey.version))
                let script = txOutput.scriptPublicKey.scriptPublicKey
                data.appendUInt64(UInt64(script.count))
                data.append(script)
            }
            let hash = data.blake2bDigest(size: 32, key: blake2bDigestKey)
            reusedValues.outputsHash = hash
        }

        return reusedValues.outputsHash!
    }

    public static func calculateSignatureHash(tx: KaspaTransaction, inputIndex: Int, txInput: TxInput, prevScriptPublicKey: KaspaScriptPublicKey, hashType: SigHashType, reusedValues: inout SighashReusedValues) -> Data? {
        var builder = Data()

        // version
        builder.appendUInt16(UInt16(tx.version))

        // previousOutputsHash
        let previousOutputsHash = getPreviousOutputsHash(tx: tx, hashType: hashType, reusedValues: &reusedValues)
        builder.append(previousOutputsHash)

        // sequencesHash
        let sequencesHash = getSequencesHash(tx: tx, hashType: hashType, reusedValues: &reusedValues)
        builder.append(sequencesHash)

        // sigOpCountsHash
        let sigOpCountsHash = getSigOpCountsHash(tx: tx, hashType: hashType, reusedValues: &reusedValues)
        builder.append(sigOpCountsHash)

        // hashOutpoint
        addOutpoint(txInput.previousOutpoint, builder: &builder)

        // prevScriptPublicKey
        builder.appendUInt16(UInt16(prevScriptPublicKey.version))
        let script = prevScriptPublicKey.scriptPublicKey
        builder.appendUInt64(UInt64(script.count))
        builder.append(script)

        // amount
        builder.appendUInt64(UInt64(txInput.utxoEntry.amount))

        // sequence
        builder.appendUInt64(UInt64(txInput.sequence))

        // sigOpCount
        builder.appendUInt8(UInt8(txInput.sigOpCount))

        // outputsHash
        let outputsHash = getOutputsHash(tx: tx, inputIndex: inputIndex, hashType: hashType, reusedValues: &reusedValues)
        builder.append(outputsHash)

        // lockTime
        builder.appendUInt64(UInt64(tx.lockTime))

        // subnetworkId
        builder.append(tx.subnetworkId)

        // gas
        builder.appendUInt64(UInt64(tx.gas))

        // payloadHash
        builder.append(Data(repeating: 0, count: 32))

        // hashType
        builder.appendUInt8(UInt8(hashType.rawValue))
        
        let hash = builder.blake2bDigest(size: 32, key: blake2bDigestKey)

        return hash
    }

    public static func calculateSignatureHashSchnorr(tx: KaspaTransaction, inputIndex: Int, hashType: SigHashType, sighashReusedValues: inout SighashReusedValues) -> Data? {

        let input = tx.inputs[inputIndex]
        let prevScriptPublicKey = input.utxoEntry.scriptPublicKey

        return calculateSignatureHash(tx: tx, inputIndex: inputIndex, txInput: input, prevScriptPublicKey: prevScriptPublicKey, hashType: hashType, reusedValues: &sighashReusedValues)
    }
    @MainActor
    public static func signSchnorr(hash: Data, privateKey: Data) throws -> Data {
        return try SignHelper.sign(data: hash, privateKey: privateKey)
    }
}
