//
//  MyChannelManagerPersister.swift
//  VelasLightningFramework
//
//  Created by Diego vila on 11/8/22.
//

import Foundation
import LightningDevKit


class MyChannelManagerPersister : Persister, ExtendedChannelManagerPersister {
        
    var lightning: Lightning? = nil
    
    public init(backUpChannelManager: Optional<(Data) -> ()> = nil) {
        super.init()
    }

    func handleEvent(event: Event) {
                
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
        
        
        if let _ = event.getValueAsPendingHtlcsForwardable() {
            print("handle_event: forward HTLC")
            lightning?.channelManager?.processPendingHtlcForwards()
        }
        
        
//        if let paymentReceivedEvent = event.getValueAsPaymentReceived() {
//            print("handle_event: payment received")
//            let paymentPreimage = paymentReceivedEvent.getPurpose().getValueAsInvoicePayment()?.getPayment_preimage()
//            let _ = lightning?.channel_manager?.claim_funds(payment_preimage: paymentPreimage!)
//        }
        
        // payment was claimed, so return preimage
        if let paymentClaimedEvent = event.getValueAsPaymentClaimable() {
            let paymentPreimage = paymentClaimedEvent.getPurpose().getValueAsInvoicePayment()?.getPaymentPreimage()
            let _ = lightning?.channelManager?.claimFunds(paymentPreimage: paymentPreimage!)
        }

        if let _ = event.getValueAsFundingGenerationReady() {
            print("ReactNativeLDK: funding generation ready")
            
        }

        if event.getValueAsPaymentForwarded() != nil {
            // we don't route as we are a light mobile node
        }

        

        if let _ = event.getValueAsChannelClosed() {
            print("ReactNativeLDK ChannelClosed")
            
        }
    }

    override open func persistManager(channelManager: ChannelManager) -> Result_NoneErrorZ {
        
        let channel_manager_bytes = channelManager.write()
        
        do {
            let data = Data(channel_manager_bytes)
            try FileMgr.writeData(data: data, path: "channel_manager")
            print("persist_manager: Success")
        }
        catch {
            NSLog("Velas/Lightning/MyChannelManagerPersister: there was a problem persisting the channel \(error)")
        }
        
        return Result_NoneErrorZ.initWithOk()
    }
    
    override func persistGraph(networkGraph: NetworkGraph) -> Result_NoneErrorZ {
       
        do {
            let network_graph_bytes = networkGraph.write()
            try FileMgr.writeData(data: Data(network_graph_bytes), path: "network_graph")
            print("persist_network_graph: save success\n");
        }
        catch {
            NSLog("persist_network_graph: persist_network_graph: Error \(error)");
        }
        
        return Result_NoneErrorZ.initWithOk()
    }
    
    override func persistScorer(scorer: Bindings.WriteableScore) -> Result_NoneErrorZ {
        do {
            let scorerBytes = scorer.write()
            try FileMgr.writeData(data: Data(scorerBytes), path: "probabilistic_scorer")
            print("probabilistic_scorer: save success")
        }
        catch {
            NSLog("persistScorer: Error \(error)");
            
        }
        
        return Result_NoneErrorZ.initWithOk()
    }
    
    
}

