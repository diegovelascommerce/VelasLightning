//
//  VelasTests.swift
//  VelasLightningTests
//
//  Created by Diego vila on 10/26/22.
//

import XCTest
import VelasLightningFramework

class VelasTests: XCTestCase {
    
    private var velas:Velas!

    override func setUpWithError() throws {
        velas = try Velas()
    }


    func testVelas() throws {
        XCTAssertNotNil(velas)
    }
    
    func testSendAward() throws {
        velas.sendAward(sats: 200)
    }

    

}
