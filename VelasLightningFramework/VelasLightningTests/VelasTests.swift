//
//  VelasTests.swift
//  VelasLightningTests
//
//  Created by Diego vila on 10/26/22.
//

import XCTest
import VelasLightningFramework

let TEST_BOLT11 = "lntb10u1p34nzegpp5740edx88s2dq605hrmadncqjutwgp2qmp0tue3lx3x7v4csmex0sdqqcqzpgxq9zm3kqsp59fr9mzs0yaaccvgx9vq74j2pljyk98arcnj7zl6rq0evmhz96c9s9qyyssq98leckfmjeunhweuulf3mc3cgqy2c8962w4gy2x2qzanfv93gxn38f4fancp9jmkmlp306l7rk6vhgcptxatsx9t5heletnag5avq3gq7lm5p4"

class VelasTests: XCTestCase {
    
    private var velas:Velas!
    
    let TestMnemonic: String = "arrive remember certain all consider apology celery melt uphold blame call blame"

    override func setUpWithError() throws {
        print(self.name)
        switch self.name {
        case "-[VelasTests testInitializationWithMnemonic]":
            velas = try Velas(mnemonic: self.TestMnemonic)
        default:
            velas = try Velas()
        }
    }


    /// test to see if velas initialized
    func testVelas() throws {
        XCTAssertNotNil(velas)
    }
    
    func testInitializationWithMnemonic() throws {
        XCTAssertNotNil(velas)
        let mnemonic = velas.getMnemonic()
        XCTAssertFalse(mnemonic.isEmpty)
        XCTAssertTrue(mnemonic == self.TestMnemonic)
    }
    
    
    /// test to see if it returns a bolt11
    func testCreateInvoice() throws {
        let res = try velas.createInvoice(amtMsat: 200000, description: "testing creating invoice from velas")
        XCTAssertFalse(res.isEmpty)
    }
    
    func testRequestChannel() throws {
        try XCTSkipIf(true)
//        try velas.requestOpeningChannel() {(nodeID,address,port) in
//            XCTAssertFalse(nodeID.isEmpty)
//            XCTAssertFalse(address.isEmpty)
//            XCTAssertFalse(port.isEmpty)
//        }
    }
    
    func testGetNodeId() throws {
        let res = try velas.getNodeId()
        XCTAssertFalse(res.isEmpty)
        print("testGetNodeId: \(res)")
    }
    
    func testBindNode() throws {
        try XCTSkipIf(true)
        let res = try velas.bindNode()
        XCTAssertTrue(res)
    }
    
    func testGetIPAddresses() {
        let (local,pub) = velas.getIPAddresses()
        XCTAssertNotNil(local)
        XCTAssertNotNil(pub)
    }
    
    func testPayInvoice() throws {
        try XCTSkipIf(true)
        let res = try velas.payInvoice(bolt11: TEST_BOLT11, amtMsat: 20000)
        XCTAssertTrue(res)
    }
    
    func testListChannels() throws -> String {
        try XCTSkipIf(true)
        let res = try velas.listChannels()
        return res
    }
    
    func testGetMnemonic() {
        let mnemonic = velas.getMnemonic()
        XCTAssertFalse(mnemonic.isEmpty)
        print("mnemonic: \(mnemonic)")
    }

    

}
