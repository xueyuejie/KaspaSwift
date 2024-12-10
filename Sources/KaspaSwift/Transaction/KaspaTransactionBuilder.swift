//
//  KaspaTransactionBuilder.swift
//  KaspaSwift
//
//  Created by xgblin on 2024/11/13.
//

import Foundation
import BigInt

public let feePerInputRaw = 10000

public struct KaspaTransactionBuilder {
    public static func createTransaction(toAddress: KaspaAddress, amount: BigUInt, changeAddress: KaspaAddress, selectUtxos: [KaspaUtxo], priorityFee: BigUInt) throws -> KaspaTransaction {
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
        var outputs = [TxOutput]()
        let changeAmount = getChangeAmountRaw(selectedUtxos: selectUtxos, spendAmount: amount, priorityFee: priorityFee)
        let changePublicKey = KaspaTxScript.payToAddressScript(address: changeAddress)
        let toPublicKey = KaspaTxScript.payToAddressScript(address: toAddress)
        outputs.append(TxOutput(value: Int64(changeAmount), scriptPublicKey: changePublicKey))
        outputs.append(TxOutput(value: Int64(amount), scriptPublicKey: toPublicKey))
        return KaspaTransaction(
            version: 0,
            inputs: inputs,
            outputs: outputs,
            lockTime: Int64(0),
            subnetworkId: Data(count: 20),
            gas: Int64(0),
            payload: nil
        )
    }
    
    public static func getChangeAmountRaw(selectedUtxos: [KaspaUtxo], spendAmount: BigUInt, priorityFee: BigUInt) -> BigUInt {
        let (totalValue, fee) = getFee(selectedUtxos: selectedUtxos, spendAmount: spendAmount, priorityFee: priorityFee)
        let totalSpend = spendAmount + fee
        return totalValue - totalSpend
    }
    
    public static func getFee(selectedUtxos: [KaspaUtxo], spendAmount: BigUInt, priorityFee: BigUInt) -> (totalValue: BigUInt, fee: BigUInt) {
        var totalValue = BigUInt(0)
        for utxo in selectedUtxos {
            totalValue += BigUInt(utxo.utxoEntry.amount)
        }
        let baseFeeRaw = feePerInputRaw * selectedUtxos.count
        let fee = BigUInt(baseFeeRaw) + priorityFee
        return (totalValue: totalValue, fee: fee)
    }
}
