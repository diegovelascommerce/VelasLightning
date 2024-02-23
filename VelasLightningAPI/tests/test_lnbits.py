import os
import pprint
import pytest

import requests
from dotenv import load_dotenv  # type: ignore

# load environment variables from .env file
load_dotenv(override=True)

# host address of lnbits test server
LNBITS_HOST = ""
env = os.getenv("LNBITS_HOST")
if env is not None:
    print("LNBITS_HOST: ", env)
    LNBITS_HOST = env

# host address of lnbits test server
SUPER_USER = ""
env = os.getenv("SUPER_USER")
if env is not None:
    print("SUPER_USER: ", env)
    SUPER_USER = env

# admin key for workit wallet
WORKIT_ADMINKEY = ""
env = os.getenv("WORKIT_ADMINKEY")
if env is not None:
    WORKIT_ADMINKEY = env

# admin key for erik wallet
ERIK_ADMINKEY = ""
env = os.getenv("ERIK_ADMINKEY")
if env is not None:
    ERIK_ADMINKEY = env

# admin key for diego wallet
DIEGO_ADMINKEY = ""
env = os.getenv("DIEGO_ADMINKEY")
if env is not None:
    DIEGO_ADMINKEY = env


def test_lnbits():
    "just test the welcome screen for lnbits"

    res = requests.get(LNBITS_HOST, verify=False)
    assert res.status_code == 200
    print(res.text)


def test_health():
    "show the wallet associated with api key"

    url = LNBITS_HOST + "/api/v1/health"

    res = requests.get(
        url,
        headers={"X-Api-Key": WORKIT_ADMINKEY},
        verify=False,
    )
    assert res.status_code == 200
    pprint.pprint(res.json())


def test_wallet():
    "show the wallet associated with api key"

    res = requests.get(
        LNBITS_HOST + "/api/v1/wallet",
        headers={"X-Api-Key": WORKIT_ADMINKEY},
        verify=False,
    )
    assert res.status_code == 200
    data = res.json()
    pprint.pprint(data)

    assert "id" in data
    assert "name" in data
    assert "balance" in data


def test_create_wallet():
    "create a new wallet for a user"

    data = {"name": "foobar wallet"}

    res = requests.post(
        LNBITS_HOST + "/api/v1/wallet",
        headers={"X-Api-Key": WORKIT_ADMINKEY},
        verify=False,
        json=data,
    )

    assert res.status_code == 200
    data = res.json()
    pprint.pprint(data)
    assert "id" in data
    assert "user" in data
    assert "name" in data
    assert "adminkey" in data
    assert "balance_msat" in data


def test_decode():
    "decode a bolt11 invoice"

    res = requests.post(
        LNBITS_HOST + "/api/v1/payments/decode",
        headers={"X-Api-Key": WORKIT_ADMINKEY},
        verify=False,
        json={
            "data": "lnbc50n1pja3m6xpp5wanddj7curc5t2f43fas4zegcpcws6v0sylhmpvahq0net3hazysdpgw35xjueqd9ejqcfqw3jhxapqvehhygp4ypekzarncqzzsxqrrsssp5dgd30mq3em33vkga37mu9jfz6far52fv4dze2x5kvcna9vu8jseq9qyyssqn40reudsj8nvrtn89p908sr0hsegxfl8g2tuphknv4slzrfkhkwkhexvvc40dmlgghnq4ygq25nffkug48uw06gfexsz9zaaa85sgscpv6uqzs"
        },
    )
    assert res.status_code == 200
    data = res.json()
    pprint.pprint(data)
    assert "payment_hash" in data
    assert "payment_secret" in data
    assert "description" in data
    assert "amount_msat" in data


def test_decode_with_superuser():
    "decode a bolt11 created from a test wallet as super user"

    # create bolt11 invoice with test user
    data = {"out": False, "amount": 50, "memo": "test invoice for decode"}

    resBolt11 = requests.post(
        LNBITS_HOST + "/api/v1/payments",
        headers={"X-Api-Key": ERIK_ADMINKEY},
        verify=False,
        json=data,
    )

    invoice = resBolt11.json()

    print("...invoice created by test user")
    pprint.pprint(invoice)

    # decode the bolt11 invoice with super user
    bolt11 = invoice["payment_request"]

    resDecode = requests.post(
        LNBITS_HOST + "/api/v1/payments/decode",
        headers={"X-Api-Key": WORKIT_ADMINKEY},
        verify=False,
        json={
            "data": bolt11,
        },
    )

    decodedInvoice = resDecode.json()

    assert "amount_msat" in decodedInvoice
    assert "description" in decodedInvoice
    assert decodedInvoice["amount_msat"] == 50000
    assert decodedInvoice["description"] == "test invoice for decode"

    print("...invoice decoded by super user")
    pprint.pprint(decodedInvoice)


def test_user_create_invoice():
    "create an invoice for user"

    # specify the amount and memo for the invoice you want to create
    data = {"out": False, "amount": 50, "memo": "test invoice"}

    res = requests.post(
        LNBITS_HOST + "/api/v1/payments",
        headers={"X-Api-Key": DIEGO_ADMINKEY},
        verify=False,
        json=data,
    )
    assert res.status_code == 201
    invoice = res.json()
    pprint.pprint(invoice)
    assert "payment_hash" in invoice
    assert "payment_request" in invoice


