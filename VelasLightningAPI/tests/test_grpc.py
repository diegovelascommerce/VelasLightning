from LAPP.gRPC import stub as lnd


def test_get_info():
    assert hasattr(lnd, 'get_stub')
    stub = lnd.get_stub()
    assert stub is not None
    assert hasattr(lnd, 'getinfo')
    info = lnd.getinfo(stub)
    assert info is not None
    print(info)
