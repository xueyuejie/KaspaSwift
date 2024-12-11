//
//  KaspaTransaction.swift
//  KaspaSwift
//
//  Created by xgblin on 2024/11/13.
//

import Foundation

public let kSubnetworkIdNativeHex  = "0000000000000000000000000000000000000000"
public let kSubnetworkIdCoinbaseHex = "0100000000000000000000000000000000000000"
public class KaspaTransaction {
    public let version: Int
    public var inputs: [TxInput]
    public var outputs: [TxOutput]
    public let lockTime: Int64
    public let subnetworkId: Data
    public let gas: Int64
    public let fee: UInt64
    public let payload: Data?

    public init(version: Int = 0,
                inputs: [TxInput] = [TxInput](),
                outputs: [TxOutput] = [TxOutput](),
                lockTime: Int64,
                subnetworkId: Data = Data(count: 20),
                gas: Int64 = 0,
                fee: UInt64 = 0,
                payload: Data? = nil) {
        self.version = version
        self.inputs = inputs
        self.outputs = outputs
        self.lockTime = lockTime
        self.subnetworkId = subnetworkId
        self.gas = gas
        self.fee = fee
        self.payload = payload
    }
    
    @MainActor
    public func sign(with keys:[KaspaKey]) throws {
        for (i,input) in inputs.enumerated() {
            let key = keys[i]
            guard let signedInput = input.signedInput(transaction: self, inputIndex: i, key: key) else {
                throw KaspaError.signError
            }
            self.inputs[i] = signedInput
        }
    }
    
    public func toRpc() -> Protowire_RpcTransaction {
        var rpctransaction = Protowire_RpcTransaction()
        rpctransaction.version = UInt32(version)
        rpctransaction.inputs = inputs.map { $0.toRpc() }
        rpctransaction.outputs = outputs.map { $0.toRpc() }
        rpctransaction.lockTime = UInt64(lockTime)
        rpctransaction.subnetworkID = subnetworkId.hexEncodedString()
        rpctransaction.gas = UInt64(gas)
        rpctransaction.payload = payload?.hexEncodedString() ?? ""
        return rpctransaction
    }
    
    public var isCoinbase: Bool {
        return subnetworkId.hexEncodedString() ==  kSubnetworkIdCoinbaseHex
    }
}

