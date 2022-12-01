//
//  FileMgr.swift
//  VelasLightningFramework
//
//  Created by Diego vila on 12/1/22.
//

import Foundation

extension URL {
    var isDirectory: Bool {
       (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}


class FileMgr {
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    static func writeString(string:String, path:String) throws {
        let url = getDocumentsDirectory().appendingPathComponent(path)
        try string.write(to: url, atomically: true, encoding: .utf8)
    }
    
    static func writeData(data:Data, path:String) throws {
        let url = getDocumentsDirectory().appendingPathComponent(path)
        try data.write(to: url)
    }
    
    static func readString(path:String) throws -> String {
        let url = getDocumentsDirectory().appendingPathComponent(path)
        
        return try String(contentsOf: url)
    }
    
    static func readData(path:String) throws -> Data {
        let url = getDocumentsDirectory().appendingPathComponent(path)
        
        return try Data(contentsOf: url)
    }
    
    static func createDirectory(path:String) throws {
        let url = getDocumentsDirectory().appendingPathComponent(path)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
    static func removeItem(path:String) throws  {
        let url = getDocumentsDirectory().appendingPathComponent(path)
        try FileManager.default.removeItem(at: url)
    }
    
    static func contentsOfDirectory(atPath:String? = nil, regex:String? = nil) throws -> [URL] {
        
        let url:URL
        if let path = atPath {
            url = getDocumentsDirectory().appendingPathComponent(path)
        }
        else {
            url = getDocumentsDirectory()
        }
        
        let content:[URL]
        if let regex = regex {
            let urlRegex = try NSRegularExpression(pattern:regex, options: .caseInsensitive)
            content = try FileManager.default.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: nil
            ).filter { (url) in
                let range = NSRange(location: 0, length: url.absoluteString.count)
                if urlRegex.firstMatch(in: url.absoluteString, range: range) != nil	{
                    return true
                } else {
                    return false
                }
            }
        }
        else {
            content = try FileManager.default.contentsOfDirectory(
                    at: url,
                    includingPropertiesForKeys: nil
                )
        }
        
        return content
    }
    
    static func removeAll() throws {
        let urls = try FileMgr.contentsOfDirectory()
        
        let urlRegex = try NSRegularExpression(pattern:"com.apple", options: .caseInsensitive)
        for url in urls {
            print(url.absoluteString)
            let range = NSRange(location: 0, length: url.absoluteString.count)
            if urlRegex.firstMatch(in: url.absoluteString, range: range) == nil {
                print("remove")
                try FileManager.default.removeItem(at: url)
            }
        }

    }
    
    static func findFile(atPath:String?, regex:String) throws -> Bool {
        let url = try contentsOfDirectory(atPath: atPath, regex: regex)
        return url.count > 0
    }
}
