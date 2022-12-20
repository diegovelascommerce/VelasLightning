
import LightningDevKit

/// What is it used for:  logging the LDK
class MyLogger: Logger {
    
    override func log(record: Record) {
        let block = [
            ("lib.rs", 520, false),
            ("peer_handler.rs", 979, false),
            ("peer_handler.rs", 1282, false),
//            ("channelmanager.rs", 6915, true),
//            ("channelmanager.rs", 5697, true),
//            ("channelmanager.rs", 5716, true),
//            ("chainmonitor.rs", 521, true),
//            ("channel.rs", 5320, true),
        ]
        let fileArr = record.get_file().split(separator: "/")
        let line = record.get_line()
        let args = record.get_args()
        
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
