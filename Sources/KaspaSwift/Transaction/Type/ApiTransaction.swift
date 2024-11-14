//
//  ApiTransaction.swift
//  KaspaSwift
//
//  Created by 薛跃杰 on 2024/11/14.
//

import Foundation
import BigInt

public struct ApiTransaction: Decodable {
    let subnetworkId: String?
    let transactionId: String
    let blockHash: [String]
    let blockTime: Int
    let isAccepted: Bool
    let acceptingBlockHash: String?
    let acceptingBlockBlueScore: Int?
    let inputs: [ApiTxInput]
    let outputs: [ApiTxOutput]

    init(
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

    static func fromRpc(_ tx: Kaspa_RpcTransaction) -> ApiTransaction {
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
