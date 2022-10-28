
import LightningDevKit

/// This is the main class for handling interactions with the Lightning Network
public class Lightning {
    
    /// Setup the LDK and run the LDK
    ///
    /// based on setup procedures explained in
    /// - https://github.com/lightningdevkit/ldk-swift/blob/main/docs/setup.md,
    /// - https://lightningdevkit.org/tutorials/build_a_node_in_java/
    /// - https://lightningdevkit.org/tutorials/build_a_node_in_rust/
    public init() throws {
        print("----- Started with setting up the LDK -----")
        
        ///  Setup:  Setup steps to run the LDK
        
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
        let filterOption = Option_FilterZ(value: filter)
        let chainMonitor = ChainMonitor(chain_source: filterOption, broadcaster: broadcaster, logger: logger,
                                        feeest: feeEstimator, persister: persister)
        
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
        
        // We will keep needing to pass around a keysInterface instance,
        // and we will also need to pass its node secret to the peer manager initialization,
        // so let's prepare it right here:
        let recipient:LDKRecipient = LDKRecipient(0)
        let nodeSecret = keysInterface.get_node_secret(recipient: recipient)
        
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
        
        /*  -- Java Example --
         *
        // Initialize the array where we'll store the `ChannelMonitor`s read from disk.
        final ArrayList channel_monitor_list = new ArrayList<>();

        // For each monitor stored on disk, deserialize it and place it in
        // `channel_monitors`.
        for (... : monitor_files) {
            byte[] channel_monitor_bytes = // read the bytes from disk the same way you
                                           // wrote them in Step 5
            channel_monitor_list.add(channel_monitor_bytes);
        }

        // Convert the ArrayList into an array so we can pass it to
        // `ChannelManagerConstructor` in Step 11.
        final byte[][] channel_monitors = (byte[][])channel_monitor_list.toArray(new byte[1][]);
        */
        
        /* -- Rust example --
         *
         // Use LDK's sample persister module provided method
         let mut channel_monitors =
             persister.read_channelmonitors(keys_manager.clone()).unwrap();

         // If you are using Electrum or BIP 157/158, you must call load_outputs_to_watch
         // on each ChannelMonitor to prepare for chain synchronization in Step 9.
         for chan_mon in channel_monitors.iter() {
             chan_mon.load_outputs_to_watch(&filter);
         }

         */
        
        let serializedChannelManager: [UInt8] = [2, 1, 111, 226, 140, 10, 182, 241, 179, 114, 193, 166, 162, 70, 174, 99, 247, 79, 147, 30, 131, 101, 225, 90, 8, 156, 104, 214, 25, 0, 0, 0, 0, 0, 0, 10, 174, 219, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 238, 87, 135, 110, 67, 215, 108, 228, 66, 226, 192, 37, 6, 193, 120, 186, 5, 214, 209, 16, 169, 31, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] // <insert bytes you would have written in following the later step "Persist channel manager">
        let serializedChannelMonitors: [[UInt8]] = []
        
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
        
//        let channelManagerConstructor = ChannelManagerConstructor(
//            network: LDKNetwork_Bitcoin,
//            config: userConfig,
//            current_blockchain_tip_hash: latestBlockHash,
//            current_blockchain_tip_height: latestBlockHeight,
//            keys_interface: keysInterface,
//            fee_estimator: feeEstimator,
//            chain_monitor: chainMonitor,
//            net_graph: nil, // see `NetworkGraph`
//            tx_broadcaster: broadcaster,
//            logger: logger
//        )
//        let channelManager = channelManagerConstructor.channelManager
        
        /* this is where exception is thrown
         
        let channelManagerConstructor = try ChannelManagerConstructor(
            channel_manager_serialized: serializedChannelManager,
            channel_monitors_serialized: serializedChannelMonitors,
            keys_interface: keysInterface,
            fee_estimator: feeEstimator,
            chain_monitor: chainMonitor,
            filter: filter,
            net_graph_serialized: nil, // or networkGraph
            tx_broadcaster: broadcaster,
            logger: logger
        )

        let channelManager = channelManagerConstructor.channelManager
        
        /// Step 11. Peer handler
        let peerManager = channelManagerConstructor.peerManager
        
        // If you need to serialize a channel manager, you can simply call its write method on itself:
        //let serializedChannelManager: [UInt8] = channelManager.write(obj: channelManager)
         
         */
    }
}











/*** Running LDK
 Everything you need to do while LDK is running to keep it operational
 
 */



