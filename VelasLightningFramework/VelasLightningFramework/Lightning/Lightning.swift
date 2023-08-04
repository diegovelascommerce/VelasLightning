import LightningDevKit
import BitcoinDevKit

public enum LightningError: Error {
    case peerManager(msg:String)
    case networkGraph(msg:String)
    case parseInvoice(msg:String)
    case channelManager(msg:String)
    case nodeId(msg:String)
    case bindNode(msg:String)
    case connectPeer(msg:String)
    case Invoice(msg:String)
    case payInvoice(msg:String)
    case chainMonitor(msg:String)
    case probabilisticScorer(msg:String)
}

public struct PayInvoiceResult {
    public let bolt11:String
    public let memo:String
    public let amt:UInt64
}

/// This is the main class for handling interactions with the Lightning Network
public class Lightning {
    
    // logger for ldk
    var logger: MyLogger!
    
    // filter for transactions
    var filter: MyFilter? = nil
    
    // graph of routes
    var router: NetworkGraph? = nil
    
    // scores routes
    var scorer: MultiThreadedLockableScore? = nil
    
    // manages keys for signing
    var keysManager: KeysManager? = nil
    
    // monitors the block chain
    var chainMonitor: ChainMonitor? = nil
    
    // constructor for creating the channel manager.
    var channelManagerConstructor: ChannelManagerConstructor? = nil
    
    // the channel manager
    var channelManager: LightningDevKit.ChannelManager? = nil
    
    // persister for the channel manager
    var channelManagerPersister: MyChannelManagerPersister?
    
    // manages the peer that node is connected to
    var peerManager: LightningDevKit.PeerManager? = nil
    
    // handle peer communications
    var peerHandler: TCPPeerHandler? = nil
    
    // port number for lightning
    let port = UInt16(9735)
    
    // which currency will be setup?  Testnet or Bitcoin?
    let currency: Bindings.Currency

    // Bitcoin network, or the Testnet network
    let network: Bindings.Network
    
    // handles all operations that have to do with bitcoin
    var btc: Bitcoin
    
