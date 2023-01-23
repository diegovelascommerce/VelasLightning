import re
from functools import wraps

from flask import jsonify, request

from velas_jwt import verify_jwt


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
        res = velas.openchannel(nodeId, amt)
        print(res)
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
        res = velas.closeChannel(txid, vout)

        return {
            "txid": res,
        }

    @app.route('/listchannels', methods=['post'])
    def listchannels():
        data = request.get_json()
        peer = data.get('peer')
        res = velas.listchannels(peer)

        channels = []
        for chan in res.channels:
            channels.append({
                "remote_pubkey": chan.remote_pubkey,
                "channel_point": chan.channel_point,
                "capacity": chan.capacity,
                "local_balance": chan.local_balance
            })

        return {
            "channels": channels,
        }

    # @app.route('/submit_bolt11', methods=['POST'])
    # def submit_bolt11():
    #     """Passes bolt11 to LAPP."""
    #     print("submitBolt11")
    #     data = request.get_json()
    #     bolt11 = data.get('bolt11')
    #     velas.payBolt11(bolt11)
    #     return "Ok", 200
