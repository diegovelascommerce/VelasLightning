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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
//        let nodeId = "03e347d089c071c27680e26299223e80a740cf3e3fc4b4237fa219bb67121a670b"
        let nodeId = "029cba2eb9edf18352e90f1a5f71e367af80d6e3ab7a5aa6122309fcbcd4375735"
//        let address = "45.33.22.210"
//        let address = "24.50.226.8"
        let address = "192.168.0.10"
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
            let bolt11 = try velas.createInvoice(amtMsat: 200000, description: "this s a test from velas lighting")
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

