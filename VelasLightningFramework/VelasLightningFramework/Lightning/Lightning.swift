import LightningDevKit

/// This is the main class for handling interactions with the Lightning Network
public class Lightning {
    
    var logger: MyLogger!
    var keys_manager: KeysManager?
    var channel_manager_constructor: ChannelManagerConstructor?
    var channel_manager: LightningDevKit.ChannelManager?
    var channel_manager_persister: MyChannelManagerPersister
    var peer_manager: LightningDevKit.PeerManager?
    var peer_handler: TCPPeerHandler?
    
    let port = UInt16(9735)
    let channelId = "testChannelID"
    let counterpartyNodeId = "testNodeID"
    let currency: LDKCurrency = LDKCurrency_BitcoinTestnet
    let network: LDKNetwork = LDKNetwork_Testnet
    
    /// Setup the LDK
    public init() throws {
        NSLog("----- Start LDK setup -----")
                
        // Step 1. initialize the FeeEstimator
        let feeEstimator = MyFeeEstimator()
        
        // Step 2. Initialize the Logger
        logger = MyLogger()
        
        // Step 3. Initialize the BroadcasterInterface
        let broadcaster = MyBroadcasterInterface()
        
        // Step 4. Initialize Persist
        let persister = MyPersister()
        
        // Step 5. Initialize the Transaction Filter
        let filter = MyFilter()
        
        /// Step 6. Initialize the ChainMonitor
        ///
        /// What it is used for:
        ///     monitoring the chain for lightning transactions that are relevant to our node,
        ///     and broadcasting transactions
        let chainMonitor = ChainMonitor(chain_source: Option_FilterZ(value: filter),
                                        broadcaster: broadcaster,
                                        logger: logger,
                                        feeest: feeEstimator,
                                        persister: persister)
        
        /// Step 7. Initialize the KeysManager
        ///
        /// What it is used for:
        ///     providing keys for signing Lightning transactions
        var keyData = Data(count: 32)
        keyData.withUnsafeMutableBytes {
            // returns 0 on success
            let didCopySucceed = SecRandomCopyBytes(kSecRandomDefault, 32, $0.baseAddress!)
            assert(didCopySucceed == 0)
        }
        let seed = [UInt8](keyData)
        let timestamp_seconds = UInt64(NSDate().timeIntervalSince1970)
        let timestamp_nanos = UInt32.init(truncating: NSNumber(value: timestamp_seconds * 1000 * 1000))
        keys_manager = KeysManager(seed: seed, starting_time_secs: timestamp_seconds, starting_time_nanos: timestamp_nanos)
        let keysInterface = keys_manager!.as_KeysInterface()
        
        
        /// Step 8.  Initialize the NetworkGraph
        ///
        /// You must follow this step if:
        ///     you need LDK to provide routes for sending payments (i.e. you are not providing your own routes)
        ///
        /// What it's used for:
        ///     generating routes to send payments over
        ///
        /// notes:
        ///     It will be used internally in ChannelManagerConstructor to build a NetGraphMsgHandler
        ///
        ///     If you intend to use the LDK's built-in routing algorithm,
        ///     you will need to instantiate a NetworkGraph that can later be passed to the ChannelManagerConstructor
        ///
        ///     A network graph instance needs to be provided upon initialization,
        ///     which in turn requires the genesis block hash.
        let networkGraph = NetworkGraph(genesis_hash: [UInt8](Data(base64Encoded: "AAAAAAAZ1micCFrhZYMek0/3Y65GoqbBcrPxtgqM4m8=")!), logger: logger)
        
        /// Step 9. Read ChannelMonitors from disk
        ///
        /// you must follow this step if:
        ///     if LDK is restarting and has at least 1 channel,
        ///     its channel state will need to be read from disk and fed to the ChannelManager on the next step.
        ///
        /// what it's used for:
        ///     managing channel state
        
        /// Step 10.  Initialize the ChannelManager
        ///
        /// you must follow this step if:
        ///     this is the first time you are initializing the ChannelManager
        ///
        /// what it's used for:
        ///   managing channel state
        ///
        /// notes:
        ///
        ///     To instantiate the channel manager, we need a couple minor prerequisites.
        ///
        ///     First, we need the current block height and hash.
        ///
        ///     Second, we also need to initialize a default user config,
        ///
        ///     Finally, we can proceed by instantiating the ChannelManager using ChannelManagerConstructor.
        let latestBlockHash = [UInt8](Data(base64Encoded: "AAAAAAAAAAAABe5Xh25D12zkQuLAJQbBeLoF1tEQqR8=")!)
        let latestBlockHeight = UInt32(700123)
        let userConfig = UserConfig()
        channel_manager_constructor = ChannelManagerConstructor(
            network: network,
            config: userConfig,
            current_blockchain_tip_hash: latestBlockHash,
            current_blockchain_tip_height: latestBlockHeight,
            keys_interface: keysInterface,
            fee_estimator: feeEstimator,
            chain_monitor: chainMonitor,
            net_graph: networkGraph, // see `NetworkGraph`
            tx_broadcaster: broadcaster,
            logger: logger
        )
        

        channel_manager = channel_manager_constructor?.channelManager
        
        peer_manager = channel_manager_constructor?.peerManager
        
        peer_handler = channel_manager_constructor?.getTCPPeerHandler()
        
        channel_manager_persister = MyChannelManagerPersister()
        
        channel_manager_constructor?.chain_sync_completed(persister: channel_manager_persister, scorer: nil)
        
        NSLog("---- End LDK setup -----")
    }
    
