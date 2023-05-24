
from .gRPC import convertion
from .gRPC import stub as lnd


class Velas:
    """Class that handles interaction between web API and LND gRPC client"""

    def __init__(self):
        self.stub = lnd.get_stub()

    def getinfo(self):
        info = lnd.getinfo(self.stub)
        return info

    def openchannel(self,
                    nodeId,
                    amt,
                    private,
                    target_conf,
                    min_confs,
                    zero_conf):
        """
        Create a outbout channel with node submitted

        return:
            channel id of newly created channel
        """
        channelPoint = lnd.openchannel(self.stub,
                                       nodeId=nodeId,
                                       amt=amt,
                                       private=private,
                                       target_conf=target_conf,
                                       min_confs=min_confs,
                                       zero_conf=zero_conf)

        brev = convertion.reverse_bytes(channelPoint.funding_txid_bytes)
        txid = convertion.bytes_to_hex(brev)
        out = channelPoint.output_index

        return (txid, out)

    def closeChannel(self, txid, vout, force):
        """Close specified channel."""
        res = lnd.closechannel(self.stub, txid, vout, force)

        return res

    def listchannels(self, peer, active_only, inactive_only, public_only, private_only):  # noqa
        res = lnd.listchannels(self.stub, peer, active_only,
                               inactive_only, public_only, private_only)
        return res

    def decodepayreq(self, pay_req):
        res = lnd.decodepayreq(self.stub, pay_req)
        return res

    def payinvoice(self, pay_req):
        res = lnd.payinvoice(self.stub, pay_req)
        return {
            "payment_error": res.payment_error,
            "payment_preimage": convertion.bytes_to_hex(res.payment_preimage),
            "payment_hash": convertion.bytes_to_hex(res.payment_hash)
        }
    
    def addinvoice(self,memo,amount):
        res = lnd.addinvoice(self.stub, memo, amount)
        return {
            "payment_request": res.payment_request,
            "payment_hash": convertion.bytes_to_hex(res.r_hash)
        }
    
    def lookupinvoice(self, hash):
        res = lnd.lookupinvoice(self.stub, hash)
        return {
            "memo": res.memo,
            "value": res.value,
            "settled": res.settled,
            "creation_date": res.creation_date,
            "settle_date": res.settle_date,
            "expiry": res.expiry
        }