    /// Setup the LDK
    public init(btc:Bitcoin, verbose:Bool = false) throws {
        
        print("----- Start LDK setup -----")
        if verbose {
            Bindings.setLogThreshold(severity: .DEBUG)
        }
        else {
            Bindings.setLogThreshold(severity: .ERROR)
        }
        
        
        self.btc = btc
        
        if btc.network == Network.testnet {
            self.network = Bindings.Network.Testnet
            self.currency = Bindings.Currency.BitcoinTestnet
        }
        else {
            self.network = Bindings.Network.Bitcoin
            self.currency = Bindings.Currency.Bitcoin
        }
        
                
        // Step 1. initialize the FeeEstimator
        let feeEstimator = MyFeeEstimator()
        
        // Step 2. Initialize the Logger
        logger = MyLogger(verbose: verbose)
        
        // Step 3. Initialize the BroadcasterInterface
        let broadcaster = MyBroadcasterInterface(btc:btc)
        
        // Step 4. Initialize Persist
        let persister = MyPersister()
        
        // Step 5. Initialize the Transaction Filter
        filter = MyFilter()
        
        /// Step 6. Initialize the ChainMonitor
        chainMonitor = ChainMonitor(chainSource: filter,
                                    broadcaster: broadcaster,
                                    logger: logger,
                                    feeest: feeEstimator,
                                    persister: persister)
        
        /// Step 7. Initialize the KeysManager
        let seed = btc.getPrivKey()
        let timestamp_seconds = UInt64(NSDate().timeIntervalSince1970)
        let timestamp_nanos = UInt32.init(truncating: NSNumber(value: timestamp_seconds * 1000 * 1000))
        keysManager = KeysManager(seed: seed, startingTimeSecs: timestamp_seconds, startingTimeNanos: timestamp_nanos)
        
        /// Step 8.  Initialize the NetworkGraph
        
        // check if network graph was backed up
        var netGraph:NetworkGraph?
        if FileMgr.fileExists(path: "network_graph") {
            let file = try FileMgr.readData(path: "network_graph")
            let readResult = NetworkGraph.read(ser: [UInt8](file), arg: logger)

            // loaded backedup networkGraph
            if readResult.isOk() {
                netGraph = readResult.getValue()
                print("Velas/Lightning: loaded network graph ok")

            // create a new NetworkGraph
            } else {
                print("Velas/Lighting: network graph failed to load, create one from scratch")
                print(String(describing: readResult.getError()))
                netGraph = NetworkGraph(network: self.network, logger: logger)
            }
            
        // create a new NetworkGraph
        } else {
            netGraph = NetworkGraph(network: self.network, logger: logger)
            print("Velas/Lightning: network graph created")
        }
        
        /// Step 8.5  Setup probability scorer for graph

        // load probabilistic scorer
        if FileMgr.fileExists(path: "probabilistic_scorer") {
            guard let netGraph = netGraph else {
                throw LightningError.networkGraph(msg: "network graph not available")
            }
            let file = try FileMgr.readData(path: "probabilistic_scorer")
            
            let scoringParams = ProbabilisticScoringParameters.initWithDefault()
            let scorerReadResult = ProbabilisticScorer.read(ser: [UInt8](file), argA: scoringParams, argB: netGraph, argC: logger)
            
            guard let readResult = scorerReadResult.getValue() else {
                throw LightningError.probabilisticScorer(msg: "failed to load probabilsticScorer")
            }

            let probabilisticScorer = readResult
            let score = probabilisticScorer.asScore()
            self.scorer = MultiThreadedLockableScore(score: score)
            print("Velas/Lightning: scorer loaded and running")
        }
        // create new probabilitic scorer
        else {
            guard let netGraph = netGraph else {
                throw LightningError.networkGraph(msg: "network graph not available")
            }
            let scoringParams = ProbabilisticScoringParameters.initWithDefault()
            let probabilisticScorer = ProbabilisticScorer(params: scoringParams, networkGraph: netGraph, logger: logger)
            let score = probabilisticScorer.asScore()
            self.scorer = MultiThreadedLockableScore(score: score)
            print("Velas/Lightning: scorer created and running")
        }
                
        /// Step 9. Read ChannelManager and ChannelMonitors from disk
        
        /// check if the channel manager was saved
        
        var channelManagerSerialized:[UInt8] = [UInt8]()
        
        if FileMgr.fileExists(path: "channel_manager") {
            let channelManagerData = try FileMgr.readData(path: "channel_manager")
            channelManagerSerialized = [UInt8](channelManagerData)
            print("Velas/Lightning: serialized channelManager loaded")
        }
        
        /// check if any channels were saved
        
        var channelMonitorsSerialized:[[UInt8]] = [[UInt8]]()
        
        if FileMgr.fileExists(path: "channels") {
            let urls = try FileMgr.contentsOfDirectory(atPath:"channels")
            for url in urls {
                let channelData = try FileMgr.readData(url: url)
                let channelBytes = [UInt8](channelData)
                channelMonitorsSerialized.append(channelBytes)
            }
            print("Velas/Lightning: serialized channelMonitors loaded")
        }
        
        /// Step 10.  Initialize the ChannelManager
        
        let handshakeConfig = ChannelHandshakeConfig.initWithDefault()
        handshakeConfig.setMinimumDepth(val: 1)
        handshakeConfig.setAnnouncedChannel(val: false)

        let handshakeLimits = ChannelHandshakeLimits.initWithDefault()
        handshakeLimits.setForceAnnouncedChannelPreference(val: false)
        handshakeLimits.setTrustOwnFunding0conf(val: true)
        
        let userConfig = UserConfig.initWithDefault()
        userConfig.setChannelHandshakeConfig(val: handshakeConfig)
        userConfig.setChannelHandshakeLimits(val: handshakeLimits)
        userConfig.setAcceptInboundChannels(val: true)
        
        guard let keysManager = keysManager else {
            throw LightningError.networkGraph(msg: "keysManager not available")
        }
        guard let chainMonitor = chainMonitor else {
            throw LightningError.chainMonitor(msg: "keysManager not available")
        }
        
        let constructionParameters = ChannelManagerConstructionParameters(
            config: userConfig,
            entropySource: keysManager.asEntropySource(),
            nodeSigner: keysManager.asNodeSigner(),
            signerProvider: keysManager.asSignerProvider(),
            feeEstimator: feeEstimator,
            chainMonitor: chainMonitor,
            txBroadcaster: broadcaster,
            logger: logger,
            enableP2PGossip: true,
            scorer: scorer
        )
        
        // if there are channel previously created
        if let netGraph = netGraph, !channelManagerSerialized.isEmpty {
            channelManagerConstructor = try ChannelManagerConstructor(
                channelManagerSerialized: channelManagerSerialized,
                channelMonitorsSerialized: channelMonitorsSerialized,
                networkGraph: NetworkGraphArgument.instance(netGraph),
                filter: filter,
                params: constructionParameters
            )
            print("Velas/Lightning: channelManagerConstructor loaded")
        }
        // else create the channel manager constructor from scratch
        else {

            // get the latest block hash and height
            let latestBlockHash = Utils.hexStringToByteArray(try btc.getBlockHash())
            let latestBlockHeight = try btc.getBlockHeight()
            
            channelManagerConstructor = ChannelManagerConstructor(
                network: network,
                currentBlockchainTipHash: latestBlockHash,
                currentBlockchainTipHeight: latestBlockHeight,
                netGraph: netGraph,
                params: constructionParameters
            )
            print("Velas/Lightning: channelManagerConstructor created")
        }

        // get the channel manager
        channelManager = channelManagerConstructor?.channelManager
                
        // set the persister for the channel manager
        channelManagerPersister = MyChannelManagerPersister()
        
        /// Step 12. Sync ChannelManager and ChainMonitor to chain tip
        try self.sync()
        
        // hookup the persister to the the channel manager
        channelManagerConstructor?.chainSyncCompleted(persister: channelManagerPersister!)

        // get the peer manager
        peerManager = channelManagerConstructor?.peerManager

        // get the peer handler
        peerHandler = channelManagerConstructor?.getTCPPeerHandler()

        router = channelManagerConstructor?.netGraph

        channelManagerPersister?.lightning = self
        
        print("---- End LDK setup -----")
    }
    
