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


def test_reverse_hex():
    hextext = "03e347d089c071c27680e26299223e80a740cf3e3fc4b4237fa219bb67121a670b"  # noqa
    hexrev = convertion.reverse_hex(hextext)
    assert hexrev == "b076a12176bb912af7324b4cf3e3fc047a08e32299262e08672c170c980d743e30"  # noqa


def test_reverse_bytes():
    btest = b'\x89\x88\xd2"U\x1dV2\xbe]U7\x82:C\xab\x98\x0b\\\xbcg\x16\x80\x92\x97\xfbU\xf5\xd3\xc9\xf5o'
    brevtest = convertion.reverse_bytes(btest)
    hextest = convertion.bytes_to_hex(brevtest)
    print(hextest)
    assert hextest == "6ff5c9d3f555fb9792801667bc5c0b98ab433a8237555dbe32561d5522d28889"  # noqa


def test_hex_to_bytes_and_reverse():
    hextext = "6ff5c9d3f555fb9792801667bc5c0b98ab433a8237555dbe32561d5522d28889"
    btext = convertion.hex_to_bytes(hextext)
    brevtest = convertion.reverse_bytes(btext)
    assert brevtest == b'\x89\x88\xd2"U\x1dV2\xbe]U7\x82:C\xab\x98\x0b\\\xbcg\x16\x80\x92\x97\xfbU\xf5\xd3\xc9\xf5o'


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
