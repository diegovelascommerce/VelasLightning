
import BitcoinDevKit

/// Handles creation of a Bitcoin wallet and interaction with the Bitcoin Blockchain
public class Bitcoin {
    
    public let network: Network
            
    public let mnemonic: String

    private let privKey: DescriptorSecretKey
    
    public let descriptor: String
    
    public let changeDescriptor: String
    
    private var blockchain: Blockchain

    private var wallet: Wallet

    
    /// Create a bitcoin wallet, by default it is setup for testnet and creates a new mnemonic
    public init(network _network: Network = Network.testnet, mnemonic _mnemonic: String? = nil) throws {
        print("***** Start BDK setup *****")
        
        self.network = _network
        
        // if mnemonic is empty then generate a new one
        if _mnemonic == nil {
            self.mnemonic = try generateMnemonic(wordCount: WordCount.words12)
        }
        else {
            self.mnemonic = _mnemonic!
        }
        
        // generate privKey from mnemonic
        self.privKey = try DescriptorSecretKey(network: self.network,
                                               mnemonic: self.mnemonic,
                                               password: nil)

        // create an xpub and set it in a descriptor
        let externalPath: DerivationPath = try DerivationPath(path:"m/84h/1h/0h/0")
        self.descriptor = "wpkh(\(privKey.extend(path:externalPath).asString()))"
        
        // create a change address
        let changeExternalPath: DerivationPath = try DerivationPath(path:"m/84h/1h/0h/1")
        self.changeDescriptor = "wpkh(\(privKey.extend(path:changeExternalPath).asString()))"
        
        // create electrum client
        let electrumUrl = self.network == Network.testnet ?
            "ssl://electrum.blockstream.info:60002" :
            "ssl://electrum.blockstream.info:50002"
        
        let electrum = ElectrumConfig(url: electrumUrl, socks5: nil, retry: 5, timeout: nil, stopGap: 10)
        
        
        // create a blockchain for syncing and broadcasting
        let blockchainConfig = BlockchainConfig.electrum(config: electrum)

        self.blockchain = try Blockchain(config: blockchainConfig)
        
        
        // create wallet
        wallet = try Wallet.init(descriptor: descriptor,
                                 changeDescriptor: changeDescriptor,
                                 network: network,
                                 databaseConfig:DatabaseConfig.memory)
        
        print("***** End BDK setup *****")
    }
    
    /// Generate a new address
    public func getNewAddress() throws -> String {
        let addressInfo = try wallet.getAddress(addressIndex: AddressIndex.new)
        return addressInfo.address
    }
    
    /// Sync wallet with the latest state of the blockchain
    public func sync() throws {
        try wallet.sync(blockchain: self.blockchain, progress: nil)
    }
    
    /// Create a transaction
    public func createTransaction(recipient: String, amt:UInt64) throws -> PartiallySignedBitcoinTransaction {
        let scriptPubKey = try Address(address: recipient).scriptPubkey()
        let res = try TxBuilder()
                    .addRecipient(script: scriptPubKey, amount: amt)
                    .feeRate(satPerVbyte: 256)
                    .finish(wallet: wallet)
        NSLog("Velas/Bitcoin/createTransaction: \(res.transactionDetails)")
        return res.psbt
    }
    
    /// Sign psbt
    public func signTransaction(psbt: PartiallySignedBitcoinTransaction) throws {
        _ = try wallet.sign(psbt: psbt)
    }
    
    /// Broadcast transacton that was passed as a base64 string
    public func broadcast(txHex: String) throws -> String? {
        let res = try Esplora.postTx(txHex: txHex, network: self.network)
        return res
    }
    
    /// Broadcast psbt.
    public func broadcast(psbt: PartiallySignedBitcoinTransaction) throws {
        try self.blockchain.broadcast(psbt: psbt)
    }
    
    /// Get the privKey in bytes
    public func getPrivKey() -> [UInt8] {
        return self.privKey.secretBytes()
    }
    
    /// Get the the latest block height from blockchain
    public func getBlockHeight() throws -> UInt32 {
        return try self.blockchain.getHeight()
    }
    
    /// Get the hash of the latest block
    public func getBlockHash() throws -> String {
        let height = try self.getBlockHeight()
        return try self.blockchain.getBlockHash(height: height)
    }
    
    /// Get the Genesis Block
    public func getGenesisHash() throws -> String {
        let genesisBlock = try self.blockchain.getBlockHash(height: 0)
        return genesisBlock
    }
    
    /// Get status of transaction
    public func getTx(txId:String) -> Transaction? {
        let res = Esplora.getTxStatus(txid:txId,
                                      network: self.network)
        return res
    }
    
    /// Get merkel proof of transaction
    public func getTxMerkleProof(txId:String) -> MerkleProof? {
        let res = Esplora.getTxMerkleProof(txid:txId,
                                      network: self.network)
        return res
    }
    
    // Get status of transaction
    public func getBlockHeader(hash:String) -> String? {
        let res = Esplora.getBlockHeader(hash: hash, network: self.network)
        return res
    }
    
    // Get raw data of transaction
    public func getTxRaw(txId:String) -> Data? {
        let res = Esplora.getTxRaw(txid: txId, network: self.network)
        return res
    }
    
    // Get tip height
    public func getTipHeight() -> Int32? {
        let res = Esplora.getTipHeight(network: self.network)
        return res
    }
    
    // Get tip hash
    public func getTipHash() -> String? {
        let res = Esplora.getTipHash(network: self.network)
        return res
    }
    
}
