//
//  Esplora.swift
//  VelasLightningFramework
//
//  Created by Diego vila on 12/8/22.
//

import Foundation

import BitcoinDevKit

public struct Transaction: Codable {
    let confirmed: Bool
    let block_height: Int32
    let block_hash: String
}

public struct MerkleProof: Codable {
    // height of block that transaction belongs to
    let block_height: Int32
    
    // position of transaction in block
    let pos: Int32
    
    // string of hashes that you can use to prove the merkel root
    let merkle: [String]
}

public class Esplora {
    
    /// get transaction data from blockstream
    public static func getTxStatus(txid:String, network: Network) -> Transaction? {
        let url = network == Network.testnet ?
            "https://blockstream.info/testnet/api/tx/\(txid)/status":
            "https://blockstream.info/api/tx/\(txid)/status";
        
        print("getTxStatus: \(url)\n")
        
        let data = Request.get(url: url)
        var res:Transaction?
        do {
            res = try JSONDecoder().decode(Transaction.self, from: data!)
        }
        catch {
            print(error)
            return nil
        }
        
        return res
    }
    
    public static func getTxMerkleProof(txid:String, network: Network) -> MerkleProof? {
        let url = network == Network.testnet ?
            "https://blockstream.info/testnet/api/tx/\(txid)/merkle-proof":
            "https://blockstream.info/api/tx/\(txid)/merkle-proof";
        
        let data = Request.get(url: url)
        var res:MerkleProof?
        do {
            res = try JSONDecoder().decode(MerkleProof.self, from: data!)
        }
        catch {
            print(error)
            return nil
        }
        
        return res
    }
    
    public static func getTxHex(txid:String, network: Network) -> String? {
        let url = network == Network.testnet ?
            "https://blockstream.info/testnet/api/tx/\(txid)/hex":
            "https://blockstream.info/api/tx/\(txid)/hex";
        
        let data = Request.get(url: url)
        
        let res = String(decoding: data!, as: UTF8.self)
        
        return res
    }
    
    // get raw transaction data from blockstream
    public static func getTxRaw(txid:String, network: Network) -> Data? {
        let url = network == Network.testnet ?
            "https://blockstream.info/testnet/api/tx/\(txid)/raw":
            "https://blockstream.info/api/tx/\(txid)/raw";
        
        let data = Request.get(url: url)
        
        return data
    }
    
    /// post transaction
    public static func postTx(txHex:String, network: Network) throws -> String? {
        let url = network == Network.testnet ?
            "https://blockstream.info/testnet/api/tx":
            "https://blockstream.info/api/tx";
                
        let res = try Request.post(url:url, body:txHex)
        
        let txId = String(decoding: res!, as: UTF8.self)
        
        return txId
    }
    
    public static func getBlockHeader(hash:String, network: Network) -> String? {
        let url = network == Network.testnet ?
            "https://blockstream.info/testnet/api/block/\(hash)/header":
            "https://blockstream.info/api/block/\(hash)/header";
        
        let data = Request.get(url: url)
        if let data = data {
            let res = String(decoding: data, as: UTF8.self)
            return res
        }
        
        return nil
    }
    
    public static func getTipHeight(network: Network) -> Int32? {
        let url = network == Network.testnet ?
            "https://blockstream.info/testnet/api/blocks/tip/height":
            "https://blockstream.info/api/blocks/tip/height";
        
        let data = Request.get(url: url)
        
        let text = String(decoding: data!, as: UTF8.self)
        
        let res = Int32(text)
        
        return res
    }
    
    public static func getTipHash(network: Network) -> String? {
        let url = network == Network.testnet ?
            "https://blockstream.info/testnet/api/blocks/tip/hash":
            "https://blockstream.info/api/blocks/tip/hash";
        
        let data = Request.get(url: url)
        
        let res = String(decoding: data!, as: UTF8.self)
        
        return res
    }
}
