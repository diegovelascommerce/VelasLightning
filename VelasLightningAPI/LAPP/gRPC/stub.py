from . import lightning_pb2 as ln
from . import lightning_pb2_grpc as lnrpc
import grpc
import os
import codecs

# due to updated ECDSA generated tls.cert we need to let grpc know
# that we need to use that cipher suite otherwise there will be a handshaking
# error when we communicate with the lnd rpc server
os.environ["GRPC_SSL_CIPHER_SUITES"] = "HIGH+ECDSA"

# get the lnd cert
cert = open(os.path.expanduser(
    '~/source/velas/VelasLightning/VelasLightningAPI/LAPP/gRPC/tls.cert'),
    'rb').read()

# get the lnd admin.macaroon
with open(os.path.expanduser('~/source/velas/VelasLightning/VelasLightningAPI/LAPP/gRPC/admin.macaroon'), 'rb') as f:  # noqa: E501
    macaroon_bytes = f.read()
    macaroon = codecs.encode(macaroon_bytes, 'hex')


def metadata_callback(context, callback):
    callback([('macaroon', macaroon)], None)


# build ssl credentials using the tls.cert
cert_creds = grpc.ssl_channel_credentials(cert)

# build metadate credentials
auth_creds = grpc.metadata_call_credentials(metadata_callback)

# now combine the creds
combined_creds = grpc.composite_channel_credentials(cert_creds, auth_creds)


def get_stub():
    channel = grpc.secure_channel('192.168.0.10:10009', combined_creds)
    stub = lnrpc.LightningStub(channel)
    return stub


def getinfo(stub):
    info = stub.GetInfo(ln.GetInfoRequest())
    return info


def get_wallet_balance(stub):
    balance = stub.WalletBalance(ln.WalletBalanceRequest())
    return balance

# if __name__ == "__main__":
#     start_server()
