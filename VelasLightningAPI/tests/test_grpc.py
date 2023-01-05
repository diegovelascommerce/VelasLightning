import pytest

from LAPP.gRPC import stub as lnd

NODE_ID = "03e347d089c071c27680e26299223e80a740cf3e3fc4b4237fa219bb67121a670b"


@pytest.fixture
def stub():
    stub = lnd.get_stub()
    return stub


def test_getinfo(stub):
    info = lnd.getinfo(stub)
    assert info is not None
    print(info)


def test_openchannel(stub):
    print(NODE_ID)
    res = lnd.openchannel(
        stub, NODE_ID, 20000)
    # assert res is not None
    print(res)
