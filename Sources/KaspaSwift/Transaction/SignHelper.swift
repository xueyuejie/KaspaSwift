import Foundation
import BigInt
import CSecp256k1
import CryptoSwift

@MainActor
public struct SignHelper{
    public static var magic: (UInt8, UInt8, UInt8, UInt8) { (218, 111, 179, 140) }
    public static let context: OpaquePointer! = secp256k1_context_create(
        UInt32(SECP256K1_CONTEXT_SIGN|SECP256K1_CONTEXT_VERIFY)
    )
    
    public static func sign(data: Data, privateKey: Data) throws -> Data {
        var message = data.bytes

        let auxRandPointer = UnsafeMutableRawPointer.allocate(byteCount: 32, alignment: MemoryLayout<UInt8>.alignment)
        for i in 0..<32 {
            auxRandPointer.storeBytes(of: 0x00, toByteOffset: i, as: UInt8.self)
        }

        var keypair = secp256k1_keypair()
        var signature = [UInt8](repeating: 0, count: 64)
        var extraParams = secp256k1_schnorrsig_extraparams(magic: magic, noncefp: nil, ndata: auxRandPointer)

        guard secp256k1_keypair_create(context, &keypair, privateKey.bytes) == 1,
              secp256k1_schnorrsig_sign_custom(context, &signature, &message, message.count, &keypair, &extraParams) == 1
        else {
            throw KaspaError.signError
        }

        return Data(signature)
    }
}

