//
//  ScriptBuilder.swift
//  KaspaSwift
//
//  Created by 薛跃杰 on 2024/12/16.
//

import Foundation

public enum ScriptBuilderError: Error {
    case opCodeRejected(UInt8)
    case opCodesRejected(Int)
    case dataRejected(Int)
    case elementExceedsMaxSize(Int)
    case integerRejected(Int64)
}

public class ScriptBuilder {
    private var script: [UInt8]
    private static let defaultScriptAlloc = 512
    private static let maxScriptsSize = 10000 // 假设的值
    private static let maxScriptElementSize = 520 // 假设的值

    init() {
        self.script = [UInt8]()
        self.script.reserveCapacity(ScriptBuilder.defaultScriptAlloc)
    }

    func scriptData() -> [UInt8] {
        return script
    }

    func drain() -> [UInt8] {
        let drainedScript = script
        script = []
        return drainedScript
    }

    func addOp(_ opcode: OpcCode) throws -> ScriptBuilder {
        guard script.count < ScriptBuilder.maxScriptsSize else {
            throw ScriptBuilderError.opCodeRejected(opcode.rawValue)
        }
        script.append(opcode.rawValue)
        return self
    }

    func addOps(_ opcodes: [OpcCode]) throws -> ScriptBuilder {
        guard script.count + opcodes.count <= ScriptBuilder.maxScriptsSize else {
            throw ScriptBuilderError.opCodesRejected(opcodes.count)
        }
        let opcodeArray = opcodes.map { $0.rawValue }
        script.append(contentsOf: opcodeArray)
        return self
    }

    static func canonicalDataSize(_ data: [UInt8]) -> Int {
        let dataLen = data.count
        if dataLen == 0 || (dataLen == 1 && (data[0] <= 16 || data[0] == 0x81)) {
            return 1
        }
        if dataLen <= 75 {
            return dataLen + 1
        } else if dataLen <= 255 {
            return dataLen + 2
        } else if dataLen <= 65535 {
            return dataLen + 3
        } else {
            return dataLen + 5
        }
    }

    private func addRawData(_ data: [UInt8]) -> ScriptBuilder {
        let dataLen = data.count
        if dataLen == 0 || (dataLen == 1 && data[0] == 0) {
            script.append(0x00)
        } else if dataLen == 1 && data[0] <= 16 {
            script.append(0x50 + data[0])
        } else if dataLen == 1 && data[0] == 0x81 {
            script.append(0x4f)
        } else if dataLen <= 75 {
            script.append(UInt8(dataLen))
        } else if dataLen <= 255 {
            script.append(0x4c)
            script.append(UInt8(dataLen))
        } else if dataLen <= 65535 {
            script.append(0x4d)
            script.append(contentsOf: withUnsafeBytes(of: UInt16(dataLen).littleEndian, Array.init))
        } else {
            script.append(0x4e)
            script.append(contentsOf: withUnsafeBytes(of: UInt32(dataLen).littleEndian, Array.init))
        }
        script.append(contentsOf: data)
        return self
    }

    func addData(_ data: [UInt8]) throws -> ScriptBuilder {
        let dataSize = ScriptBuilder.canonicalDataSize(data)
        guard script.count + dataSize <= ScriptBuilder.maxScriptsSize else {
            throw ScriptBuilderError.dataRejected(dataSize)
        }
        guard data.count <= ScriptBuilder.maxScriptElementSize else {
            throw ScriptBuilderError.elementExceedsMaxSize(data.count)
        }
        return addRawData(data)
    }

    func addI64(_ val: Int64) throws -> ScriptBuilder {
        guard script.count + 1 <= ScriptBuilder.maxScriptsSize else {
            throw ScriptBuilderError.integerRejected(val)
        }
        if val == 0 {
            script.append(0x00)
        } else if val == -1 || (1...16).contains(val) {
            script.append(UInt8(0x50 + val))
        } else {
            let bytes = withUnsafeBytes(of: val.littleEndian, Array.init)
            let _ = try addData(bytes)
        }
        return self
    }

    func addLockTime(_ lockTime: UInt64) throws -> ScriptBuilder {
        return try addU64(lockTime)
    }

    func addSequence(_ sequence: UInt64) throws -> ScriptBuilder {
        return try addU64(sequence)
    }

    private func addU64(_ val: UInt64) throws -> ScriptBuilder {
        let buffer = withUnsafeBytes(of: val.littleEndian, Array.init)
        let trimmed = buffer.drop { $0 == 0 }
        return try addData(Array(trimmed))
    }
}
