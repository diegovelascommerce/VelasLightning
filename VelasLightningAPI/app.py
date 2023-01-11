
from flask import Flask

from LAPP.velas import Velas
from routes import configure_routes

if __name__ == "__main__":
    print("...Running VelasLightningAPI")
    velas = Velas()
    app = Flask(__name__)
    configure_routes(app, velas)
    app.run(debug=True, ssl_context="adhoc")