    /// unconfirm or confirm all the transactions that can be reorg and confirm all transation and outputs
    /// that come from the Filter object.
    func sync() throws {
        var reorgTxIds = [[UInt8]]()
        var confirmedTxs = [[String:Any]]()
       
        /// get all txIds that could be reorginized
        
        for tx in channelManager!.asConfirm().getRelevantTxids() {
            reorgTxIds.append(tx.0)
        }
        
        for tx in chainMonitor!.asConfirm().getRelevantTxids() {
            reorgTxIds.append(tx.0)
        }
                
        /// unconfirm any transactions that that have been reorginized or add them to the confirmed list

        if reorgTxIds.count > 0 {
            for txId in reorgTxIds {
                let txIdHex = Utils.bytesToHex32Reversed(bytes: Utils.array_to_tuple32(array: txId))
                let tx = self.btc.getTx(txId: txIdHex)
                if let tx = tx, tx.confirmed == false {
                    try transactionUnconfirmed(txId:txId)
                }
                // add it to confirmed list
                else if let tx = tx, tx.confirmed == true {
                    let txDict = getTransactionDict(txIdHex: txIdHex, tx: tx)
                    confirmedTxs.append(txDict)
                }
            }
        }
        
        /// add the txIds from the filter object.
        
        if let filteredTxIds = filter?.txIds, filteredTxIds.count > 0 {
            for txId in filteredTxIds {
                let txIdHex = Utils.bytesToHex32Reversed(bytes: Utils.array_to_tuple32(array: txId))
                let tx = self.btc.getTx(txId: txIdHex)
                if let tx = tx, tx.confirmed == true {
                    if(!confirmedTxs.contains(where: { $0["txIdHex"] as! String == txIdHex })){
                        let txDict = getTransactionDict(txIdHex: txIdHex, tx: tx)
                        confirmedTxs.append(txDict)
                    }
                }
            }
        }
        
        /// add txIds that spent the outputs
        
        if let outputs = filter?.outputs, outputs.count > 0 {
            for output in outputs {
                let outpoint = output.getOutpoint()
                let txId = outpoint.getTxid()
                let txIdHex = Utils.bytesToHex32Reversed(bytes: Utils.array_to_tuple32(array: txId!))
                let outputIndex = outpoint.getIndex()
                
                if let res = btc.outSpend(txId: txIdHex, index: outputIndex) {
                    if res.spent {
                        let tx = self.btc.getTx(txId: res.txid!)
                        if let tx = tx, tx.confirmed == true {
                            if(!confirmedTxs.contains(where: { $0["txIdHex"] as! String == res.txid! })){
                                let txDict = getTransactionDict(txIdHex: res.txid!, tx: tx)
                                confirmedTxs.append(txDict)
                            }
                        }
                    }
                }

            }
        }
        
        /// group txIds by blockheight
        
        let groupByBlockHeight = Dictionary(grouping: confirmedTxs) { txDict in
            txDict["height"] as! Int32
        }
        
        /// confirm txids
        
        for (_, txList) in groupByBlockHeight.sorted(by: { $0.key < $1.key }) {
            
            // sort txIds by output order
            let sortedTxList = txList.sorted(by: {
                return ($0["txPos"] as! Int32) < ($1["txPos"] as! Int32)
            })
            
            try transactionsConfirmed(txList: sortedTxList)
        }
        
        // sync the ChannelManager and ChainManager
        try updateBestBlock()
    }
    