    /// Get return the node id of our node.
    ///
    /// throws:
    ///     NSError
    ///
    /// return:
    ///     the nodeId of our lightning node
    func getNodeId() throws -> String {
        if let nodeId = channel_manager?.get_our_node_id() {
            let res = bytesToHex(bytes: nodeId)
            NSLog("Velas/Lightning/getNodeId: \(res)")
            return res
        } else {
            let error = NSError(domain: "getNodeId",
                                code: 1,
                                userInfo: [NSLocalizedDescriptionKey: "failed to get nodeId"])
            throw error
        }
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
        guard let peer_handler = peer_handler else {
            let error = NSError(domain: "bindNode",
                                code: 1,
                                userInfo: [NSLocalizedDescriptionKey: "peer_handler is not available"])
            throw error
        }
        
        let res = peer_handler.bind(address: address, port: port)
        if(!res){
            let error = NSError(domain: "bindNode",
                                code: 1,
                                userInfo: [NSLocalizedDescriptionKey: "failed to bind \(address):\(port)"])
            throw error
        }
        NSLog("Velas/Lightning/bindNode: connected")
        NSLog("Velas/Lightning/bindNode address: \(address)")
        NSLog("Velas/Lightning/bindNode port: \(port)")
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
    
    /// Connect to a lightning node
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
        guard let peer_handler = peer_handler else {
            let error = NSError(domain: "bindNode", code: 1, userInfo: nil)
            throw error
        }
        
        let res = peer_handler.connect(address: address,
                                       port: UInt16(truncating: port),
                                       theirNodeId: hexStringToByteArray(nodeId))
        
        if (!res) {
            let error = NSError(domain: "connectPeer",
                                code: 1,
                                userInfo: [NSLocalizedDescriptionKey: "failed to connect to peer \(nodeId)@\(address):\(port)"])
            throw error
        }
        
        return res
    }
    
    /// List peers that you are connected to.
    ///
    /// throws:
    ///     NSError
    ///
    /// return:
    ///     array of bytes that represent the node
    func listPeers() throws -> String {
        guard let peer_manager = peer_manager else {
            let error = NSError(domain: "listPeers",
                                code: 1,
                                userInfo: [NSLocalizedDescriptionKey: "peer_manager not available"])
            throw error
        }
        
        let peer_node_ids = peer_manager.get_peer_node_ids()
        
        
        var json = "["
        var first = true
        for it in peer_node_ids {
            if (!first) { json += "," }
            first = false
            json += "\"" + bytesToHex(bytes: it) + "\""
        }
        json += "]"
        
        return json
    }
    
    /// Close channel in the nice way.
    ///
    /// both parties aggree to close the channel
    ///
    /// throws:
    ///     NSError
    ///
    /// return:
    ///     true if close correctly
    func closeChannelCooperatively() throws -> Bool {
        guard let close_result = channel_manager?.close_channel(channel_id: hexStringToByteArray(channelId), counterparty_node_id: hexStringToByteArray(counterpartyNodeId)), close_result.isOk() else {
            let error = NSError(domain: "closeChannelCooperatively",
                                code: 1,
                                userInfo: [NSLocalizedDescriptionKey: "closeChannelCooperatively Failed"])
            throw error
        }
        
        return true
    }
    
