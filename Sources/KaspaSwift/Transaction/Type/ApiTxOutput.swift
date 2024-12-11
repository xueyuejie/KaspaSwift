//
//  ApiTxOutput.swift
//  KaspaSwift
//
//  Created by xgblin on 2024/11/14.
//

import Foundation

public struct ApiTxOutput: Decodable {
    public let transactionId: String
    public let index: Int
    public let amount: Int
    public let scriptPublicKey: String
    public let scriptPublicKeyAddress: String
    public let scriptPublicKeyType: String
    
    public init(
        transactionId: String,
        index: Int,
        amount: Int,
        scriptPublicKey: String,
        scriptPublicKeyAddress: String,
        scriptPublicKeyType: String
    ) {
        self.transactionId = transactionId
        self.index = index
        self.amount = amount
        self.scriptPublicKey = scriptPublicKey
        self.scriptPublicKeyAddress = scriptPublicKeyAddress
        self.scriptPublicKeyType = scriptPublicKeyType
    }
    
//    static func fromJson(_ json: [String: Any]) -> ApiTxOutput? {
//        
//        guard let transactionId = json["transaction_id"] as? String,
//              let index = json["index"] as? Int,
//              let amount = json["amount"] as? Int,
//              let scriptPublicKey = json["script_public_key"] as? String,
//              let scriptPublicKeyAddress = json["script_public_key_address"] as? String,
//              let scriptPublicKeyType = json["script_public_key_type"] as? String else {
//            return nil
//        }
//        
//        return ApiTxOutput(
//            transactionId: transactionId,
//            index: index,
//            amount: amount,
//            scriptPublicKey: scriptPublicKey,
//            scriptPublicKeyAddress: scriptPublicKeyAddress,
//            scriptPublicKeyType: scriptPublicKeyType
//        )
//    }
}
