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
