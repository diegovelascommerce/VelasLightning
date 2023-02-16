//
//  ViewController.swift
//  VelasLightningExample
//
//  Created by Diego vila on 10/25/22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var hostLable: UILabel!
    @IBOutlet weak var nodeIdTextView: UITextView!
    
    var peer: String!
    var address: String!
    var port: NSNumber!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let (_, pub) = velas.getIPAddresses()
        hostLable.text = pub!
        hostLable.sizeToFit()
        hostLable.center.x = self.view.center.x
        
        let plist = getPlist()
        self.peer = plist["peer"] as? String
        self.address = plist["address"] as? String
        self.port = NSNumber(value: Int(plist["port"] as! String)!)
        
        do {
            let nodeId = try velas.getNodeId()
            nodeIdTextView.text = nodeId
        }
        catch {
            NSLog("there was a problem getting the node id \(error)")
        }
    }
    
    func alert(title:String, message:String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        
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
                print("payment went through: \(res)")
            }
            catch {
                print("problem paying invoice: \(error)")
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
            let res = try velas.connectToPeer(nodeId: self.peer, address: self.address, port: self.port)
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
    
    @IBAction func listChannels(_ sender: Any) {
        do {
            let channels = try velas.listChannels()
            print("channels: \(channels)")
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

