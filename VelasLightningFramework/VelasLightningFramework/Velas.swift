import Foundation
import BitcoinDevKit

public enum VelasError: Error {
    case Electrum(msg:String)
    case Error(msg:String)
}

/// Main Class that projects will use to interact with Bitcoin and Lightning
public class Velas {
    
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


