
import LightningDevKit

public var channel_manager: LightningDevKit.ChannelManager?

/// This is the main class for handling interactions with the Lightning Network
public class Lightning {
    
//    var channel_manager: LightningDevKit.ChannelManager?
    var channel_manager_persister: MyChannelManagerPersister
    var peer_manager: LightningDevKit.PeerManager?
    var peer_handler: TCPPeerHandler?
    
    /// Setup the LDK
    public init() throws {
        print("----- Start LDK setup -----")
                
        // Step 1. initialize the FeeEstimator
        let feeEstimator = MyFeeEstimator()
        
        // Step 2. Initialize the Logger
        let logger = MyLogger()
        
        // Step 3. Initialize the BroadcasterInterface
        let broadcaster = MyBroadcasterInterface()
        
        // Step 4. Initialize Persist
        let persister = MyPersister()
        
        // Step 5. Initialize the Transaction Filter
        let filter = MyFilter()
        
        /// Step 6. Initialize the ChainMonitor
        ///
        /// What it is used for:
        ///   monitoring the chain for lightning transactions that are relevant to our node,
        ///   and broadcasting transactions
        
        let chainMonitor = ChainMonitor(chain_source: Option_FilterZ(value: filter), broadcaster: broadcaster, logger: logger, feeest: feeEstimator, persister: persister)
        

        /// Step 7. Initialize the KeysManager
        ///
        ///   What it is used for:
        ///     providing keys for signing Lightning transactions
        ///
        ///   notes:
        ///     Note that you must write the key_seed you give to the KeysManager on startup to disk,
        ///     and keep using it to initialize the KeysManager every time you restart.
        ///     This key_seed is used to derive your node's secret key (which corresponds to its node pubkey)
        ///     and all other secret key material
        ///
        ///     The current time is part of the KeysManager's parameters because
        ///     it is used to derive random numbers from the seed where required,
        ///     to ensure all random generation is unique across restarts.
        
        var keyData = Data(count: 32)
        keyData.withUnsafeMutableBytes {
            // returns 0 on success
            let didCopySucceed = SecRandomCopyBytes(kSecRandomDefault, 32, $0.baseAddress!)
            assert(didCopySucceed == 0)
        }
        let seed = [UInt8](keyData)
        let timestamp_seconds = UInt64(NSDate().timeIntervalSince1970)
        let timestamp_nanos = UInt32.init(truncating: NSNumber(value: timestamp_seconds * 1000 * 1000))
        let keysManager = KeysManager(seed: seed, starting_time_secs: timestamp_seconds, starting_time_nanos: timestamp_nanos)
        let keysInterface = keysManager.as_KeysInterface()
        
        
        /// Step 8.  Initialize the NetworkGraph
        ///
        /// You must follow this step if:
        ///   you need LDK to provide routes for sending payments (i.e. you are not providing your own routes)
        ///
        /// What it's used for:
        ///   generating routes to send payments over
        ///
        /// notes:
        ///   this struct is not required if you are providing your own routes.
        ///   It will be used internally in ChannelManagerConstructor to build a NetGraphMsgHandler
        ///
        ///   If you intend to use the LDK's built-in routing algorithm,
        ///   you will need to instantiate a NetworkGraph that can later be passed to the ChannelManagerConstructor
        ///
        ///   Note that a network graph instance needs to be provided upon initialization,
        ///   which in turn requires the genesis block hash.

        let networkGraph = NetworkGraph(genesis_hash: [UInt8](Data(base64Encoded: "AAAAAAAZ1micCFrhZYMek0/3Y65GoqbBcrPxtgqM4m8=")!), logger: logger)
        
        /// Step 9. Read ChannelMonitors from disk
        ///
        /// What it's used for:
        ///   if LDK is restarting and has at least 1 channel,
        ///   its channel state will need to be read from disk and fed to the ChannelManager on the next step.

        
        /// Step 10.  Initialize the ChannelManager
        ///
        /// what it's used for:
        ///   managing channel state
        ///
        /// notes:
        ///
        ///  To instantiate the channel manager, we need a couple minor prerequisites.
        ///
        ///  First, we need the current block height and hash.
        ///
        ///  Second, we also need to initialize a default user config,
        ///
        ///  Finally, we can proceed by instantiating the ChannelManager using ChannelManagerConstructor.
        let latestBlockHash = [UInt8](Data(base64Encoded: "AAAAAAAAAAAABe5Xh25D12zkQuLAJQbBeLoF1tEQqR8=")!)
        let latestBlockHeight = UInt32(700123)
        
        let userConfig = UserConfig()
        
        let channelManagerConstructor = ChannelManagerConstructor(
            network: LDKNetwork_Testnet,
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
        

        channel_manager = channelManagerConstructor.channelManager
        
        peer_manager = channelManagerConstructor.peerManager
        
        peer_handler = channelManagerConstructor.getTCPPeerHandler()
        
        channel_manager_persister = MyChannelManagerPersister()
        
        channelManagerConstructor.chain_sync_completed(persister: channel_manager_persister, scorer: nil)
        
        print("---- End LDK setup -----")
    }
    
    /// get the node id of our node.
    func getNodeId() throws -> String {
        if let nodeId = channel_manager?.get_our_node_id() {
            let res = bytesToHex(bytes: nodeId)
            print("Lightning/getNodeId: \(res)")
            return res
        } else {
            let error = NSError(domain: "getNodeId", code: 1, userInfo: nil)
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
            let error = NSError(domain: "bindNode", code: 1, userInfo: nil)
            throw error
        }
        
        let res = peer_handler.bind(address: address, port: port)
        if(!res){
            let error = NSError(domain: "bindNode", code: 1)
            throw error
        }
        print("Lightning/bindNode: connected")
        print("Lightning/bindNode address: \(address)")
        print("Lightning/bindNode port: \(port)")
        return res
    }
    
    /// Bind node to local address
    func bindNode() throws -> Bool {
        let address:String? = "0.0.0.0"
        let port = UInt16(9735)
        if let address = address {
            return try bindNode(address, port)
        }
        return false
    }
    
    /// Connect to a lightning node
    func connect(nodeId: String, address: String, port: NSNumber) throws -> Bool {
        guard let peer_handler = peer_handler else {
            let error = NSError(domain: "bindNode", code: 1, userInfo: nil)
            throw error
        }
        
        let res = peer_handler.connect(address: address,
                                       port: UInt16(truncating: port),
                                       theirNodeId: hexStringToByteArray(nodeId))
        
        if (!res) {
            let error = NSError(domain: "connectPeer", code: 1, userInfo: nil)
            throw error
        }
        
        return res
    }
    
    func listPeers() throws -> [[UInt8]] {
        guard let peer_manager = peer_manager else {
            let error = NSError(domain: "listPeers", code: 1, userInfo: nil)
            throw error
        }
        
        let peer_node_ids = peer_manager.get_peer_node_ids()
        print("peer_node_ids: \(peer_node_ids)")
        return peer_node_ids
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

private func hexStringToByteArray(_ string: String) -> [UInt8] {
    let length = string.count
    if length & 1 != 0 {
        return []
    }
    var bytes = [UInt8]()
    bytes.reserveCapacity(length/2)
    var index = string.startIndex
    for _ in 0..<length/2 {
        let nextIndex = string.index(index, offsetBy: 2)
        if let b = UInt8(string[index..<nextIndex], radix: 16) {
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
///     optional of String of IP address
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
                
//                print("getIPAdress name: \(name)")
                
                if name == "en0" {  // String.fromCString() is deprecated in Swift 3. So use the following code inorder to get the exact IP Address.
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t((interface.ifa_addr.pointee.sa_len)), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                    print("getIPAdress address: \(address!)")
                }
                
            }
        }
        freeifaddrs(ifaddr)
    }
    
    return address
}

/// Get the public IP address of device
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

