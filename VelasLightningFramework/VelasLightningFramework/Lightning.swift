//
//  LDK.swift
//  VelasLightningFramework
//
//  Created by Diego vila on 10/25/22.
//

import Foundation
import LightningDevKit

public class Lightning {
    public init(){
        print("***** Hello LDK *****")
        
        //// Phase 1
        let feeEstimator = MyFeeEstimator()
        let logger = MyLogger()
        let broadcaster = MyBroadcasterInterface()
        let persister = MyPersister()
        let filter = MyFilter()
        
        //// Phase 2
        
        /* 8. Initialize the ChainMonitor
         
         What it is used for:  monitoring the chain for lightning transactions that are relevant
         to our node, and broadcasting transactions
         
         */
        let filterOption = Option_FilterZ(value: filter)
        let chainMonitor = ChainMonitor(chain_source: filterOption, broadcaster: broadcaster, logger: logger, feeest: feeEstimator, persister: persister)
        
        /* 9. Initialize the KeysManager
         
         What it is used for:  providing keys for signing Lightning transactions
         
         */
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
        let recipient:LDKRecipient = LDKRecipient(0)
        let nodeSecret = keysInterface.get_node_secret(recipient: recipient)
        
        /* 10.  ChannelManager
         
         what it's used for: managing channel state
         
         To instantiate the channel manager, we need a couple minor prerequisites.
         First, we need the current block height and hash.
         
         Second, we also need to initialize a default user config,
         
         Finally, we can proceed by instantiating the ChannelManager using ChannelManagerConstructor.
         
         */
        
        let latestBlockHash = [UInt8](Data(base64Encoded: "AAAAAAAAAAAABe5Xh25D12zkQuLAJQbBeLoF1tEQqR8=")!)
        let latestBlockHeight = UInt32(700123)
        
        let userConfig = UserConfig()
        
        let channelManagerConstructor = ChannelManagerConstructor(
            network: LDKNetwork_Bitcoin,
            config: userConfig,
            current_blockchain_tip_hash: latestBlockHash,
            current_blockchain_tip_height: latestBlockHeight,
            keys_interface: keysInterface,
            fee_estimator: feeEstimator,
            chain_monitor: chainMonitor,
            net_graph: nil, // see `NetworkGraph`
            tx_broadcaster: broadcaster,
            logger: logger
        )
        let channelManager = channelManagerConstructor.channelManager
    }
}

/***** Setup
 Covers everything you need to do to setup LDK on startup.
 
 */

/* 1. Initialize the FeeExtimator

 What it is used for:  estimating fees for on-chain transactions
 
 notes:
    1. Fees must be returned in: satoshis per 1000 weight units
    2. Fees returned must be no smaller than 253(equivalent to 1 satoshi)
    3. To reduce network traffic, you may want to cache fee result rather than retrieveing
       fresh ones every time
 */

class MyFeeEstimator: FeeEstimator {
    
    override func get_est_sat_per_1000_weight(confirmation_target: LDKConfirmationTarget) -> UInt32 {
        return 253
    }
    
}

/* 2. Logger
 
 What is it used for:  LDK logging
 
 */

class MyLogger: Logger {
    
    override func log(record: Record) {
        print("log event: \(record.get_args())")
    }
    
}

/* 3. BroadcasterInterface
 
 What is it used for:  broadcasting various Lightning transactions
 
 */
class MyBroadcasterInterface: BroadcasterInterface {
    
    override func broadcast_transaction(tx: [UInt8]) {
        // insert code to broadcast transaction
    }
    
}

/* 4. Persist
 
 What it is used for:  persisting crucial channel data
 
 notes:  ChannelMonitors are objects which are capable of responding to on-chain events for a given
         channel.  Thus, you will have on ChannelMonitor per channel, identified by channel_id: Outpoint.
         the persist methods will block progress on sending or receiving payment until they return.
         you must ensure that ChannelMonitors are durably persisted to disk or you may lose funds.
 
 */

class MyPersister: Persist {
    
    override func persist_new_channel(channel_id: OutPoint, data: ChannelMonitor, update_id: MonitorUpdateId) -> Result_NoneChannelMonitorUpdateErrZ {
        let idBytes: [UInt8] = channel_id.write()
        let monitorBytes: [UInt8] = data.write()
        
        // persist monitorBytes to disk, keyed by idBytes
        
        return Result_NoneChannelMonitorUpdateErrZ.ok()
    }
    
    override func update_persisted_channel(channel_id: OutPoint, update: ChannelMonitorUpdate, data: ChannelMonitor, update_id: MonitorUpdateId) -> Result_NoneChannelMonitorUpdateErrZ {
        let idBytes: [UInt8] = channel_id.write()
        let monitorBytes: [UInt8] = data.write()
        
        // modify persisted monitorBytes keyed by idBytes on disk
        
        return Result_NoneChannelMonitorUpdateErrZ.ok()
    }
    
}

/* Filter
 
 You must follow this step if: you are not providing full blocks to LDK, i.e. if you're using
 BIP 157/158 or Electrum as your chain backend.
 
 What it is used for:  If you are not providing full blocks, LDK uses this object to tell you
 what transactions and outputs to watch for on-chain.
 
 */

class MyFilter: Filter {
    
    override func register_tx(txid: [UInt8]?, script_pubkey: [UInt8]) {
        // watch this transaction on-chain
    }
    
    override func register_output(output: Bindings.WatchedOutput) {
        // watch outputs
    }
    
//    override func register_output(output: WatchedOutput) -> Option_C2Tuple_usizeTransactionZZ {
//        let scriptPubkeyBytes = output.get_script_pubkey()
//        let outpoint = output.get_outpoint()!
//        let txid = outpoint.get_txid()
//        let outputIndex = outpoint.get_index()
//
//        // watch for any transactions that spend this output on-chain
//
//        let blockHashBytes = output.get_block_hash()
//        // if block hash bytes are not null, return any transaction spending the output that is found in the corresponding block along with its index
//
//        return Option_C2Tuple_usizeTransactionZZ.none()
//    }
}


/*** Running LDK
 Everything you need to do while LDK is running to keep it operational
 
 */



