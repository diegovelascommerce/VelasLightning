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

}
