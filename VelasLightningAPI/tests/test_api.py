"""
These are a list of REST API functions that will be runing on the same machine as the rasperblitz.

These functons are necessary for workit to integrate lightning awards to their app.


"""

from urllib import response
from flask import Flask
import pytest
import json

from ..app import configure_routes
from ..LAPP import Velas

TEST_NODE_ID = "03e347d089c071c27680e26299223e80a740cf3e3fc4b4237fa219bb67121a670b"
TEST_CHANNEL_ID = "2583303668972126208"


@pytest.fixture
def client():
    velas = Velas()
    app = Flask(__name__)
    configure_routes(app, velas)
    client = app.test_client()
    return client


def test_get_node_id(client):
    """Retrurn NodeId of lnd so that workit client and setup a peer connection with it."""
    response = client.get("/get_node_id")
    assert response.text == TEST_NODE_ID


def test_create_channel(client):
    """
    Create outbounded channel with workit app.
    
    the workit app will provide the nodeId, address, and port so that we can create
    an outbounded channel with workit app. 
    """
    data = {
        'nodeId':
        "02393813695fc7d7bc946ccfa64f65c7d699ac04ccf6b1b5198f1a33c975988e52",
        'address': "173.70.37.248",
        'port': 9735
    }
    response = client.post('/create_channel',
                           data=json.dumps(data),
                           content_type='application/json')
    assert response.status_code == 200
    assert response.text == TEST_CHANNEL_ID


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