import pytest

from LAPP.velas import Velas

NODE_ID = "03e347d089c071c27680e26299223e80a740cf3e3fc4b4237fa219bb67121a670b"


@pytest.fixture
def velas():
    velas = Velas()
    return velas


def test_getinfo(velas):
    info = velas.getinfo()
    assert info is not None
    print(info)


def test_openchannel(velas):
    channelPoint = velas.openchannel(NODE_ID, 20000)
    assert channelPoint is not None
    print(channelPoint)


def test_listchannels(velas):
    res = velas.listchannels(NODE_ID,
                             active_only=True,
                             inactive_only=False,
                             public_only=True,
                             private_only=False)  # noqa
    print(res)


def test_closechannel(velas):
    txid = velas.closeChannel(
        "bff3097bdcab8c8cb47f98e1bf144c9ea9b8e7c0de9616aa242aaf0845f6280f", 1, False)  # noqa
    assert txid is not None
    print(txid)
