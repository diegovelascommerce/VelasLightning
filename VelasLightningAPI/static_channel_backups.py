from LAPP.gRPC import voltage

stub = voltage.get_stub()

info = voltage.getinfo(stub)
print(info)
