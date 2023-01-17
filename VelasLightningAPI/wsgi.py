from waitress import serve

from app import app

if __name__ == '__main__':
    print("started wsgi at port:5000")
    serve(app, host='0.0.0.0', port=5000, url_scheme='https')
