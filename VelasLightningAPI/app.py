from flask import Flask, render_template, request
import json
from LAPP import Velas


def configure_routes(app, velas):
    """Configure routes for the app."""

    @app.route('/')
    def index():
        """Just a basic route for testing purposes."""
        return "Hello VelasLightning"

    @app.route('/submitBolt11', methods=['POST'])
    def submitBolt11():
        """Passes bolt11 to LAPP."""
        print("submitBolt11")
        data = request.get_json()
        bolt11 = data.get('bolt11')
        velas.payBolt11(bolt11)
        return "Ok", 200


if __name__ == "__main__":
    print("...Running VelasLightningAPI")
    velas = Velas()
    app = Flask(__name__)
    configure_routes(app, velas)
    app.run(debug=True)