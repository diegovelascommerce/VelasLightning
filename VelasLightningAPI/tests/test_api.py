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


def test_submit_bolt11(client):
    """
    this is where workit will submit a bolt11 invoice to be payed automatically.

    the workit app will create the invoice but it the workit backend that will forward it
    to the REST API for raspberryblitz.
    """
    data = {"bolt11": "testBolt11Invoice"}
    response = client.post('/submit_bolt11',
                           data=json.dumps(data),
                           content_type='application/json')
    assert response.status_code == 200
    assert response.text == "Ok"
