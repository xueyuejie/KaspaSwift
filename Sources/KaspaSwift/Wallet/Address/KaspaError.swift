//
//  KaspaError.swift
//  KaspaSwift
//
//  Created by 薛跃杰 on 2024/11/4.
//

import Foundation

public enum KaspaError: LocalizedError {
    case message(String)
    public var errorDescription: String? {
        switch self {
        case .message(let message):
            return message
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

public enum SchnorrError: Error {
    case liftXError
    case privateKeyTweakError
    case keyTweakError
    case signError
}
