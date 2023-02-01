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
    private var lapp:LAPP!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lapp = LAPP(baseUrl: "https://45.33.22.210",
                         jwt: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ2ZWxhcyIsInN1YiI6IndvcmtpdCJ9.CnksMqUsywjH4W8JgPePodi10pO_xJMrPyq9c19tQmo");
        let (_, pub) = velas.getIPAddresses()
        hostLable.text = pub!
        hostLable.sizeToFit()
        hostLable.center.x = self.view.center.x
        
        do {
            let nodeId = try velas.getNodeId()
            nodeIdTextView.text = nodeId

        }
        catch {
            NSLog("there was a problem getting the node id \(error)")
        }
        


    }
    
    @IBAction func connectClick(_ sender: Any) {
        print("connect to a peer")
        
        let res = self.lapp.getinfo()
        
//        let nodeId = "029cba2eb9edf18352e90f1a5f71e367af80d6e3ab7a5aa6122309fcbcd4375735"
        let nodeId = res!.identity_pubkey

//        let address = "192.168.0.10"
        let address = res!.urls.publicIP
        
        let port = NSNumber(9735)
        
        do {
            let res = try velas.connectToPeer(nodeId: nodeId, address: address, port: port)
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

