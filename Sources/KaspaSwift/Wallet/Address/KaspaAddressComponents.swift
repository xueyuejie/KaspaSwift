//
//  KaspaAddressComponents.swift
//  KaspaSwift
//
//  Created by xgblin on 2024/10/28.
//

import Foundation
public struct KaspaAddressComponents {
    public let prefix: String
    public let type: KaspaAddressType
    public let hash: Data
}

extension KaspaAddressComponents {
    public enum KaspaAddressType: UInt8 {
        case P2PK_Schnorr = 0
        case P2PK_ECDSA = 1
        case P2SH = 8
    }
}
