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
        
        let res = lapp.getinfo()
        
        do {
            let res = try velas.connectToPeer(nodeId: res!.identity_pubkey,
                                              address: velas_plist["grpc_ip"] as! String,
                                              port: NSNumber(9735))
            print("connect: \(res)")
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
        }
        catch {
            NSLog("problem with showPeerList \(error)")
        }

    }
    
    @IBAction func openChannel(_ sender: Any) {
    
        let res = lapp.openChannel(nodeId: self.nodeId, amt: 20000)
        
        if let res = res {
            print(res)
        }
        else {
            print("there was a problem creating a channel")
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

