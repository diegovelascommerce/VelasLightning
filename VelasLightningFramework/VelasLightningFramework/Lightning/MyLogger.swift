
import LightningDevKit

/// What is it used for:  logging the LDK
class MyLogger: Logger {
    
    var verbose = false
    
    public init(verbose:Bool = false){
        self.verbose = verbose
    }
    
    override func log(record: Record) {
        let level = record.getLevel()
        
        if self.verbose == false &&
           level == .Gossip ||
           level == .Trace ||
           level == .Debug {
            return
        }

        let recordString = "\(record.getArgs())"
        print("log: \(recordString)")
    }
    
}
