import LightningDevKit

 
/// What is it used for:  broadcasting various Lightning transactions
class MyBroadcasterInterface: BroadcasterInterface {
    
    override func broadcast_transaction(tx: [UInt8]) {
        // insert code to broadcast transaction
    }
    
}

