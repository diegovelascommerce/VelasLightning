import Foundation
import BitcoinDevKit

/// Main Class that projects will use to interact with Bitcoin and Lightning
public class Velas {
    
    private var btc:Bitcoin!
    private var ln:Lightning!
    
    /// Initialize Bitcoin and Lightning
    public init(network: Network = Network.testnet,
                mnemonic: String? = nil,
                getChannels: Optional<() -> [Data]> = nil,
                backUpChannel: Optional<(Data) -> ()> = nil,
                getChannelManager: Optional<() -> Data> = nil,
                backUpChannelManager: Optional<(Data) -> ()> = nil) throws {
        btc = try Bitcoin(network: network, mnemonic: mnemonic)
        try btc.sync()
        ln = try Lightning(btc:btc,
                           backUpChannel:backUpChannel,
                           backUpChannelManager:backUpChannelManager)
    }
    
    public func getMnemonic() -> String {
        return btc.mnemonic
    }
    
    public func getNodeInformation() throws -> (nodeID:String, address:String, port:String) {
        let nodeID = try getNodeId()
        let address = Utils.getPublicIPAddress()
        let port = String(ln.port)
        return (nodeID,address!,port)
    }
    
    /// Close your channel this nice way.
    ///
    /// throws:
    ///     NSError
//    public func closeChannel() throws -> Bool {
//        return try ln.closeChannelCooperatively()
//    }
    
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
    ///     amtMsat: amount you want to pay in milisats
    ///
    /// throws:
    ///     NSError
    ///
    /// return:
    ///     true if payment went through
    public func payInvoice(bolt11: String, amtMsat: Int) throws -> Bool {
        let res = try ln.payInvoice(bolt11:bolt11, amtMSat:amtMsat)
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
    public func listPeers() throws -> String {
        return try ln.listPeers()
    }
    
    /// Get all the channels that this node is setup for.
    ///
    /// return:
    ///     list of peers
    public func listChannels() throws -> String {
        let res = try ln.listChannels()
        return res
    }
    
    /// Get the local and public IP addresses of this node
    ///
    /// return:
    ///     return the local and public IP of this node
    public func getIPAddresses() -> (String?, String?) {
        let local = Utils.getLocalIPAdress()
        let pub = Utils.getPublicIPAddress()
        if let local = local, let pub = pub {
            print("local IP Address: \(local)")
            print("public IP Address: \(pub)")
        }
        
        return (local, pub)
    }
    
    public func closeChannelsCooperatively() throws {
        try ln.closeChannelsCooperatively()
    }
    
    public func closeChannelsForcefully() throws {
        try ln.closeChannelsForcefully()
    }
}
