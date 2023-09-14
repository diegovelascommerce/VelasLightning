import Foundation
import BitcoinDevKit


/// Errors that the Velas object can throw
public enum VelasError: Error {
    case Electrum(msg:String)
    case Error(msg:String)
}

/// Main Class that projects will use to interact with Bitcoin and Lightning
public class Velas {
    
    // shared static object that can be accessed globaly
    public static var shared:Velas?
    
    public var publicURL: Bool
    
    /// Login to Workit backend and load the global Velas object if available.
    ///
    /// params
    ///     url: url to the workit backend
    ///     username: username to workit account
    ///     password: password to workit account
    public static func Login(url:String, username:String?=nil, password:String?=nil, jwt:String?=nil){
        do {
            // login to workit backend
            try LAPP.Login(url: url, username: username, password: password, jwt: jwt)
            
            // check if a velas object is ready to be load
            if Velas.Check() {
                // load a previouly created velas object
                Velas.Load()
                
                // connect to the workit server
                let connected = Velas.Connect(workit: true)
                
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
    public static func Load(plist:String?=nil) {
        do {
            var verbose = false
            var publicURL = false
            
            if let plist = plist {
                let plist = FileMgr.getPlist(plist)
                verbose = plist["verbose"] as! Bool
                publicURL = plist["public_url"] as! Bool
            }
            if FileMgr.fileExists(path: "key") {
                let mnemonicData = try FileMgr.readData(path: "mnemonic")
                let key = try FileMgr.readString(path: "key")
                if let mnemonic = Cryptography.decrypt(encryptedData: mnemonicData, key: key) {
                    print("read mnemonic: \(mnemonic)")
                    shared = try Velas(mnemonic: mnemonic, verbose: verbose, publicURL: publicURL)
                }
            }
            else {
                let mnemonic = try FileMgr.readString(path: "mnemonic")
                shared = try Velas(mnemonic: mnemonic, verbose: verbose, publicURL: publicURL)
            }
            if let plist {
                try LAPP.Setup(plist: plist)
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
    public static func Setup(plist:String?=nil) {
        do {
            if let plist = plist {
                let plist = FileMgr.getPlist(plist)
                let verbose = plist["verbose"] as! Bool
                let publicURL = plist["public_url"] as! Bool
                shared = try Velas(verbose:verbose, publicURL: publicURL)
            }
            else {
                shared = try Velas()
            }
           
            
            if let velas = shared {
                let mnemonic = velas.getMnemonic()
                print("create new mnemonic: \(mnemonic)")
                if let (cipherData, key) = Cryptography.encrypt(message: mnemonic) {
                    try FileMgr.writeString(string: key, path: "key")
                    try FileMgr.writeData(data: cipherData, path: "mnemonic")
                }
            }
            if let plist = plist {
                try LAPP.Setup(plist: plist)
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
    
    /// connect to a lighting node
    public static func Connect(workit:Bool=false) -> Bool {
        if Velas.Connected() {
            return true
        }
        else {
            do {
                if let velas = shared {
                    if(workit){
                        if let nodeInfo = LAPP.NodeId {
                            let connected = try velas.connectToPeer(nodeId: nodeInfo.node_id!, address: nodeInfo.public_url!, port: 9735)
                            return connected
                        }
                    }
                    else {
                        if let info = LAPP.Info {
                            let address = velas.publicURL ? info.urls.publicIP : info.urls.localIP
                            let connected = try velas.connectToPeer(nodeId: info.identity_pubkey, address: address, port: 9735)
                            return connected
                        }
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
        
        return false
    }
    
    /// check to see if Velas is connected to another lightning node
    public static func Connected() -> Bool {
        if let velas = Velas.shared {
            do {
                if try velas.listPeers().count > 0 {
                    return true
                }
                else {
                    return false
                }
            }
            catch {
                print("problem connected")
            }
        }
        return false
    }
    
    /// List the peers that Velas is connected to.
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
    
    /// Sync the lightingin node
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
    
    /// Make a request through the Workit backend to create a channel
    public static func OpenChannelWorkit(amt:Int, userId:Int) -> OpenChannelWorkitResponse? {
        
        if let velas = shared, let lapp = LAPP.shared {
            do {
                let res = try lapp.openChannelWorkit(nodeId: velas.getNodeId(), amt: amt, userId: userId)

                if let res = res {
                    return res
                }
                else {
                    return nil
                }
            }
            catch {
                NSLog("velas: problem with getting peers")
            }
        }
        return nil
    }
    
    /// List channels that are associated with velas
    public static func ListChannels(usable:Bool=false, lapp:Bool=false, workit:Bool=false) -> [[String:Any]] {
        
        if let velas = shared {
            do {
                if lapp {
                    let peer = try velas.getNodeId()
                    let channels = velas.listChannelsLapp(peer:peer)
                    return channels
                }
                else if workit {
                    let peer = try velas.getNodeId()
                    let channels = velas.listChannelsWorkit(peer:peer)
                    return channels
                }
                else {
                    if usable == true {
                        let channels = try velas.listUsableChannelsDict()
                        return channels
                    }
                    else {
                        let channels = try velas.listChannelsDict()
                        return channels
                    }
                }
            }
            catch {
                NSLog("problem with listing channels: \(error)")
            }
        }
        return []
    }
    
    /// Create a bolt11 and make request to LAPP to pay it.
    public static func PaymentRequest(amt:Int, description:String, workit:Bool=false, userId:Int?=nil) -> (String,PayInvoicResponse?) {
        if let velas = shared {
            do {
                // must have at least one usable channel
                let channels = try velas.listUsableChannelsDict()
                if channels.count > 0 {
                    
                    // create a bolt11
                    let amtMsat = amt * 1000
                    let bolt11 = try velas.createInvoice(
                        amtMsat: amtMsat,
                        description: description)
                    
                    // make a request to pay this invoice
                    let res = LAPP.PayInvoice(bolt11: bolt11, workit:workit, userId: userId)
                    
                    return (bolt11, res)
                }
            }
            catch {
                NSLog("velas: \(error)")
            }
        }
        return ("", nil)
    }
    
    public func channelsAvailable() throws -> Bool {
        let channels = try listUsableChannelsDict()
        if channels.count > 0 {
            return true
        }
        return false
    }
    
    /// Create a bolt11 invoice
    public static func CreateInvoice(amt:Int, description:String) -> String? {
        if let velas = shared {
            do {
                let available = try velas.channelsAvailable()
                if available {
                    let bolt11 = try velas.createInvoice(
                        amtMsat: amt * 1000,
                        description: description)
                    return bolt11;
                }
                return nil
            }
            catch {
                NSLog("velas: \(error)")
            }
        }
        return nil
    }
    
    public static func CloseChannels(force:Bool = false) -> Bool {
        do {
            if let velas = shared {
                if force {
                    try velas.closeChannelsForcefully()
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
                mnemonic: String? = nil, verbose: Bool = false, publicURL: Bool = true) throws {
        do {
            self.publicURL = publicURL
            btc = try Bitcoin(network: network, mnemonic: mnemonic)
            try btc.sync()
            ln = try Lightning(btc:btc,verbose: verbose)
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
    
    /// Create a bolt11 and make request to LAPP to pay it.
    public static func PayInvoice(_ bolt11:String) -> PayInvoiceResult? {
        if let velas = shared {
            do {
                let res = try velas.ln.payInvoice(bolt11:bolt11)
                return res
            }
            catch {
                NSLog("velas: \(error)")
            }
        }
        return nil
    }
    
    /// find route
    public static func FindFee(bolt11: String) -> UInt64 {
        if let velas = shared {
            do {
                let fee = try velas.ln.findFee(bolt11: bolt11)
                return fee
            }
            catch {
                NSLog("velas: \(error)")
            }
        }
        return 0;
    }
    
    /// show balance of  channel
    public static func GetBalance() -> (UInt64, UInt64) {
        if let velas = shared {
            do {
                let res = try velas.ln.getBalance()
                return res
            }
            catch {
                NSLog("velas: \(error)")
            }
        }
        
        return (0, 0)
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
    
    public func listChannelsLapp(peer:String) -> [[String:Any]] {
        let res = LAPP.ListChannels(peer:peer)
        return res
    }
    
    public func listChannelsWorkit(peer:String) -> [[String:Any]] {
        let res = LAPP.ListChannels(peer:peer, workIt:true)
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
    
    
    public func getBalance() throws -> (UInt64, UInt64) {
        try ln.getBalance()
    }
}


