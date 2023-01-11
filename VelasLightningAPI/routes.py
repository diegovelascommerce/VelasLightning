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
            payload = verify_jwt(token)
            print(payload)
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
    def get_info():
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

    @app.route('/get_node_id', methods=['get'])
    def getNodeId():
        """ 
        Return the NodeId of the workit lightning node. 

        Workit client app will then use the nodeId to attempt to connect to it.

        return:
            the nodeId of the backend lightning node
        """
        return velas.getNodeID()

    @app.route('/create_channel', methods=['post'])
    def create_channel():
        """ 
        Create a channel from nodeId, address and port
        """
        data = request.get_json()
        nodeId = data.get('nodeId')
        address = data.get('address')
        port = data.get('port')
        res = velas.create_channel(nodeId, address, port)
        return res, 200

    @app.route('/submit_bolt11', methods=['POST'])
    def submit_bolt11():
        """Passes bolt11 to LAPP."""
        print("submitBolt11")
        data = request.get_json()
        bolt11 = data.get('bolt11')
        velas.payBolt11(bolt11)
        return "Ok", 200
