import os

import requests
from dotenv import load_dotenv

load_dotenv()

LNBITS_HOST = "https://lnbits.com"
env = os.getenv("LNBITS_HOST")
if env is not None:
    LNBITS_HOST = env

LNBITS_API_KEY = "api_key"
env = os.getenv("LNBITS_API_KEY")
if env is not None:
    LNBITS_API_KEY = env


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
    print(res.json())


def test_decode():
    "decode a bolt11 invoice"

    res = requests.get(
        LNBITS_HOST + "/api/v1/wallet",
        headers={"X-Api-Key": LNBITS_API_KEY},
        verify=False,
    )
    assert res.status_code == 200
    print(res.json())
