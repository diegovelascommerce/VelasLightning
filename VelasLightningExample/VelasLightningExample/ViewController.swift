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
//        do {
            
            //let res = try velas.connectToPeer(nodeId: LAPPNodeId, address: LAPPIp, port: LAPPPort)
//            velas.ln.runScorrer()
           
//        }
//        catch {
//            NSLog("problem")
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
    
    
    @IBAction func payInvoiceClick(_ sender: Any) {
        do {
            let channels = try velas.listUsableChannelsDict()
            if(channels.count > 0){
                self.alert(title: "Pay Invoice", message: "Past bolt11 here", text: "bolt11:", onSumbit: {(bolt11)  in
                    do {
                        let res = try velas.payInvoice(bolt11: bolt11)
                        if let res = res {
                            self.alert(title: "Pay Invoice", message: "Success(\(res))")
                        }
                    }
                    catch {
                        self.alert(title: "Pay Invoice", message: "error(\(error))")
                        NSLog("\(error)")
                    }
                })
            }
            else {
                self.alert(title: "Pay Invoice", message: "None of the channels are ready")
            }
        }
        catch {
            NSLog("there was a problem: \(error)")
        }
        
//        let alert = UIAlertController(title: "bolt11", message: "Please enter bolt11", preferredStyle: .alert)
//
//        alert.addTextField { (textField) in
//            textField.placeholder = "enter bolt11"
//        }

//        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak alert] (_) in
//            guard let textField = alert?.textFields?[0], let bolt11 = textField.text else { return }
//
//            // pay invoice
//            print("bolt11: \(bolt11)")
//
//            do {
//                let res = try velas.payInvoice(bolt11: bolt11)
//                if let res = res {
//                    print("payInvoice: success(\(res))")
////                    self.alert(title: "payInvoice", message: "success(\(res))")
//                }
//            }
//            catch {
//                print("payInvoice: error(\(error))")
////                self.alert(title: "payInvoice", message: "error(\(error))")
//            }
//        }))

//        self.present(alert, animated: true, completion: nil)
    }
    
    func getPlist() -> NSDictionary {
        let path = Bundle.main.path(forResource: "Velas", ofType:"plist")!
        let dict = NSDictionary(contentsOfFile: path)

        return dict!
    }
    
    @IBAction func connectClick(_ sender: Any) {
        print("connect to a peer")

        do {
            
            let res = try velas.connectToPeer(nodeId: LAPPNodeId, address: LAPPIp, port: LAPPPort)
            print("connect: \(res)")
            alert(title: "Peer Connect", message: "\(res)")
           
        }
        catch {
            alert(title: "Peer Connect", message: "could not make connection")
            NSLog("there was a problem: \(error)")
        }
    }
    
    @IBAction func syncClick(_ sender: Any) {
        print("syncing")

        do {
            try velas.sync()
            self.alert(title: "Sync", message: "success")
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
                
                let res = lapp.openChannel(nodeId: velasNodeId, amt: 20000, target_conf:1, min_confs:1, privChan: false)
                
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
            let channels = try velas.listUsableChannelsDict()
            let ready = channels.count > 0 ? true : false
            
            if(ready){
                self.alert(title:"Submit bolt11", message:"Please enter amount in milisats", text:"amount:", onSumbit: {(amt) in
                    do {
                        let bolt11 = try velas.createInvoice(
                            amtMsat: Int(amt)!,
                            description: "this s a test from velas lighting")
                        
                        self.alert(title: "bolt11", message: bolt11, onAction: {(action) -> Void in
                            let res = lapp.payInvoice(bolt11: bolt11)
                            if let res = res {
                                self.alert(title: "Payment Claimed", message: "\(res)")
                            }
                            else {
                                NSLog("payment did not go through")
                            }
                            
                        })
                    }
                    catch {
                        NSLog("problem paying invoice \(error)")
                    }
                })

            } else {
                self.alert(title: "Submit bolt11", message: "None of the channels are ready")
            }
        }
        catch {
            NSLog("problem with listing channels: \(error)")
        }
    }
    
//    @IBAction func createBolt11(_ sender: Any) {
//        do {
//            let bolt11 = try velas.createInvoice(amtMsat: 500000, description: "this s a test from velas lighting")
//            print("bolt11: \(bolt11)")
//        }
//        catch {
//            NSLog("problem creating bolt11 invoice: \(error)")
//        }
//    }
    
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

