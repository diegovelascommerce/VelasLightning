# VelasAPI Tests

## _API calls for running various functions with your Lightning Application (LApp)_

The LApp has an API interface for communicating with an LND Node. Currently, it supports the following functions.

Important note: this interface currently only communicates with a testnet LND node. No real bitcoin are ever at risk using this interface.

- **[HelloLightning](#HelloLightning)** - Communication test
- **GetInfo** - Returns basic information about the LND node
- **OpenChannel** - Opens a channel between the LND node and another node
- **ListChannels** - returns channel balances, optional to pass in a pub key to be given info about only that remote node balance
- **CloseChannel** - Closes a channel given the channel point
- **PayInvoice** - Submit a bolt 11 invoice to be paid automatically
- **DecodeReq** - Decode a bolt 11 invoice to view amount, notes, preimage etc.

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

Returns basic information about the main LND node. It can also be used to make sure the main node is online and to find the channel points belonging to a specific node pub key.

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
2. If channel opening failed, we recommend viewing the error response for details.
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

The local balance are the funds on the main node side. The sum of remote balances across all channels with the remote pub key is the users funds.

Without any arguments, this call returns the channel balances across the entire node.

Therefore, to get a user balance, the node id in question must be passed in the body as the "peer".

Method: POST

URL: https://45.33.22.210/listchannels

Header: Authorization Token

Body: JSON

{
"peer": "",
"active_only": 1,
"inactive_only": 0,
"public_only": 1,
"private_only": 0
}

Response: JSON

Example Response:

{"channels":[{"active":true,"capacity":5000000,"channel_point":"f51c3c91d8689577aab436dff79bc9ef13f6f8014c11d929ad1e77a5f6d86244:1","commit_fee":184,"local_balance":4785533,"local_chan_reserve_sat":50000,"remote_balance":214283,"remote_chan_reserve_sat":50000,"remote_pubkey":"0225ff2ae6a3d9722b625072503c2f64f6eddb78d739379d2ee55a16b3b0ed0a17"}]}

Example Curl Command:

```sh
$ curl -X POST -k -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ2ZWxhcyIsInN1YiI6IndvcmtpdCJ9.CnksMqUsywjH4W8JgPePodi10pO_xJMrPyq9c19tQmo' -H 'Content-Type: application/json' -i 'https://45.33.22.210/listchannels' --data '{
  "peer": "0225ff2ae6a3d9722b625072503c2f64f6eddb78d739379d2ee55a16b3b0ed0a17",
  "active_only": 1,
  "inactive_only": 0,
  "public_only": 1,
  "private_only": 0
}'
```

## CloseChannel

Closes a channel between the main LND node and another user node. The transaction id "txid" and output "vout", must be specified.

**Notes:**

1. The cooperative close method and only works when both nodes are online and the channel opening transaction has been confirmed on the Bitcoin blockchain.
2. If the user node is offline, the channel needs to be force closed. Force closure are signalled in the body of the API call.
3. The input, a combination of transaction id and output number is also known as the "channel point".

Method: POST

URL: https://45.33.22.210/closechannel

Header: Authorization Token

Body: JSON

{
"txid": "string",
"vout": 0,
"force": 0
}

Response: JSON

Example Response:

{"txid":"57f502594aaea27dcd90b720aa4f32040904a576f88acc31cafe2ae80f432931"}

Example Curl Command:

```sh
$ curl -X POST -k -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ2ZWxhcyIsInN1YiI6IndvcmtpdCJ9.CnksMqUsywjH4W8JgPePodi10pO_xJMrPyq9c19tQmo' -H 'Content-Type: application/json' -i 'https://45.33.22.210/listchannels' --data '{
  "peer": "0225ff2ae6a3d9722b625072503c2f64f6eddb78d739379d2ee55a16b3b0ed0a17",
  "active_only": 1,
  "inactive_only": 0,
  "public_only": 1,
  "private_only": 0
}'
```

## PayInvoice

Submit a bolt 11 invoice string for automatic payment by the LApp.

**Notes:**

1. Bolt 11 invoice strings cannot be reused.
2. See decode pay request API call to get more info about an invoice.
3. For testing this out, we recommend using this excellent browser based testnet lightning wallet: https://htlc.me/

Method: POST

URL: https://45.33.22.210/payinvoice

Header: Authorization Token

Body: JSON

{
"bolt11": "string"
}

Response: JSON

Example Response:

{"payment_error":"","payment_hash":"5c332c7f98773db0504d3aa1c3132ee4b8bfbd79bb1381b3e80f954fd558cfde","payment_preimage":"d2ee69b4934102208b632ab58224359c3673250b8625d0db05b2689b3699b27c"}

Example Curl Command:

```sh
$ curl -X POST -k -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ2ZWxhcyIsInN1YiI6IndvcmtpdCJ9.CnksMqUsywjH4W8JgPePodi10pO_xJMrPyq9c19tQmo' -H 'Content-Type: application/json' -i 'https://45.33.22.210/payinvoice' --data '{
  "bolt11": "lntb31200n1p3agr34pp5tsejclucwu7mq5zd82suxyewujutl0tehvfcrvlgp725l42cel0qdqqcqzpgxqyz5vqsp5q9agrw2lrvpaj3fh7cadf3ugdzwucum2m3w6cycgztljup9js8ts9qyyssqmwerkmyj6lwv4p8dah9n6gqsc6ez92c3wtwgn7u5yk8zf3q9vrn5u9w9mr206jchh97sgsln4d9sq8ku3lyw0un0trky5ru20dtzmlcqwly4f2"
}'
```

## DecodeReq

Decode a bolt 11 invoice to view the information contained in the string.

Method: POST

URL: https://45.33.22.210/decodereq

Header: Authorization Token

Body: JSON

{
"bolt11": "string"
}

Response: JSON

Example Response:

{"description":"please pay to velastest","destination":"03e347d089c071c27680e26299223e80a740cf3e3fc4b4237fa219bb67121a670b","expiry":86400,"num_satoshis":200,"payment_hash":"b6095d73adb58535671101eb095aeb0baa366dfd5a48453ebbca444bc94fc270","timestamp":1673034655}

Example Curl Command:

```sh
$ curl -X POST -k -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ2ZWxhcyIsInN1YiI6IndvcmtpdCJ9.CnksMqUsywjH4W8JgPePodi10pO_xJMrPyq9c19tQmo' -H 'Content-Type: application/json' -i 'https://45.33.22.210/decodereq' --data '{
  "bolt11": "lntb2u1p3ms7ulpp5kcy46uadkkzn2ec3q84sjkhtpw4rvm0atfyy204mefzyhj20cfcqdp9wpkx2ctnv5s8qcteyp6x7grkv4kxzum5v4ehgcqzpgxqyz5vqsp5sn0209yqdfku0anll6gvjc3xve9gf0jcq2j285az6xky7jc8vyrs9qyyssqmfl3y4r08mua52yt83cd2qyq67qcvll28p2jg8ffkeygnnaqk92juym0ctka9y49hf2jmjkkdupkr5f74aujja8yxpkaump55605szqq45cfjs"
}'
```
