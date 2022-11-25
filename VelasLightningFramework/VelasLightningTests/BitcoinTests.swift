//
//  BitcoinTests.swift
//  VelasLightningTests
//
//  Created by Diego vila on 10/25/22.
//

import XCTest
import BitcoinDevKit
@testable import VelasLightningFramework

class BitcoinTests: XCTestCase {

    private var btc:Bitcoin!
    
    let TestMnemonic: String = "arrive remember certain all consider apology celery melt uphold blame call blame"
    let TestDescriptor: String = "wpkh(tprv8ZgxMBicQKsPe8KpaZGC5AXw4xwNarzvopzHcG1txk39s3DPxH44hFN15fQFFWEKXUrUUbCR2wSFRNHuHhdqwo987QdpaStrpS6Js1igQZk/84'/1'/0'/0/*)"
    let TestAddress = "tb1q7skyn4rvw0y4zdxtqaqusctnne0hhwkdl0zpu7"

    override func setUpWithError() throws {
        print(self.name)
        switch self.name {
        case "-[BitcoinTests testMainnetGenesis]":
            btc = try Bitcoin(network: Network.bitcoin)
        case "-[BitcoinTests testInitializationWithMnemonic]":
            btc = try Bitcoin(mnemonic:self.TestMnemonic)
        default:
            btc = try Bitcoin()
        }
    }
    

    func testInitialization() throws {
        XCTAssertNotNil(btc)
    }
    
    func testInitializationWithMnemonic() throws {
        XCTAssertNotNil(btc)
        XCTAssertFalse(btc.mnemonic.isEmpty)
        XCTAssertTrue(btc.mnemonic == self.TestMnemonic)
        XCTAssertFalse(btc.descriptor.isEmpty)
        XCTAssertTrue(btc.descriptor == self.TestDescriptor)
        let address = try btc.getNewAddress()
        XCTAssertTrue(address == self.TestAddress)
    }
    
    func testGetAddress() throws {
        let res = try btc.getNewAddress()
        print("address: \(res)")
        XCTAssertFalse(res.isEmpty)
    }
    
    func testGetMnemonic(){
        print("mnemonic: \(btc.mnemonic)")
        XCTAssertFalse(btc.mnemonic.isEmpty)
    }
    
    func testDescriptor(){
        print("descriptor: \(btc.descriptor)")
        XCTAssertFalse(btc.descriptor.isEmpty)
    }
    
    func testSync(){
        XCTAssertNoThrow(try btc.sync())
    }
    
    func testGetHeight() throws {
        try btc.sync()
        let height = try btc.getHeight()
        print("height: \(height)")
        XCTAssert(height > 0)
    }
    
    func testGetBlockHash() throws {
        try btc.sync()
        let hash = try btc.getBlockHash()
        print("hash: \(hash)")
        XCTAssertFalse(hash.isEmpty)
    }
    
    func testMainnetGenesis() throws {
        XCTAssertTrue(btc.genesis == "000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f")
    }
    
    func testTestnetGenesis() throws {
        XCTAssertTrue(btc.genesis == "000000000933ea01ad0ee984209779baaec3ced90fa3f408719526f8d77f4943")
    }
    
}
