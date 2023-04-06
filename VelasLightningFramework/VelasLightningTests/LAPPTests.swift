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
        
        print(self.name)
        switch self.name {
        case "-[VelasLightningTests.LAPPTests testLogin]":
            self.lapp = LAPP(baseUrl: "http://65.109.88.41/WORKIT_BE_DEV/public/api");
        default:
            self.lapp = LAPP(baseUrl: "https://45.33.22.210",
                             jwt: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ2ZWxhcyIsInN1YiI6IndvcmtpdCJ9.CnksMqUsywjH4W8JgPePodi10pO_xJMrPyq9c19tQmo");
        }
    }

    func testHelloVelas() {
        let res = self.lapp.helloVelas()
        XCTAssertNotNil(res)
        XCTAssertEqual("Hello VelasLightning", res)
    }
    
    func testLogin() throws {
        let res = try self.lapp.login(username: "1@1.com", password: "123456")
        XCTAssertNotNil(res)
    }
    
    func testGetinfo() throws {
        
        let res = try self.lapp.getinfo()
        XCTAssertNotNil(res)
        XCTAssertEqual(res?.alias, "VelasCommerce-Testnet")
        XCTAssertEqual(res?.identity_pubkey, "03e347d089c071c27680e26299223e80a740cf3e3fc4b4237fa219bb67121a670b")
        XCTAssertEqual(res?.urls.localIP, "127.0.0.1")
        XCTAssertEqual(res?.urls.publicIP, "45.33.22.210")
    }
    
    func testListChannels() throws {
        let res = try self.lapp.listChannels()
        XCTAssertNotNil(res)
    }
    
//    func testOpenChannel(){
//        let res = self.lapp.openChannel(nodeId: <#T##String#>, amt: 20000)
//    }
}
