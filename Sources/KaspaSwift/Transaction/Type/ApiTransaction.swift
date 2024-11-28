//
//  ApiTransaction.swift
//  KaspaSwift
//
//  Created by xgblin on 2024/11/14.
//

import Foundation
import BigInt

public struct ApiTransaction: Decodable {
    public let subnetworkId: String?
    public let transactionId: String
    public let blockHash: [String]
    public let blockTime: Int
    public let isAccepted: Bool
    public let acceptingBlockHash: String?
    public let acceptingBlockBlueScore: Int?
    public let inputs: [ApiTxInput]
    public let outputs: [ApiTxOutput]

    public init(
        subnetworkId: String? = nil,
        transactionId: String,
        blockHash: [String] = [],
        blockTime: Int,
        isAccepted: Bool,
        acceptingBlockHash: String? = nil,
        acceptingBlockBlueScore: Int? = nil,
        inputs: [ApiTxInput] = [],
        outputs: [ApiTxOutput] = []
    ) {
        self.subnetworkId = subnetworkId
        self.transactionId = transactionId
        self.blockHash = blockHash
        self.blockTime = blockTime
        self.isAccepted = isAccepted
        self.acceptingBlockHash = acceptingBlockHash
        self.acceptingBlockBlueScore = acceptingBlockBlueScore
        self.inputs = inputs
        self.outputs = outputs
    }
//
//    static func fromJson(_ json: [String: Any]) -> ApiTransaction? {
//        // Implement JSON parsing logic
//    }

    public static func fromRpc(_ tx: Protowire_RpcTransaction) -> ApiTransaction {
        return ApiTransaction(
            transactionId: tx.verboseData.transactionID,
            blockTime: Int(tx.verboseData.blockTime),
            isAccepted: false,
            inputs: tx.inputs.enumerated().map { index, e in
                return ApiTxInput(
                    transactionId: tx.verboseData.transactionID,
                    index: index,
                    previousOutpointHash: e.previousOutpoint.transactionID,
                    previousOutpointIndex: BigInt(e.previousOutpoint.index),
                    signatureScript: e.signatureScript,
                    sigOpCount: BigInt(e.sigOpCount)
                )
            },
            outputs: tx.outputs.enumerated().map { index, e in
                return ApiTxOutput(
                    transactionId: tx.verboseData.transactionID,
                    index: index,
                    amount: Int(e.amount),
                    scriptPublicKey: e.scriptPublicKey.scriptPublicKey,
                    scriptPublicKeyAddress: e.verboseData.scriptPublicKeyAddress,
                    scriptPublicKeyType: e.verboseData.scriptPublicKeyType
                )
            }
        )
    }
}
