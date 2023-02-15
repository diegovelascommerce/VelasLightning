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
    
    var utxos:Set<Bindings.WatchedOutput> = Set<Bindings.WatchedOutput>()
    
    var lightning: Lightning? = nil
    
    /// get transactions that we should monitor and filter
    override func registerTx(txid: [UInt8]?, scriptPubkey: [UInt8]) {
        if let txid = txid {
            txIds.append(txid)
            print("register_tx:\(Utils.bytesToHex32Reversed(bytes: Utils.array_to_tuple32(array: txid)))\n")
        }
    }
    
    
    /// get outputs that should be monitored
    override func registerOutput(output: Bindings.WatchedOutput) {
        utxos.insert(output)
    }
}
