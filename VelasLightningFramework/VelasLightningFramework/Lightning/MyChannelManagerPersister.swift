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
        return Result_NoneErrorZ()
    }
    
    override func persist_scorer(scorer: Bindings.WriteableScore) -> Bindings.Result_NoneErrorZ {
        Result_NoneErrorZ()
    }
}

