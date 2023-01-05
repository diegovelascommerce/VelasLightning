//
//  MyChannelManagerPersister.swift
//  VelasLightningFramework
//
//  Created by Diego vila on 11/8/22.
//

import Foundation
import LightningDevKit


class MyChannelManagerPersister : Persister, ExtendedChannelManagerPersister {
    
    var backUpChannelManager: Optional<(Data) -> ()>
    
    var lightning: Lightning? = nil
    
    public init(backUpChannelManager: Optional<(Data) -> ()> = nil) {
        self.backUpChannelManager = backUpChannelManager
        super.init()
    }

    func handle_event(event: Event) {
                
        if let _ = event.getValueAsSpendableOutputs() {
            print("ReactNativeLDK: trying to spend output")
           
        }

        if let paymentSentEvent = event.getValueAsPaymentSent() {
            print("handle_event: Payment Sent \(paymentSentEvent)")
        }
        
        if let paymentFailedEvent = event.getValueAsPaymentFailed() {
            print("handle_event: Payment Sent \(paymentFailedEvent)")
        }

        if let paymentPathFailedEvent = event.getValueAsPaymentPathFailed() {
            print("handle_event: Payment Path Failed \(paymentPathFailedEvent)")
        }

        if let _ = event.getValueAsPendingHTLCsForwardable() {
            print("handle_event: forward HTLC")
            lightning?.channel_manager?.process_pending_htlc_forwards()
        }

        if let paymentReceivedEvent = event.getValueAsPaymentReceived() {
            print("handle_event: payment received")
            let paymentPreimage = paymentReceivedEvent.getPurpose().getValueAsInvoicePayment()?.getPayment_preimage()
            let _ = lightning?.channel_manager?.claim_funds(payment_preimage: paymentPreimage!)
        }

        if let _ = event.getValueAsFundingGenerationReady() {
            print("ReactNativeLDK: funding generation ready")
            
        }

        if event.getValueAsPaymentForwarded() != nil {
            // we don't route as we are a light mobile node
        }

        if let _ = event.getValueAsPaymentClaimed() {
            
        }

        if let _ = event.getValueAsChannelClosed() {
            print("ReactNativeLDK ChannelClosed")
            
        }
    }

    override func persist_manager(channel_manager: ChannelManager) -> Result_NoneErrorZ {
        
        let channel_manager_bytes = channel_manager.write()
        
        do {
            let data = Data(channel_manager_bytes)
            try FileMgr.writeData(data: data, path: "channel_manager")
            print("persist_manager: Success")
            if let backUpChannelManager = backUpChannelManager {
                backUpChannelManager(data)
                print("persist_manager: successfully backup channel_manager to server \n")
            }
        }
        catch {
            NSLog("Velas/Lightning/MyChannelManagerPersister: there was a problem persisting the channel \(error)")
        }
        
        //return Result_NoneErrorZ()
        return Result_NoneErrorZ.ok()
    }
    
    override func persist_graph(network_graph: NetworkGraph) -> Result_NoneErrorZ {
       
        do {
            let network_graph_bytes = network_graph.write()
            try FileMgr.writeData(data: Data(network_graph_bytes), path: "network_graph")
            print("persist_network_graph: Success\n");
            return Result_NoneErrorZ.ok()
        }
        catch {
            NSLog("persist_network_graph: persist_network_graph: Error \(error)");
            return Result_NoneErrorZ.ok()
        }
    }
    
    
}

