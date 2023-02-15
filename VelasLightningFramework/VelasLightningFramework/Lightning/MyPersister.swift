import LightningDevKit

/// What it is used for:  persisting ChannelMonitors, which contain crucial channel data, in a timely manner
///
/// notes:
///   ChannelMonitors are objects which are capable of responding to on-chain events for a given channel.
///   Thus, you will have one ChannelMonitor per channel, identified by channel_id: Outpoint.
class MyPersister: Persist {
    
    /// backup a new channel
    override func persistNewChannel(channelId: OutPoint, data: ChannelMonitor, updateId: MonitorUpdateId) -> Bindings.ChannelMonitorUpdateStatus {
        
        // get channelID in bytes
        let idBytes: [UInt8] = channelId.write()
        
        // get the channel data from the ChannelMonitor
        let monitorBytes: [UInt8] = data.write()
        
        // save channel to file system
        do {
            let data = Data(monitorBytes)
            try FileMgr.createDirectory(path: "channels")
            try FileMgr.writeData(data: data, path: "channels/\(Utils.bytesToHex(bytes: idBytes))")
            print("persistNewChannel: successfully backup channel to channels/\(Utils.bytesToHex(bytes: idBytes))\n")
        }
        catch {
            NSLog("persistNewChannel: problem saving channels/\(Utils.bytesToHex(bytes: idBytes))")
        }
        
        return Bindings.ChannelMonitorUpdateStatus.Completed
    }
    

    override func updatePersistedChannel(channelId: OutPoint, update: ChannelMonitorUpdate, data: ChannelMonitor, updateId: MonitorUpdateId) -> ChannelMonitorUpdateStatus {
        
        // get channel id
        let idBytes: [UInt8] = channelId.write()
        
        // get channel data
        let monitorBytes: [UInt8] = data.write()
        
        // save updated channel to file
        do {
            let data = Data(monitorBytes)
            try FileMgr.createDirectory(path: "channels")
            try FileMgr.writeData(data: data, path: "channels/\(Utils.bytesToHex(bytes: idBytes))")
            print("updatePersistedChannel: update channel at channels/\(Utils.bytesToHex(bytes: idBytes))\n")
        }
        catch {
            NSLog("updatePersistedChannel: problem updating channels/\(Utils.bytesToHex(bytes: idBytes))")
        }
        
        return Bindings.ChannelMonitorUpdateStatus.Completed
    }
    
}
    
