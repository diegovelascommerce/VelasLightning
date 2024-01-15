import os
import pprint

import requests
from dotenv import load_dotenv  # type: ignore

# load environment variables from .env file
load_dotenv()

# host address of lnbits test server
LNBITS_HOST = ""
env = os.getenv("LNBITS_HOST")
if env is not None:
    LNBITS_HOST = env

# super user setup for lnbits
SUPER_USER = ""
env = os.getenv("SUPER_USER")
if env is not None:
    SUPER_USER = env

# api key of the super user
SUPER_USER_API_KEY = ""
env = os.getenv("SUPER_USER_API_KEY")
if env is not None:
    SUPER_USER_API_KEY = env

# just a random test user that was setup
TEST_USER = ""
env = os.getenv("TEST_USER")
if env is not None:
    TEST_USER = env

# the api key of the test user
TEST_USER_API_KEY = ""
env = os.getenv("TEST_USER_API_KEY")
if env is not None:
    TEST_USER_API_KEY = env

# wallet of the test user
TEST_USER_WALLET = ""
env = os.getenv("TEST_USER_WALLET")
if env is not None:
    TEST_USER_WALLET = env


def test_lnbits():
    "just test the welcome screen for lnbits"

    res = requests.get(LNBITS_HOST, verify=False)
    assert res.status_code == 200
    print(res.text)


def test_wallet():
    "show the wallet associated with api key"

    res = requests.get(
        LNBITS_HOST + "/api/v1/wallet",
        headers={"X-Api-Key": SUPER_USER_API_KEY},
        verify=False,
    )
    assert res.status_code == 200
    pprint.pprint(res.json())


def test_create_wallet():
    "create a new wallet for a user"

    # specify the name of the wallet you want to create
    data = {"name": "test wallet"}

    res = requests.post(
        LNBITS_HOST + "/api/v1/wallet",
        headers={"X-Api-Key": SUPER_USER_API_KEY},
        verify=False,
        json=data,
    )

    assert res.status_code == 200
    pprint.pprint(res.json())


def test_decode():
    "decode a bolt11 invoice"

    res = requests.post(
        LNBITS_HOST + "/api/v1/payments/decode",
        headers={"X-Api-Key": SUPER_USER_API_KEY},
        verify=False,
        json={
            "data": "lntb500n1pjhp3s2pp5tp5farf5v644x8j0gsthmyxzdkdtp3mylr5m0edyepyyl5ues9uqdqhw35xjueqd9ejqcfqw3jhxaqcqzzsxqzjcsp5jttxa5u5e6edj4jsex5xa0wkzkkzg2a2x25qhsn3lswvzjympxtq9qyyssqvkh74rdhmmspek9cpnz2dax3pqemv9rjpcat9f8gf8uy532mqjnk806ljsup0sql62zsa4mlw0gau0x5teakfcwydlf5c6l0s2scxespwlnyyw"
        },
    )
    assert res.status_code == 200
    pprint.pprint(res.json())


def test_user_create_invoice():
    "create an invoice for user"

    # specify the amount and memo for the invoice you want to create
    data={"out": False, "amount": 50, "memo": "test invoice"}

    res = requests.post(
        LNBITS_HOST + "/api/v1/payments",
        headers={"X-Api-Key": TEST_USER_API_KEY},
        verify=False,
        json=data
    )
    assert res.status_code == 201
    invoice = res.json()
    pprint.pprint(invoice)
    assert "payment_hash" in invoice
    assert "payment_request" in invoice


def test_user_pay_invoice():
    "have a user pay an invoice"
    
    bolt11 = "lntb50n1pjegajtpp5urx7sc9dgh2q9waxxhs8v3ekqehfrxyff0hdl34lfl3elf64muqqdqqcqzzsxqyz5vqsp5uxdfz2ke3wn82x6cmqdpdslzxhup5aaqstjjq03hqg4gg3tjs0nq9qyyssquacvnxlqwn534r00g597s2pke2pph9q8795gqsyryvaspw8y59xrfwgdaumlevseq8da7uq4j7qsqtmsvqy07h6r27ktvcpp39nn87qq97z2tu"

    # specify the bolt11 invoice you want to pay
    body ={
        "out": True,
        "internal": True,
        "bolt11": bolt11,
    }

    res = requests.post(
        LNBITS_HOST + "/api/v1/payments",
        headers={"X-Api-Key": TEST_USER_API_KEY},
        verify=False,
        json=body
    )
    data = res.json()
    pprint.pprint(data)
    assert res.status_code == 201


def test_check_invoice():
    "check if invoice is paid"

    payment_hash = (
        "5d0ff92844b21f8b62079843490f0dae9452d88dcb138669110d73492d0ad8aa"
    )

    res = requests.get(
        LNBITS_HOST + "/api/v1/payments/" + payment_hash,
        headers={"X-Api-Key": SUPER_USER_API_KEY},
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


def test_topup():
    "top up wallet, fund it from lightning source"

    # specify the wallet you want to give funds to and the amount
    body = {"id": TEST_USER_WALLET, "amount": 50}

    res = requests.put(
        LNBITS_HOST + "/admin/api/v1/topup/",
        params={"usr": SUPER_USER},
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
        headers={"X-Api-Key": SUPER_USER_API_KEY},
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
        headers={"X-Api-Key": SUPER_USER_API_KEY},
        verify=False,
    )
    assert res.status_code == 200
    users = res.json()
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
        headers={"X-Api-Key": SUPER_USER_API_KEY},
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
            headers={"X-Api-Key": SUPER_USER_API_KEY},
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
        headers={"X-Api-Key": SUPER_USER_API_KEY},
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
            headers={"X-Api-Key": SUPER_USER_API_KEY},
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
