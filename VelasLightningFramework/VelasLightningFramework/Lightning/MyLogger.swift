
import LightningDevKit

/// What is it used for:  logging the LDK
class MyLogger: Logger {
    
    override func log(record: Record) {
        
        NSLog("\(String(describing: type(of: self))):\(#function) LDK/log: \(record.get_args())")
        //NSLog("LDK/log: \(record.get_args())")
    }
    
}
