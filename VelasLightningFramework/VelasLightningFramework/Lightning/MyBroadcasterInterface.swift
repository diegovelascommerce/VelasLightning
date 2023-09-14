import LightningDevKit

 
/// What is it used for:  broadcasting various Lightning transactions
class MyBroadcasterInterface: BroadcasterInterface {
    
    private var btc:Bitcoin
    public init(btc:Bitcoin) {
        self.btc = btc
        super.init()
    }
    
    override func broadcastTransactions(txs: [[UInt8]]) {
        do {
            for tx in txs {
                let txHex = Utils.bytesToHex(bytes: tx)
                let txId = try btc.broadcast(txHex: txHex)
                if let txId = txId {
                    print("broadcast_transaction txId:\(txId)")
                }
                
            }
        }
        catch {
            NSLog("error broadcast_transaction:\(error)")
        }
    }
    
    
}