    /// return Transaction data in a dictonary
    func getTransactionDict(txIdHex: String, tx: Transaction) -> [String:Any] {
        var txDict = [String:Any]()
        txDict["txIdHex"] = txIdHex
        txDict["height"] = tx.block_height
        txDict["txRaw"] = btc.getTxRaw(txId: txIdHex)
        txDict["headerHex"] = btc.getBlockHeader(hash: tx.block_hash)
        let merkleProof = btc.getTxMerkleProof(txId: txIdHex)
        txDict["txPos"] = merkleProof!.pos
        return txDict
    }
    
    /// confirm the transaction
    func transactionsConfirmed(txList: [[String:Any]]) throws {
        guard let channelManager = channelManager, let chainMonitor = chainMonitor else {
            let error = NSError(domain: "Channel manager", code: 1, userInfo: nil)
            throw error
        }
        
        var txArray = [(UInt,[UInt8])]()
        
        for tx in txList {
            let txPos = UInt(tx["txPos"] as! Int32)
            let txRaw = [UInt8](tx["txRaw"] as! Data)
            txArray.append((txPos,txRaw))
        }
        
        let headerHex = txList[0]["headerHex"] as! String
        let height = UInt32(truncating: txList[0]["height"] as! NSNumber)

        // confirm transaction for bothe the ChannelMonitor and ChainMonitor
        channelManager.asConfirm().transactionsConfirmed(header: Utils.hexStringToByteArray(headerHex), txdata: txArray, height: height)

        chainMonitor.asConfirm().transactionsConfirmed(header: Utils.hexStringToByteArray(headerHex), txdata: txArray, height: height)
        
    }
    
    /// set transaction as unconfirmed
    func transactionUnconfirmed(txId: [UInt8]) throws {
        guard let channelManager = channelManager, let chainMonitor = chainMonitor else {
            let error = NSError(domain: "Channel manager", code: 1, userInfo: nil)
            throw error
        }
        
        // set transaction as unconfirmed for both ChannelManger and ChainManager
        channelManager.asConfirm().transactionUnconfirmed(txid: txId)
        chainMonitor.asConfirm().transactionUnconfirmed(txid: txId)
    }
    

    /// update the bestblock for both the ChannelManager and ChainManager
    func updateBestBlock() throws {
        guard let channelManager = channelManager, let chainMonitor = chainMonitor else {
            let error = NSError(domain: "Channel manager", code: 1, userInfo: nil)
            throw error
        }
        
        // get the best block data
        let best_height = btc.getTipHeight()
        let best_hash = btc.getTipHash()
        let best_header = btc.getBlockHeader(hash: best_hash!)


        channelManager.asConfirm().bestBlockUpdated(header: Utils.hexStringToByteArray(best_header!), height: UInt32(truncating: best_height! as NSNumber))

        chainMonitor.asConfirm().bestBlockUpdated(header: Utils.hexStringToByteArray(best_header!), height: UInt32(truncating: best_height! as NSNumber))
        
    }

    
    /// Get return the node id of our node.
    ///
    /// throws:
    ///     NSError
    ///
    /// return:
    ///     the nodeId of our lightning node
    func getNodeId() throws -> String {
        guard let channelManager = channelManager else {
            throw LightningError.nodeId(msg:"failed to get nodeID")
        }
        
        let nodeId = channelManager.getOurNodeId()
        
        let res = Utils.bytesToHex(bytes: nodeId)
        
        return res
    }
    
