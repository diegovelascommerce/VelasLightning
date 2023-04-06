import Foundation
import BitcoinDevKit

public enum VelasError: Error {
    case Electrum(msg:String)
    case Error(msg:String)
}

/// Main Class that projects will use to interact with Bitcoin and Lightning
public class Velas {
    
    public static var shared:Velas?
    
    public static func Login(url:String, username:String, password:String){
        do {
            try LAPP.Login(url: url, username: username, password: password)
            
            if Velas.Check() {
                Velas.Load()
                let connected = Velas.Connect()
                print("velas connected: \(connected)")
            }
        }
        catch LAPPError.Error(let msg){
            NSLog("LAPPError: \(msg)")
        }
        catch {
            NSLog("Velas: \(error)")
        }
    }
    
    // check if velas object has already been created
    public static func Check() -> Bool {
        let mnemonic = FileMgr.fileExists(path: "mnemonic")
        return mnemonic
    }
    
    /// load velas
    public static func Load() {
        do {
            if FileMgr.fileExists(path: "key") {
                let mnemonicData = try FileMgr.readData(path: "mnemonic")
                let key = try FileMgr.readString(path: "key")
                if let mnemonic = Cryptography.decrypt(encryptedData: mnemonicData, key: key) {
                    print("read mnemonic: \(mnemonic)")
                    shared = try Velas(mnemonic: mnemonic)
                }
            }
            else {
                let mnemonic = try FileMgr.readString(path: "mnemonic")
                shared = try Velas(mnemonic: mnemonic)
            }
            
        }
        catch VelasError.Electrum(let msg){
            NSLog("problem with Electrum: \(msg)")
        }
        catch VelasError.Error(let msg){
            NSLog("problem with Velas: \(msg)")
        }
        catch LAPPError.JSONDecoder(let msg) {
            NSLog("problem with JSONDecoder: \(msg)")
        }
        catch LAPPError.Error(let msg) {
            NSLog("problem with lapp: \(msg)")
        }
        catch {
            NSLog("velas error: \(error)")
        }
    }
    
    /// setup velas
    public static func Setup() {
        do {
            shared = try Velas()
            if let velas = shared {
                let mnemonic = velas.getMnemonic()
                print("create new mnemonic: \(mnemonic)")
                if let (cipherData, key) = Cryptography.encrypt(message: mnemonic) {
                    try FileMgr.writeString(string: key, path: "key")
                    try FileMgr.writeData(data: cipherData, path: "mnemonic")
                }
            }
        }
        catch VelasError.Electrum(let msg){
            NSLog("problem with Electrum: \(msg)")
        }
        catch VelasError.Error(let msg){
            NSLog("problem with Velas: \(msg)")
        }
        catch LAPPError.JSONDecoder(let msg) {
            NSLog("problem with JSONDecoder: \(msg)")
        }
        catch LAPPError.Error(let msg) {
            NSLog("problem with lapp: \(msg)")
        }
        catch {
            NSLog("velas error: \(error)")
        }
    }
    
    public static func Connect() -> Bool {
        do {
            if let velas = shared {
                if let nodeInfo = LAPP.NodeId {
                    let connected = try velas.connectToPeer(nodeId: nodeInfo.node_id!, address: nodeInfo.public_url!, port: 9735)
                    return connected
                }
                if let info = LAPP.Info {
                    let connected = try velas.connectToPeer(nodeId: info.identity_pubkey, address: info.urls.publicIP, port: 9735)
                    return connected
                }
            }
        }
        catch VelasError.Electrum(let msg){
            NSLog("problem with Electrum: \(msg)")
        }
        catch VelasError.Error(let msg){
            NSLog("problem with Velas: \(msg)")
        }
        catch LAPPError.JSONDecoder(let msg) {
            NSLog("problem with JSONDecoder: \(msg)")
        }
        catch LAPPError.Error(let msg) {
            NSLog("problem with lapp: \(msg)")
        }
        catch {
            NSLog("velas error: \(error)")
        }
        return false
    }
    
    public static func Peers() -> [String] {
        do {
            if let velas = shared {
                let num = try velas.ln.listPeers()
                return num
            }
        }
        catch {
            NSLog("velas no peers")
        }
        return []
    }
    
    public static func Sync() -> Bool {
        do {
            if let velas = shared {
                try velas.sync()
                return true
            }
        }
        catch {
            NSLog("velas could not sync")
        }
        return false
    }
    
    /// Make a request to LAPP to create a channel
    public static func OpenChannel(amt:Int, target_conf:Int=1, min_confs:Int=1) -> OpenChannelResponse? {
        if let velas = shared {
            do {
                if try velas.listPeers().count > 0 {
                    if let lapp = LAPP.shared {
                        let res = try lapp.openChannel(nodeId: velas.getNodeId(), amt: amt, target_conf:target_conf, min_confs:min_confs, privChan: true)
                        
                        if let res = res {
                            return res
                        }
                        else {
                            return nil
                        }
                    }
                }
            }
            catch {
                NSLog("velas: problem with getting peers")
            }
        }
        return nil
    }
    
