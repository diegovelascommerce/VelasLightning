import LightningDevKit

/// What it is used for:  persisting persisting ChannelMonitors, which contain crucial channel data, in a timely manner
///
/// notes:
///   ChannelMonitors are objects which are capable of responding to on-chain events for a given channel.
///   Thus, you will have one ChannelMonitor per channel, identified by channel_id: Outpoint.
///
///   the persist methods will block progress on sending or receiving payment until they return.
///   you must ensure that ChannelMonitors are durably persisted to disk or you may lose funds.
class MyPersister: Persist {
    
    var backUpChannel: Optional<(Data) -> ()>
    
    public init(backUpChannel: Optional<(Data) -> ()> = nil) {
        self.backUpChannel = backUpChannel
        super.init()
    }
    
    override func persistNewChannel(channelId: Bindings.OutPoint, data: Bindings.ChannelMonitor, updateId: Bindings.MonitorUpdateId) -> Bindings.ChannelMonitorUpdateStatus {
        let idBytes: [UInt8] = channelId.write()
        let monitorBytes: [UInt8] = data.write()
        
        do {
            let data = Data(monitorBytes)
            try FileMgr.createDirectory(path: "channels")
            try FileMgr.writeData(data: data, path: "channels/\(Utils.bytesToHex(bytes: idBytes))")
            print("persist_new_channel: successfully backup channel to channels/\(Utils.bytesToHex(bytes: idBytes))\n")
            if let backUpChannel = backUpChannel {
                backUpChannel(data)
                print("persist_new_channel: successfully backup channel server\n")
            }
        }
        catch {
            NSLog("persist_new_channel: problem saving channels/\(Utils.bytesToHex(bytes: idBytes))")
            
        }
        
        
        return Bindings.ChannelMonitorUpdateStatus.Completed
    }
    
//    override func persist_new_channel(channel_id: OutPoint, data: ChannelMonitor, update_id: MonitorUpdateId) -> LDKChannelMonitorUpdateStatus {
//
//        let idBytes: [UInt8] = channel_id.write()
//        let monitorBytes: [UInt8] = data.write()
//
//        do {
//            let data = Data(monitorBytes)
//            try FileMgr.createDirectory(path: "channels")
//            try FileMgr.writeData(data: data, path: "channels/\(Utils.bytesToHex(bytes: idBytes))")
//            print("persist_new_channel: successfully backup channel to channels/\(Utils.bytesToHex(bytes: idBytes))\n")
//            if let backUpChannel = backUpChannel {
//                backUpChannel(data)
//                print("persist_new_channel: successfully backup channel server\n")
//            }
//        }
//        catch {
//            NSLog("persist_new_channel: problem saving channels/\(Utils.bytesToHex(bytes: idBytes))")
//
//        }
//
//
//        return LDKChannelMonitorUpdateStatus_Completed
//    }

    override func updatePersistedChannel(channelId: Bindings.OutPoint, update: Bindings.ChannelMonitorUpdate, data: Bindings.ChannelMonitor, updateId: Bindings.MonitorUpdateId) -> Bindings.ChannelMonitorUpdateStatus {
        let idBytes: [UInt8] = channelId.write()
        let monitorBytes: [UInt8] = data.write()
        
        do {
            let data = Data(monitorBytes)
            try FileMgr.createDirectory(path: "channels")
            try FileMgr.writeData(data: data, path: "channels/\(Utils.bytesToHex(bytes: idBytes))")
            print("update_persisted_channel: update channel at channels/\(Utils.bytesToHex(bytes: idBytes))\n")
            if let backUpChannel = backUpChannel {
                backUpChannel(data)
                print("persist_new_channel: successfully backup channel server\n")
            }
        }
        catch {
            NSLog("update_persisted_channel: problem updating channels/\(Utils.bytesToHex(bytes: idBytes))")
        }
        
        return Bindings.ChannelMonitorUpdateStatus.Completed
    }
    
//    override func update_persisted_channel(channel_id: OutPoint, update: ChannelMonitorUpdate, data: ChannelMonitor, update_id: MonitorUpdateId) -> LDKChannelMonitorUpdateStatus {
//
//        let idBytes: [UInt8] = channel_id.write()
//        let monitorBytes: [UInt8] = data.write()
//
//        do {
//            let data = Data(monitorBytes)
//            try FileMgr.createDirectory(path: "channels")
//            try FileMgr.writeData(data: data, path: "channels/\(Utils.bytesToHex(bytes: idBytes))")
//            print("update_persisted_channel: update channel at channels/\(Utils.bytesToHex(bytes: idBytes))\n")
//            if let backUpChannel = backUpChannel {
//                backUpChannel(data)
//                print("persist_new_channel: successfully backup channel server\n")
//            }
//        }
//        catch {
//            NSLog("update_persisted_channel: problem updating channels/\(Utils.bytesToHex(bytes: idBytes))")
//        }
//
//        return LDKChannelMonitorUpdateStatus_Completed
//    }
}
    
