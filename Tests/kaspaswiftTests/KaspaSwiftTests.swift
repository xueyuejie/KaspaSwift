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
        guard let (prefixStr, data) = CashAddrBech32.decode("kaspa:qpfe3ds9hpcvcerwagtut8mxqvjaexcudh4m7e6ldt06hcugsj5yu0dynflex") else {
            throw KaspaError.message("address decode error")
        }
        let aa = try KaspaAddressService(isTestnet: false).makeAddress(for: Data(hex: "0293cf3586cf565be84ff6eb6f36d283b448f561e66b9921cbab4cdd95dcde43b4"))
        debugPrint(aa)
        debugPrint("adddda")
 
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
        let client = try KaspaClient(url: "kaspa.maiziqianbao.net:80")
        do {
            let result = try await client.getBlockDagInfo()
            debugPrint(result)
        } catch let error as KaspaError{
            debugPrint(error.errorDescription ?? "")
        }
    }
}
