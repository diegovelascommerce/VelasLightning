
import LightningDevKit

/// What is it used for:  logging the LDK
class MyLogger: Logger {
    
    override func log(record: Record) {
        let block = [
            ("lib.rs", 520),
            ("peer_handler.rs", 979),
            ("peer_handler.rs", 1282)
        ]
        let fileArr = record.get_file().split(separator: "/")
        let line = record.get_line()
        let args = record.get_args()
        
        if !block.contains(where: { $0.0 == fileArr.last! && $0.1 == line }) {
            print("Velas/Lightning/log: file: \(fileArr[7...].joined(separator: "/"))")
            print("Velas/Lightning/log: line: \(line)")
            print("Velas/Lightning/log: message: \(args)")
        }
    }
    
}