    /// Bind node to an IP address and port.
    ///
    /// so that it can receive connection request from another node in the lightning network
    ///
    /// throws:
    ///   NSError - if there was a problem connecting
    ///
    /// return:
    ///   a boolean to indicate that binding of node was a success
    public func bindNode(_ address:String, _ port:UInt16) throws -> Bool {
        guard let peerHandler = peerHandler else {
            throw LightningError.peerManager(msg: "peer_handler is not available")
        }
        
        let res = peerHandler.bind(address: address, port: port)
        if(!res){
            throw LightningError.bindNode(msg: "failed to bind \(address):\(port)")
        }
        print("Velas/Lightning/bindNode: connected")
        print("Velas/Lightning/bindNode address: \(address)")
        print("Velas/Lightning/bindNode port: \(port)")
        return res
    }
    
    /// Bind node to local address.
    ///
    /// throws:
    ///     NSError
    ///
    /// return:
    ///     true if bind was a success
    func bindNode() throws -> Bool {
        let res = try bindNode("0.0.0.0", port)
        return res
    }
    
    /// Connect to a peer
    ///
    /// params:
    ///     nodeId: node id that you want to connect to
    ///     address: ip address of node
    ///     port: port of node
    ///
    /// throws:
    ///     NSError
    ///
    /// return:
    ///     true if connection went through
    func connect(nodeId: String, address: String, port: NSNumber) throws -> Bool {
        guard let peerHandler = peerHandler else {
            throw LightningError.peerManager(msg: "peerHandler not working")
        }
        
        let res = peerHandler.connect(address: address,
                                       port: UInt16(truncating: port),
                                       theirNodeId: Utils.hexStringToByteArray(nodeId))
        
        if (!res) {
            throw LightningError.connectPeer(msg: "failed to connect to peer")
        }
        
        return res
    }
    
    /// List peers that you are connected to.
    ///
    /// throws:
    ///     LightningError.peerManager
    ///
    /// return:
    ///     array of bytes that represent the node
    func listPeers() throws -> [String] {
        guard let peerManager = peerManager else {
            throw LightningError.peerManager(msg: "peerManager was not available for listPeers")
        }
        
        let peerNodeIds = peerManager.getPeerNodeIds()
        
        var res = [String]()

        for it in peerNodeIds {
            let nodeId = Utils.bytesToHex(bytes: it.0)
            let address = Utils.bytesToIpAddress(bytes: it.1!.getValueAsIPv4()!.getAddr())
            let port = it.1!.getValueAsIPv4()!.getPort()
            res.append("\(nodeId)@\(address):\(port)")
        }

        return res
    }
    
    
    /// Get list of all channels
    ///
    /// throws:
    ///     LightningError.channelManager
    ///
    /// returns:
    ///     array of channels
    func listChannelsDict() throws -> [[String:Any]] {
        guard let channelManager = channelManager else {
            throw LightningError.channelManager(msg: "Channel Manager not initialized")
        }

        let channels = channelManager.listChannels().isEmpty ? [] : channelManager.listChannels()
        var channelsDict = [[String:Any]]()
        _ = channels.map { (it: ChannelDetails) in
            let channelDict = self.channel2ChannelDictionary(it: it)
            channelsDict.append(channelDict)
        }

        return channelsDict
    }
    
    /// Get list of usable channels.
    ///
    /// throws:
    ///
    /// returns:
    ///     array of usable channels
    func listUsableChannelsDict() throws -> [[String:Any]] {
        guard let channelManager = channelManager else {
            throw LightningError.channelManager(msg: "Channel Manager not initialized")
        }

        let channels = channelManager.listUsableChannels().isEmpty ? [] : channelManager.listChannels()
        var channelsDict = [[String:Any]]()
        _ = channels.map { (it: ChannelDetails) in
            let channelDict = self.channel2ChannelDictionary(it: it)
            channelsDict.append(channelDict)
        }

        return channelsDict
    }
    
    
    
