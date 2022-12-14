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
    
    func testGetBlockHeaderTestnet() throws {
        let res = Esplora.getBlockHeader(hash: "00000000000000315aac0ec1519047edd43c27843bd44a6b0dcdf42cc24dd1db", network: Network.testnet)
        XCTAssertNotNil(res)
        print(res!)
        XCTAssert(res! == "000080200258b3b0796682c70bbf2b2c8ba7fbf17176c2462b1688ccd57e0000000000005254efa5fbb7d94aa9c94c6544e8b1ca516fd5be61f593a1056d97cd28c1f80d1b6797638ac733190e83693f")
    }
    
    func testGetBlockHeaderMainnet() throws {
        let res = Esplora.getBlockHeader(hash: "0000000000000000000291f53fcc3577d34fb488e1656b75e916262d9f873cd0", network: Network.bitcoin)
        XCTAssertNotNil(res)
        print(res!)
        XCTAssert(res! == "0040be2fd0d44d9e21aa59c9980815e1e0f8a7c36245ec828da5010000000000000000001ae4056bbb6bc9fcca925020f619b923e4fd3a6dd2c4eebab2952bc826b425ecd9279663303808170c40cab0")
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
    
    func testGetTxHexTestnet() throws {
        let res = Esplora.getTxHex(txid:"39df5d0cd00fbf21fb76fd07aa6b85579f8a224d6feb986c0ba0b2600736c80c",
                                      network: Network.testnet)
        XCTAssertNotNil(res)
        print(res!)
        XCTAssert(res! == "0200000000010191873233d9ea4b998a40252f5b989c573d02443608babf6163beeccbbd7d8e750100000000ffffffff02dd720000000000001600146f5936cef2d10ad50394d9ddcbd28c17c08aecb95ad2ec00000000001600142217798f457852eed27f3570bce89cbe8a7d3d3402483045022100a55756fff6ef7a2437116cce5ef8e4624a781fbd454373f1014d506ef47dfb27022007196d9726112b3e2c097b6e4d7f27db485d0535f2e4b6ee7320de83ebae25b9012102c8d59c1c162a885ce1b93a14b71c3135f364874ed11afc386c147246d54b79b300000000")
    }
    
    func testGetTxHexMainnet() throws {
        let res = Esplora.getTxHex(txid:"00cbda881afea89d97c6cccda41057ad9db07b500f65e29d4de4b42513f1a491",
                                   network: Network.bitcoin)
        XCTAssertNotNil(res)
        print(res!)
        XCTAssert(res! == "0200000000010380dd8668193972f1b9381cfeeeb510fec2c2fb67656c1b9bdbaeb82e841510f3040000000000000000a908940de1725728e03bec67a1539610a288966520455411a5a5731709d1cc630700000000000000003f0af18de595d4e35a4121b1eeed866a47db584af46aea32067b4d9b55c9cda54800000000000000000168f230010000000017a9149a74594b4b11957606341b4ac9f150909f7c18ce87024830450221008c67d872d49a0419b5f4e78b0dc8e697fb35e2d4bedd3c8880a98478d160c918022035b6c08f21517807f43afa3d0bfb0cffb03b73596d1b5e428b9deb63e784d0e0012102fe1e4a848fcf63d7a65750810ca400c89aa46b85320d65e854f5e5c615cc5ef10247304402202f29394624a68b8fc47835d354975898ef5e4cd3d9cb509dffa881f93cf96dea02204e905953fecfafda3dcbfb43b953a31e6e4cee9fab519b3f3be9fb079c75b847012103267580df2855d76b15911f0285bf7eb5792f932622207eefeb873301a226163a02473044022019526cf7af6f7770cb597a65fe03cb6ca1461df7fb61420373ba7d354248a12302206cf81593ca08ea4319b1354c7470cd479d18fc56895087959967d0fa4d3e58aa0121033c3d7df04e6d4d098572979f05298ab458711aca78c92050df1ff7bf938e1d9200000000")
    }
    
    func testGetTxRawTestnet() throws {
        let res = Esplora.getTxRaw(txid:"39df5d0cd00fbf21fb76fd07aa6b85579f8a224d6feb986c0ba0b2600736c80c",
                                      network: Network.testnet)
        
        let testBundle = Bundle(for: type(of: self))
        let fileURL = testBundle.url(forResource: "tx_raw_testnet", withExtension: "")
        XCTAssertNotNil(fileURL)

        let rawData: Data = try Data(contentsOf: fileURL!)
        
        XCTAssertNotNil(res)
        XCTAssert(res! == rawData)
    }
    
    func testGetTxRawMainnet() throws {
        let res = Esplora.getTxRaw(txid:"00cbda881afea89d97c6cccda41057ad9db07b500f65e29d4de4b42513f1a491",
                                   network: Network.bitcoin)
        
        let testBundle = Bundle(for: type(of: self))
        let fileURL = testBundle.url(forResource: "tx_raw", withExtension: "")
        XCTAssertNotNil(fileURL)

        let rawData: Data = try Data(contentsOf: fileURL!)
        
        XCTAssertNotNil(res)
        XCTAssert(res! == rawData)

    }
    
    func testGetTipHeightTestnet() throws {
        let res = Esplora.getTipHeight(network: Network.testnet)
        XCTAssertNotNil(res)
        XCTAssert(res! > 0)
        print(res!)
    }
    
    func testGetTipHeightMainnet() throws {
        let res = Esplora.getTipHeight(network: Network.bitcoin)
        XCTAssertNotNil(res)
        XCTAssert(res! > 0)
        print(res!)
    }
    
    func testGetTipHashTestnet() throws {
        let res = Esplora.getTipHash(network: Network.testnet)
        XCTAssertNotNil(res)
        XCTAssertFalse(res!.isEmpty)
        print(res!)
    }
    
    func testGetTipHashMainnet() throws {
        let res = Esplora.getTipHash(network: Network.bitcoin)
        XCTAssertNotNil(res)
        XCTAssertFalse(res!.isEmpty)
        print(res!)
    }
    
    


    

}
