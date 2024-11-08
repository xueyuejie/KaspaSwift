
import XCTest
import BIP32Swift

@testable import KaspaSwift

final class KaspaSwiftTests: XCTestCase {
    func testAccountExample() throws {
        do {
            let mkey = KaspaKey.fromMnemonics("hat crime liquid unhappy exhaust journey tilt tape comfort humble ahead own")!
            var hdVer = HDNode.HDversion()
            hdVer.publicPrefix = Data([0x03, 0x8f, 0x33, 0x2e])
            hdVer.privatePrefix = Data([0x03, 0x8f, 0x2e, 0xf4])
            let mMasterPubKey = mkey.serializePublicKey(version: hdVer)
            let mroot = try mkey.derive(path: "44'/111111'")
            let akey = try mroot.derive(path: "0'")
            let kpub = akey.serializePublicKeyString(version: hdVer)
            // kpub 通过
            
            let node = HDNode(kpub!)
            let hdnode = node?.derive(path: "0/0", derivePrivateKey: false)
            let addressService = KaspaAddressService(isTestnet: false)
            let address = try addressService.makeAddress(for: hdnode!.publicKey)
            debugPrint(address)
            debugPrint(address)
        } catch let error {
            debugPrint(error)
        }
    }
    
    func testGrpcExample() async throws {
        let client = try KaspaClient(url: "47.238.220.71:16110")
        try await client.getBalancesByAddresses(addresses: ["kaspa:qrmynkncs7lxe34knahjtusztek3sqwpsea8443rentqqle6vglfx8s55enju","kaspa:qzfu7dvxeat9h6z07m4k7dkjsw6y3atpue4ejgwt4dxdm9wumepmgz8qcectr"]) { entries in
            debugPrint(entries.count)
            debugPrint("ddddddddddddd")
        }
    }
}
