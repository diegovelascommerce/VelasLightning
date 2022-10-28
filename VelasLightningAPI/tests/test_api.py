from urllib import response
from flask import Flask
import pytest
import json

from ..app import configure_routes
from ..LAPP import Velas


@pytest.fixture
def client():
    velas = Velas()
    app = Flask(__name__)
    configure_routes(app, velas)
    client = app.test_client()
    return client


def test_index(client):
    response = client.get("/")
    assert response.get_data() == b"Hello VelasLightning"
    assert response.status_code == 200


def test_submitBolt11(client):
    data = {"bolt11": "testBolt11Invoice"}
    response = client.post('/submitBolt11',
                           data=json.dumps(data),
                           content_type='application/json')
    assert response.status_code == 200