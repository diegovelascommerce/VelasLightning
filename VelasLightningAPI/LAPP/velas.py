
from .gRPC import convertion
from .gRPC import stub as lnd


class Velas:
    """Class that handles interaction between web API and LND gRPC client"""

    def __init__(self):
        self.stub = lnd.get_stub()

    def getinfo(self):
        info = lnd.getinfo(self.stub)
        return info

    def openchannel(self, nodeId, amt):
        """
        Create a outbout channel with node submitted

        return:
            channel id of newly created channel
        """
        channelPoint = lnd.openchannel(self.stub, nodeId, amt)  # noqa

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
