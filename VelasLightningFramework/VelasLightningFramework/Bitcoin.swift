//
//  BDK.swift
//  VelasLightningFramework
//
//  Created by Diego vila on 10/25/22.
//

//import Foundation
import BitcoinDevKit


public class Bitcoin {
    
    private let network: Network
    
    private var wallet: Wallet
    
    public let mnemonic: String
        
    public let privKey: [UInt8]
    
    public let pubKey: String
    
    public var genesis: String {
        if(network == Network.bitcoin){
            return "000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f"
        }
        else {
            return "000000000933ea01ad0ee984209779baaec3ced90fa3f408719526f8d77f4943"
        }
    }
        
    public init(main: Bool = false) throws {
        print("***** Start BDK setup *****")
        
        network = main ? Network.bitcoin : Network.testnet
        
        mnemonic = try generateMnemonic(wordCount: WordCount.words12)
        
        let bip32RootKey = try DescriptorSecretKey(network: Network.testnet,
                                               mnemonic: mnemonic,
                                               password: nil)
        
        pubKey = bip32RootKey.asPublic().asString()
        
        privKey = bip32RootKey.secretBytes()
        
        let desc = "wpkh(\(pubKey)/0/*)"
                
        wallet = try Wallet.init(descriptor: desc, changeDescriptor: nil, network: Network.testnet, databaseConfig:DatabaseConfig.memory)
            
        
        
        print("***** End BDK setup *****")
    }
    
    
    public func getNewAddress() throws -> String {
        let addressInfo = try wallet.getAddress(addressIndex: AddressIndex.new)
        return addressInfo.address
    }
   
}
