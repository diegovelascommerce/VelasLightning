//
//  EsploraTests.swift
//  VelasLightningTests
//
//  Created by Diego vila on 12/12/22.
//

import XCTest
import BitcoinDevKit
@testable import VelasLightningFramework

class EsploraTests: XCTestCase {
        

    func testGetTxStatusTestnet() throws {
        let res = Esplora.getTxStatus(txid:"39df5d0cd00fbf21fb76fd07aa6b85579f8a224d6feb986c0ba0b2600736c80c",
                                      network: Network.testnet)
        XCTAssertNotNil(res)
        XCTAssert(res!.confirmed)
        XCTAssert(res!.block_height == 2410971)
        XCTAssert(res!.block_hash == "00000000000000315aac0ec1519047edd43c27843bd44a6b0dcdf42cc24dd1db")
    }
    
    func testGetTxStatusMainnet() throws {
        let res = Esplora.getTxStatus(txid:"00cbda881afea89d97c6cccda41057ad9db07b500f65e29d4de4b42513f1a491",
                                      network: Network.bitcoin)
        XCTAssertNotNil(res)
        XCTAssert(res!.confirmed)
        XCTAssert(res!.block_height == 766957)
        XCTAssert(res!.block_hash == "0000000000000000000291f53fcc3577d34fb488e1656b75e916262d9f873cd0")
    }
    
    func testGetTxMerkleProofTestnet() throws {
        let res = Esplora.getTxMerkleProof(txid:"39df5d0cd00fbf21fb76fd07aa6b85579f8a224d6feb986c0ba0b2600736c80c",
                                      network: Network.testnet)
        XCTAssertNotNil(res)
        print(res!)
        XCTAssert(res!.block_height == 2410971)
        XCTAssert(res!.pos == 2)
    }
    
    func testGetTxMerkleProofMainnet() throws {
        let res = Esplora.getTxMerkleProof(txid:"00cbda881afea89d97c6cccda41057ad9db07b500f65e29d4de4b42513f1a491",
                                           network: Network.bitcoin)
        XCTAssertNotNil(res)
        print(res!)
        XCTAssert(res!.block_height == 766957)
        XCTAssert(res!.pos == 767)
    }

    

}
