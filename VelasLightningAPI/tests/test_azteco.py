import os
import pprint

import requests
from dotenv import load_dotenv  # type: ignore

# load environment variables from .env file
load_dotenv()

AZTECO_HOST = "https://api.azte.co"

AZTECO_API_KEY = ""
env = os.getenv("AZTECO_API_KEY")
if env is not None:
    AZTECO_API_KEY = env


def test_get_price():
    "Test getting the price of bitcoin in USD."

    res = requests.get(
        AZTECO_HOST + "/v1/price/usd",
        headers={"X-Api-Key": AZTECO_API_KEY},
    )
    assert res.status_code == 200

    data = res.json()[0]

    assert "bitcoin_price" in data
    assert "currency" in data
    assert data["currency"] == "USD"
    assert "status" in data
    assert data["status"] == "success"

    pprint.pprint(data)


def test_get_balance():
    "Test getting your current top up balance."

    res = requests.get(
        AZTECO_HOST + "/v1/balance/usd",
        headers={"X-Api-Key": AZTECO_API_KEY},
    )
    assert res.status_code == 200

    data = res.json()[0]

    assert "balance" in data
    assert "currency" in data
    assert data["currency"] == "USD"
    assert "fx_rate" in data
    assert data["fx_rate"] == "1"
    assert "status" in data
    assert data["status"] == "success"

    pprint.pprint(data)


def test_get_statement():
    "Test getting a complete list of your sales"

    res = requests.get(
        AZTECO_HOST + "/v1/statement",
        headers={"X-Api-Key": AZTECO_API_KEY},
    )
    assert res.status_code == 200

    data = res.json()

    assert "bitcoin_total" in data[0]
    assert "commission_total" in data[0]
    assert "sales_total" in data[0]
    pprint.pprint(data[0])

    for item in data[1:]:
        assert "bitcoin" in item
        assert "commission" in item
        assert "currency" in item
        assert "fx_rate" in item
        assert "index" in item
        assert "timestamp" in item
        assert "total" in item
        assert "uniqe_id" in item
        pprint.pprint(item)


def test_stage_order():
    "Test staging an order to get an order_id for an on-chain voucher."

    res = requests.post(
        AZTECO_HOST + "/v1/stage/usd/1.00",
        headers={"X-Api-Key": AZTECO_API_KEY},
    )

    assert res.status_code == 200

    # this does not work, I suppose it's because I'm using a sandbox account
    data = res.json()[0]

    assert "order_id" in data
    assert "currency" in data
    assert "total" in data
    assert "purchase_amount" in data
    assert "commission" in data
    assert "network_fee" in data
    assert "bitcoin" in data
    assert "ttl" in data

    pprint.pprint(data)


def test_stage_lightning_order():
    "Test staging an lightning order."

    res = requests.post(
        AZTECO_HOST + "/v1/stage_lightning/usd/1.00",
        headers={"X-Api-Key": AZTECO_API_KEY},
    )

    assert res.status_code == 200

    data = res.json()[0]

    assert "bitcoin_price" in data
    assert "commission" in data
    assert "currency" in data
    assert "fx_rate" in data
    assert "network_fee" in data
    assert "order_id" in data
    assert "purchase_amount" in data
    assert "status" in data
    assert "total" in data
    assert "ttl" in data

    pprint.pprint(data)


def test_finalize_lightning_order():
    "finalize a lightning order"

    orderID = "3605275"

    res = requests.post(
        AZTECO_HOST + "/v1/order_lightning/" + orderID,
        headers={"X-Api-Key": AZTECO_API_KEY},
    )

    assert res.status_code == 200

    data = res.json()[0]

    assert "bitcoin_price" in data
    assert "commission" in data
    assert "fx_rate" in data
    assert "lnurl" in data
    assert "network_fee" in data
    assert "order_id" in data
    assert "purchase_amount" in data
    assert "reference_code" in data
    assert "total" in data

    pprint.pprint(data)


def test_buy_lightning():
    "create a boltt11 to receive lightning payment"

    res = requests.post(
        AZTECO_HOST + "/v1/buy_lightning/usd/1.00",
        headers={"X-Api-Key": AZTECO_API_KEY},
    )

    assert res.status_code == 200

    data = res.json()[0]
    assert "bitcoin_price" in data
    assert "commission" in data
    assert "currency" in data
    assert "fx_rate" in data
    assert "payment_request" in data
    assert "total" in data
    assert "uuid" in data

    pprint.pprint(data)


def test_buy_lightning_confirm():
    "confirm the payment of a lightning order"

    UUID = "0001-00000000-65bbe9b4-cd85-269f1cc5"
    res = requests.put(
        AZTECO_HOST + "/v1/buy_lightning_confirm/" + UUID,
        headers={"X-Api-Key": AZTECO_API_KEY},
    )

    assert res.status_code == 200

    data = res.json()[0]
    assert "payment_received_status" in data
    assert data["payment_received_status"] == "true"
    assert "status" in data
    assert data["status"] == "success"

    pprint.pprint(data)


def test_get_topup_address():
    "get a bitcoin address to top up your account"

    res = requests.get(
        AZTECO_HOST + "/v1/topup",
        headers={"X-Api-Key": AZTECO_API_KEY},
    )

    assert res.status_code == 200

    data = res.json()[0]
    assert "address" in data

    pprint.pprint(data)


def test_verify_voucher():
    "test check the status of a a voucher"

    # this is returned from the Finalize Lightning Order
    referenceCode = "8296130293832205"

    res = requests.get(
        AZTECO_HOST + "/v1/verify/" + referenceCode,
        headers={"X-Api-Key": AZTECO_API_KEY},
    )

    assert res.status_code == 200

    data = res.json()[0]

    assert "genuine" in data
    assert "redeem_date" in data
    assert "redeem_status" in data
    assert "sale_date" in data

    pprint.pprint(data)
