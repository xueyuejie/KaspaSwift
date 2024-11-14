//
//  ApiTxInput.swift
//  KaspaSwift
//
//  Created by 薛跃杰 on 2024/11/14.
//

import Foundation
import BigInt

public struct ApiTxInput: Decodable {
    let transactionId: String
    let index: Int
    let previousOutpointHash: String
    let previousOutpointIndex: BigInt
    let signatureScript: String
    let sigOpCount: BigInt
    // 新字段
    let previousOutpointAddress: String?
    let previousOutpointAmount: Int?

    init(
        transactionId: String,
        index: Int,
        previousOutpointHash: String,
        previousOutpointIndex: BigInt,
        signatureScript: String,
        sigOpCount: BigInt,
        previousOutpointAddress: String? = nil,
        previousOutpointAmount: Int? = nil
    ) {
        self.transactionId = transactionId
        self.index = index
        self.previousOutpointHash = previousOutpointHash
        self.previousOutpointIndex = previousOutpointIndex
        self.signatureScript = signatureScript
        self.sigOpCount = sigOpCount
        self.previousOutpointAddress = previousOutpointAddress
        self.previousOutpointAmount = previousOutpointAmount
    }

//    static func fromJson(_ json: [String: Any]) -> ApiTxInput? {
//        guard let transactionId = json["transaction_id"] as? String,
//              let index = json["index"] as? Int,
//              let previousOutpointHash = json["previous_outpoint_hash"] as? String,
//              let previousOutpointIndexValue = json["previous_outpoint_index"] as? Int64,
//              let signatureScript = json["signature_script"] as? String,
//              let sigOpCountValue = json["sig_op_count"] as? Int64 else {
//            return nil
//        }
//        
//        let previousOutpointAddress = json["previous_outpoint_address"] as? String
//        let previousOutpointAmount = json["previous_outpoint_amount"] as? Int
//
//        return ApiTxInput(
//            transactionId: transactionId,
//            index: index,
//            previousOutpointHash: previousOutpointHash,
//            previousOutpointIndex: BigInt(previousOutpointIndexValue),
//            signatureScript: signatureScript,
//            sigOpCount: BigInt(sigOpCountValue),
//            previousOutpointAddress: previousOutpointAddress,
//            previousOutpointAmount: previousOutpointAmount
//        )
//    }
}
