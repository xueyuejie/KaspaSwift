//
//  TransactionBuilder.swift
//  KaspaSwift
//
//  Created by xgblin on 2024/11/13.
//

import Foundation
import BigInt

public let feePerInputRaw = 10000
public let kMinChangeTarget = BigUInt(20000000)

public struct TransactionBuilder {
    public static func createTransaction(toAddress: KaspaAddress, amount: BigUInt, changeAddress: KaspaAddress, utxos: [KaspaUtxo], priorityFee: BigUInt) throws -> Transaction {
        guard let (selectUtxos, changeAmount, fee) = getChangeAmountAndFee(utxoArray: utxos, amount: amount, priorityFee: priorityFee) else {
            throw KaspaError.message("Insufficient balance")
        }
        let inputs = try selectUtxos.map { utxo in
            return TxInput(
                address: try KaspaAddress.decodeAddress(address: utxo.address, expectedPrefix: KaspaAddressPrefix.kaspa),
                previousOutpoint: utxo.outpoint,
                signatureScript: Data(count: 64 + 2),
                sequence: Int64(0),
                sigOpCount: 1,
                utxoEntry: utxo.utxoEntry.copyWith(blockDaaScore: BigInt(-1), isCoinbase: false)
            )
        }
        //        let changeAmount = getChangeAmountRaw(selectedUtxos: selectUtxos, spendAmount: amount, priorityFee: priorityFee)
        var outputs = [TxOutput]()
        let changePublicKey = KaspaTxScript.payToAddressScript(address: changeAddress)
        let toPublicKey = KaspaTxScript.payToAddressScript(address: toAddress)
        outputs.append(TxOutput(value: Int64(changeAmount), scriptPublicKey: changePublicKey))
        outputs.append(TxOutput(value: Int64(amount), scriptPublicKey: toPublicKey))
        return Transaction(
            version: 0,
            inputs: inputs,
            outputs: outputs,
            lockTime: Int64(0),
            subnetworkId: Data(count: 20),
            gas: Int64(0),
            fee: UInt64(fee.description) ?? UInt64(0),
            payload: nil
        )
    }
    
    public static func getChangeAmountAndFee(utxoArray: [KaspaUtxo], amount: BigUInt, priorityFee: BigUInt) -> (selectUtxos: [KaspaUtxo], changeAmount: BigUInt, fee: BigUInt)? {
        let sortedUtxos = utxoArray.sorted {
            $0.utxoEntry.amount > $1.utxoEntry.amount
        }
        var selectUtxos = [KaspaUtxo]()
        var totalAmount = BigUInt(0)
        var needAmount = amount
        var fee = BigUInt(0)
        for i in 0..<sortedUtxos.count {
            let utxo = sortedUtxos[i]
            selectUtxos.append(utxo)
            totalAmount += BigUInt(utxo.utxoEntry.amount)
            let feeValue = getFee(selectedUtxos: selectUtxos, priorityFee: priorityFee)
            needAmount = amount + feeValue
            fee = feeValue
            if totalAmount == needAmount ||  (totalAmount >= needAmount + kMinChangeTarget && selectUtxos.count > 1) {
                break
            }
        }
        if needAmount > totalAmount {
            return nil
        }
        return (selectUtxos, totalAmount - needAmount, fee)
    }
    
//    public static func getChangeAmountRaw(selectedUtxos: [KaspaUtxo], spendAmount: BigUInt, priorityFee: BigUInt) -> BigUInt {
//        let (totalValue, fee) = getFee(selectedUtxos: selectedUtxos, spendAmount: spendAmount, priorityFee: priorityFee)
//        let totalSpend = spendAmount + fee
//        return totalValue - totalSpend
//    }
    
    public static func getFee(selectedUtxos: [KaspaUtxo], priorityFee: BigUInt) -> BigUInt {
        let baseFeeRaw = feePerInputRaw * selectedUtxos.count
        let fee = BigUInt(baseFeeRaw) + priorityFee
        return fee
    }
}