    /// Convert ChannelDetails to a string
    func channel2ChannelDictionary(it: ChannelDetails) -> [String:Any] {
        
        var channelsDict = [String: Any]()
        
//        channelsDict["short_channel_id"] = it.getShortChannelId() ?? 0;
        channelsDict["confirmations_required"] = it.getConfirmationsRequired() ?? 0;
//        channelsDict["force_close_spend_delay"] = it.getForceCloseSpendDelay() ?? 0;
//        channelsDict["unspendable_punishment_reserve"] = it.getUnspendablePunishmentReserve() ?? 0;
        
        channelsDict["channel_id"] = Utils.bytesToHex(bytes: it.getChannelId()!)
        channelsDict["channel_value_satoshis"] = String(it.getChannelValueSatoshis())
        channelsDict["inbound_capacity_msat"] = String(it.getInboundCapacityMsat())
        channelsDict["outbound_capacity_msat"] = String(it.getOutboundCapacityMsat())
        channelsDict["next_outbound_htlc_limit"] = String(it.getNextOutboundHtlcLimitMsat())
        
        channelsDict["is_usable"] = it.getIsUsable() ? "true" : "false"
        channelsDict["is_channel_ready"] = it.getIsChannelReady() ? "true" : "false"
//        channelsDict["is_outbound"] = it.getIsOutbound() ? "true" : "false"
        channelsDict["is_public"] = it.getIsPublic() ? "true" : "false"
        channelsDict["remote_node_id"] = Utils.bytesToHex(bytes: it.getCounterparty().getNodeId())

        if let funding_txo = it.getFundingTxo() {
            //channelsDict["funding_txo_txid"] = Utils.bytesToHex(bytes: funding_txo.getTxid()!)
            channelsDict["funding_txo_txid"] =  Utils.bytesToHex32Reversed(bytes: Utils.array_to_tuple32(array: funding_txo.getTxid()!))
            
            channelsDict["funding_txo_index"] = String(funding_txo.getIndex())
        }
   

//        channelsDict["counterparty_unspendable_punishment_reserve"] = String(it.getCounterparty().getUnspendablePunishmentReserve())

//        let channelId = it.getUserChannelId()
//        channelsDict["user_id"] = String(cString: channelId)

        return channelsDict
    }
    
    /// Close all channels in the nice way, cooperatively.
    func closeChannelsCooperatively() throws {
        guard let channelManager = channelManager else {
            throw LightningError.channelManager(msg: "Channel Manager not initialized")
        }

        let channels = channelManager.listChannels().isEmpty ? [] : channelManager.listChannels()
       
        _ = try channels.map { (channel: ChannelDetails) in
            try closeChannelCooperatively(nodeId: channel.getCounterparty().getNodeId(),
                                      channelId: channel.getChannelId()!)
        }
    }
    
    /// Close a channel in the nice way, cooperatively.
    ///
    /// both parties aggree to close the channel
    ///
    /// throws:
    ///     NSError
    ///
    /// return:
    ///     true if close correctly
    func closeChannelCooperatively(nodeId: [UInt8], channelId: [UInt8]) throws -> Bool {
        guard let close_result = channelManager?.closeChannel(channelId: channelId, counterpartyNodeId: nodeId), close_result.isOk() else {
            throw LightningError.channelManager(msg: "closeChannelCooperatively")
        }
        try removeChannelBackup(channelId: Utils.bytesToHex(bytes: channelId))
        
        return true
    }
    
    /// Close all channels the ugly way, forcefully.
    func closeChannelsForcefully() throws {
        guard let channel_manager = channelManager else {
            throw LightningError.channelManager(msg: "closeChannelsForcefully")
        }

        let channels = channel_manager.listChannels().isEmpty ? [] : channel_manager.listChannels()
       
        _ = try channels.map { (channel: ChannelDetails) in
            try closeChannelForcefully(nodeId: channel.getCounterparty().getNodeId(),
                                      channelId: channel.getChannelId()!)
        }
    }
    
