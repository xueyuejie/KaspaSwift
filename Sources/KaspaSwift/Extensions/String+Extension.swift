//
//  File.swift
//  KaspaSwift
//
//  Created by xgblin on 2024/11/7.
//

import Foundation

extension String {
    func isGRPC() -> Bool {
        let regex = try? NSRegularExpression(pattern: "^([A-Za-z0-9]{1,}\\.)+[A-Za-z0-9]{1,}(:\\d*)?$", options: .caseInsensitive)
        if let result = regex?.matches(in: self, options: [], range: NSRange(location: 0, length: self.count)), result.count > 0 {
            return true
        }
        return false
    }
}
