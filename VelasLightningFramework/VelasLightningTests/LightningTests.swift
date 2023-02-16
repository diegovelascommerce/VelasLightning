//
//  LightningTests.swift
//  VelasLightningTests
//
//  Created by Diego vila on 10/25/22.
//

import XCTest
@testable import VelasLightningFramework

class LightningTests: XCTestCase {

    private var ln:Lightning!
    
    // test mnemonic we will use for creating private keys for signing
    let TestMnemonic: String = "arrive remember certain all consider apology celery melt uphold blame call blame"
    
    // nodeid we will try to connect with
    let TestNodeId: String = "03aff3289b9e0ad31ef511bee1e37cfcf4324ab67a4a5646d6b1cc12ad58f5517b"

    override func setUpWithError() throws {
        var btc:Bitcoin
        
        print(self.name)
        switch self.name {
        case "-[LightningTests testGetConsistenteNodeId]":
            btc = try Bitcoin(mnemonic:self.TestMnemonic)
        default:
            btc = try Bitcoin()
        }
        
        try FileMgr.removeAll()
        try btc.sync()
        ln = try Lightning(btc: btc)
    }

    /// test to see if light creates and object
    func testStartLightning() throws {
        XCTAssertNotNil(ln)
    }
    
    /// test get nodeId
    func testGetNodeId() throws {
        try FileMgr.removeAll()
        let res = try ln.getNodeId()
        XCTAssertFalse(res.isEmpty)
        print("testGetNodeId: \(res)")
    }
    
    /// test if we can get a consitent nodeId
    func testGetConsistenteNodeId() throws {
        let nodeId = try ln.getNodeId()
        XCTAssertFalse(nodeId.isEmpty)
        XCTAssertEqual(nodeId, self.TestNodeId)
        print("testGetConsistenteNodeId: \(nodeId)")
    }
    
    /// test creation of invoice
    func testCreateInvoice() throws {
        let res = try ln.createInvoice(amtMsat: 200000, description: "testing createInvoice")
        XCTAssertFalse(res.isEmpty)
    }
    
    /// test get the local IP address
    func testGetLocalIPAddress() {
        let res = Utils.getLocalIPAdress()
        XCTAssertNotNil(res)
        print("testGetLocalIPAddress: \(res!)")
    }
    
    /// test get the public IP address
    func testGetPublicIPAddress() {
        let res = Utils.getPublicIPAddress()
        XCTAssertNotNil(res)
        print("LightningTests/testGetPublicIPAddress: \(res!)")
    }
    
    func testBindNode() throws {
        let res = try ln.bindNode()
        XCTAssertTrue(res)
    }
    
    func testBindNode_WithLocalIpAddress() throws {
        try XCTSkipIf(true)
        let address = Utils.getLocalIPAdress()
        let port = UInt16(9735)
        if let address = address {
            let res = try ln.bindNode(address, port)
            XCTAssertTrue(res)
        }
    }
    
    func testBindNode_WithPublicIpAddress() throws {
        try XCTSkipIf(true)
        let address = Utils.getPublicIPAddress()
        let port = UInt16(9735)
        if let address = address {
            XCTAssertThrowsError(try ln.bindNode(address,port)) { error in
                XCTAssertEqual(error as NSError, NSError(domain: "bindNode", code: 1, userInfo: nil))
            }
        }
    }
    
    
    func testBindNode_WithHostIPAddress() throws {
        try XCTSkipIf(true)
        let address = "0.0.0.0"
        let port = UInt16(9735)
        
        do {
            let res = try ln.bindNode(address, port)
            XCTAssertTrue(res)
        }
        catch {
            XCTFail("this shouldn't happen")
        }
    }
    
    /// test connecting with velastestnet
    func testConnect() throws {
        let nodeId = "03e347d089c071c27680e26299223e80a740cf3e3fc4b4237fa219bb67121a670b"
        let address = "45.33.22.210"
        let port = NSNumber(9735)
        
        do {
            let res = try ln.connect(nodeId: nodeId, address: address, port: port)
            XCTAssertTrue(res)
        }
        catch {
            XCTFail("this shouldn't happen")
        }
    }
    
    func testListPeers() throws {
        let nodeId = "03e347d089c071c27680e26299223e80a740cf3e3fc4b4237fa219bb67121a670b"
        let address = "45.33.22.210"
        let port = NSNumber(9735)
        
        do {
            let res = try ln.connect(nodeId: nodeId, address: address, port: port)
            XCTAssertTrue(res)
            
            // give it time to handshake
            Thread.sleep(forTimeInterval: 1)
            
            let peers = try ln.listPeers()
            print("peers: \(peers)")
            XCTAssertFalse(peers.isEmpty)
            XCTAssertTrue(peers.count == 1)
        }
        catch {
            XCTFail("this shouldn't happen")
        }
    }
    
    func testListChannels() throws {
        let res = try ln.listChannels()
        XCTAssertFalse(res.isEmpty)
        print("channels: \(res)")
    }
    
    func testCloseChannelsCooperatively() throws {
        XCTAssertNoThrow(try ln.closeChannelsCooperatively())
    }
    
    func testCloseChannelsForcefully() throws {
        XCTAssertNoThrow(try ln.closeChannelsForcefully())
    }

}
