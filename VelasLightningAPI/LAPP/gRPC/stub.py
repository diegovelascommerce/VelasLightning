import codecs
import os

import grpc

from config import config

from . import convertion
from . import lightning_pb2 as ln
from . import lightning_pb2_grpc as lnrpc

# due to updated ECDSA generated tls.cert we need to let grpc know
# that we need to use that cipher suite otherwise there will be a handshaking
# error when we communicate with the lnd rpc server
os.environ["GRPC_SSL_CIPHER_SUITES"] = "HIGH+ECDSA"

cwd = os.path.dirname(__file__)
print(cwd)
# get the lnd cert
cert = open(os.path.expanduser(
    config['grpc']['tls']),
    'rb').read()

# get the lnd admin.macaroon
with open(os.path.expanduser(config['grpc']['macaroon']), 'rb') as f:  # noqa: E501
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
    channel = grpc.secure_channel(
        f"{config['grpc']['ip']}:{config['grpc']['port']}", combined_creds)
    stub = lnrpc.LightningStub(channel)
    return stub


def getinfo(stub):
    info = stub.GetInfo(ln.GetInfoRequest())
    return info


def openchannel(stub,
                nodeId: str,
                amt: int,
                private: bool,
                target_conf: int,
                min_confs: int,
                zero_conf: bool):

    request = ln.OpenChannelRequest(
        # sat_per_vbyte= < uint64 > ,
        node_pubkey=convertion.hex_to_bytes(nodeId),
        # node_pubkey_string=nodeId,
        local_funding_amount=amt,
        # push_sat= < int64 > ,
        target_conf=target_conf,
        # sat_per_byte= < int64 > ,
        private=private,
        # min_htlc_msat= < int64 > ,
        # remote_csv_delay= < uint32 > ,
        min_confs=min_confs,
        # spend_unconfirmed= < bool > ,
        # close_address= < string > ,
        # funding_shim= < FundingShim > ,
        # remote_max_value_in_flight_msat= < uint64 > ,
        # remote_max_htlcs= < uint32 > ,
        # max_local_csv= < uint32 > ,
        # commitment_type= < CommitmentType > ,
        # zero_conf=zero_conf,
        # scid_alias= < bool > ,
        # base_fee= < uint64 > ,
        # fee_rate= < uint64 > ,
        # use_base_fee= < bool > ,
        # use_fee_rate= < bool > ,
        # remote_chan_reserve_sat= < uint64 > ,
    )
    response = stub.OpenChannelSync(request)
    return response


def closechannel(stub, txId, vout, force):
    btxId = convertion.hex_to_bytes(txId)
    revbtxid = convertion.reverse_bytes(btxId)
    channel_point = ln.ChannelPoint(
        funding_txid_bytes=revbtxid,
        output_index=vout,
    )
    request = ln.CloseChannelRequest(
        channel_point=channel_point,
        force=force,
        # target_conf=<int32>,
        # sat_per_byte=<int64>,
        # delivery_address=<string>,
        # sat_per_vbyte=<uint64>,
        # max_fee_per_vbyte=<uint64>,
    )

    for response in stub.CloseChannel(request):
        if hasattr(response, 'close_pending'):
            pendingUpdate = response.close_pending
            revtxid = convertion.reverse_bytes(pendingUpdate.txid)
            txid = convertion.bytes_to_hex(revtxid)
            return txid


def listchannels(stub, peer, active_only, inactive_only, public_only, private_only):  # noqa
    bpeer = convertion.hex_to_bytes(peer)
    request = ln.ListChannelsRequest(
        active_only=active_only,
        inactive_only=inactive_only,
        public_only=public_only,
        private_only=private_only,
        peer=bpeer,
    )
    response = stub.ListChannels(request)
    return response


def decodepayreq(stub, pay_req):
    request = ln.PayReqString(
        pay_req=pay_req
    )
    res = stub.DecodePayReq(request)
    return res


def payinvoice(stub, pay_req):
    request = ln.SendRequest(
        payment_request=pay_req
    )
    res = stub.SendPaymentSync(request)
    return res


def get_wallet_balance(stub):
    balance = stub.WalletBalance(ln.WalletBalanceRequest())
    return balance


def addinvoice(stub, memo, amount):
    request = ln.Invoice(
        memo=memo,
        value=int(amount)
    )
    print(request)
    response = stub.AddInvoice(request)
    # return f"invoice: {memo}, {amount}"
    return response

def lookupinvoice(stub, hash):
    request = ln.PaymentHash(
        r_hash_str=hash
    )
    response = stub.LookupInvoice(request)
    return response
