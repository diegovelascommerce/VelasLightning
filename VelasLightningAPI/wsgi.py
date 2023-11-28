from waitress import serve

from app import app
from config import config

if __name__ == '__main__':
    print(f"started wsgi at port:{config['port']}")
    serve(app, host=config['host'], port=config['port'], url_scheme='https')
