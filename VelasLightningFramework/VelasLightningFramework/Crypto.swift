//
//  Crypto.swift
//  VelasLightningFramework
//
//  Created by Diego vila on 3/9/23.
//

import Foundation
import CryptoKit

public class Cryptography {
    
    public static func encrypt(message:String, key:String? = nil) -> (Data, String)? {
        let symmetricKey:SymmetricKey
        
        if let key = key {
            let keyData = Data(base64Encoded: key)
            symmetricKey = SymmetricKey(data: keyData!)
        }
        else {
            symmetricKey = SymmetricKey(size: .bits256)
        }
        
        let data = Data(message.utf8)
        
        do {
            let encryptedData = try ChaChaPoly.seal(data, using: symmetricKey).combined
            let symmetricKeyb64 = symmetricKey.withUnsafeBytes {
                return Data(Array($0)).base64EncodedString()
            }
            return (encryptedData, symmetricKeyb64)
        }
        catch {
            print("error: \(error)")
            return nil
        }
    }
    
    public static func decrypt(encryptedData:Data, key:String) -> String? {
        do {
            let keyData = Data(base64Encoded: key)
            let symmetricKey = SymmetricKey(data: keyData!)
            
            let sealedBox = try ChaChaPoly.SealedBox(combined: encryptedData)
            let decryptedData = try ChaChaPoly.open(sealedBox, using: symmetricKey)
            let decryptedString = String(decoding: decryptedData, as: UTF8.self)
            return decryptedString
        }
        catch {
            print("error: \(error)")
            return nil
        }
    }
    
    
}
