import jwt


def create_jwt(payload: dict, secret) -> str:
    print("create a jwt here")
    token = jwt.encode(payload, secret, algorithm='HS256')
    return token


def verify_jwt(token, secret) -> dict:
    payload = jwt.decode(token, secret, algorithms=['HS256'])
    return payload


if __name__ == '__main__':
    token = create_jwt({'iss': 'velas', 'sub': 'workit'}, 'secret')
    print(token)
