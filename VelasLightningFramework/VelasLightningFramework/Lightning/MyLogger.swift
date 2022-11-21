
import LightningDevKit

/// What is it used for:  logging the LDK
class MyLogger: Logger {
    
    override func log(record: Record) {
        let fileArr = record.get_file().split(separator: "/")
        let line = record.get_line()
        let args = record.get_args()
        if(fileArr.last != "lib.rs" && line != 520){
            NSLog("Velas/LDK/log: file: \(fileArr[7...].joined(separator: "/"))")
            NSLog("Velas/LDK/log: line: \(line)")
            NSLog("Velas/LDK/log: args: \(args)")
        }
        
       
        //NSLog("LDK/log: \(record.get_args())")
    }
    
}
