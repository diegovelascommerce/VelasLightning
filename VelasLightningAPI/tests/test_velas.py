from LAPP.velas import Velas


def test_get_info():
    velas = Velas()
    info = velas.get_info()
    assert info is not None
    print(info)
