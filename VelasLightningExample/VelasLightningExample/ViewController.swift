//
//  ViewController.swift
//  VelasLightningExample
//
//  Created by Diego vila on 10/25/22.
//

import UIKit
import VelasLightningFramework

class ViewController: UIViewController {

    
    
    var ip:String!
    var jwt:String!
    var port:NSNumber!
    var nodeId:String!
    var publicUrl:Bool!
    
    private var lapp:LAPP!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let (_, pub) = velas.getIPAddresses()
       
        let plist = getPlist()
        
        self.ip = plist["ip"] as? String
        self.jwt = plist["jwt"] as? String
        self.port = plist["port"] as? NSNumber
        self.publicUrl = plist["public_url"] as? Bool
        
        
        self.lapp = LAPP(baseUrl: "https://\(String(describing: self.ip!))",
                         jwt: self.jwt);
        
        do {
            self.nodeId = try velas.getNodeId()
            print("nodeId: \(self.nodeId!)")
        }
        catch {
            NSLog("there was a problem getting the node id \(error)")
        }
    }
    
    func alert(title:String, message:String, onAction: ((UIAlertAction)->())? = nil) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let onAction = onAction {
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: onAction))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        } else {
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
        }
        
        
        self.present(alertController, animated: true, completion: nil)
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
                if let res = res {
                    print("payInvoice: success(\(res))")
//                    self.alert(title: "payInvoice", message: "success(\(res))")
                }
            }
            catch {
                print("payInvoice: error(\(error))")
//                self.alert(title: "payInvoice", message: "error(\(error))")
            }
        }))

        self.present(alert, animated: true, completion: nil)
    }
    
    func getPlist() -> NSDictionary {
        let path = Bundle.main.path(forResource: "Velas", ofType:"plist")!
        let dict = NSDictionary(contentsOfFile: path)

        return dict!
    }
    
    @IBAction func connectClick(_ sender: Any) {
        print("connect to a peer")

        do {
            let info = self.lapp.getinfo()
            let nodeId = info?.identity_pubkey
//            var url:String?
//            if(self.publicUrl){
//                url = info?.urls.publicIP
//            }
//            else {
//                url = info?.urls.localIP
//            }
            let res = try velas.connectToPeer(nodeId: nodeId!, address: self.ip, port: self.port)
            print("connect: \(res)")
            alert(title: "Peer Connect", message: "\(res)")
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
            alert(title: "Peer List", message: "\(res)")
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
                    self.alert(title: "Create Channel", message: "channel: \(res)")
                }
                else {
                    print("there was a problem creating a channel")
                }
            }
            else {
                self.alert(title: "Create Channel", message: "No peers were connected")
            }
            
        }
        catch {
            NSLog("problem with showPeerList \(error)")
        }
    }
    
    @IBAction func listChannels(_ sender: Any) {
        do {
            let channels = try velas.listChannelsDict()
            print("channels: \(channels)")
            self.alert(title: "List All Channels", message: "channels: \(channels)")
        }
        catch {
            NSLog("problem with listing channels: \(error)")
        }
    }
    
    @IBAction func listChannelsUsable(_ sender: Any) {
        do {
            let channels = try velas.listUsableChannelsDict()
            print("channels: \(channels)")
            self.alert(title: "List Usable Channels", message: "channels: \(channels)")
        }
        catch {
            NSLog("problem with listing channels: \(error)")
        }
    }
    
    @IBAction func submitBolt11(_ sender: Any) {
        do {
            let peers = try velas.listPeers()
            
            if(peers.count > 0){
                let channels = try velas.listChannelsDict()
                var ready = false
                
                // check to see if any of the channel are ready to receive payments
                for channel in channels {
                    if channel["is_usable"] as! String == "true" && channel["is_channel_ready"] as! String == "true" {
                        ready = true
                    }
                }
                
                // if there are create a bolt11 and submit it
                if(ready){
                    let bolt11 = try velas.createInvoice(amtMsat: 500000, description: "this s a test from velas lighting")
                    print("bolt11: \(bolt11)")
                    self.alert(title: "bolt11", message: bolt11){(action) -> Void in
                        let res = self.lapp.payInvoice(bolt11: bolt11)
                        self.alert(title: "Payment Claimed", message: "\(res!)")
                    }
//                    let res = lapp.payInvoice(bolt11: bolt11)
                    
//                    print(res!)
//                    self.alert(title: "Submit bolt11", message: "\(res!)")
                } else {
                    self.alert(title: "Submit bolt11", message: "None of the channels are ready")
                }

            }
            else {
                self.alert(title: "Submit bolt11", message: "No peers were connected")
            }
        }
        catch {
            NSLog("problem with listing channels: \(error)")
        }
    }
    
    @IBAction func createBolt11(_ sender: Any) {
        do {
            let bolt11 = try velas.createInvoice(amtMsat: 500000, description: "this s a test from velas lighting")
            print("bolt11: \(bolt11)")
        }
        catch {
            NSLog("problem creating bolt11 invoice: \(error)")
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
    
}

