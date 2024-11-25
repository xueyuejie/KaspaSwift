import XCTest
@testable import KaspaSwift

final class KaspaSwiftTests: XCTestCase {
    func testExample() throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
    }
    
    func testAccountExample() throws {
//        do {
//            let mkey = KaspaKey.fromMnemonics("")!
//            var hdVer = HDNode.HDversion()
//            hdVer.publicPrefix = pubKeyPrefix
//            hdVer.privatePrefix = privatePrefix
//            let mMasterPubKey = mkey.serializePublicKey(version: hdVer)
//            let account = try mkey.derive(path: "44'/111111'/0'")
////            let akey = try mroot.derive(path: "0'")
//            let kpub = account.serializePublicKeyString(version: hdVer)
//            // kpub 通过
//            
//            let node = try account.derive(path: "0").derive(path: "0")
//            
////            let hdnode = node?.derive(path: "0/0", derivePrivateKey: false)
//            let addressService = KaspaAddressService(isTestnet: false)
//            let address = try addressService.makeAddress(for: node.publicKey)
//            
//            debugPrint(address)
//            debugPrint(address)
//        } catch let error {
//            debugPrint(error)
//        }
    }
    
    func testGrpcExample() async throws {
        let client = KaspaClient(host: "kaspa.maiziqianbao.net", port: 80)
        //        try KaspaClient(url: "47.238.220.71:16110")
        let result =  try await client.getBalancesByAddresses(addresses: ["kaspa:qrmynkncs7lxe34knahjtusztek3sqwpsea8443rentqqle6vglfx8s55enju","kaspa:qzfu7dvxeat9h6z07m4k7dkjsw6y3atpue4ejgwt4dxdm9wumepmgz8qcectr"])
        debugPrint(result)
        debugPrint("1111111111")
    }
}
