//
//  BitcoinTests.swift
//  VelasLightningTests
//
//  Created by Diego vila on 10/25/22.
//

import XCTest
@testable import VelasLightningFramework

class BitcoinTests: XCTestCase {

    private var btc:Bitcoin!

    override func setUpWithError() throws {
        btc = try Bitcoin()
    }

    func testStartBitcoin() throws {
        XCTAssertNotNil(btc)
    }
    
    func testGetAddress(){
        print("address: \(btc.address)")
        XCTAssertNotNil(btc.address)
    }
}
