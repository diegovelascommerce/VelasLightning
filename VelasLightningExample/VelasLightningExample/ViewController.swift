//
//  ViewController.swift
//  VelasLightningExample
//
//  Created by Diego vila on 10/25/22.
//

import UIKit
import VelasLightningFramework

class ViewController: UIViewController {

    @IBOutlet weak var hostLable: UILabel!
    @IBOutlet weak var nodeIdTextView: UITextView!
    var nodeId:String!
    var bolt11:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let (_, pub) = velas.getIPAddresses()
        hostLable.text = pub!
        hostLable.sizeToFit()
        hostLable.center.x = self.view.center.x
        
        do {
            nodeId = try velas.getNodeId()
            nodeIdTextView.text = nodeId

        }
        catch {
            NSLog("there was a problem getting the node id \(error)")
        }
    }
    
    @IBAction func connectClick(_ sender: Any) {
        print("connect to a peer")
        
        let info = lapp.getinfo()
        
        do {
            let res = try velas.connectToPeer(nodeId: info!.identity_pubkey,
                                              address: velas_plist["grpc_ip"] as! String,
                                              port: NSNumber(9735))
            print("connect: \(res)")
            
            if(res){
                let alert = UIAlertController(title: "Connected", message: "you are now connected to \(info!.identity_pubkey)@\(velas_plist["grpc_ip"] as! String)", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Close", style: .cancel))

                self.present(alert, animated: true, completion: nil)
            }
        }
        catch {
            NSLog("there was a problem: \(error)")
        }
        
        
    }
    
    @IBAction func showPeerList(_ sender: Any) {
        print("show peer list")
        do {
            let res = try velas.listPeers()
            print("peers: \(res)")
            if(res.count > 0){
                let alert = UIAlertController(title: "Peers", message: "peers: \(res)", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Close", style: .cancel))

                self.present(alert, animated: true, completion: nil)
            }
        }
        catch {
            NSLog("problem with showPeerList \(error)")
        }

    }
    
    @IBAction func openChannel(_ sender: Any) {
        do {
            let peers = try velas.listPeers()
            
            if(peers.count > 0){
                let res = lapp.openChannel(nodeId: self.nodeId, amt: 20000, target_conf:1, min_confs:1)
                
                if let res = res {
                    print(res)
                    
                    let alert = UIAlertController(title: "Channel", message: "channel: \(res)", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Close", style: .cancel))

                    self.present(alert, animated: true, completion: nil)
                   
                }
                else {
                    print("there was a problem creating a channel")
                }
            }
            else {
                let alert = UIAlertController(title: "Channel", message: "peer not connected", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Close", style: .cancel))

                self.present(alert, animated: true, completion: nil)
            }
            
        }
        catch {
            NSLog("problem with showPeerList \(error)")
        }
    }
    
    @IBAction func listChannels(_ sender: Any) {
        do {
            let channels = try velas.listChannels()
            var res = ""
            for channel in channels {
                res.append("channel: \(channel.remote_node_id)@ \(channel.funding_txo_txid):\(channel.funding_txo_index)\n")
            }
            print("channels: \(res)")
            
            let alert = UIAlertController(title: "Channels", message: "\(res)", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Close", style: .cancel))

            self.present(alert, animated: true, completion: nil)
        }
        catch {
            NSLog("problem with listing channels: \(error)")
        }
    }
    
    @IBAction func createBolt11(_ sender: Any) {
        do {
            bolt11 = try velas.createInvoice(amtMsat: 500000, description: "this s a test from velas lighting")
            
            print("bolt11: \(bolt11 ?? "nothing")")
        }
        catch {
            NSLog("problem creating bolt11 invoice: \(error)")
        }
        
        let alert = UIAlertController(title: "bolt11", message: bolt11, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))

        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func submitBolt11(_ sender: Any) {
        
        do {
            let peers = try velas.listPeers()
            let channels = try velas.listChannels()
            var ready = true
            for channel in channels {
                if channel.is_usable == false || channel.is_channel_ready == false {
                    ready = false
                }
            }
            if(ready && peers.count > 0){
                
                let res = lapp.payInvoice(bolt11: bolt11)
                
                print(res!)
                
                let alert = UIAlertController(title: "submit bolt11", message: "response:\(res!) submited", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Close", style: .cancel))

                self.present(alert, animated: true, completion: nil)
                
            }
            else {
                let message:String = peers.count == 0 ? "peer not connected" : "channels are not ready yet"
                let alert = UIAlertController(title: "submit bolt11", message: message, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Close", style: .cancel))

                self.present(alert, animated: true, completion: nil)
            }
        }
        catch {
            NSLog("problem with listing channels: \(error)")
        }
    }
    
    
    @IBAction func closeChannelCooperatively(_ sender: Any) {
        do {
            try velas.closeChannelsCooperatively()
        } catch {
            NSLog("problem clossing channels cooperatively: \(error)")
        }
    }
    
    @IBAction func closeChannelForcefully(_ sender: Any) {
        do {
            try velas.closeChannelsForcefully()
        } catch {
            NSLog("problem clossing channels forcefuly: \(error)")
        }
    }
    
    @IBAction func payInvoiceClick(_ sender: Any) {
            
        let alert = UIAlertController(title: "bolt11", message: "Please enter bolt11", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "enter bolt11"
        }

        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak alert] (_) in
            guard let textField = alert?.textFields?[0], let bolt11 = textField.text else { return }
            
            // pay invoice
            print("bolt11: \(bolt11)")
            
            do {
                let res = try velas.payInvoice(bolt11: bolt11)
                print("payment went through: \(res)")
            }
            catch {
                print("problem paying invoice: \(error)")
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        self.present(alert, animated: true, completion: nil)
    }
    
}