    public static func ListChannels(usable:Bool=false) -> [[String:Any]]{
        if let velas = shared {
            do {
                if usable == true {
                    let channels = try velas.listUsableChannelsDict()
                    return channels
                }
                else {
                    let channels = try velas.listChannelsDict()
                    return channels
                }
            }
            catch {
                NSLog("problem with listing channels: \(error)")
            }
        }
        return []
    }
    /// Create a bolt11 and make request to LAPP to pay it.
    public static func PaymentRequest(amt:Int, description:String) -> (String,PayInvoicResponse?) {
        if let velas = shared {
            do {
                let channels = try velas.listUsableChannelsDict()
                if channels.count > 0 {
                    let amtMsat = amt * 1000
                    let bolt11 = try velas.createInvoice(
                        amtMsat: amtMsat,
                        description: description)
                    
//                    return (bolt11, nil)
                    
                    let res = LAPP.PayInvoice(bolt11: bolt11)

                    return (bolt11, res)
//                    if let res = LAPP.PayInvoice(bolt11: bolt11) {
////                        return (bolt11, res.payment_error.isEmpty && !res.payment_hash.isEmpty)
//                        return (bolt11, res)
//                    }
//                    else {
//                        return (bolt11, nil)
//                    }
                }
            }
            catch {
                NSLog("velas: \(error)")
            }
        }
        return ("", nil)
    }
    
    public static func CloseChannels(force:Bool = false) -> Bool {
        do {
            if let velas = shared {
                if force {
                    try velas.closeChannelsCooperatively()
                    return true
                } else {
                    try velas.closeChannelsCooperatively()
                    return true
                }
            }
        }
        catch {
            print("velas: could not close channels")
        }
        return false
    }
    
    
    private var btc:Bitcoin!
    public var ln:Lightning!
    
    
    
    /// Initialize Bitcoin and Lightning
    public init(network: Network = Network.testnet,
                mnemonic: String? = nil) throws {
        do {
            btc = try Bitcoin(network: network, mnemonic: mnemonic)
            try btc.sync()
            ln = try Lightning(btc:btc)
        }
        catch BdkError.Electrum(let message) {
            throw VelasError.Electrum(msg: message)
        }
        catch {
            throw VelasError.Error(msg: "\(error)")
        }
    }
    
    public func sync() throws {
        try ln.sync()
    }
    
    /// get the mnemonic that creates the bitcoin wallet and private keys for signing
    public func getMnemonic() -> String {
        return btc.mnemonic
    }
    
    /// return information about this lightning node
    public func getNodeInformation() throws -> (nodeID:String, address:String, port:String) {
        let nodeID = try getNodeId()
        let address = Utils.getPublicIPAddress()
        let port = String(ln.port)
        return (nodeID,address!,port)
    }
    
    
    /// Create a bolt11 invoice
    ///
    /// params:
    ///   amt: amount in milisatoshis
    ///   description: text for description field of invoice
    /// return:
    ///   A bolt11 string of the invoice just created
    public func createInvoice(amtMsat: Int, description: String) throws -> String {
        let res = try ln.createInvoice(amtMsat: amtMsat, description: description)
        return res
    }
    
    
    /// Pay invoice.
    ///
    /// params:
    ///     bolt11:  the bolt11 invoice you want to pay
    ///
    /// return:
    ///     true if payment went through
    public func payInvoice(bolt11: String) throws -> PayInvoiceResult? {
        let res = try ln.payInvoice(bolt11:bolt11)
        return res
    }
    
    
    /// Gets the lightning node ID of this machine.
    public func getNodeId() throws -> String {
        return try ln.getNodeId()
    }
    
    /// bind our node to listen for peer requests
    public func bindNode() throws -> Bool {
        return try ln.bindNode()
    }
    
    /// Connect to a lightning peer
    ///
    /// params:
    ///     nodeId: lightning nodeId
    ///     address: IP address of lightning node
    ///     port: port number to lighting node
    ///
    /// return:
    ///     true is succeded
    public func connectToPeer(nodeId: String, address: String, port: NSNumber) throws -> Bool {
        return try ln.connect(nodeId: nodeId, address: address, port: port)
    }
    
    /// List all the peers that we are connected to.
    ///
    /// return:
    ///     array of peers
    public func listPeers() throws -> [String] {
        return try ln.listPeers()
    }
    
    /// Get all the channels that this node is setup for.
    ///
    /// return:
    ///     list of channels
    public func listChannelsDict() throws -> [[String:Any]] {
        let res = try ln.listChannelsDict()
        return res
    }
    
    /// Get all the channels that this node is setup for.
    ///
    /// return:
    ///     list of channels
    public func listUsableChannelsDict() throws -> [[String:Any]] {
        let res = try ln.listUsableChannelsDict()
        return res
    }
    
    /// Get the local and public IP addresses of this node
    ///
    /// return:
    ///     return the local and public IP of this node
    public func getIPAddresses() -> (String?, String?) {
        let local = Utils.getLocalIPAdress()
        let pub = Utils.getPublicIPAddress()
        
        return (local, pub)
    }
    
    /// close channels cooperatively, the good way
    public func closeChannelsCooperatively() throws {
        try ln.closeChannelsCooperatively()
    }
    
    /// close channels forcfuly, the bad way
    public func closeChannelsForcefully() throws {
        try ln.closeChannelsForcefully()
    }
}


