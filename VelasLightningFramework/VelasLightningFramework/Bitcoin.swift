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
            
    public let mnemonic: String

    private let rootKey: DescriptorSecretKey
    
    public let descriptor: String
    
    public let changeDescriptor: String
    
    private var blockchain: Blockchain

    private var wallet: Wallet

    
        
    public init(network _network: Network = Network.testnet, mnemonic _mnemonic: String? = nil) throws {
        print("***** Start BDK setup *****")
        
        self.network = _network
        
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
        
        let changeExternalPath: DerivationPath = try DerivationPath(path:"m/84h/1h/0h/1")
        self.changeDescriptor = "wpkh(\(rootKey.extend(path:changeExternalPath).asString()))"
        
        let electrumUrl = self.network == Network.testnet ?
            "ssl://electrum.blockstream.info:60002" :
            "ssl://electrum.blockstream.info:50002"
        let electrum = ElectrumConfig(url: electrumUrl, socks5: nil, retry: 5, timeout: nil, stopGap: 10)
        
        let blockchainConfig = BlockchainConfig.electrum(config: electrum)

        self.blockchain = try Blockchain(config: blockchainConfig)
        
        wallet = try Wallet.init(descriptor: descriptor,
                                 changeDescriptor: changeDescriptor,
                                 network: network,
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
    
    public func createTransaction(recipient: String, amt:UInt64) throws -> PartiallySignedBitcoinTransaction {
        let scriptPubKey = try Address(address: recipient).scriptPubkey()
        let res = try TxBuilder()
                    .addRecipient(script: scriptPubKey, amount: amt)
                    .feeRate(satPerVbyte: 256)
                    .finish(wallet: wallet)
        NSLog("Velas/Bitcoin/createTransaction: \(res.transactionDetails)")
        return res.psbt
    }
    
    public func signTransaction(psbt: PartiallySignedBitcoinTransaction) throws {
        _ = try wallet.sign(psbt: psbt)
    }
    
    public func broadcast(tx: String) throws {
        let psbt = try PartiallySignedBitcoinTransaction(psbtBase64: tx)
        //_ = try wallet.sign(psbt: psbt)
        try self.blockchain.broadcast(psbt: psbt)
    }
    
    public func broadcast(psbt: PartiallySignedBitcoinTransaction) throws {
        try self.blockchain.broadcast(psbt: psbt)
    }
    
    public func getPrivKey() -> [UInt8] {
        return self.rootKey.secretBytes()
    }
    
    public func getBlockHeight() throws -> UInt32 {
        return try self.blockchain.getHeight()
    }
    
    public func getBlockHash() throws -> String {
        let height = try self.getBlockHeight()
        return try self.blockchain.getBlockHash(height: height)
    }
    
    public func getGenesisHash() throws -> String {
        let genesisBlock = try self.blockchain.getBlockHash(height: 0)
        return genesisBlock
    }
   
}
