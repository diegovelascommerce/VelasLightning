"""
These are a list of REST API functions that will be runing on the same machine
as the rasperblitz.

These functons are necessary for workit to integrate lightning awards to their
app.

"""

import json

import pytest
from flask import Flask

from ..app import configure_routes
from ..LAPP.velas import Velas

# from urllib import response


NODE_ID = "03e347d089c071c27680e26299223e80a740cf3e3fc4b4237fa219bb67121a670b"  # noqa

TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ2ZWxhcyIsInN1YiI6IndvcmtpdCJ9.CnksMqUsywjH4W8JgPePodi10pO_xJMrPyq9c19tQmo"


@pytest.fixture
def client():
    velas = Velas()
    app = Flask(__name__)
    configure_routes(app, velas)
    client = app.test_client()
    return client


def test_hello(client):
    res = client.get('/',
                     headers=dict(
                         Authorization=f"Bearer {TOKEN}"
                     ))
    print(res.text)


def test_getinfo(client):
    res = client.get("/getinfo",
                     headers=dict(
                         Authorization=f"Bearer {TOKEN}"
                     ))

    assert res is not None
    print(res.text)
    info = json.loads(res.text)
    assert info['identity_pubkey'] == "029cba2eb9edf18352e90f1a5f71e367af80d6e3ab7a5aa6122309fcbcd4375735"  # noqa


def test_openchannel(client):
    """
    Create outbounded channel with workit app.

    the workit app will provide the nodeId, address, and port so that we can create
    an outbounded channel with workit app.
    """
    data = {
        'nodeId': NODE_ID,
        'amt': 20000
    }
    response = client.post('/openchannel',
                           data=json.dumps(data),
                           content_type='application/json',
                           headers=dict(
                               Authorization=f"Bearer {TOKEN}"
                           ))

    print(response)

    assert response.status_code == 200

    print(response.text)


def test_closechannel(client):
    data = {
        'txid': "22575680d830ff738205fa1cbee9f2a4a50a4171c61a920b0748b3c55adee995",  # noqa
        'vout': 1,
        'force': False
    }
    print(data)
    response = client.post('/closechannel',
                           data=json.dumps(data),
                           content_type='application/json',
                           headers=dict(
                               Authorization=f"Bearer {TOKEN}"
                           ))

    print(response)
    print(response.text)

    assert response.status_code == 200

    print(response.text)


def test_listchannels(client):
    data = {
        'peer': NODE_ID,
        'active_only': True,
        'inactive_only': False,
        'public_only': True,
        'private_only': False
    }
    response = client.post('/listchannels',
                           data=json.dumps(data),
                           content_type='application/json',
                           headers=dict(
                               Authorization=f"Bearer {TOKEN}"
                           ))

    print(response)

    assert response.status_code == 200

    print(response.text)


def test_decodereq(client):
    data = {
        'bolt11': "lntb2u1p3ms7ulpp5kcy46uadkkzn2ec3q84sjkhtpw4rvm0atfyy204mefzyhj20cfcqdp9wpkx2ctnv5s8qcteyp6x7grkv4kxzum5v4ehgcqzpgxqyz5vqsp5sn0209yqdfku0anll6gvjc3xve9gf0jcq2j285az6xky7jc8vyrs9qyyssqmfl3y4r08mua52yt83cd2qyq67qcvll28p2jg8ffkeygnnaqk92juym0ctka9y49hf2jmjkkdupkr5f74aujja8yxpkaump55605szqq45cfjs"  # noqa
    }
    response = client.post('/decodereq',
                           data=json.dumps(data),
                           content_type='application/json',
                           headers=dict(
                               Authorization=f"Bearer {TOKEN}"
                           ))

    assert response is not None

    print(response)


def test_payinvoice(client):
    data = {
        'bolt11': "lntb2u1p3a9h0npp5nyrz2n4xqdw3xfkc7g2sr0v0h22egv0zrlz73cewf0p40z8alnqqdzqw35xjueqd9ejqcfqw3jhxapqveex7mfqv35k2em0yaejqunpwdcxyetjwfujqurfcqzpgxqyz5vqsp5y5m89ru9yudfl7wqxktwda5hf3u4z5u68ys33rs6nt2d3qrjqcps9qyyssqcd8xjyhf62yemamaa57evn8y7as48pda5dc2aftg4ytyh3200xfn78jnrxgprmyxnajxckfj6rh77k3asx2tym56pwvj6crykf3h7rgqxn6v83"  # noqa
    }
    response = client.post('/payinvoice',
                           data=json.dumps(data),
                           content_type='application/json',
                           headers=dict(
                               Authorization=f"Bearer {TOKEN}"
                           ))

    assert response is not None

    print(response)
