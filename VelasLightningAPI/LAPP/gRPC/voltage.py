# import codecs, grpc, os
import os
import codecs
import grpc
from dotenv import load_dotenv  # type: ignore

from . import lightning_pb2
from . import lightning_pb2_grpc as lightning_grpc


def get_stub():
    load_dotenv(override=True)

    GRPC_HOST = str(os.getenv("GRPC_HOST") or "")
    MACAROON_PATH = str(os.getenv("MACAROON_PATH") or "")
    TLS_PATH = str(os.getenv("TLS_PATH") or "")

    # create macaroon credentials
    macaroon = str()
    with open(MACAROON_PATH, "rb") as f:
        data = f.read()
        macaroon = codecs.encode(data, "hex")

    def metadata_callback(_, callback):
        callback([("macaroon", macaroon)], None)

    auth_creds = grpc.metadata_call_credentials(metadata_callback)

    # create SSL credentials
    os.environ["GRPC_SSL_CIPHER_SUITES"] = "HIGH+ECDSA"

    cert = str()
    with open(TLS_PATH, "rb") as f:
        cert = f.read()

    ssl_creds = grpc.ssl_channel_credentials(cert)

    # combine macaroon and SSL credentials
    combined_creds = grpc.composite_channel_credentials(ssl_creds, auth_creds)

    # make the request
    channel = grpc.secure_channel(GRPC_HOST, combined_creds)

    stub = lightning_grpc.LightningStub(channel)

    return stub


def getinfo(stub):
    info = stub.GetInfo(lightning_pb2.GetInfoRequest())
    return info
