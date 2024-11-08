////
////  KaspaInput.swift
////  KaspaSwift
////
////  Created by 薛跃杰 on 2024/11/4.
////
//
//import Foundation
//
//public class KaspaInput {
//    public let address: String
//    public let prev_hash: Data
//    public let index: UInt32
//    public let value: UInt64
//    public let sequence: UInt32
//    public var signatureScript: Data
//    
//    public init(address:String,
//         prev_hash:Data,
//         index:UInt32,
//         value:UInt64,
//         signatureScript:Data,
//         sequence:UInt32 = 0xffffffff,
//         pub:String = "",
//         path:String = "") {
//        self.address = address
//        self.prev_hash = Data(prev_hash)
//        self.index = index
//        self.value = value
//        self.signatureScript = signatureScript
//        self.sequence = sequence
//    }
//    
//    func getInput() -> KaspaInput? {
//        if BitcoinPublicKeyAddress.isValidAddress(self.address) {
//            return BitcoinInput(
//                address:self.address,
//                prev_hash:Data(self.prev_hash.reversed()),
//                index:self.index,
//                value:self.value,
//                signatureScript:self.signatureScript,
//                sequence: self.sequence,
//                pub:self.pub,
//                path:self.path
//            )
//        } else if BitcoinScriptHashAddress.isValidAddress(self.address) {
//            return BitcoinSegwitInput(
//                address:self.address,
//                prev_hash:Data(self.prev_hash.reversed()),
//                index:self.index,
//                value:self.value,
//                signatureScript:self.signatureScript,
//                sequence: self.sequence,
//                pub:self.pub,
//                path:self.path
//            )
//        } else if BitcoinTaprootAddress.isValidAddress(self.address) {
//            return BitcoinTaprootInput(
//                address:self.address,
//                prev_hash:Data(self.prev_hash.reversed()),
//                index:self.index,
//                value:self.value,
//                signatureScript:self.signatureScript,
//                sequence: self.sequence,
//                pub:self.pub,
//                path:self.path
//            )
//        } else if BitcoinNativeSegwitAddress.isValidAddress(self.address) {
//            return BitcoinNativeSegwitInput(
//                address:self.address,
//                prev_hash:Data(self.prev_hash.reversed()),
//                index:self.index,
//                value:self.value,
//                signatureScript:self.signatureScript,
//                sequence: self.sequence,
//                pub:self.pub,
//                path:self.path
//            )
//        }else {
//            return nil
//        }
//    }
//    
//    func signedInput(transaction:BitcoinTransaction,inputIndex: Int,key:BitcoinKey) -> BitcoinInput?{
//        let sighash: Data = transaction.sighashHelper.createSignatureHash(of: transaction, for: self, inputIndex: inputIndex)
//        var signature: Data
//        do {
//            signature = try Crypto.sign(sighash, privateKey: key.privateKey!)
//        } catch {
//            return nil
//        }
//        signature.appendUInt8(SIGHASH_ALL)
//        // Create Signature Script
//        var unlockingScript: Script
//        do {
//            unlockingScript = try Script()
//                .appendData(signature)
//                .appendData(key.publicKey)
//        } catch {
//            return nil
//        }
//        self.signatureScript = unlockingScript.data
//        return self
//    }
//    
//    func serialized() -> Data {
//        var data = Data()
//        data.append(prev_hash)
//        data.appendUInt32(index)
//        data.appendVarInt(UInt64(signatureScript.count))
//        data.append(signatureScript)
//        data.appendUInt32(sequence)
//        return data
//    }
//}
