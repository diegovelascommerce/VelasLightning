import LAPP.gRPC.convertion as convertion


def test_str_to_bytes():
    res = convertion.str_to_bytes("python")
    assert type(res) is bytes


def test_hex_to_bytes():
    hextext = convertion.str_to_hex("python")
    print(hextext)
    res = convertion.hex_to_bytes(hextext)
    print(res)
    assert type(res) is bytes


def test_hex_to_base64():
    hextext = convertion.str_to_hex("python")
    res = convertion.hex_to_base64(hextext)
    print(res)
    assert type(res) is bytes
    print(res.decode('ascii'))

    res = convertion.hex_to_base64(
        "03e347d089c071c27680e26299223e80a740cf3e3fc4b4237fa219bb67121a670b")

    print(res)


# def test_bytes_to_str():
#     btext = convertion.str_to_bytes("python")
#     res = convertion.bytes_to_str(btext)
#     assert res == "python"


# def test_str_to_hex():
#     res = convertion.str_to_hex("python")
#     assert res == "707974686f6e"


# def test_hex_to_str():
#     htext = convertion.str_to_hex("python")
#     res = convertion.hex_to_str(htext)
#     assert res == "python"


# def test_str_to_base64():
#     res = convertion.str_to_base64("python")
#     assert res == "cHl0aG9u"


# def test_base64_to_str():
#     message = convertion.str_to_base64("python")
#     res = convertion.base64_to_str(message)
#     assert res == "python"
