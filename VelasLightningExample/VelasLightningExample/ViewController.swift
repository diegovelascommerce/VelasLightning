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


}

