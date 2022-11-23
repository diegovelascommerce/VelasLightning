//
//  BitcoinTests.swift
//  VelasLightningTests
//
//  Created by Diego vila on 10/25/22.
//

import XCTest
@testable import VelasLightningFramework

class BitcoinTests: XCTestCase {

    private var btc:Bitcoin!

    override func setUpWithError() throws {
        btc = try Bitcoin()
    }

    func testStartBitcoin() throws {
        XCTAssertNotNil(btc)
    }
    
//    func testGetAddress(){
//        print("address: \(btc.address)")
//        XCTAssertNotNil(btc.address)
//    }
    
//    func testGetMnemonic(){
//        print("mnemonic: \(btc.mnemonic)")
//        XCTAssertFalse(btc.mnemonic.isEmpty)
//    }
    
//    func testBip32RootKey(){
//        let res = btc.bip32RootKey.asString()
//        print("bip32RootKey: \(res)")
//        XCTAssertFalse(res.isEmpty)
//    }
//
//    func testPrivateKey(){
//        let res = btc.privateKey
//        print("privateKey: \(res)")
//        XCTAssertNotNil(res)
//    }
}
