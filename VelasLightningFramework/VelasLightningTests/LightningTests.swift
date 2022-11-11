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

    override func setUpWithError() throws {
        ln = try Lightning()
    }

    func testStartLightning() throws {
        XCTAssertNotNil(ln)
    }
    
    func testGetNodeId() throws {
        let res = try ln.getNodeId()
        XCTAssertFalse(res.isEmpty)
        print("testGetNodeId: \(res)")
    }
    
    func testCreateInvoice() throws {
        let res = try ln.createInvoice(amtMsat: 200000, description: "testing createInvoice")
        XCTAssertFalse(res.isEmpty)
    }
    
    func testGetLocalIPAddress() {
        let res = getLocalIPAdress()
        XCTAssertNotNil(res)
        print("testGetLocalIPAddress: \(res!)")
    }
    
    func testGetPublicIPAddress() {
        let res = getPublicIPAddress()
        XCTAssertNotNil(res)
        print("LightningTests/testGetPublicIPAddress: \(res!)")
    }
    
    func testBindNode() throws {
       
        let res = try ln.bindNode()
        XCTAssertTrue(res)
           
    }
    
    func testBindNode_WithLocalIpAddress() throws {
        try XCTSkipIf(true)
        let address = getLocalIPAdress()
        let port = UInt16(9735)
        if let address = address {
            let res = try ln.bindNode(address, port)
            XCTAssertTrue(res)
        }
    }
    
    func testBindNode_WithPublicIpAddress() throws {
        try XCTSkipIf(true)
        let address = getPublicIPAddress()
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
            XCTAssertFalse(peers.isEmpty)
            XCTAssertTrue(peers.count > 5)
        }
        catch {
            XCTFail("this shouldn't happen")
        }
    }
    
    func testListChannels() throws {
        try XCTSkipIf(true)
        let res = try ln.listChannels()
        XCTAssertFalse(res.isEmpty)
        XCTAssertTrue(res.count > 5)
    }

}
