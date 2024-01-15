# LNBits

LNBits is a software layer on top of the lightning network which manages multiple wallets for a single lightning node.
All the funds are stored in the single lighting node but the funds are partitioned out by the wallets that are created on top of the lighting node.

## Unit test

these are unit test to help understand how the API for LNbits works. The are located under file `test_lnbits.py`.

to run these tests you need to have Pipenv installed (https://pipenv.pypa.io/en/latest/)

- pipenv is python virtual environment management tool.

- to load the virtual environment for this project go to the root of `velaslightningAPI/` and run the following command in the shell `pipenv shell`

  - this should load all the pip dependencies that this project uses which include `pytest`

- to run all the unit test type the following text in you console and hit enter `pytest tests/test_lnbits.py`

- to run a single test from `test_lnbits.py` type the following text into your console and press enter

also you will need a `.env` file that sets up the environment variables need to run these test. they contain things like where the LNBits test server is located and what user and apikey to use for these tests.

- the `.env` is not save in the repo. you need to request it through a secure channel like Signal or Slack

```bash
pytest tests/test_lnbits.py::<test_name>
```
