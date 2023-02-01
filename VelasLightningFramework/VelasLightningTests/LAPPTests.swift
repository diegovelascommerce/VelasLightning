//
//  LAPPTests.swift
//  VelasLightningTests
//
//  Created by Diego vila on 1/30/23.
//

import XCTest
@testable import VelasLightningFramework

class LAPPTests: XCTestCase {
    
    private var lapp:LAPP!

    override func setUpWithError() throws {
        self.lapp = LAPP(baseUrl: "https://192.168.0.10",
                         jwt: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ2ZWxhcyIsInN1YiI6IndvcmtpdCJ9.CnksMqUsywjH4W8JgPePodi10pO_xJMrPyq9c19tQmo");
    }

    func testHelloVelas() {
        let res = self.lapp.helloVelas()
        XCTAssertNotNil(res)
        XCTAssertEqual("Hello VelasLightning", res)
    }
    
    func testGetinfo() {
        let res = self.lapp.getinfo()
        XCTAssertNotNil(res)
        XCTAssertEqual(res?.alias, "ruahaman")
        XCTAssertEqual(res?.identity_pubkey, "029cba2eb9edf18352e90f1a5f71e367af80d6e3ab7a5aa6122309fcbcd4375735")
        XCTAssertEqual(res?.urls.localIP, "192.168.0.10")
        XCTAssertEqual(res?.urls.publicIP, "24.50.226.128")
    }

}
