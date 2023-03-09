//
//  CryptographyTests.swift
//  VelasLightningTests
//
//  Created by Diego vila on 3/9/23.
//

import XCTest
@testable import VelasLightningFramework

final class CryptographyTests: XCTestCase {

    func testEncryption() throws {
        if let (encryptedData, key) = Cryptography.encrypt(message: "hello crypto world") {
            print(key)
            let res = Cryptography.decrypt(encryptedData: encryptedData, key: key)
            XCTAssertEqual(res, "hello crypto world")
        }
    }
    
}
