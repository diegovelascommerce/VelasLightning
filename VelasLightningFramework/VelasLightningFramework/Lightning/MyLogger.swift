
import LightningDevKit

/// What is it used for:  logging the LDK
class MyLogger: Logger {
    
    override func log(record: Record) {
        print("LDK/log: \(record.get_args())")
    }
    
}
