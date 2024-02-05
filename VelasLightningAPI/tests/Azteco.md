# Welcome to azteco, 

> a third party for creating Bitcoin vouchers.

Azteco is an online service that allows users to create vouchers that are backed by bitcoin and 
sell them for a commission.

selling Azteco vouchers is no different than selling gift cards for a commission.

once you sign up as a partner with Azteco you are given access to their API which allows you to create vouchers that you can
sell.

the one who buys the voucher can redeem it for bitcoin by entering a 16-digit code at `azte.co/redeem` 

you earn commission on the sale of every Azteco vouche

Remember you are not selling Bitcoin.  You're selling Azteco vouchers which the customer can redeem for bitcoin.

To create a voucher is a two step process. 

1. Call either `Stage Order`or `Stage Lightning Order` endpoint to obtain the `order_id`
2. Call the `Finalize Order` or `Finalize Lightning Order` endpoint with the `order_id` to get the `voucher code` for on-chain.
   and a LNURL for lighting.
   
   
# Authentication #

request for an Azteco Vender API Key from `support@azte.co`

- note the API Key that I am using for testing is the **sandbox** API Key, you need to replace it with you own 



# Stage Order #

in order to create a voucher for on-chain, you need to get an `order-id`.

to get an `order_id` for an on-chain voucher, you need to make the following request

POST: https://api.azte.co/v1/stage/<currency>/<amount>
- params:
  * currency: the currency you want the voucher to be in
  * amount: the amount you want to create the voucher
 - header:
  * X-API-KEY: <Azteco-API-Key>
  
once you get the `order-id` it should have a TTL (time to live) of 5 minutes

to convert the `order-id` for an on-chain voucher you need to call the `Finalize Order` end-point.

# Finalize Order #

call the `Finalize Order` end-point with the `order-id` returned from your last call from `Stage Order` end-point.
- make sure it's before it's ttl has expired.

PUT:  https://api.azte.co/v1/order/<order-id>
- params:
  * order-id: `order-id` that was returned from you last call from the `Stage Order` end-point.
  
you are returned the complete order with the `voucher_code` and `reference_code`
- the `voucher_code` is needed when the someone wants to redeem the voucher
- `reference_code` is used for other APIs for checking the status of the voucher.

to redeem an on-chain voucher go to `https://azte.co/redeem`

you pre-populate the voucher code in the URL and encode it as a QRcode for you user.

ex: https://azte.co/redeem?code=1111222233334444


# Stage Lightning Order #

Call the `Stage Lightning Order` to obtain an `order-id` for a Lightning Voucher.


POST: https://api.azte.co/v1/stage_lightning/<currency>/<amount>
- params:
  * currency:  the currency you want to make out the voucher
  * amount: the amount you want to make the voucher 
  
you should receive the `order_id` which is necessary to finalize the voucher when you call the `Finalize Lightning Order` end-point

the `order_id` should have a ttl (time to live) of about 5 minutes


# Finalize Lightning Order #

PUT: https://api.azte.co/v1/order_lightning/<order-id>
- params:
  * order_id: the order id returned from last call for `Stage Lightning Order` 
  
you are then returned the `LNURL` and `reference_code` for this voucher.

if the user want to redeem their voucher for Lightning, they just need an
LNURL compatible  lightning wallet.

The LNURL can be encoded in a QR Code.  The user can scan the LNURL with a supported lightning wallet.
the amount will then show on the users wallet.

## LNURL ##

is another layer ontop of the lightning network which help in orchestrating lighting payments.

### LNURL PAY ###

it automatically handles the process of requesting bolt11 from some one you want to pay to.

for example the person who want to receive the payment will create a `LNURL PAY` and share it via a QR Code.

the person who want to pay with then scan the QR Code,  if he has a LNURL compatable wallet then it will automatically request the for the bolt11 so that he can pay that person

### LNURL Withdraw ###

it automatically handles the process of creating a bolt11 to withdraw from you wallet.
this could be used for Refunds or redeeming vouchers

for example say Azteco creates a voucher that someone can redeem for Satoshis on the lightning network.
to redeem the voucher you just have to share the `LNURL Withdraw` url with the person.
the person then scans the url and automatically submits a bolt11 for Azteco to pay to.



