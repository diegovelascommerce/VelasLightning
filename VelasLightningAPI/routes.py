from flask import request


def configure_routes(app, velas):
    """Configure routes for the app."""

    @app.route('/')
    def index():
        """Just a basic route for testing purposes."""
        return "Hello VelasLightning"

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
