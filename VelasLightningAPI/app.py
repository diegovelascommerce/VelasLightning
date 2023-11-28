
from flask import Flask

from LAPP.velas import Velas
from routes import configure_routes
from config import config

app = Flask(__name__)
velas = Velas()
configure_routes(app, velas)

if __name__ == "__main__":
    print("...Running VelasLightningAPI")
    app.run(host=config['host'], port=config['port'])
