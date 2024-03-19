from LAPP.gRPC import voltage

stub = voltage.get_stub()

# voltage.getinfo(stub)

# voltage.subscribe_channel_backups(stub)

# voltage.subscribe_channel_events(stub)

voltage.export_all_channel_backups(stub)
