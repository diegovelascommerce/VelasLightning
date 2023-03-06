
import LightningDevKit

/// What is it used for:  logging the LDK
class MyLogger: Logger {
    
    override func log(record: Record) {
        let level = record.getLevel()
//        if level == .Gossip || level == .Trace || level == .Debug {
//            return
//        }
        if level == .Gossip {
            return
        }
        let recordString = "\(record.getArgs())"
        print("log: \(recordString)")
    }
    
}
