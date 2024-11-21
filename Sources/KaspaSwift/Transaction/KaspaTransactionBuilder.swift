//
//  KaspaTransactionBuilder.swift
//  KaspaSwift
//
//  Created by 薛跃杰 on 2024/11/13.
//

import Foundation
import BigInt

@MainActor public let kSompiPerKaspa = BigInt(100000000)
@MainActor public let kStorageMassParameter = kSompiPerKaspa * BigInt(10000)

@MainActor public let kMinChangeTarget = BigInt(20000000)
@MainActor public let kFeePerInput = BigInt(10000)
@MainActor public let kMaxInputsPerTransaction = 84
@MainActor public let kMaximumStandardTransactionMass = BigInt(100000)
public let kDomainHashSize = 32
public let kDomainSubnetworkIDSize = 20

public let kMaxTransactionVersion = 0

public let kSubnetworkIdNative = Data(count: kDomainSubnetworkIDSize)

@MainActor public let kSubnetworkIdCoinbase: Data = {
    var data = Data(count: kDomainSubnetworkIDSize)
    data[0] = 1
    return data
}()
@MainActor public let kSubnetworkIdRegistry: Data = {
    var data = Data(count: kDomainSubnetworkIDSize)
    data[0] = 2
    return data
}()

public let kSubnetworkIdNativeHex = kSubnetworkIdNative.hexEncodedString()
@MainActor public let kSubnetworkIdCoinbaseHex = kSubnetworkIdCoinbase.hexEncodedString()
@MainActor public let kSubnetworkIdRegistryHex = kSubnetworkIdRegistry.hexEncodedString()

public let kUnacceptedDAASccore = Int64(-1)

public let kSigHashAll = 1
public let kSigHashNone = 1 << 1
public let kSigHashSingle = 1 << 2
public let kSigHashAnyOneCanPay = 1 << 7

public class KaspaTransactionBuilder {
    public let utxos: [KaspaUtxo]
    public let feePerInputRaw: BigInt
    public let priorityFee: BigInt
    
    private var _change: BigInt = .zero
    var change: BigInt {
        return _change
    }
    
    private var _changeAddress: KaspaAddress?
    var changeAddress: KaspaAddress? {
        return _changeAddress
    }
    
    private var _baseFee: BigInt = .zero
    var baseFee: BigInt {
        return BigInt(_baseFee)
    }
    
    private var _selectedUtxos: [KaspaUtxo] = []
    public var selectedUtxos: [KaspaUtxo] {
        return _selectedUtxos
    }
    
    @MainActor
    public init(utxos: [KaspaUtxo], feePerInput: BigInt? = nil, priorityFee: BigInt? = nil) {
        self.utxos = utxos
        self.feePerInputRaw = feePerInput ?? kFeePerInput
        self.priorityFee = priorityFee ?? BigInt.zero
    } 
    
    @MainActor
    public func rebuildTransaction(tx: ApiTransaction, toAddress: KaspaAddress, changeAddress: KaspaAddress) throws -> KaspaTransaction? {
        let amountRaw = BigInt(tx.outputs.first?.amount ?? 0)
        
        var utxoMap: Set<UtxoKey> = Set(tx.inputs.map { input in
            return UtxoKey(
                previousOutpointHash: input.previousOutpointHash,
                previousOutpointIndex: Int(input.previousOutpointIndex)
            )
        })
        
        var txUtxos: [KaspaUtxo] = []
        
        for utxo in utxos {
            let outpoint = UtxoKey(previousOutpointHash: utxo.outpoint.transactionId, previousOutpointIndex: Int(utxo.outpoint.index))
            if utxoMap.contains(outpoint) {
                txUtxos.append(utxo)
                utxoMap.remove(outpoint)
                if utxoMap.isEmpty {
                    break
                }
            }
        }
        
        for _ in 0..<kMaxInputsPerTransaction {
            do {
                let tx = try createUnsignedTransaction(toAddress: toAddress, amountRaw: amountRaw, changeAddress: changeAddress, preselectedUtxos: txUtxos)
                return tx
            } catch {
                if utxos.count == txUtxos.count { throw error }
                if let newUtxo = utxos.first(where: { !selectedUtxos.contains($0) }) {
                    txUtxos.append(newUtxo)
                }
            }
        }
        return nil
    }
    
