//
//  RequestTests.swift
//  VelasLightningTests
//
//  Created by Diego vila on 12/8/22.
//

import XCTest
@testable import VelasLightningFramework


class RequestTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGet() {
        let data = Request.get(url: "https://blockstream.info/testnet/api/blocks/tip/hash")
        XCTAssertNotNil(data)
        let str = String(decoding: data!, as: UTF8.self)
        XCTAssertFalse(str.isEmpty)
        print(str)
    }
    
    func testGetAsync() {
        Task {
            let data = try await Request.getAsync(url: "https://blockstream.info/testnet/api/blocks/tip/hash")
            XCTAssertNotNil(data)
            let str = String(decoding: data!, as: UTF8.self)
            XCTAssertFalse(str.isEmpty)
            print(str)
        }
    }

}
