
import Foundation

extension URL {
    var isDirectory: Bool {
       (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}

/// This is incharge of managing file for iOS
public class FileMgr {
    
    /// get the current document directory for the app
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    /// write a string to a file
    public static func writeString(string:String, path:String) throws {
        let url = getDocumentsDirectory().appendingPathComponent(path)
        try string.write(to: url, atomically: true, encoding: .utf8)
    }
    
    /// write raw data to a file
    public static func writeData(data:Data, path:String) throws {
        let url = getDocumentsDirectory().appendingPathComponent(path)
        try data.write(to: url)
    }
    
    /// write plist to a file
    static func writePlist(plist:NSMutableDictionary, path:String) throws {
        let url = getDocumentsDirectory().appendingPathComponent(path)
        try plist.write(to: url)
    }
    
    /// read string from a file, using a relative path
    public static func readString(path:String) throws -> String {
        let url = getDocumentsDirectory().appendingPathComponent(path)
        
        return try String(contentsOf: url)
    }
    
    /// read raw data from a file, using a relative path
    public static func readData(path:String) throws -> Data {
        let url = getDocumentsDirectory().appendingPathComponent(path)
        
        return try Data(contentsOf: url)
    }
    
    /// read raw data from a url
    static func readData(url:URL) throws -> Data {
        return try Data(contentsOf: url)
    }
    
    /// check if file exists using a url
    public static func fileExists(url:URL) -> Bool {
        let res = FileManager.default.fileExists(atPath: url.path)
        return res
    }
    
    /// check if file exists using a relative path
    public static func fileExists(path:String) -> Bool {
        let url = getDocumentsDirectory().appendingPathComponent(path)
        let res = fileExists(url: url)
        return res
    }
    
    /// find file
    static func findFile(atPath:String?, regex:String) throws -> Bool {
        let url = try contentsOfDirectory(atPath: atPath, regex: regex)
        return url.count > 0
    }
    
    /// create a directory
    static func createDirectory(path:String) throws {
        let url = getDocumentsDirectory().appendingPathComponent(path)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
    /// remove an item
    static func removeItem(path:String) throws  {
        let url = getDocumentsDirectory().appendingPathComponent(path)
        try FileManager.default.removeItem(at: url)
    }
    
    /// remove an item
    static func removeItem(url:URL) throws  {
        try FileManager.default.removeItem(at: url)
    }
    
    /// show content inside directory, and can filter results using regex
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
    
    /// remove everything in document directory for app
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
    
    public static func getPlist(_ file:String) -> NSDictionary {
        let path = Bundle.main.path(forResource: file, ofType:"plist")!
        let dict = NSDictionary(contentsOfFile: path)
        return dict!
    }
    
    
}
