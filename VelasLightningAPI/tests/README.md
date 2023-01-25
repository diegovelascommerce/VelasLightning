# VelasAPI Tests

## _API calls for running various functions with your Lightning Application (LApp)_

The LApp has an API interface for communicating with an LND Node. Currently, it supports the following functions.

Important note: this interface currently only communicates with a testnet LND node. No real bitcoin are ever at risk using this interface.

- **HelloLightning** - Communication test
- **GetInfo** - Returns basic information about the LND node
- **OpenChannel** - Options a channel between the LND node and another node
- **CloseChannel** - Closes a channel given the channel point
- **ListChannels** - returns channel balances, optional to pass in a pub key to be given info about only that remote node balance
- **SubmitBolt11** - Submit a bolt 11 invoice to be paid automatically

Below the list of functions is a detail of each API call, the necessary parameters, and the response.

## HelloLightning

This is a basic test that tests the connection between the LApp and the LND node. Use this to ensure that the authentication tokens, macaroons, etc, are working correctly.

Method: GET

URL: https://45.33.22.210

Header: Authorization Token

Response: _Hello VelasLightning_

Example Curl Command:

```sh
$ curl -X GET -k -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ2ZWxhcyIsInN1YiI6IndvcmtpdCJ9.CnksMqUsywjH4W8JgPePodi10pO_xJMrPyq9c19tQmo' -i 'https://45.33.22.210'
```

## GetInfo

Returns basic information about the main LND node. It can also be used to make sure the main node is online.

Method: GET

URL: https://45.33.22.210/getinfo

Header: Authorization Token

Response: JSON

Example Response:

{"alias":"alias","best_header_timestamp":1674591574,"block_hash":"0000000000005f5e23b75491ddd7d41065e98aa8089f6a59832ea261c6f8eb4c","block_height":2417674,"identity_pubkey":"03e347d089c071c27680e26299223e80a740cf3e3fc4b4237fa219bb67121a670b","num_active_channels":20,"num_inactive_channels":13,"num_peers":18}

Example Curl Command:

```sh
$ curl -X GET -k -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ2ZWxhcyIsInN1YiI6IndvcmtpdCJ9.CnksMqUsywjH4W8JgPePodi10pO_xJMrPyq9c19tQmo' -i 'https://45.33.22.210/getinfo'
```

## OpenChannel

Opens a channel between the main LND node and another user node. The user node pub key and the channel amount, in Satoshis, must be specified.

// **TO-DO** - add option for opening a private channel - this is the type of channel we should be opening between the main node and user nodes.

**Notes:**

1. This only works when both nodes are online.
2. We are working on better error response messages here. We want to specify if the channel open failed because a node was offline, the channel amount was too small, etc.
3. The response, a combination of transaction id and output number is also known as the "channel point", and is needed for closing channels.

Method: POST

URL: https://45.33.22.210/openchannel

Header: Authorization Token

Body: JSON

{
"nodeId": "string",
"amt": integer
}

Response: JSON

Example Response:

{"txid":"f5f34632c74a5599bf2ce6a071371cfd543bc3c828b14c1e35e65d742570f984","vout":1}

Example Curl Command:

```sh
$ curl -X POST -k -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ2ZWxhcyIsInN1YiI6IndvcmtpdCJ9.CnksMqUsywjH4W8JgPePodi10pO_xJMrPyq9c19tQmo' -H 'Content-Type: application/json' -i 'https://45.33.22.210/openchannel' --data '{
  "nodeId": "0225ff2ae6a3d9722b625072503c2f64f6eddb78d739379d2ee55a16b3b0ed0a17",
  "amt": 100000
}'
```

## ListChannels

This shows the channel balances which can be used to calculate a users balance.

The local balance are the funds on the main node side. The remote balance is the users funds.

// **TO-DO** - add remote balance and channel reserve to the response

Without any arguments, this call returns the channel balances across the entire node. Therefore, to get a user balance, the node id in question must be passed in the body as the "peer".

Method: POST

URL: https://45.33.22.210/listchannels

Header: Authorization Token

Body: JSON

{
"peer": "string",
}

Response: JSON

Example Response:

{"channels":[{"capacity":5000000,"channel_point":"f51c3c91d8689577aab436dff79bc9ef13f6f8014c11d929ad1e77a5f6d86244:1","local_balance":4785533,"remote_pubkey":"0225ff2ae6a3d9722b625072503c2f64f6eddb78d739379d2ee55a16b3b0ed0a17"}]}

Example Curl Command:

```sh
$ curl -X POST -k -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ2ZWxhcyIsInN1YiI6IndvcmtpdCJ9.CnksMqUsywjH4W8JgPePodi10pO_xJMrPyq9c19tQmo' -H 'Content-Type: application/json' -i 'https://45.33.22.210/listchannels' --data '{
  "peer": "0225ff2ae6a3d9722b625072503c2f64f6eddb78d739379d2ee55a16b3b0ed0a17"
}'
```

## CloseChannel

Closes a channel between the main LND node and another user node. The transaction id "txid" and output "vout", must be specified.

**Notes:**

1. This is a cooperative close method and only works when both nodes are online and the channel opening transaction has been confirmed on the Bitcoin blockchain.
2. We are working on better error handling here. If the user node is offline, the channel needs to be force closed. Force closure will be a seperate API call.
3. The input, a combination of transaction id and output number is also known as the "channel point".

Method: POST

URL: https://45.33.22.210/closechannel

Header: Authorization Token

Body: JSON

{
"txid": "string",
"vout": integer
}

Response: JSON

Example Response:

{"txid":"57f502594aaea27dcd90b720aa4f32040904a576f88acc31cafe2ae80f432931"}

Example Curl Command:

```sh
$ curl -X POST -k -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ2ZWxhcyIsInN1YiI6IndvcmtpdCJ9.CnksMqUsywjH4W8JgPePodi10pO_xJMrPyq9c19tQmo' -H 'Content-Type: application/json' -i 'https://45.33.22.210/closechannel' --data '{
  "txid": "a64acc60e84133a4364a87b46da65a3796c12e5404f2c6b8dcd77b1c1948dc38",
  "vout": 0
}'
```
