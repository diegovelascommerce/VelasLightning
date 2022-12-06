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
    
    override func persist_new_channel(channel_id: OutPoint, data: ChannelMonitor, update_id: MonitorUpdateId) -> LDKChannelMonitorUpdateStatus {
        
        let idBytes: [UInt8] = channel_id.write()
        let monitorBytes: [UInt8] = data.write()
        
        do {
            try FileMgr.createDirectory(path: "channels")
            try FileMgr.writeData(data: Data(monitorBytes), path: "channels/\(bytesToHex(bytes: idBytes))")
            print("Velas/Lightning/MyPersister/persist_new_channel: successfully backup channel to channels/\(bytesToHex(bytes: idBytes))")
        }
        catch {
            NSLog("Velas/Lightning/MyPersister/persist_new_channel: problem saving channels/\(bytesToHex(bytes: idBytes))")
            
        }
        
        
        return LDKChannelMonitorUpdateStatus_Completed
    }

    override func update_persisted_channel(channel_id: OutPoint, update: ChannelMonitorUpdate, data: ChannelMonitor, update_id: MonitorUpdateId) -> LDKChannelMonitorUpdateStatus {
        
        let idBytes: [UInt8] = channel_id.write()
        let monitorBytes: [UInt8] = data.write()
        
        do {
            try FileMgr.createDirectory(path: "channels")
            try FileMgr.writeData(data: Data(monitorBytes), path: "channels/\(bytesToHex(bytes: idBytes))")
            NSLog("Velas/Lightning/MyPersister/update_persisted_channel: update channel at channels/\(bytesToHex(bytes: idBytes))")
        }
        catch {
            NSLog("Velas/Lightning/MyPersister/update_persisted_channel: problem updating channels/\(bytesToHex(bytes: idBytes))")
        }
        
        return LDKChannelMonitorUpdateStatus_Completed
    }
}
    
