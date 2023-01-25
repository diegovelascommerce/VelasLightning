import jwt
import pytest

from .. import velas_jwt

TEST_PAYLOAD = {'some': 'payload'}
TEST_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzb21lIjoicGF5bG9hZCJ9.4twFt5NiznN84AWoo1d7KO1T_yoc0Z6XOpOVswacPZg"  # noqa
TOKEN_WORKIT = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ2ZWxhcyIsInN1YiI6IndvcmtpdCJ9.CnksMqUsywjH4W8JgPePodi10pO_xJMrPyq9c19tQmo"
TOKEN_PHONY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOIJ2ZWxhcyIsInN1YiI6IndvcmtpdCJ9.CnksMqUsywjH4W8JgPePodi10pO_xJMrPyq9c19tQmo"
SECRET = 'secret'


def test_create_jwt():
    token = velas_jwt.create_jwt(TEST_PAYLOAD)
    assert token is not None
    assert token == TEST_TOKEN

    token = velas_jwt.create_jwt({'iss': 'velas', 'sub': 'workit'})
    assert token == TOKEN_WORKIT


def test_verify_jwt():
    payload = velas_jwt.verify_jwt(TEST_TOKEN)
    assert payload == {'some': 'payload'}

    payload = velas_jwt.verify_jwt(TOKEN_WORKIT)
    assert payload == {'iss': 'velas', 'sub': 'workit'}

    with pytest.raises(jwt.exceptions.InvalidSignatureError):
        payload = velas_jwt.verify_jwt(TOKEN_PHONY)
