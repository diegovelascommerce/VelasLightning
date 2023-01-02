
from .gRPC import stub as lnd

TEST_NODE_ID = \
    "03e347d089c071c27680e26299223e80a740cf3e3fc4b4237fa219bb67121a670b"
TEST_CHANNEL_ID = "2583303668972126208"


class Velas:
    """Class that handles interaction between web API and LND gRPC client"""

    def __init__(self):
        self.stub = lnd.get_stub()

    def getinfo(self):
        info = lnd.getinfo(self.stub)
        return info

    def getNodeID(self):
        """
        Get node id of LND.

        return:
            True
        """
        return TEST_NODE_ID

    def create_channel(self, nodeId, address, port):
        """
        Create a outbout channel with node submitted

        return:
            channel id of newly created channel
        """
        print("Outbound channel created with {nodeId}@{address}:{port}")
        return TEST_CHANNEL_ID

    def payBolt11(self, bolt11):
        """Pay bolt11 invoice that is submitted to it."""
        print("pay bolt11: {bolt11}")
        return True

    def closeChannel(channelID):
        """Close specified channel."""
        print("channel: {channelID} was closed")
        return True
