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
    
    public var genesis: String
        
    public let mnemonic: String

    private let rootKey: DescriptorSecretKey
    
    public let descriptor: String
    
    private var blockchain: Blockchain

    private var wallet: Wallet

    
        
    public init(network _network: Network = Network.testnet, mnemonic _mnemonic: String? = nil) throws {
        print("***** Start BDK setup *****")
        
        self.network = _network
        if(self.network == Network.bitcoin){
            self.genesis = "000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f"
        }
        else {
            self.genesis = "000000000933ea01ad0ee984209779baaec3ced90fa3f408719526f8d77f4943"
        }
        
        if _mnemonic == nil {
            self.mnemonic = try generateMnemonic(wordCount: WordCount.words12)
        }
        else {
            self.mnemonic = _mnemonic!
        }
        
        self.rootKey = try DescriptorSecretKey(network: self.network,
                                               mnemonic: self.mnemonic,
                                               password: nil)

        let externalPath: DerivationPath = try DerivationPath(path:"m/84h/1h/0h/0")

        self.descriptor = "wpkh(\(rootKey.extend(path:externalPath).asString()))"
        
        let electrum = ElectrumConfig(url: "ssl://electrum.blockstream.info:60002", socks5: nil, retry: 5, timeout: nil, stopGap: 10)
        
        let blockchainConfig = BlockchainConfig.electrum(config: electrum)

        self.blockchain = try Blockchain(config: blockchainConfig)
        
        wallet = try Wallet.init(descriptor: self.descriptor,
                                 changeDescriptor: nil,
                                 network: self.network,
                                 databaseConfig:DatabaseConfig.memory)
        
        print("***** End BDK setup *****")
    }
    
    
    public func getNewAddress() throws -> String {
        let addressInfo = try wallet.getAddress(addressIndex: AddressIndex.new)
        return addressInfo.address
    }
    
    public func sync() throws {
        try wallet.sync(blockchain: self.blockchain, progress: nil)
    }
    
    public func getHeight() throws -> UInt32 {
        return try self.blockchain.getHeight()
    }
    
    public func getBlockHash() throws -> String {
        let height = try self.getHeight()
        return try self.blockchain.getBlockHash(height: height)
    }
   
}
