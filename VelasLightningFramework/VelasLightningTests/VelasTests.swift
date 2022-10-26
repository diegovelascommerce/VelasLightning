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


    func testVelas() throws {
        XCTAssertNotNil(velas)
    }
    
    func testRequestAward() throws {
        velas.requestAward(sats: 200) {(bolt11) in
            // here enter you code to submit the bolt11 string to the backend of your choosing
            XCTAssertEqual(bolt11, TEST_BOLT11)
        }
    }

    

}
