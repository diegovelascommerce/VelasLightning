//
//  FileMgrTests.swift
//  VelasLightningTests
//
//  Created by Diego vila on 12/1/22.
//

import XCTest
@testable import VelasLightningFramework

class FileMgrTests: XCTestCase {

    override func tearDownWithError() throws {
        try FileMgr.removeAll()
     }

    func testGetDocumentDirectory() {
        let res = FileMgr.getDocumentsDirectory()
        XCTAssertFalse(res.absoluteString.isEmpty)
        print(res)
    }
    
    func testWriteString() throws {
        XCTAssertNoThrow(try FileMgr.writeString(string: "Hello World", path: "hello_world.txt"))
    }
    
    func testWriteData() throws {
        XCTAssertNoThrow(try FileMgr.writeData(data: Data("Hello World".utf8), path: "hello_world.data"))
    }
    
    func testFileExists() throws {
        XCTAssertNoThrow(try FileMgr.writeData(data: Data("Hello World".utf8), path: "hello_world.data"))
        let url = FileMgr.getDocumentsDirectory().appendingPathComponent("hello_world.data")
        XCTAssert(FileMgr.fileExists(url: url))
        XCTAssert(FileMgr.fileExists(path: "hello_world.data"))
        let url2 = FileMgr.getDocumentsDirectory().appendingPathComponent("hello_world.dataaaaaa")
        XCTAssertFalse(FileMgr.fileExists(url: url2))
        XCTAssertFalse(FileMgr.fileExists(path: "hello_world.dataaaaaa"))
    }
    
    func testReadString() throws {
        XCTAssertNoThrow(try FileMgr.writeString(string: "Hello World", path: "hello_world.txt"))
        
        do {
            let res = try FileMgr.readString(path: "hello_world.txt")
            XCTAssertEqual(res, "Hello World")
        }
        catch {
            print(error)
            throw error
        }
    }
    
    func testReadData() throws {
        XCTAssertNoThrow(try FileMgr.writeData(data: Data("Hello Data".utf8), path: "hello_world.data"))
        
        do {
            let data = try FileMgr.readData(path: "hello_world.data")
            let str = String(decoding: data, as: UTF8.self)
            XCTAssertEqual(str, "Hello Data")
        }
        catch {
            print(error)
            throw error
        }
    }
    
    func testCreateDirectory() throws {
        XCTAssertNoThrow(try FileMgr.createDirectory(path: "velas"))
        do {
            let files = try FileMgr.contentsOfDirectory()
            for file in files {
                print(file.lastPathComponent)
            }
        } catch {
            print(error)
            throw error
        }
    }
    
    func testCreateDirectoryAndAddFilesToIt() throws {
        XCTAssertNoThrow(try FileMgr.createDirectory(path: "velas"))
        XCTAssertNoThrow(try FileMgr.writeString(string: "Hello World1", path: "velas/hello_world1.txt"))
        XCTAssertNoThrow(try FileMgr.writeString(string: "Hello World2", path: "velas/hello_world2.txt"))
        XCTAssertNoThrow(try FileMgr.writeString(string: "Hello World3", path: "velas/hello_world3.txt"))
        do {
            let files = try FileMgr.contentsOfDirectory(atPath:"velas")
            XCTAssert(files.count == 3)
        } catch {
            print(error)
            throw error
        }
    }
    
    func testCreateDirectoryAndAddFilesToItData() throws {
        XCTAssertNoThrow(try FileMgr.createDirectory(path: "velas"))
        XCTAssertNoThrow(try FileMgr.writeData(data: Data("foobar 1".utf8), path: "velas/foobar1.data"))
        XCTAssertNoThrow(try FileMgr.writeData(data: Data("foobar 2".utf8), path: "velas/foobar2.data"))
        XCTAssertNoThrow(try FileMgr.writeData(data: Data("foobar 3".utf8), path: "velas/foobar3.data"))
        do {
            let urls = try FileMgr.contentsOfDirectory(atPath:"velas")
            XCTAssert(urls.count == 3)
            for url in urls {
                let data = try FileMgr.readData(url: url)
                let str = String(decoding: data, as: UTF8.self)
                switch(url.lastPathComponent){
                case "foobar1.data":
                    XCTAssert(str == "foobar 1")
                    break
                case "foobar2.data":
                    XCTAssert(str == "foobar 2")
                    break
                case "foobar3.data":
                    XCTAssert(str == "foobar 3")
                    break
                default:
                    print("there is a problem")
                    XCTAssert(false)
                    break
                }
                print(str)
            }
        } catch {
            print(error)
            throw error
        }
    }
    
    func testContentsOfDirectory() throws {
        XCTAssertNoThrow(try FileMgr.writeString(string: "foobar1", path: "file1.txt"))
        XCTAssertNoThrow(try FileMgr.writeString(string: "foobar2", path: "file2.txt"))
        XCTAssertNoThrow(try FileMgr.writeString(string: "foobar3", path: "file3.txt"))
        do {
            let files = try FileMgr.contentsOfDirectory()
            for file in files {
                print(file)
            }
            XCTAssertTrue(files.count == 5)
        } catch {
            print(error)
            throw error
        }
    }
    
    func testContentsOfDirectoryRegEx() throws {
        XCTAssertNoThrow(try FileMgr.writeString(string: "foobar1", path: "file1.txt"))
        XCTAssertNoThrow(try FileMgr.writeString(string: "foobar2", path: "file2.txt"))
        XCTAssertNoThrow(try FileMgr.writeString(string: "foobar3", path: "file3.txt"))
        do {
            let files = try FileMgr.contentsOfDirectory(regex: "\\w+\\.txt$")
            for file in files {
                print(file)
            }
            XCTAssertTrue(files.count == 3)
        } catch {
            print(error)
            throw error
        }
    }
    
    func testIsDirectory() throws {
        XCTAssertNoThrow(try FileMgr.writeString(string: "foobar1", path: "file1.txt"))
        XCTAssertNoThrow(try FileMgr.writeString(string: "foobar2", path: "file2.txt"))
        XCTAssertNoThrow(try FileMgr.writeString(string: "foobar3", path: "file3.txt"))
        do {
            let files = try FileMgr.contentsOfDirectory().filter { $0.isDirectory }
            for file in files {
                if file.isDirectory {
                    print(file)
                }
            }
            XCTAssertTrue(files.count == 2)
        } catch {
            print(error)
            throw error
        }
    }
    
    func testRemoveItem() throws {
        XCTAssertNoThrow(try FileMgr.writeString(string: "dumydata", path: "dumydata.txt"))
        XCTAssertNoThrow(try FileMgr.removeItem(path: "dumydata.txt"))
    }
    
    func testRemoveAll() throws {
        XCTAssertNoThrow(try FileMgr.removeAll())
    }

}
