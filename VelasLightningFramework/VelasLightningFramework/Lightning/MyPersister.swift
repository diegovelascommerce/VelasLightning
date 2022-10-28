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
    
    override func persist_new_channel(channel_id: OutPoint, data: ChannelMonitor, update_id: MonitorUpdateId) -> Result_NoneChannelMonitorUpdateErrZ {
        let idBytes: [UInt8] = channel_id.write()
        let monitorBytes: [UInt8] = data.write()
        
        // persist monitorBytes to disk, keyed by idBytes
        
        return Result_NoneChannelMonitorUpdateErrZ.ok()
    }
    
    override func update_persisted_channel(channel_id: OutPoint, update: ChannelMonitorUpdate, data: ChannelMonitor, update_id: MonitorUpdateId) -> Result_NoneChannelMonitorUpdateErrZ {
        let idBytes: [UInt8] = channel_id.write()
        let monitorBytes: [UInt8] = data.write()
        
        // modify persisted monitorBytes keyed by idBytes on disk
        
        return Result_NoneChannelMonitorUpdateErrZ.ok()
    }
    
}
