//
//  File.swift
//  KaspaSwift
//
//  Created by xgblin on 2024/11/14.
//

import Foundation

public enum SigHashType {
    case sigHashAll
    case sigHashNone
    case sigHashSingle
    case sigHashAnyOneCanPay

    public var rawValue: Int {
        switch self {
        case .sigHashAll:
            return 1
        case .sigHashNone:
            return 1 << 1
        case .sigHashSingle:
            return 1 << 2
        case .sigHashAnyOneCanPay:
            return 1 << 7
        }
    }
}