def test_user_pay_invoice():
    "have a user pay an invoice"

    # create a bolt11 from a test user
    data = {"out": False, "amount": 5, "memo": "test invoice for 5sats"}

    res = requests.post(
        LNBITS_HOST + "/api/v1/payments",
        headers={"X-Api-Key": DIEGO_ADMINKEY},
        verify=False,
        json=data,
    )
    assert res.status_code == 201
    invoice = res.json()

    bolt11 = invoice["payment_request"]

    # pay the bolt11 invoice with super user
    body = {
        "out": True,
        "internal": True,
        "bolt11": bolt11,
    }

    res = requests.post(
        LNBITS_HOST + "/api/v1/payments",
        headers={"X-Api-Key": WORKIT_ADMINKEY},
        verify=False,
        json=body,
    )
    assert res.status_code == 201
    data = res.json()
    pprint.pprint(data)
    assert "payment_hash" in data
    assert "checking_id" in data


def test_check_invoice():
    "check if invoice was paid"

    payment_hash = (
        "5f82041eceeaa30134f36900cdb9c973029ff545613640c9999b012a63ba8981"
    )

    res = requests.get(
        LNBITS_HOST + "/api/v1/payments/" + payment_hash,
        headers={"X-Api-Key": WORKIT_ADMINKEY},
        verify=False,
    )

    assert res.status_code == 200
    invoice = res.json()
    assert "paid" in invoice
    assert invoice["paid"] is True
    assert "details" in invoice
    assert "bolt11" in invoice["details"]
    assert "payment_hash" in invoice["details"]
    assert "memo" in invoice["details"]
    assert payment_hash == invoice["details"]["payment_hash"]
    pprint.pprint(invoice)


@pytest.mark.skip(reason="topup is not allowed for voltage")
def test_topup():
    "top up wallet, fund it from lightning source"

    # specify the wallet you want to give funds to and the amount
    body = {"id": DIEGO_ADMINKEY, "amount": 50}

    res = requests.put(
        LNBITS_HOST + "/admin/api/v1/topup/",
        params={"usr": WORKIT_ADMINKEY},
        json=body,
        verify=False,
    )

    assert res.status_code == 200
    data = res.json()
    pprint.pprint(data)
    assert "status" in data
    assert data["status"] == "Success"


def test_create_user():
    """create a new user"""

    res = requests.post(
        LNBITS_HOST + "/usermanager/api/v1/users",
        headers={"X-Api-Key": WORKIT_ADMINKEY},
        verify=False,
        json={
            "user_name": "pytest",
            "wallet_name": "pytest-wallet",
            "email": "pytest@email.com",
            "password": "pytest",
        },
    )
    assert res.status_code == 200
    data = res.json()
    pprint.pprint(data)
    assert "email" in data
    assert "extra" in data
    assert "id" in data
    assert "name" in data
    assert "password" in data
    assert "wallets" in data

    wallet = data["wallets"][0]
    assert "admin" in wallet
    assert "adminkey" in wallet
    assert "id" in wallet
    assert "inkey" in wallet
    assert "name" in wallet
    assert "user" in wallet


def test_get_users():
    """show all the users that you created with super user"""

    res = requests.get(
        LNBITS_HOST + "/usermanager/api/v1/users",
        headers={"X-Api-Key": WORKIT_ADMINKEY},
        verify=False,
    )
    assert res.status_code == 200
    users = res.json()
    pprint.pprint(users)
    for user in users:
        pprint.pprint(user)
        assert "admin" in user
        assert user["admin"] == SUPER_USER
        assert "email" in user
        assert "id" in user
        assert "name" in user


def test_get_user_info():
    """get info on user, wallets, api keys, etc"""

    resUsers = requests.get(
        LNBITS_HOST + "/usermanager/api/v1/users",
        headers={"X-Api-Key": WORKIT_ADMINKEY},
        verify=False,
    )
    assert resUsers.status_code == 200
    users = resUsers.json()
    for user in users:
        # get user id
        userId = user["id"]

        # get user info
        resUser = requests.get(
            LNBITS_HOST + "/usermanager/api/v1/users/" + userId,
            headers={"X-Api-Key": WORKIT_ADMINKEY},
            verify=False,
        )
        assert resUser.status_code == 200
        user = resUser.json()
        assert "admin" in user
        assert user["admin"] == SUPER_USER
        assert "id" in user
        assert "email" in user
        assert "wallets" in user
        for wallet in user["wallets"]:
            assert "id" in wallet
            assert "adminkey" in wallet
            assert "name" in wallet
            pprint.pprint(wallet)


def test_get_user_wallet():
    """get wallet info for user"""
    resUsers = requests.get(
        LNBITS_HOST + "/usermanager/api/v1/users",
        headers={"X-Api-Key": WORKIT_ADMINKEY},
        verify=False,
    )
    assert resUsers.status_code == 200
    users = resUsers.json()
    for user in users:
        # get user id
        userId = user["id"]

        # get user info
        resUser = requests.get(
            LNBITS_HOST + "/usermanager/api/v1/users/" + userId,
            headers={"X-Api-Key": WORKIT_ADMINKEY},
            verify=False,
        )
        assert resUser.status_code == 200
        user = resUser.json()
        for wallet in user["wallets"]:
            adminKey = wallet["adminkey"]
            resWallet = requests.get(
                LNBITS_HOST + "/api/v1/wallet",
                headers={"X-Api-Key": adminKey},
                verify=False,
            )
            assert resWallet.status_code == 200
            wallet = resWallet.json()
            assert "balance" in wallet
            assert "id" in wallet
            assert "name" in wallet
            pprint.pprint(wallet)
