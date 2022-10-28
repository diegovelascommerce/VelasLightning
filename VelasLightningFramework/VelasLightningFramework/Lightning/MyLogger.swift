
import LightningDevKit

/// What is it used for:  logging the LDK
class MyLogger: Logger {
    
    override func log(record: Record) {
        print("log event: \(record.get_args())")
    }
    
}
