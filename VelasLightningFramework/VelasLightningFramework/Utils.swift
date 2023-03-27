//
//  Utils.swift
//  VelasLightningFramework
//
//  Created by Diego vila on 12/14/22.
//

import Foundation

public class Utils {
    
    /// convert bytes array to Hex String
    ///
    /// params:
    ///     bytes:  bytes to convert
    ///
    /// return:
    ///     hex string of byte array
    static func bytesToHex(bytes: [UInt8]) -> String
    {
        var hexString: String = ""
        var count = bytes.count
        for byte in bytes
        {
            hexString.append(String(format:"%02X", byte))
            count = count - 1
        }
        return hexString.lowercased()
    }
    
    /// convert bytes array to Hex String
    ///
    /// params:
    ///     bytes:  bytes to convert
    ///
    /// return:
    ///     hex string of byte array
    static func bytesToIpAddress(bytes: [UInt8]) -> String
    {
        var result: String = ""
        var count = 1
        for byte in bytes
        {
            result.append(String(Int(byte)))
            if count < bytes.count {
                result.append(".")
                count = count + 1
            }
        }
        
        return result
    }
    
    /// Convert string of hex to a byte array.
    ///
    /// params:
    ///     string:  string of hex to convert
    ///
    /// return:
    ///     array of bytes that was converted from hexstring
    static func hexStringToByteArray(_ hexString: String) -> [UInt8] {
        let length = hexString.count
        if length & 1 != 0 {
            return []
        }
        var bytes = [UInt8]()
        bytes.reserveCapacity(length/2)
        var index = hexString.startIndex
        for _ in 0..<length/2 {
            let nextIndex = hexString.index(index, offsetBy: 2)
            if let b = UInt8(hexString[index..<nextIndex], radix: 16) {
                bytes.append(b)
            } else {
                return []
            }
            index = nextIndex
        }
        return bytes
    }
    
    static func bytesToHex32Reversed(bytes: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)) -> String
    {
        var bytesArray: [UInt8] = []
        bytesArray.append(bytes.0)
        bytesArray.append(bytes.1)
        bytesArray.append(bytes.2)
        bytesArray.append(bytes.3)
        bytesArray.append(bytes.4)
        bytesArray.append(bytes.5)
        bytesArray.append(bytes.6)
        bytesArray.append(bytes.7)
        bytesArray.append(bytes.8)
        bytesArray.append(bytes.9)
        bytesArray.append(bytes.10)
        bytesArray.append(bytes.11)
        bytesArray.append(bytes.12)
        bytesArray.append(bytes.13)
        bytesArray.append(bytes.14)
        bytesArray.append(bytes.15)
        bytesArray.append(bytes.16)
        bytesArray.append(bytes.17)
        bytesArray.append(bytes.18)
        bytesArray.append(bytes.19)
        bytesArray.append(bytes.20)
        bytesArray.append(bytes.21)
        bytesArray.append(bytes.22)
        bytesArray.append(bytes.23)
        bytesArray.append(bytes.24)
        bytesArray.append(bytes.25)
        bytesArray.append(bytes.26)
        bytesArray.append(bytes.27)
        bytesArray.append(bytes.28)
        bytesArray.append(bytes.29)
        bytesArray.append(bytes.30)
        bytesArray.append(bytes.31)

        return Utils.bytesToHex(bytes: bytesArray.reversed())
    }

    static func array_to_tuple32(array: [UInt8]) -> (UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8) {
                    return (array[0], array[1], array[2], array[3], array[4], array[5], array[6], array[7], array[8], array[9], array[10], array[11], array[12], array[13], array[14], array[15], array[16], array[17], array[18], array[19], array[20], array[21], array[22], array[23], array[24], array[25], array[26], array[27], array[28], array[29], array[30], array[31])
    }
    
    /// Get the Local IP address of current machine
    ///
    /// from https://gist.github.com/SergLam/9a90ffda7c57740beb18fb28da125b8a
    ///
    /// return:
    ///     the local ip address of this node
    static func getLocalIPAdress() -> String? {
            
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        
        if getifaddrs(&ifaddr) == 0 {
            
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next } // memory has been renamed to pointee in swift 3 so changed memory to pointee
                
                guard let interface = ptr?.pointee else {
                    return nil
                }
                let addrFamily = interface.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    
                    guard let ifa_name = interface.ifa_name else {
                        return nil
                    }
                    let name: String = String(cString: ifa_name)
                    
                    if name == "en0" {  // String.fromCString() is deprecated in Swift 3. So use the following code inorder to get the exact IP Address.
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface.ifa_addr, socklen_t((interface.ifa_addr.pointee.sa_len)), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                    }
                    
                }
            }
            freeifaddrs(ifaddr)
        }
        
        return address
    }

    /// Get the public IP address of device
    ///
    /// return:
    ///     the public IP of this node
    static func getPublicIPAddress() -> String? {
        var publicIP: String?
        do {
            try publicIP = String(contentsOf: URL(string: "https://www.bluewindsolution.com/tools/getpublicip.php")!, encoding: String.Encoding.utf8)
            publicIP = publicIP?.trimmingCharacters(in: CharacterSet.whitespaces)
        }
        catch {
            print("Error: \(error)")
        }
        return publicIP
    }



}
