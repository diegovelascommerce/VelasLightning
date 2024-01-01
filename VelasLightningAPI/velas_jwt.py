import jwt

from config import config


def create_jwt(payload: dict) -> str:
    print(f"secret:{config['secret']}")
    token = jwt.encode(payload, config["secret"], algorithm="HS256")
    return token


def verify_jwt(token) -> dict:
    payload = jwt.decode(token, config["secret"], algorithms=["HS256"])
    return payload


if __name__ == "__main__":
    token = create_jwt({"iss": "velas", "sub": "workit"})
    print(token)
