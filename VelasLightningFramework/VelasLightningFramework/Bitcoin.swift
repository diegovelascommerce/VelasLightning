//
//  BDK.swift
//  VelasLightningFramework
//
//  Created by Diego vila on 10/25/22.
//

//import Foundation
import BitcoinDevKit


public class Bitcoin {
    
    private var wallet: Wallet
    
    private var addressInfo: AddressInfo
    
    public var address:String {
        addressInfo.address
    }
    
    public init() throws {
        print("***** Hello from workitLightningWallet *****")
        
        let desc = "wpkh([c258d2e4/84h/1h/0h]tpubDDYkZojQFQjht8Tm4jsS3iuEmKjTiEGjG6KnuFNKKJb5A6ZUCUZKdvLdSDWofKi4ToRCwb9poe1XdqfUnP4jaJjCB2Zwv11ZLgSbnZSNecE/0/*)"
                
        wallet = try Wallet.init(descriptor: desc, changeDescriptor: nil, network: Network.testnet, databaseConfig:DatabaseConfig.memory)
            
        addressInfo = try wallet.getAddress(addressIndex: AddressIndex.new)
    }
    
    public func getMnemonic(){
        
    }
    
    public func getPrivateKey(){
        
    }
    
}
