
import LightningDevKit

/// What is it used for:  logging the LDK
class MyLogger: Logger {
    
    override func log(record: Record) {
        let block = [
            ("lib.rs", 520, false),
            ("peer_handler.rs", 979, false),
            ("peer_handler.rs", 1282, false),
            ("peer_handler.rs", 1280, false),
        ]
        let fileArr = record.getFile().split(separator: "/")
        let line = record.getLine()
        let args = record.getArgs()
        
        if let item = block.first(where: { $0.0 == fileArr.last! && $0.1 == line }) {
            if(item.2){
                print("log: (\(fileArr.last!):\(line)) \(args) \n")
            }
        }
        else {
            print("log: (\(fileArr.last!):\(line)) \(args) \n")
        }
        
        
        
        
    }
    
}
