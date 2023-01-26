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


def test_decodereq(velas):
    bolt11 = "lntb2u1p3ms7ulpp5kcy46uadkkzn2ec3q84sjkhtpw4rvm0atfyy204mefzyhj20cfcqdp9wpkx2ctnv5s8qcteyp6x7grkv4kxzum5v4ehgcqzpgxqyz5vqsp5sn0209yqdfku0anll6gvjc3xve9gf0jcq2j285az6xky7jc8vyrs9qyyssqmfl3y4r08mua52yt83cd2qyq67qcvll28p2jg8ffkeygnnaqk92juym0ctka9y49hf2jmjkkdupkr5f74aujja8yxpkaump55605szqq45cfjs"
    res = velas.decodepayreq(pay_req=bolt11)
    assert res is not None
    print(res)


def test_payinvoice(velas):
    bolt11 = "lntb2u1p3a94n5pp5cant9p58qtavvphvus26rm6ry7m0k2lvvcmdf57szs3ych9tn2mqdzqw35xjueqd9ejqcfqw3jhxapqveex7mfqv35k2em0yaejqunpwdcxyetjwfujqurfcqzpgxqyz5vqsp59mm8lufhm6lz9sun7pss0rces8q32zqaeqhx66gtdtnpm2paqm9q9qyyssq53xytkjx9lc0g5qedlkyrjssawyp8xkk34klpv35s9xsnqdn5w7nvtgq2u4w3f2v06ngsund50xgcyqd5wtfpnku4rm6fpwa5ugwjhqqjtq87n"
    res = velas.payinvoice(pay_req=bolt11)
    assert res is not None
    print(res)