    /// Close a channel the bad way, forcefully.
    ///
    /// force to close the channel due to maybe the other peer being unresponsive
    ///
    /// throws:
    ///     NSError
    ///
    /// return:
    ///     true is channel was closed
    func closeChannelForcefully(nodeId: [UInt8], channelId: [UInt8]) throws -> Bool {
        guard let close_result = channelManager?.forceCloseBroadcastingLatestTxn(channelId: channelId, counterpartyNodeId: nodeId) else {
            throw LightningError.channelManager(msg: "closeChannelForce Failed")
        }
        if (close_result.isOk()) {
            try removeChannelBackup(channelId: Utils.bytesToHex(bytes: channelId))
            return true
        } else {
            let error = NSError(domain: "closeChannelForce",
                                code: 1,
                                userInfo: [NSLocalizedDescriptionKey: "closeChannelForce Failed"])
            throw error
        }
    }
    
    func removeChannelBackup(channelId:String) throws {
        print("try to delete channel: \(channelId)")
        do {
            let urls = try FileMgr.contentsOfDirectory(atPath:"channels")
            for url in urls {
                print(url)
                if url.lastPathComponent.contains(channelId) {
                    print("delete url:\(url)")
                    try FileMgr.removeItem(url: url)
                }
            }
        }
        catch {
            print("remove channel backup: \(error)")
        }
    }
    
    /// Create Bolt11 Invoice.
    ///
    /// params:
    ///     amtMsat:  amount in mili satoshis
    ///     description:  descrition of invoice
    ///
    /// returns:
    ///     bolt11 invoice
    ///
    /// throws:
    ///     NSError
    func createInvoice(amtMsat: Int, description: String) throws -> String {
        
        guard let channelManager = channelManager, let keysManager = keysManager else {
            throw LightningError.channelManager(msg: "createInvoice")
        }
        
        let invoiceResult = Bindings.createInvoiceFromChannelmanager(
            channelmanager: channelManager,
            nodeSigner: keysManager.asNodeSigner(),
            logger: logger,
            network: self.currency,
            amtMsat: UInt64(exactly: amtMsat),
            description: description,
            invoiceExpiryDeltaSecs: 24 * 3600,
            minFinalCltvExpiryDelta: 24
        )


        if let invoice = invoiceResult.getValue() {
            return invoice.toStr()
        } else {
            let error = NSError(domain: "addInvoice",
                                code: 1,
                                userInfo: [NSLocalizedDescriptionKey: "addInvoice failed"])
            throw error
        }
    }
    
    /// deserialized the bolt11
    func deserializeBolt11(bolt11: String) throws -> (Invoice, String, String, UInt64) {
        let invoiceParsed = Invoice.fromStr(s: bolt11)
        
        guard let invoice = invoiceParsed.getValue(), invoiceParsed.isOk() else {
            throw LightningError.Invoice(msg: "deserializeBolt11")
        }
        
//        print("payeePubKey: \(invoice.payeePubKey()!)")
        
        let restoredBolt11 = invoice.toStr()
        
        print("restoredBolt11: \(restoredBolt11)")
        
        let memo = invoice.intoSignedRaw().rawInvoice().description()?.intoInner()
        let amt = invoice.amountMilliSatoshis()
        
//        let pubKey = invoice.payeePubKey()
        
//        let pubKey = invoice.recoverPayeePubKey()

        
        return (invoice, restoredBolt11, memo!, amt!)
    }
    
    func getInvoice(bolt11: String) throws -> Invoice {
        let invoiceParsed = Invoice.fromStr(s: bolt11)
        
        guard let invoice = invoiceParsed.getValue(), invoiceParsed.isOk() else {
            throw LightningError.Invoice(msg: "deserializeBolt11")
        }
        
        return invoice
    }
    
