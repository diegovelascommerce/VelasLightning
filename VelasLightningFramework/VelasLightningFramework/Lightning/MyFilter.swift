import LightningDevKit

/// You must follow this step if:
///   you are not providing full blocks to LDK, i.e. if you're using
///   BIP 157/158 or Electrum as your chain backend.
///
/// What it is used for:
///   If you are not providing full blocks, LDK uses this object to tell you
///   what transactions and outputs to watch for on-chain.
///
///   You'll inform LDK about these transactions/outputs in Step 14.
class MyFilter: Filter {
    
    var txIds:[[UInt8]] = [[UInt8]]()
    
    var startSyncTimer:Optional<()->()> = nil
    
    override func register_tx(txid: [UInt8]?, script_pubkey: [UInt8]) {
        if let txid = txid {
            txIds.append(txid)
            
            let txIdHex = Utils.bytesToHex32Reversed(bytes: Utils.array_to_tuple32(array: txid))
            print("Velas/Lightning/MyFilter register_tx:\(txIdHex)")
            
            if let startSyncTimer = startSyncTimer {
                startSyncTimer()
            }
        }
    }
    
    func remove_tx(txid: [UInt8]){
        if let index = txIds.firstIndex(of: txid) {
            txIds.remove(at: index)
        }
    }
    
    
    
    // modified to compile
    override func register_output(output: Bindings.WatchedOutput) {
        // <insert code for you to watch for any transactions that spend this output on-chain>
    }
}
