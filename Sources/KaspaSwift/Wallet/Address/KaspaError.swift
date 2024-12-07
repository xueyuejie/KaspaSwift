//
//  KaspaError.swift
//  KaspaSwift
//
//  Created by 薛跃杰 on 2024/11/4.
//

import Foundation

public enum KaspaError: LocalizedError {
    case message(String)
    case invalidDerivePath
    case invaildPublicKey
    case signError
    public var errorDescription: String? {
        switch self {
        case .message(let message):
            return message
        case .invalidDerivePath:
            return "invalidDerivePath"
        case .invaildPublicKey:
            return "invaildPublicKey"
        case .signError:
            return "signError"
        }
    }
}

public enum KaspaClientError: LocalizedError {
    case invalidUrl
    public var errorDescription: String? {
        switch self {
        case .invalidUrl:
            return "invalidUrl"
        }
    }
}
