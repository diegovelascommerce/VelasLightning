//
//  MyChannelManagerPersister.swift
//  VelasLightningFramework
//
//  Created by Diego vila on 11/8/22.
//

import Foundation
import LightningDevKit


class MyChannelManagerPersister : Persister, ExtendedChannelManagerPersister {

    func handle_event(event: Event) {
        
        NSLog("Velas/Lightning/MyChannelManagerPersister: \(event)")
        
        if let _ = event.getValueAsSpendableOutputs() {
            print("ReactNativeLDK: trying to spend output")
           
        }

        if let _ = event.getValueAsPaymentSent() {
            print("ReactNativeLDK: payment sent")
            
        }

        if let _ = event.getValueAsPaymentPathFailed() {
            print("ReactNativeLDK: payment path failed")
            
        }

        if let _ = event.getValueAsPendingHTLCsForwardable() {
            print("ReactNativeLDK: forward HTLC")
           
        }

        if let _ = event.getValueAsPaymentReceived() {
            print("ReactNativeLDK: payment received")
        }

        //

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
            try FileMgr.writeData(data: Data(channel_manager_bytes), path: "channel_manager")
            print("Velas/Lightning/MyChannelManagerPersister/persist_manager: Success")
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
            print("Velas/Lightning/MyChannelManagerPersister/persist_network_graph: Success");
            return Result_NoneErrorZ.ok()
        }
        catch {
            NSLog("Velas/Lightning/MyChannelManagerPersister/persist_network_graph: persist_network_graph: Error \(error)");
            return Result_NoneErrorZ.ok()
        }
    }
    
    
}