    @MainActor
    public func createUnsignedTransaction(toAddress: KaspaAddress, amountRaw: BigInt, changeAddress: KaspaAddress, preselectedUtxos: [KaspaUtxo]? = nil) throws -> KaspaTransaction {
        _selectedUtxos = preselectedUtxos != nil ? try _userSelectedUtxos(userSelectedUtxos: preselectedUtxos!, spendAmountRaw: amountRaw) : try _selectUtxos(spendAmount: amountRaw)
        
        let changeAmount = _getChangeAmountRaw(selectedUtxos: _selectedUtxos, spendAmount: amountRaw)
        
        let hasChange = changeAmount >= kMinChangeTarget || changeAmount >= amountRaw / BigInt(2)
        
        var payments: [KaspaAddress: Int64] = [toAddress: Int64(amountRaw)]
        if hasChange {
            payments[changeAddress] = Int64(changeAmount)
        }
        
        if hasChange {
            _change = changeAmount
            _changeAddress = changeAddress
            _baseFee = feePerInputRaw * BigInt(_selectedUtxos.count)
        } else {
            _change = .zero
            _changeAddress = nil
            _baseFee = feePerInputRaw * BigInt(_selectedUtxos.count) + changeAmount
        }
        
        return try _createUnsignedTransaction(utxos: _selectedUtxos, payments: payments)
    }
    
    private func _createUnsignedTransaction(utxos: [KaspaUtxo], payments: [KaspaAddress: Int64]) throws -> KaspaTransaction {
        let inputs = try utxos.map { utxo in
            return TxInput(
                address: try KaspaAddress.decodeAddress(address: utxo.address),
                previousOutpoint: utxo.outpoint,
                signatureScript: Data(count: 64 + 2),
                sequence: Int64(0),
                sigOpCount: 1,
                utxoEntry: utxo.utxoEntry.copyWith(blockDaaScore: BigInt(kUnacceptedDAASccore), isCoinbase: false)
            )
        }
        
        let outputs = payments.map { (address, value) in
            let scriptPublicKey = KaspaTxScript.payToAddressScript(address: address)
            return TxOutput(value: Int64(value), scriptPublicKey: scriptPublicKey)
        }
        
        return KaspaTransaction(
            version: kMaxTransactionVersion,
            inputs: inputs,
            outputs: outputs,
            lockTime: Int64(0),
            subnetworkId: kSubnetworkIdNative,
            gas: Int64(0),
            payload: nil
        )
    }
    
    private func _userSelectedUtxos(userSelectedUtxos: [KaspaUtxo], spendAmountRaw: BigInt) throws -> [KaspaUtxo] {
        let selectedUtxos = userSelectedUtxos
        let totalValue = selectedUtxos.reduce(BigInt.zero) { $0 + $1.utxoEntry.amount }
        
        let baseFeeRaw = feePerInputRaw * BigInt(selectedUtxos.count)
        let totalSpendRaw = spendAmountRaw + baseFeeRaw + priorityFee
        
        if totalValue < totalSpendRaw {
            throw KaspaError.message("Not enough funds")
        }
        
        return selectedUtxos
    }
    
    @MainActor
    private func _selectUtxos(spendAmount: BigInt) throws -> [KaspaUtxo] {
        var selectedUtxos: [KaspaUtxo] = []
        var totalValue = BigInt.zero
        
        for utxo in utxos {
            selectedUtxos.append(utxo)
            totalValue += utxo.utxoEntry.amount
            
            let baseFeeRaw = feePerInputRaw * BigInt(selectedUtxos.count)
            let totalSpend = spendAmount + baseFeeRaw + priorityFee
            
            if totalValue == totalSpend || (totalValue >= totalSpend + kMinChangeTarget && selectedUtxos.count > 1) {
                break
            }
        }
        
        let baseFeeRaw = feePerInputRaw * BigInt(selectedUtxos.count)
        let totalSpend = spendAmount + baseFeeRaw + priorityFee
        
        if totalValue < totalSpend {
            throw KaspaError.message("Not enough funds")
        }
        
        return selectedUtxos
    }
    
    
    public func _getChangeAmountRaw(selectedUtxos: [KaspaUtxo], spendAmount: BigInt) -> BigInt {
        var totalValue = BigInt(0)
        
        for utxo in selectedUtxos {
            totalValue += utxo.utxoEntry.amount
        }
        
        let baseFeeRaw = feePerInputRaw * BigInt(selectedUtxos.count)
        let fee = baseFeeRaw + priorityFee
        let totalSpend = spendAmount + fee
        
        return totalValue - totalSpend
    }
}

private struct UtxoKey: Hashable {
    let previousOutpointHash: String
    let previousOutpointIndex: Int
}
