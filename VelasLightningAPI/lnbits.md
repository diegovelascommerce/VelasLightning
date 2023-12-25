# Welcome to LNBits

a third layer on top of Bitcoin and Lightning network.

## How it works

it partitions the Liquidity/Funds of your lightning node into separate logical wallet wallets.

you don't need a separate channel for each wallet. All wallets share the same channels.
it's LNBits job to keep track which wallet has share of the liquidity/Funds on the lightning node.

# Get Started

First step is to create a wallet from the LNBits site that you setup.

![LND home page](lnbits_home.png)

It should take you to your wallet page.

![wallet home page](wallet_home.png)

now click the section called `api-info`

![API Info](api-info.png)

- you should see `Wallet ID`, `Admin key`, and `Invoice/read key`
  - `Wallet ID`: is the id that represents your wallet on lnbits.  
    There are some API calls that require you to pass the `Wallet ID` of your wallet.
    such as `topup`. but for most api calls you will be using the `Admin Key`
  - `Admin Key`: this is the key that you will use for most api calls. it gives access for everything so be carefull. otherwise anyone can do anything they want and take out whatever they would like.
  - `Invoice/read key`: this key can be use for just reading data and creating invoices.

# APIs

the following APIs can be use for creating wallet, funding them, sending and receiving funds, etc.

## Get Wallet

this should show you info on your wallet that is associated with your `Admin key`.

GET `https://188.129.133.145:5001/api/v1/wallet`

![Get Wallet](get-wallet.png)

- just make sure you pass the `Admin Key` in `X-Api-Key` in the header.

## topup

this allows you to fund any wallet from the liquidity/funds of the underlining lightning node.
