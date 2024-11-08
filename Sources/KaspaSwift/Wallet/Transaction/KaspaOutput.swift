//
//  KaspaOutput.swift
//
//
//  Created by xgblin on 2021/12/27.
//

import Foundation

public struct KaspaOutput {
    let value: UInt64
    let script: Data
    
    public init?(value: UInt64, address: String) {
        guard let scriptData = try? KaspaAddress.decodeAddress(address: address).payload else {
            return nil
        }
        self.value = value
        self.script = scriptData
    }
    
    public init?(value: UInt64, opReturn: Data) {
        var scriptData = Data()
        scriptData.appendData(Data(hex: "6a")!)
        scriptData.appendVarInt(UInt64(opReturn.count))
        scriptData.appendData(opReturn)
        
        self.value = value
        self.script = scriptData
    }
    
    public init?(value: UInt64, script: Data) {
        self.value = value
        self.script = script
    }
    
    public func serialized() -> Data {
        var data = Data()
        data.appendUInt64(value)
        data.appendVarInt(UInt64(script.count))
        data.append(script)
        return data
    }
}
