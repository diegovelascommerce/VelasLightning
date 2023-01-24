# Example Lightning App (LApp)

## Velas LApp

[![Build Status](https://travis-ci.org/joemccann/dillinger.svg?branch=master)](https://travis-ci.org/joemccann/dillinger)

The Velas LApp is client side software that can use python scripts to control an LND node. It is a Python application designed to run on a Ubuntu Server running LND.

For example, it can be used for:

- Create channels
- Send payments
- Create invoices
- Stream payments

The LApp mainly follows this set of instructions by Lightning Labs [How to write a Python gRPC client for the Lightning Network Daemon](https://github.com/lightningnetwork/lnd/blob/master/docs/grpc/python.md)

## Features

Currently the Velas LApp is built to support lightning.proto gRPC calls. We have working examples of the following:

- Hello World - Communication test
- GetInfo - Returns basic information about the LND node
- OpenChannel - Options a channel between the LND node and another node
- CloseChannel - Closes a channel given the channel point
- ListChannels - returns channel balances, optional to pass in a pub key to be given info about only that remote node balance
- SubmitBolt11 - Submit a bolt 11 invoice to be paid automatically
- WalletBalance - Retrieve and display the on-chain wallet balance
- A complete list of supported gRPC API calls is located here [ln.proto](https://github.com/lightningnetwork/lnd/blob/de3e0d7875de11d8f04c29e2d58f8bdc8d4051d7/lnrpc/lightning.proto)

## Tech

The Velas LApp uses a number of open source projects to work properly:

- [Python] - a programming language that lets you work quickly
  and integrate systems more effectively.
- [VirtualEnv] - a tool to create isolated Python environments.
- [LND] - a complete implementation of a Lightning Network node.
- [googleapis] - the original interface definitions of public Google APIs that support both REST and gRPC protocols.

And of course the Velas LApp itself is open source with a [public repository][dill]
on GitHub.

## Setup and Installation

Lnd uses the gRPC protocol for communication with clients like lncli. gRPC is based on protocol buffers and as such, you will need to compile the lnd proto file in Python before you can use it to communicate with lnd.

1. Create a virtual environment for your project

```sh
$ virtualenv lnd
```

2. Activate the virtual environment

```
$ source lnd/bin/activate
```

3. Install dependencies (googleapis-common-protos is required due to the use of google/api/annotations.proto)

```
lnd $  pip install grpcio grpcio-tools googleapis-common-protos
```

4. Clone the google api's repository (required due to the use of google/api/annotations.proto)

```
lnd $  git clone https://github.com/googleapis/googleapis.git
```

5. Copy the lnd lightning.proto file (you'll find this at [ln.proto](https://github.com/lightningnetwork/lnd/blob/de3e0d7875de11d8f04c29e2d58f8bdc8d4051d7/lnrpc/lightning.proto) or just download it

```
lnd $  curl -o lightning.proto -s https://raw.githubusercontent.com/lightningnetwork/lnd/master/lnrpc/lightning.proto
```

6. Compile the proto file

```
lnd $  python -m grpc_tools.protoc --proto_path=googleapis:. --python_out=. --grpc_python_out=. lightning.proto
```

After following these steps, two files lightning_pb2.py and lightning_pb2_grpc.py will be generated. These files will be imported in your project anytime you use Python gRPC.

\*Note: It is possible to setup RPC modules for subservers. We skipped this for our LApp. If wanted, instructions can be found here: [Generating RPC modules for subservers](https://github.com/lightningnetwork/lnd/blob/master/docs/grpc/python.md#generating-rpc-modules-for-subservers))

## Imports

Every time you use Python gRPC, you will have to import the generated rpc modules and set up a channel and stub to your connect to your lnd node.

To authenticate using macaroons you need to include the macaroon in the metadata of the request. This is included in the Client run.py as an example for running on Regtest using Polar and needs to be adapted for use in Testnet or Mainnet applications.

\*Note that when an IP address is used to connect to the node

```sh
(e.g. 192.168.1.21 instead of localhost)
```

you need to add

```sh
--tlsextraip=192.168.1.21
```

to your lnd configuration and re-generate the certificate (delete tls.cert and tls.key and restart lnd).

## Client

The following code is contained in the run.py file and contains the bulk of the logic needed to run the LApp

```sh
import lightning_pb2 as ln
import lightning_pb2_grpc as lnrpc
import grpc
import os
import codecs

# Due to updated ECDSA generated tls.cert we need to let gprc know that
# we need to use that cipher suite otherwise there will be a handhsake
# error when we communicate with the lnd rpc server.
os.environ["GRPC_SSL_CIPHER_SUITES"] = 'HIGH+ECDSA'

# Lnd cert is at ~/.lnd/tls.cert on Linux and
# ~/Library/Application Support/Lnd/tls.cert on Mac
cert = open(os.path.expanduser('/home/hannah/.polar/networks/1/volumes/lnd/alice/tls.cert'), 'rb').read()
creds = grpc.ssl_channel_credentials(cert)

# Lnd admin macaroon is at ~/.lnd/data/chain/bitcoin/simnet/admin.macaroon on Linux and
# ~/Library/Application Support/Lnd/data/chain/bitcoin/simnet/admin.macaroon on Mac
with open(os.path.expanduser('/home/hannah/.polar/networks/1/volumes/lnd/alice/data/chain/bitcoin/regtest/admin.macaroon'), 'rb') as f:
    macaroon_bytes = f.read()
    macaroon = codecs.encode(macaroon_bytes, 'hex')

def metadata_callback(context, callback):
    # for more info see grpc docs
    callback([('macaroon', macaroon)], None)

# build ssl credentials using the cert the same as before
cert_creds = grpc.ssl_channel_credentials(cert)

# now build meta data credentials
auth_creds = grpc.metadata_call_credentials(metadata_callback)

# combine the cert credentials and the macaroon auth credentials
# such that every call is properly encrypted and authenticated
combined_creds = grpc.composite_channel_credentials(cert_creds, auth_creds)

channel = grpc.secure_channel('localhost:10001', combined_creds)
stub = lnrpc.LightningStub(channel)

# now every call will be made with the macaroon already included
stub.GetInfo(ln.GetInfoRequest())

# Retrieve and display the wallet balance
response = stub.WalletBalance(ln.WalletBalanceRequest())
print(response.total_balance)
```

## More examples

More examples, including streaming payments via RPC can be found here: [Examples](https://github.com/lightningnetwork/lnd/blob/master/docs/grpc/python.md#examples))

## License

MIT

**Free Software, Hell Yeah!**

[//]: # "These are reference links used in the body of this note and get stripped out when the markdown processor does its job. There is no need to format nicely because it shouldn't be seen. Thanks SO - http://stackoverflow.com/questions/4823468/store-comments-in-markdown-syntax"
[dill]: https://github.com/joemccann/dillinger
[git-repo-url]: https://github.com/joemccann/dillinger.git
[john gruber]: http://daringfireball.net
[lnd]: https://github.com/lightningnetwork/lnd
[virtualenv]: https://virtualenv.pypa.io/en/latest/
[googleapis]: https://github.com/googleapis/googleapis.git
[python]: https://www.python.org/downloads/
