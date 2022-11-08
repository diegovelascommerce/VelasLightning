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
            print("there was a problem getting the node id \(error)")
        }
//
//        peerlistLable.text = "Hello peerlist"
//        peerlistLable.sizeToFit()
//        peerlistLable.center.x = self.view.center.x
    }
    
    @IBAction func connectClick(_ sender: Any) {
        NSLog("connect to a peer")
        let nodeId = "03e347d089c071c27680e26299223e80a740cf3e3fc4b4237fa219bb67121a670b"
        let address = "45.33.22.210"
        let port = NSNumber(9735)
        do {
            let res = try velas.connect(nodeId: nodeId, address: address, port: port)
            NSLog("connect: \(res)")
        }
        catch {
            NSLog("there was a problem: \(error)")
        }
    }
    
    @IBAction func showPeerList(_ sender: Any) throws {
        NSLog("show peer list")
        let res = try velas.listPeers()
        NSLog("peers: \(res)")
    }
    
}

