//
//  ViewController.swift
//  VelasLightningExample
//
//  Created by Diego vila on 10/25/22.
//

import UIKit
import VelasLightningFramework

class ViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()

        if Velas.Check(){
            Velas.Load(plist: "velas")
        }
        else {
            Velas.Setup(plist: "velas")
        }
        
//        do {
//            try LAPP.Setup(plist: "velas")
//        }
//        catch {
//            NSLog("velas: \(error)")
//        }
        
    }
    
    func alert(title:String, message:String, text:String? = nil, onAction: ((UIAlertAction)->())? = nil, onSumbit: ((String) ->())? = nil) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let onSumbit = onSumbit, let text = text {
            alertController.addTextField { (textField) in
                textField.placeholder = text
            }
            alertController.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak alertController] (_) in
                
                guard let textField = alertController?.textFields?[0], let textValue = textField.text else { return }
                
                onSumbit(textValue)
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        }
        else if let onAction = onAction {
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: onAction))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        }
        else {
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
        }
        
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func getNodeIdClick(_ sender: Any) {
        do {
            if let velas = Velas.shared {
                let nodeId = try velas.getNodeId()
                print("nodeId: \(nodeId)")
                self.alert(title: "NodeId", message: nodeId)
            }
            
        }
        catch {
            NSLog("error: \(error)")
        }
    }
    
    
    @IBAction func payInvoiceClick(_ sender: Any) {
       
        let channels = Velas.ListChannels(usable: true)
        if(channels.count > 0){
            self.alert(title: "Pay Invoice", message: "Past bolt11 here", text: "bolt11:", onSumbit: {(bolt11)  in
                let res = Velas.PayInvoice(bolt11)
                if let res = res {
                    self.alert(title: "Pay Invoice", message: "\(res)")
                }
                else {
                    self.alert(title: "Pay Invoice", message: "payment did not go through")
                }
            })
        }
        else {
            self.alert(title: "Pay Invoice", message: "None of the channels are ready")
        }
       
    }

    
    @IBAction func connectClick(_ sender: Any) {
        let connected = Velas.Connect()
        print("connect to a peer: \(connected)")
        self.alert(title: "Connect", message: "\(connected)")
    }
    
    @IBAction func syncClick(_ sender: Any) {
        let res = Velas.Sync()
        
        if res {
            self.alert(title: "Sync", message: "success")
        }
        else {
            self.alert(title: "Sync", message: "could not sync")
            NSLog("could not sync")
        }
    }
    
    @IBAction func showPeerList(_ sender: Any) {
        let peers = Velas.Peers()
        print("show peer list: \(peers)")
        self.alert(title: "Peers", message: "\(peers)")
    }
    
    @IBAction func openChannel(_ sender: Any) {
        
        let res = Velas.OpenChannel(amt: 20000, target_conf: 0, min_confs: 0)
        if let res = res {
            print(res)
            self.alert(title: "Channel created", message: "channel: \(res)")
        }
        else {
            print("there was a problem creating a channel")
            self.alert(title: "Channel created", message: "problem creating channel")
        }
    }
    
    @IBAction func listChannels(_ sender: Any) {
        let channels = Velas.ListChannels()
        print("channels: \(channels)")
        self.alert(title: "Channels", message: "channels: \(channels)")
    }
    
    @IBAction func listChannelsUsable(_ sender: Any) {
        let channels = Velas.ListChannels(usable: true)
        print("usable channels: \(channels)")
        self.alert(title: "Usable Channels", message: "channels: \(channels)")
    }
    
    @IBAction func listChannelsLapp(_ sender: Any) {
        let channels = Velas.ListChannels(lapp: true)
        print("channels: \(channels)")
        self.alert(title: "LAPP Channels", message: "channels: \(channels)")
    }
    
    @IBAction func submitBolt11(_ sender: Any) {
       
        self.alert(title:"Submit bolt11", message:"Please enter amount", text:"amount:", onSumbit: {(amt) in
            
            let res = Velas.PaymentRequest(amt: Int(amt)!, description: "this s a test from velas lighting")
            
            let (bolt11, result) = res

            if let result = result {
                print("\(bolt11) : \(result)")
                self.alert(title: "PaymentRequest", message: "\(bolt11) :\n \(result)")
            }
            else {
                print("\(bolt11) : nil")
                self.alert(title: "PaymentRequest", message: "\(bolt11) : did not go through")
            }
            
        })
        
//        do {
//            let channels = try velas.listUsableChannelsDict()
//            let ready = channels.count > 0 ? true : false
//
//            if(ready){
//                self.alert(title:"Submit bolt11", message:"Please enter amount in milisats", text:"amount:", onSumbit: {(amt) in
//                    do {
//                        let bolt11 = try velas.createInvoice(
//                            amtMsat: Int(amt)!,
//                            description: "this s a test from velas lighting")
//
//                        self.alert(title: "bolt11", message: bolt11, onAction: {(action) -> Void in
//                            let res = lapp.payInvoice(bolt11: bolt11)
//                            if let res = res {
//                                self.alert(title: "Payment Claimed", message: "\(res)")
//                            }
//                            else {
//                                NSLog("payment did not go through")
//                            }
//
//                        })
//                    }
//                    catch {
//                        NSLog("problem paying invoice \(error)")
//                    }
//                })
//
//            } else {
//                self.alert(title: "Submit bolt11", message: "None of the channels are ready")
//            }
//        }
//        catch {
//            NSLog("problem with listing channels: \(error)")
//        }
    }
    
    
    @IBAction func closeChannelCooperatively(_ sender: Any) {
        let res = Velas.CloseChannels()
        
        if !res {
            NSLog("problem clossing channels")
        }
    }
    
    @IBAction func closeChannelForcefully(_ sender: Any) {
        let res = Velas.CloseChannels(force: true)
        
        if !res {
            NSLog("problem clossing channels")
        }

    }
    
    @IBAction func findRoute(_ sender: Any)  {
        self.alert(title:"Check bolt11", message:"Please a bolt11", text:"bolt11:", onSumbit: {(bolt11) in
            Velas.FindRoute(bolt11: bolt11)
        })
    }
    
}

