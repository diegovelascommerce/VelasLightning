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
    let block_height: Int32
    let pos: Int32
}

public class Esplora {
    public static func getTxStatus(txid:String, network: Network) -> Transaction? {
        let url = network == Network.testnet ?
            "https://blockstream.info/testnet/api/tx/\(txid)/status":
            "https://blockstream.info/api/tx/\(txid)/status";
        
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
}
