from LAPP.gRPC import voltage

stub = voltage.get_stub()

response = voltage.getinfo(stub)
