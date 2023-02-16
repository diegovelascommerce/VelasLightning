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
    
    // test menemonic that we will use
    let TestMnemonic: String = "arrive remember certain all consider apology celery melt uphold blame call blame"
    
    // this is the descriptor that should be generated
    let TestDescriptor: String = "wpkh(tprv8ZgxMBicQKsPe8KpaZGC5AXw4xwNarzvopzHcG1txk39s3DPxH44hFN15fQFFWEKXUrUUbCR2wSFRNHuHhdqwo987QdpaStrpS6Js1igQZk/84'/1'/0'/0/*)"
    
    // first address that should be generated
    let TestAddress = "tb1q7skyn4rvw0y4zdxtqaqusctnne0hhwkdl0zpu7"

    override func setUpWithError() throws {
        print(self.name)
        switch self.name {
        /// these test cases use the mainnet
        case "-[BitcoinTests testMainnetGenesis]",
            "-[BitcoinTests testGetTxMainnet]",
            "-[BitcoinTests testGetBlockHeaderMainnet]",
            "-[BitcoinTests testGetTxRawMainnet]",
            "-[BitcoinTests testGetTipHeightMainnet]",
            "-[BitcoinTests testGetTipHashMainnet]",
            "-[BitcoinTests testGetTxMerkleProofMainnet]":
            btc = try Bitcoin(network: Network.bitcoin)
        /// these test use the testnet
        case "-[BitcoinTests testInitializationWithMnemonic]":
            btc = try Bitcoin(mnemonic:self.TestMnemonic)
        /// default if no mnemonic or network were passed in
        default:
            btc = try Bitcoin()
        }
    }
    
    /// test is basic initialization without mnemonic works
    func testInitialization() throws {
        XCTAssertNotNil(btc)
        // default network is always testnet
        XCTAssertEqual(Network.testnet, btc.network)
        
        // it should come up with a random mnemonic
        XCTAssertNotEqual(self.TestMnemonic, btc.mnemonic)
    }
    
    // test with mnemonic
    func testInitializationWithMnemonic() throws {
        XCTAssertNotNil(btc)
        XCTAssertFalse(btc.mnemonic.isEmpty)
        XCTAssertTrue(btc.mnemonic == self.TestMnemonic)
        XCTAssertFalse(btc.descriptor.isEmpty)
        XCTAssertTrue(btc.descriptor == self.TestDescriptor)
        let address = try btc.getNewAddress()
        XCTAssertTrue(address == self.TestAddress)
    }
    
    // test address generation
    func testGetAddress() throws {
        let res = try btc.getNewAddress()
        print("address: \(res)")
        XCTAssertFalse(res.isEmpty)
    }
    
    // test the generation of mnemonic
    func testGetMnemonic(){
        print("mnemonic: \(btc.mnemonic)")
        XCTAssertFalse(btc.mnemonic.isEmpty)
    }
    
    // test if a descriptor is created
    func testDescriptor(){
        print("descriptor: \(btc.descriptor)")
        XCTAssertFalse(btc.descriptor.isEmpty)
    }
    
    // test if sync works
    func testSync(){
        XCTAssertNoThrow(try btc.sync())
    }
    
    // test if we can get the latest block height from blockchain
    func testGetHeight() throws {
        try btc.sync()
        let height = try btc.getBlockHeight()
        print("height: \(height)")
        XCTAssert(height > 0)
    }
    
    // test if we can get the latest block hash
    func testGetBlockHash() throws {
        try btc.sync()
        let hash = try btc.getBlockHash()
        print("hash: \(hash)")
        XCTAssertFalse(hash.isEmpty)
    }
    
    // test getting the genesis hash from mainnet block chain
    func testMainnetGenesis() throws {
        try btc.sync()
        XCTAssertTrue(try btc.getGenesisHash() == "000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f")
    }
    
    // test getting the genesis hash from testnet block chain
    func testTestnetGenesis() throws {
        try btc.sync()
        XCTAssertTrue(try btc.getGenesisHash() == "000000000933ea01ad0ee984209779baaec3ced90fa3f408719526f8d77f4943")
    }
    
    // test getting transaction data from testnet
    func testGetTxTestnet() {
        let res = btc.getTx(txId: "39df5d0cd00fbf21fb76fd07aa6b85579f8a224d6feb986c0ba0b2600736c80c")
        XCTAssertNotNil(res)
        XCTAssert(res!.confirmed)
        XCTAssert(res!.block_height == 2410971)
        XCTAssert(res!.block_hash == "00000000000000315aac0ec1519047edd43c27843bd44a6b0dcdf42cc24dd1db")
    }
    
    /// test raw transaction data from testnet
    func testGetTxRawTestnet() throws {
        
        //get test data
        let testBundle = Bundle(for: type(of: self))
        let fileURL = testBundle.url(forResource: "tx_raw_testnet", withExtension: "")
        let rawData: Data = try Data(contentsOf: fileURL!)
        
        let res = btc.getTxRaw(txId:"39df5d0cd00fbf21fb76fd07aa6b85579f8a224d6feb986c0ba0b2600736c80c")
        
        XCTAssert(res! == rawData)
    }
    
    /// get raw data for transaction in mainnet
    func testGetTxRawMainnet() throws {
        let testBundle = Bundle(for: type(of: self))
        let fileURL = testBundle.url(forResource: "tx_raw", withExtension: "")
        let rawData: Data = try Data(contentsOf: fileURL!)
        
        let res = btc.getTxRaw(txId:"00cbda881afea89d97c6cccda41057ad9db07b500f65e29d4de4b42513f1a491")
        
        XCTAssert(res! == rawData)
    }
    
    /// test getting blockheader from testnet
    func testGetBlockHeaderTestnet() {
        let res = btc.getBlockHeader(hash: "00000000000000315aac0ec1519047edd43c27843bd44a6b0dcdf42cc24dd1db")
        XCTAssertNotNil(res)
        XCTAssert(res! == "000080200258b3b0796682c70bbf2b2c8ba7fbf17176c2462b1688ccd57e0000000000005254efa5fbb7d94aa9c94c6544e8b1ca516fd5be61f593a1056d97cd28c1f80d1b6797638ac733190e83693f")
    }
    
    /// test getting blockheader from mainnet
    func testGetBlockHeaderMainnet() {
        let res = btc.getBlockHeader(hash: "0000000000000000000291f53fcc3577d34fb488e1656b75e916262d9f873cd0")
        XCTAssertNotNil(res)
        XCTAssert(res! == "0040be2fd0d44d9e21aa59c9980815e1e0f8a7c36245ec828da5010000000000000000001ae4056bbb6bc9fcca925020f619b923e4fd3a6dd2c4eebab2952bc826b425ecd9279663303808170c40cab0")
    }
    
    /// test getting transaction information from mainnet
    func testGetTxMainnet() {
        let res = btc.getTx(txId: "00cbda881afea89d97c6cccda41057ad9db07b500f65e29d4de4b42513f1a491")
        XCTAssertNotNil(res)
        XCTAssert(res!.confirmed)
        XCTAssert(res!.block_height == 766957)
        XCTAssert(res!.block_hash == "0000000000000000000291f53fcc3577d34fb488e1656b75e916262d9f873cd0")
    }
    
    // get merkle proof for transaction
    func testGetTxMerkleProofTestnet() {
        let res = btc.getTxMerkleProof(txId: "39df5d0cd00fbf21fb76fd07aa6b85579f8a224d6feb986c0ba0b2600736c80c")
        XCTAssertNotNil(res)
        XCTAssert(res!.block_height == 2410971)
        XCTAssert(res!.pos == 2)
        XCTAssert(res!.merkle.count == 2)
    }
    
    // get merkle proof for transaction
    func testGetTxMerkleProofMainnet() {
        let res = btc.getTxMerkleProof(txId: "00cbda881afea89d97c6cccda41057ad9db07b500f65e29d4de4b42513f1a491")
        XCTAssertNotNil(res)
        XCTAssert(res!.block_height == 766957)
        XCTAssert(res!.pos == 767)
        XCTAssert(res!.merkle.count == 12)
    }
    
    // test getting height of block chain for testnet
    func testGetTipHeightTestnet() throws {
        let res = btc.getTipHeight()
        XCTAssertNotNil(res)
        XCTAssert(res! > 0)
        print(res!)
    }
    
    // test get height of block chain mainnet
    func testGetTipHeightMainnet() throws {
        let res = btc.getTipHeight()
        XCTAssertNotNil(res)
        XCTAssert(res! > 0)
        print(res!)
    }
    
    /// test get tip hash testnet
    func testGetTipHashTestnet() throws {
        let res = btc.getTipHash()
        XCTAssertNotNil(res)
        XCTAssertFalse(res!.isEmpty)
        print(res!)
    }
    
    /// test get tip hash mainnet
    func testGetTipHashMainnet() throws {
        let res = btc.getTipHash()
        XCTAssertNotNil(res)
        XCTAssertFalse(res!.isEmpty)
        print(res!)
    }
    
}
