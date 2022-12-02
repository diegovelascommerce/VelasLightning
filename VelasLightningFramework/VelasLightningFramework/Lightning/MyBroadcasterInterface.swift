import LightningDevKit

 
/// What is it used for:  broadcasting various Lightning transactions
class MyBroadcasterInterface: BroadcasterInterface {
    
    private var btc:Bitcoin
    public init(btc:Bitcoin) {
        self.btc = btc
        super.init()
    }
    
    override func broadcast_transaction(tx: [UInt8]) {
        // insert code to broadcast transaction
        let txBase64 = Data(tx).base64EncodedString()
        print("LDK/broadcast_transaction: \(txBase64)")
        do {
            try btc.broadcast(tx: txBase64)
        }
        catch {
            NSLog("Velas/Lightning/MyBroadcasterInterface/broadcast_transaction: \(error)")
        }
        
    }
    
}

