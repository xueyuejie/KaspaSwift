//
//  KaspaTransaction.swift
//  KaspaSwift
//
//  Created by 薛跃杰 on 2024/11/13.
//

import Foundation

public struct KaspaTransaction {
    public let version: Int
    public let inputs: [TxInput]
    public let outputs: [TxOutput]
    public let lockTime: Int64
    public let subnetworkId: Data
    public let gas: Int64
    public let payload: Data?
    public let fee: Int64?
    public let mass: Int64?
    public let id: Data?

    public init(version: Int, inputs: [TxInput], outputs: [TxOutput], lockTime: Int64, subnetworkId: Data, gas: Int64, payload: Data? = nil, fee: Int64? = nil, mass: Int64? = nil, id: Data? = nil) {
        self.version = version
        self.inputs = inputs
        self.outputs = outputs
        self.lockTime = lockTime
        self.subnetworkId = subnetworkId
        self.gas = gas
        self.payload = payload
        self.fee = fee
        self.mass = mass
        self.id = id
    }

    public func toRpc() -> Kaspa_RpcTransaction {
        var rpctransaction = Kaspa_RpcTransaction()
        rpctransaction.version = UInt32(version)
        rpctransaction.inputs = inputs.map { $0.toRpc() }
        rpctransaction.outputs = outputs.map { $0.toRpc() }
        rpctransaction.lockTime = UInt64(lockTime)
        rpctransaction.subnetworkID = subnetworkId.hexEncodedString()
        rpctransaction.gas = UInt64(gas)
        rpctransaction.payload = payload?.hexEncodedString() ?? ""
        return rpctransaction
    }
    
    @MainActor
    public var isCoinbase: Bool {
        return subnetworkId.hexEncodedString() ==  kSubnetworkIdCoinbaseHex
    }
}

