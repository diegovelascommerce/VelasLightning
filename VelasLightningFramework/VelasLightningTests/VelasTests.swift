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

    override func setUpWithError() throws {
        velas = try Velas()
    }


    /// test to see if velas initialized
    func testVelas() throws {
        XCTAssertNotNil(velas)
    }
    
    
    /// test to see if it returns a bolt11
    func testCreateInvoice() throws {
        let res = try velas.createInvoice(amtMsat: 200000, description: "testing creating invoice from velas")
        XCTAssertFalse(res.isEmpty)
    }
    
    func testRequestChannel() throws {
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
