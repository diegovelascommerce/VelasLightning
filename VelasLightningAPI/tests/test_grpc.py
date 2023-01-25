import pytest

import LAPP.gRPC.convertion as convertion
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
    res = lnd.openchannel(
        stub, NODE_ID, 20000)

    assert res.funding_txid_bytes
    print(f"funding_txid_bytes: {res.funding_txid_bytes}")

    assert res.output_index
    print(f"output_index: {res.output_index}")

    # assert res.funding_txid_str
    # print(f"funding_txid_str: {res.funding_txid_str}")

    brev = convertion.reverse_bytes(res.funding_txid_bytes)
    txid = convertion.bytes_to_hex(brev)
    print(txid)


def test_closechannel(stub):
    txId = "4cf41a1af733808dd01a3391338e7079132db6b5da38bd52d24c8624e43c8f39"
    vout = 1
    force = False
    res = lnd.closechannel(stub, txId, vout, force)
    print(res)
    assert res is not None
    # asster res is None


def test_listchannels(stub):
    peer = "03e347d089c071c27680e26299223e80a740cf3e3fc4b4237fa219bb67121a670b"
    res = lnd.listchannels(stub, peer, active_only=True,
                           inactive_only=False, public_only=True, private_only=False)  # noqa
    print(res)


def test_decodepayreq(stub):
    bolt11 = "lntb2u1p3ms7ulpp5kcy46uadkkzn2ec3q84sjkhtpw4rvm0atfyy204mefzyhj20cfcqdp9wpkx2ctnv5s8qcteyp6x7grkv4kxzum5v4ehgcqzpgxqyz5vqsp5sn0209yqdfku0anll6gvjc3xve9gf0jcq2j285az6xky7jc8vyrs9qyyssqmfl3y4r08mua52yt83cd2qyq67qcvll28p2jg8ffkeygnnaqk92juym0ctka9y49hf2jmjkkdupkr5f74aujja8yxpkaump55605szqq45cfjs"
    res = lnd.decodepayreq(stub, pay_req=bolt11)
    print(res)


def test_payinvoice(stub):
    bolt11 = "lntb2u1p3m3q8dpp5xn6jna8p7729rr5spr29x7a49cjcxgj3nc2x9fyuedj927ywhauqdq4wpshjgrkv4kxzum5v4ehgcqzpgxqyz5vqsp5glggsm7wvh87ljlktar5w9yjthkvjuvvepejvspa4tv498dsx0kq9qyyssqflrxdst0wyc7crzvl3pm82099nv3f0l7lhag9mcuvyhru7c4n0y3nnydpzuk7tmupqjsukvvgrfvy2e9uppsuz8q8thrcpnj300m4ngpanl858"
    res = lnd.payinvoice(stub, pay_req=bolt11)
    print(res)
