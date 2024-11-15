//
//  KaspaTransactionUtil.swift
//  KaspaSwift
//
//  Created by 薛跃杰 on 2024/11/14.
//

import Foundation
import Blake2

public struct KaspaTransactionUtil {
    static let kTransactionHashDomain = "TransactionHash"
    static let kTransactionIdDomain = "TransactionID"
    static let blake2bDigestKey = "TransactionSigningHash".data(using: .utf8)?.bytes ?? []
    static func getUint16(_ value: Int) -> Data {
        var data = Data(count: 2)
        data.withUnsafeMutableBytes { (pointer: UnsafeMutableRawBufferPointer) in
            pointer.bindMemory(to: UInt16.self).baseAddress?.pointee = UInt16(value).littleEndian
        }
        return data
    }

    static func getUint32(_ value: Int) -> Data {
        var data = Data(count: 4)
        data.withUnsafeMutableBytes { (pointer: UnsafeMutableRawBufferPointer) in
            pointer.bindMemory(to: UInt32.self).baseAddress?.pointee = UInt32(value).littleEndian
        }
        return data
    }

    static func addOutpoint(_ outpoint: KaspaOutpoint, builder: inout Data) {
        builder.append(Data(hex: outpoint.transactionId))
        builder.append(getUint32(Int(outpoint.index)))
    }

    static func getPreviousOutputsHash(tx: KaspaTransaction, hashType: SigHashType, reusedValues: inout SighashReusedValues) -> Data {
        assert(hashType == .sigHashAll)
        
        if reusedValues.previousOutputsHash == nil {
            var builder = Data()
            for txInput in tx.inputs {
                addOutpoint(txInput.previousOutpoint, builder: &builder)
            }
            
            let hash = builder.blake2bDigest(size: 32, key: blake2bDigestKey)
            reusedValues.previousOutputsHash = hash
        }

        return reusedValues.previousOutputsHash!
    }

    static func getSequencesHash(tx: KaspaTransaction, hashType: SigHashType, reusedValues: inout SighashReusedValues) -> Data {
        assert(hashType == .sigHashAll)

        if reusedValues.sequencesHash == nil {
            var builder = Data()
            for txInput in tx.inputs {
                builder.appendUInt64(UInt64(txInput.sequence))
            }
            let hash = builder.blake2bDigest(size: 32, key: blake2bDigestKey)
            reusedValues.sequencesHash = hash
        }

        return reusedValues.sequencesHash!
    }

    static func getSigOpCountsHash(tx: KaspaTransaction, hashType: SigHashType, reusedValues: inout SighashReusedValues) -> Data {
        assert(hashType == .sigHashAll)

        if reusedValues.sigOpCountsHash == nil {
            var builder = Data()
            for txInput in tx.inputs {
                builder.append(UInt8(txInput.sigOpCount))
            }
            
            let hash = builder.blake2bDigest(size: 32, key: blake2bDigestKey)
            reusedValues.sigOpCountsHash = hash
        }

        return reusedValues.sigOpCountsHash!
    }

    static func getOutputsHash(tx: KaspaTransaction, inputIndex: Int, hashType: SigHashType, reusedValues: inout SighashReusedValues) -> Data {
        assert(hashType == .sigHashAll)

        if reusedValues.outputsHash == nil {
            var builder = Data()
            for txOutput in tx.outputs {
                builder.appendUInt64(UInt64(txOutput.value))
                builder.append(getUint16(Int(txOutput.scriptPublicKey.version)))
                let script = txOutput.scriptPublicKey.scriptPublicKey
                builder.appendUInt64(UInt64(script.count))
                builder.append(script)
            }
            let hash = builder.blake2bDigest(size: 32, key: blake2bDigestKey)
            reusedValues.outputsHash = hash
        }

        return reusedValues.outputsHash!
    }

    static func calculateSignatureHash(tx: KaspaTransaction, inputIndex: Int, txInput: TxInput, prevScriptPublicKey: KaspaScriptPublicKey, hashType: SigHashType, reusedValues: inout SighashReusedValues) -> Data? {
        var builder = Data()

        // version
        let version = getUint16(tx.version)
        builder.append(version)

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
        builder.append(getUint16(Int(prevScriptPublicKey.version)))
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
        builder.append(UInt8(hashType.rawValue))
        
        let hash = builder.blake2bDigest(size: 32, key: blake2bDigestKey)

        return hash
    }

    static func calculateSignatureHashSchnorr(tx: KaspaTransaction, inputIndex: Int, hashType: SigHashType, sighashReusedValues: inout SighashReusedValues) -> Data? {
        assert(hashType == .sigHashAll)

        let input = tx.inputs[inputIndex]
        let prevScriptPublicKey = input.utxoEntry.scriptPublicKey

        return calculateSignatureHash(tx: tx, inputIndex: inputIndex, txInput: input, prevScriptPublicKey: prevScriptPublicKey, hashType: hashType, reusedValues: &sighashReusedValues)
    }

    static func genAux(bytes: Int = 32) -> Data {
        var aux = Data(count: bytes)
        _ = aux.withUnsafeMutableBytes { SecRandomCopyBytes(kSecRandomDefault, bytes, $0.baseAddress!) }
        return aux
    }

    static func signSchnorrHex(privateKey: String, hash: Data, aux: String) -> String {
        
        return ""
    }

    static func signSchnorr(hash: Data, privateKey: Data) -> Data {
        let signatureHex = signSchnorrHex(privateKey: privateKey.hexEncodedString(), hash: hash, aux: genAux().hexEncodedString())
        return Data(hex: signatureHex)
    }
}
