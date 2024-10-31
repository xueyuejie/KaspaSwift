
import XCTest
import BitcoinSwift
import BIP32Swift

@testable import KaspaSwift

final class KaspaSwiftTests: XCTestCase {
    func testAccountExample() throws {
        let key = BitcoinKey.fromMnemonics("")!
        let dk = try key.derive(path: "m/44'/111111'/0'")
        var hdVer = HDNode.HDversion()
        hdVer.privatePrefix = Data(hex: "0x038f2ef4")
        hdVer.publicPrefix = Data(hex: "0x038f332e")
        let xPub = dk.serializePublicKey(version: hdVer)
        let node = HDNode(xPub!)!
        let hdNode = node.derive(path: "0/0", derivePrivateKey: false)!
        let addressService = KaspaAddressService(isTestnet: false)
        let address = try addressService.makeAddress(for: hdNode.publicKey)
        debugPrint(address)
    }
}
