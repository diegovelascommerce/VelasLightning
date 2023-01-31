from velas_jwt import verify_jwt
from config import config
from flask import jsonify, request
import re
from functools import wraps
import requests
import socket


def get_urls():
    public_ip = requests.get('https://checkip.amazonaws.com').text.strip()
    local_ip = config['grpc']['ip']
    if local_ip == "127.0.0.1":
        hostname = socket.gethostname()
        local_ip = socket.gethostbyname(hostname)

    return {
        "local": local_ip,
        "public": public_ip
    }


def token_required(f):
    @wraps(f)
    def decorator(*args, **kwargs):
        token = None

        # ensure the jwt-token is passed with the headers
        if 'Authorization' in request.headers:
            text = request.headers['Authorization']
            token = re.search("Bearer (.*)", text).group(1)

        if not token:
            return jsonify({"message": "A valid token is missing!"}), 401

        try:
            verify_jwt(token)
        except:  # noqa
            return jsonify({"message": "Invalid token!"}), 401

        return f(*args, **kwargs)
    return decorator


def configure_routes(app, velas):
    """Configure routes for the app."""

    @app.route('/')
    @token_required
    def index():
        """Just a basic route for testing purposes."""
        return "Hello VelasLightning"

    @app.route('/getinfo')
    @token_required
    def getinfo():
        info = velas.getinfo()
        return {
            "identity_pubkey": info.identity_pubkey,
            "urls": get_urls(),
            "alias": info.alias,
            "num_active_channels": info.num_active_channels,
            "num_inactive_channels": info.num_inactive_channels,
            "num_peers": info.num_peers,
            "block_height": info.block_height,
            "block_hash": info.block_hash,
            "best_header_timestamp": info.best_header_timestamp
        }

    @app.route('/openchannel', methods=['post'])
    @token_required
    def openchannel():
        """
        Create a channel from nodeId, address and port
        """
        data = request.get_json()
        nodeId = data.get('nodeId')
        amt = data.get('amt')
        private = data.get('private')
        res = velas.openchannel(nodeId=nodeId, amt=amt, private=private)

        return {
            "txid": res[0],
            "vout": res[1]
        }

    @app.route('/closechannel', methods=['post'])
    @token_required
    def closechannel():
        data = request.get_json()
        txid = data.get('txid')
        vout = data.get('vout')
        force = data.get('force')

        print(data)
        res = velas.closeChannel(txid, vout, force)

        return {
            "txid": res,
        }

    @app.route('/listchannels', methods=['post'])
    @token_required
    def listchannels():
        data = request.get_json()
        peer = data.get('peer')
        active_only = data.get('active_only')
        inactive_only = data.get('inactive_only')
        public_only = data.get('public_only')
        private_only = data.get('private_only')

        print(data)

        res = velas.listchannels(peer,
                                 active_only=active_only,
                                 inactive_only=inactive_only,
                                 public_only=public_only,
                                 private_only=private_only)

        channels = []
        for chan in res.channels:
            print(chan)
            channels.append({
                "active": chan.active,
                "private": chan.private,
                "remote_pubkey": chan.remote_pubkey,
                "channel_point": chan.channel_point,
                "capacity": chan.capacity,
                "local_balance": chan.local_balance,
                "remote_balance": chan.remote_balance,
                "local_chan_reserve_sat": chan.local_chan_reserve_sat,
                "remote_chan_reserve_sat": chan.remote_chan_reserve_sat,
                "commit_fee": chan.commit_fee,
            })

        return {
            "channels": channels,
        }

    @app.route('/decodereq', methods=['post'])
    @token_required
    def decodereq():
        data = request.get_json()
        bolt11 = data.get('bolt11')

        res = velas.decodepayreq(pay_req=bolt11)
        print(res)
        return {
            "destination": res.destination,
            "payment_hash": res.payment_hash,
            "num_satoshis": res.num_satoshis,
            "description": res.description,
            "expiry": res.expiry,
            "timestamp": res.timestamp,
        }

    @app.route('/payinvoice', methods=['post'])
    @token_required
    def payinvoice():
        data = request.get_json()
        bolt11 = data.get('bolt11')

        res = velas.payinvoice(pay_req=bolt11)
        print(res)
        return res

    @app.errorhandler(Exception)
    def handle_exception(e):
        return {'message': repr(e)}, 500

    # @app.route('/submit_bolt11', methods=['POST'])
    # def submit_bolt11():
    #     """Passes bolt11 to LAPP."""
    #     print("submitBolt11")
    #     data = request.get_json()
    #     bolt11 = data.get('bolt11')
    #     velas.payBolt11(bolt11)
    #     return "Ok", 200