    /// Pay a bolt11 invoice.
    ///
    /// params:
    ///     bolt11: the bolt11 invoice we want to pay
    ///     amtMSat: amount we want to pay in milisatoshis
    ///
    /// throws:
    ///     NSError
    ///
    /// return:
    ///     true is payment when through
    func payInvoice(bolt11: String) throws -> PayInvoiceResult? {

        let invoiceResult = Invoice.fromStr(s: bolt11)
        guard let invoice = invoiceResult.getValue(), let channelManager = self.channelManager else {
            throw LightningError.Invoice(msg: "couldn't parse bolt11")
        }
        
        let invoicePaymentResult = Bindings.payInvoice(invoice: invoice,
                                                       retryStrategy: Bindings.Retry.initWithAttempts(a: 3),
                                                       channelmanager: channelManager)
        if invoicePaymentResult.isOk() {
            let deserializedBolt11 = try deserializeBolt11(bolt11: bolt11)
            return PayInvoiceResult(bolt11: deserializedBolt11.1, memo: deserializedBolt11.2, amt: deserializedBolt11.3)
        } else {
            let deserializedBolt11 = try deserializeBolt11(bolt11: bolt11)
            print("Velas/Lightning payInvoice: \(deserializedBolt11)")
            let error = invoicePaymentResult.getError()
            print("Velas/Lightning payInvoice error: \(String(describing: error))")
            print("Velas/Lightning payInvoice error: \(String(describing: error?.getValueAsInvoice()))")
            print("Velas/Lightning payInvoice error: \(String(describing: error?.getValueAsSending()))")
            print("Velas/Lightning payInvoice error: \(String(describing: error?.getValueType()))")
            throw LightningError.payInvoice(msg: "payInvoice error: \(String(describing: error?.getValueType()))")
        }
        
    }
    
    func findRout(bolt11: String) throws {
        guard let networkGraph = router,
              let logger = logger
//              let keysManager = keysManager
//              let scorer = scorer
        else {
            throw LightningError.Invoice(msg: "couldn't parse bolt11")
        }
        
        print("bolt11: \(bolt11)")

        guard let channelManager = channelManager else {
            throw LightningError.nodeId(msg:"failed to get nodeID")
        }
        
        let payerPubkey = channelManager.getOurNodeId()
        
        print("payerPubkey: \(payerPubkey)")
       
        let invoice = try getInvoice(bolt11: bolt11)
        
        let payeePubkey = invoice.recoverPayeePubKey()
        
        print("payeePubkey: \(payeePubkey)")
        
        let paymentParameters = PaymentParameters.initForKeysend(payeePubkey: payeePubkey, finalCltvExpiryDelta: 3)
        
        let amount = invoice.amountMilliSatoshis()!
                
        let routeParameters = RouteParameters(paymentParamsArg: paymentParameters, finalValueMsatArg: amount)
        
        let randomSeedBytes: [UInt8] = [UInt8](repeating: 0, count: 32)
        
        let scoringParams = ProbabilisticScoringParameters.initWithDefault()
        let scorer = ProbabilisticScorer(params: scoringParams, networkGraph: networkGraph, logger: logger)
        let score = scorer.asScore()

        
        let foundRoute = Bindings.findRoute(
            ourNodePubkey: payerPubkey,
            routeParams: routeParameters,
            networkGraph: networkGraph,
            firstHops: [],
            logger: logger,
            scorer: score,
            randomSeedBytes: randomSeedBytes
        )

        print(foundRoute)

        if let route = foundRoute.getValue() {
            let fees = route.getTotalFees()
            print("fees: \(fees)")
            let paths = route.getPaths()
            print("found route with \(paths.count) paths!")
        }

        
//        ProbabilisticScorer
//        let randomSeedBytes: [UInt8] = [UInt8](repeating: 0, count: 32)
//        let scoreParams = ProbabilisticScoringFeeParameters.initWithDefault();
//        let foundRoute = Bindings.findRoute(
//            ourNodePubkey: payerPubkey,
//            routeParams: routeParameters,
//            networkGraph: networkGraph,
//            firstHops: [],
//            logger: logger,
//            scorer: scorer,
////            scoreParams: scoreParams,
//            randomSeedBytes: randomSeedBytes)


//        let invoice = try deserializeBolt11(bolt11: bolt11)

//        let amount = invoice.amountMilliSatoshis()
//
//        print("amount: \(amount)")

//        print(deserializedBolt11)

        
//        let defaultRouter = DefaultRouter.init(networkGraph: networkGraph,
//                                               logger: logger,
//                                               randomSeedBytes: keysManager.asEntropySource().getSecureRandomBytes(),
//                                               scorer: scorer.asLockableScore())
//
//        let res = defaultRouter.asRouter().findRoute(
//            payer: payerPubkey,
//            routeParams: routeParameters,
//            firstHops: [],
//            inflightHtlcs: InFlightHtlcs())
//
//        let r = res.getValue()
//
//        print("r: \(r)")
        
        
        
    }

}










