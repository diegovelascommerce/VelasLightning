
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
        channelPoint = lnd.openchannel(self.stub, nodeId, amt)

        brev = convertion.reverse_bytes(channelPoint.funding_txid_bytes)
        txid = convertion.bytes_to_hex(brev)
        out = channelPoint.output_index

        return (txid, out)

    def payBolt11(self, bolt11):
        """Pay bolt11 invoice that is submitted to it."""
        print("pay bolt11: {bolt11}")
        return True

    def closeChannel(channelID):
        """Close specified channel."""
        print("channel: {channelID} was closed")
        return True
