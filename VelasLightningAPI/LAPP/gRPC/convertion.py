import base64


def str_to_bytes(text: str) -> bytes:
    res = text.encode('ascii')
    return res


def hex_to_bytes(hextext: str) -> bytes:
    res = bytes.fromhex(hextext)
    return res


def hex_to_base64(hextext: str) -> bytes:
    btext = hex_to_bytes(hextext)
    res = bytes_to_base64(btext)
    return res


def base64_to_hex(b64bytes: bytes) -> str:
    btext = base64.b64decode(b64bytes)
    res = btext.hex()
    return res


def bytes_to_str(btext: bytes) -> str:
    res = btext.decode('ascii')
    return res


def str_to_hex(text: str) -> str:
    btext = text.encode('ascii')
    res = btext.hex()
    return res


def bytes_to_base64(btext: bytes) -> bytes:
    res = base64.b64encode(btext)
    return res


def hex_to_str(oxtext: str) -> str:
    res = bytes.fromhex(oxtext).decode('ascii')
    return res


def str_to_base64(message: str) -> str:
    message_bytes = message.encode('ascii')
    base64_bytes = base64.b64encode(message_bytes)
    base64_message = base64_bytes.decode('ascii')
    return base64_message


def base64_to_str(base64_message: str) -> str:
    base64_bytes = base64_message.encode('ascii')
    message_bytes = base64.b64decode(base64_bytes)
    message = message_bytes.decode('ascii')
    return message
