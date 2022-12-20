import LightningDevKit

 
/// What is it used for:  broadcasting various Lightning transactions
class MyBroadcasterInterface: BroadcasterInterface {
    
    private var btc:Bitcoin
    public init(btc:Bitcoin) {
        self.btc = btc
        super.init()
    }
    
    override func broadcast_transaction(tx: [UInt8]) {
        
        do {
            let txHex = Utils.bytesToHex(bytes: tx)
            print("broadcast_transaction txHex:\(txHex)")
            let txId = try btc.broadcast(txHex: txHex)
            print("broadcast_transaction txId:\(txId!)")
        }
        catch {
            NSLog("error broadcast_transaction:\(error)")
        }
        
    }
    
}

