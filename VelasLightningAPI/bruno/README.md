# Welcome to Bruno

This a bruno, it like postman but does not requeire an account and you can do some scripting
for responses from the API.

LNBits is a layer ontop of the Lightning network. it allows a Lightning Node to have multiple wallets but they all use the same channel funds.

It is LNBits that keeps track what part of the funds belong to which wallet.

## velastestnet LNBits

these are the APIs for LNBits setup on the velastestnet server.

in order to use these APIs you need to setup an environment in bruno,
which provides the credentials you need to use the APIs.

![bruno environment](./environment.png)

for the majority of the API call you will just need the `api-token`,
which is associated with a account that has access to the API.  
this value will be used in header of most requests

![header](./headers.png)

### 1. Create User

this is the api call for creating a new user with a wallet.

`POST: https://45.33.22.210:5001/usermanager/api/v1/users`

you can specify the user and the wallet you want to create for the user through
the body.

![create user](./create-user-body.png)

a new user with a wallet and apikeys is created

![create user response](./create-user-response.png)

- you can use the `apikey` to do transactons the the newly created wallet

### 2. Get users

this is an api call that gets all the users that were created.

- you must use the `apikey` of the super user.

`GET: https://45.33.22.210:5001/usermanager/api/v1/users`

it returns all the users who were created with the super user.

![get user response](./get-users-response.png)

### 3. Get wallet for user

if you want to findout what the balance is for a users wallet you would use this API.

`GET: https://45.33.22.210:5001/api/v1/wallet`

you must passin the `apikey` that is associated with the wallet you want to query.

![get user header](./get-wallet-header.png)

it will return the name of the wallet associated the the key and the balance.

![get user response](./get-wallet-response.png)

### 4. TOPUP

this is the main way how you will assign awards to a user.

TOPUP just gets funds from the lightning node and assigns them to a wallet,
without having to use the lightning network.

`PUT https://45.33.22.210:5001/admin/api/v1/topup/?usr=<super-user-id>`

- super-user-id: the ID of the super user who has access to the funds of the Lightning Node.

you have to specify the id of the wallet that you want to assign funds to
and the amount of funds you want to assign it.

![topup body](./topup-body.png)

you should get the following response, if successful.

![topup response](./topup-response.png)

### 5. PAY INVOICE

when you want to pay an invoice with a user wallet you just created.

`POST: https://45.33.22.210:5001/api/v1/payments`

you spcify the bolt 11 you want to pay here

![pay bolt11](./pay-bolt11-body.png)

you specify the `apikey` of the wallet you want to pay the invoice with in the header.

![pay invoice header](./pay-invoice-header.png)

you should get a response like this.

![pay invoice response](./pay-invoice-response.png)