    /// Close channel the bad way.
    ///
    /// force to close the channel due to maybe the other peer being unresponsive
    ///
    /// throws:
    ///     NSError
    ///
    /// return:
    ///     true is channel was closed
    func closeChannelForce() throws -> Bool {
        guard let close_result = channel_manager?.force_close_broadcasting_latest_txn(channel_id: hexStringToByteArray(channelId), counterparty_node_id: hexStringToByteArray(counterpartyNodeId)) else {
            let error = NSError(domain: "closeChannelForce",
                                code: 1,
                                userInfo: [NSLocalizedDescriptionKey: "closeChannelForce Failed"])
            throw error
        }
        if (close_result.isOk()) {
            return true
        } else {
            let error = NSError(domain: "closeChannelForce",
                                code: 1,
                                userInfo: [NSLocalizedDescriptionKey: "closeChannelForce Failed"])
            throw error
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
        
        guard let channel_manager = channel_manager, let keys_manager = keys_manager else {
            let error = NSError(domain: "addInvoice",
                                code: 1,
                                userInfo: [NSLocalizedDescriptionKey: "No channel_manager or keys_manager initialized"])
            throw error
        }
        
        let invoiceResult = Bindings.swift_create_invoice_from_channelmanager(
            channelmanager: channel_manager,
            keys_manager: keys_manager.as_KeysInterface(),
            logger: logger,
            network: currency,
            amt_msat: Bindings.Option_u64Z(value: UInt64(exactly: amtMsat)),
            description: description,
            invoice_expiry_delta_secs: 24 * 3600)

        if let invoice = invoiceResult.getValue() {
            return invoice.to_str()
        } else {
            let error = NSError(domain: "addInvoice",
                                code: 1,
                                userInfo: [NSLocalizedDescriptionKey: "addInvoice failed"])
            throw error
        }
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
    func payInvoice(bolt11: String, amtMSat: Int) throws -> Bool {

        guard let payer = channel_manager_constructor?.payer else {
            let error = NSError(domain: "payInvoice", code: 1, userInfo: nil)
            throw error
        }

        let parsedInvoice = Invoice.from_str(s: bolt11)

        guard let parsedInvoiceValue = parsedInvoice.getValue(), parsedInvoice.isOk() else {
            let error = NSError(domain: "payInvoice", code: 1, userInfo: nil)
            throw error
        }

        if let _ = parsedInvoiceValue.amount_milli_satoshis().getValue() {
            let sendRes = payer.pay_invoice(invoice: parsedInvoiceValue)
            if sendRes.isOk() {
                return true
            } else {
                print("pay_invoice error")
                print(String(describing: sendRes.getError()))
            }
        } else {
            if amtMSat == 0 {
                let error = NSError(domain: "payInvoice", code: 1, userInfo: nil)
                throw error
            }
            let unsignedAmount = UInt64(truncating: NSNumber(value: amtMSat))
            let amountInMillisatoshis = unsignedAmount * 1000
            let sendRes = payer.pay_zero_value_invoice(invoice: parsedInvoiceValue, amount_msats: amountInMillisatoshis)
            if sendRes.isOk()  {
                return true
            } else {
                print("pay_zero_value_invoice error")
                print(String(describing: sendRes.getError()))
            }
        }

        let error = NSError(domain: "payInvoice", code: 1, userInfo: nil)
        throw error
    }

}

/// convert bytes array to Hex String
///
/// params:
///     bytes:  bytes to convert
///
/// return:
///     hex string of byte array
func bytesToHex(bytes: [UInt8]) -> String
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


/// Convert string of hex to a byte array.
///
/// params:
///     string:  string of hex to convert
///
/// return:
///     array of bytes that was converted from hexstring
private func hexStringToByteArray(_ hexString: String) -> [UInt8] {
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


/// Get the Local IP address of current machine
///
/// from https://gist.github.com/SergLam/9a90ffda7c57740beb18fb28da125b8a
///
/// return:
///     the local ip address of this node
func getLocalIPAdress() -> String? {
        
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
func getPublicIPAddress() -> String? {
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



