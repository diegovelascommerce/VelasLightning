import os
import pprint

import requests
from dotenv import load_dotenv  # type: ignore

load_dotenv()

LNBITS_HOST = ""
env = os.getenv("LNBITS_HOST")
if env is not None:
    LNBITS_HOST = env

LNBITS_API_KEY = ""
env = os.getenv("LNBITS_API_KEY")
if env is not None:
    LNBITS_API_KEY = env

LNBITS_USR = ""
env = os.getenv("LNBITS_USR")
if env is not None:
    LNBITS_USR = env


def test_lnbits():
    "show welcome screen for lnbits"

    res = requests.get(LNBITS_HOST, verify=False)
    assert res.status_code == 200
    print(res.text)


def test_wallet():
    "show wallet for user associated with api key"

    res = requests.get(
        LNBITS_HOST + "/api/v1/wallet",
        headers={"X-Api-Key": LNBITS_API_KEY},
        verify=False,
    )
    assert res.status_code == 200
    pprint.pprint(res.json())


def test_create_wallet():
    "create a new wallet"

    res = requests.post(
        LNBITS_HOST + "/api/v1/wallet",
        headers={"X-Api-Key": LNBITS_API_KEY},
        verify=False,
        json={"name": "test wallet"},
    )

    assert res.status_code == 200
    pprint.pprint(res.json())


def test_decode():
    "decode a bolt11 invoice"

    res = requests.post(
        LNBITS_HOST + "/api/v1/payments/decode",
        headers={"X-Api-Key": LNBITS_API_KEY},
        verify=False,
        json={
            "data": "lntb500n1pjhp3s2pp5tp5farf5v644x8j0gsthmyxzdkdtp3mylr5m0edyepyyl5ues9uqdqhw35xjueqd9ejqcfqw3jhxaqcqzzsxqzjcsp5jttxa5u5e6edj4jsex5xa0wkzkkzg2a2x25qhsn3lswvzjympxtq9qyyssqvkh74rdhmmspek9cpnz2dax3pqemv9rjpcat9f8gf8uy532mqjnk806ljsup0sql62zsa4mlw0gau0x5teakfcwydlf5c6l0s2scxespwlnyyw"
        },
    )
    assert res.status_code == 200
    pprint.pprint(res.json())


def test_invoice():
    "create an invoice"

    res = requests.post(
        LNBITS_HOST + "/api/v1/payments",
        headers={"X-Api-Key": LNBITS_API_KEY},
        verify=False,
        json={"out": False, "amount": 50, "memo": "test invoice"},
    )
    assert res.status_code == 201
    pprint.pprint(res.json())


def test_pay():
    "pay an invoice"

    bolt11 = "lntb500n1pjckt8ppp5j88en48cxg6p3rpqtr3qmtk6w8fdqczqgw7h5tsa26l7y89f4hcqdq5w3jhxapqd9h8vmmfvdjscqzzsxqzjcsp5t9k4zgmngs9c3r6lhcd2aga4nalf8d6qtck27cf7tnxpz32d0nlq9qyyssqdkpn0r6tuna08v9s746w9wjhfhhv8aw4r8pk5p6h6w7h7su3vuwxynr40cw58e5mru8ustsrrz0gv70zcjt29rmp739tjf2g324xqcgqtcptjc"

    res = requests.post(
        LNBITS_HOST + "/api/v1/payments",
        headers={"X-Api-Key": LNBITS_API_KEY},
        verify=False,
        json={
            "out": True,
            "bolt11": bolt11,
        },
    )
    assert res.status_code == 201
    pprint.pprint(res.json())


def test_check():
    "check if invoice is paid"

    payment_hash = "5d0ff92844b21f8b62079843490f0dae9452d88dcb138669110d73492d0ad8aa"

    res = requests.get(
        LNBITS_HOST + "/api/v1/payments/" + payment_hash,
        headers={"X-Api-Key": LNBITS_API_KEY},
        verify=False,
    )

    assert res.status_code == 200
    pprint.pprint(res.json())


def test_topup():
    "top up wallet, fund it from lightning source"

    res = requests.put(
        LNBITS_HOST + "/admin/api/v1/topup/",
        headers={"X-Api-Key": LNBITS_API_KEY},
        verify=False,
        params={"usr": LNBITS_USR},
        json={"id": "f112b1ad37e043e380cb26365690b3b1", "amount": 50},
    )

    assert res.status_code == 200
    pprint.pprint(res.json())
