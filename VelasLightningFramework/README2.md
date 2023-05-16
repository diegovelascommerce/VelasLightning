# Welcome to the VelasFrame for the client side

this is an xcFramework that can be included inside any xcode project.

All interaction with the lightning network is done through the Velas Class.



# [Velas Class](https://github.com/diegovelascommerce/VelasLightning/blob/main/VelasLightningFramework/VelasLightningFramework/Velas.swift):

the client will be interacting with the lighting network through a class called [Velas](https://github.com/diegovelascommerce/VelasLightning/blob/7cec361affe799d883b0ac9afa6ad4f93c2701ed/VelasLightningFramework/VelasLightningFramework/Velas.swift#L7).

Since starting up a lightning node does take sometime because the state of the channels, peers and transactions must be synced and verified,  it is recommended to initialize the Velas class in the same startup method as your application. For example, in the AppDelegate of an iOS project.

## [Velas.Login](https://github.com/diegovelascommerce/VelasLightning/blob/70b67d025a7723794f181c100bca5338816b3fca/VelasLightningFramework/VelasLightningFramework/Velas.swift#L23)

login to the workit backend and load the bitcoin wallet and lighting node if created earlier.  

### params
- url : url to the workit server.
- username : username to account in workit
- password : password to workit account

## [Velas.Setup](https://github.com/diegovelascommerce/VelasLightning/blob/70b67d025a7723794f181c100bca5338816b3fca/VelasLightningFramework/VelasLightningFramework/Velas.swift#L89)

This is a static function that will setup velas for the first time.

### params
- plist:String? : path to a plist which contains information needed to communicate with the LAPP server.

## [Velsa.Load](https://github.com/diegovelascommerce/VelasLightning/blob/70b67d025a7723794f181c100bca5338816b3fca/VelasLightningFramework/VelasLightningFramework/Velas.swift#L53)

This function load the bitcoin wallet and lightning load if it was already setup

### params
- plist:String? : path to a plist which contains information needed to communicate with the LAPP server.


## [Velas.Check](https://github.com/diegovelascommerce/VelasLightning/blob/70b67d025a7723794f181c100bca5338816b3fca/VelasLightningFramework/VelasLightningFramework/Velas.swift#L47)

Checks if a bitcoin wallet was already setup yet


## [Velas.Connect](https://github.com/diegovelascommerce/VelasLightning/blob/70b67d025a7723794f181c100bca5338816b3fca/VelasLightningFramework/VelasLightningFramework/Velas.swift#L123)

This connects to the LAPP lightning server.

## [Velas.Connected](https://github.com/diegovelascommerce/VelasLightning/blob/70b67d025a7723794f181c100bca5338816b3fca/VelasLightningFramework/VelasLightningFramework/Velas.swift#L165)

Checks to see if Velas Lighting client is currently connected to another lighting node.

## [Velas.Peers](https://github.com/diegovelascommerce/VelasLightning/blob/70b67d025a7723794f181c100bca5338816b3fca/VelasLightningFramework/VelasLightningFramework/Velas.swift#L183)

Shows peers that the lighting node on the client side is connected to.

## [Velas.Sync](https://github.com/diegovelascommerce/VelasLightning/blob/70b67d025a7723794f181c100bca5338816b3fca/VelasLightningFramework/VelasLightningFramework/Velas.swift#L197)

update the lighting node to with the latest bitcoin block so that communications between channels go smoothly.

## [Velas.OpenChannel](https://github.com/diegovelascommerce/VelasLightning/blob/70b67d025a7723794f181c100bca5338816b3fca/VelasLightningFramework/VelasLightningFramework/Velas.swift#L211)

make a request to the LAPP to open a channel between the lighting node on the velas side and the lighting node on the LAPP side.

### params
- amt  :  amount of sats the channels should hold
- target_conf:  amount target confirmations 
- min_confs:  minimum confirmations

## [Velas.ListChannels](https://github.com/diegovelascommerce/VelasLightning/blob/70b67d025a7723794f181c100bca5338816b3fca/VelasLightningFramework/VelasLightningFramework/Velas.swift#L256) 

list channels that were setup between the velas lighting node and the LAPP lighting node.

### params
- usable : list only the channels that are usable.
- lapp: get the list of channels from the lapp.
- workit: get list of channels from workit backend.


## [Velas.PaymentRequest](https://github.com/diegovelascommerce/VelasLightning/blob/70b67d025a7723794f181c100bca5338816b3fca/VelasLightningFramework/VelasLightningFramework/Velas.swift#L289) 

### params
- amt :  amount you would like to be paid.
- description : memo you would like associated with your invoice
- workit : make the request to the workit server.
- userId : id of the user, this is used when communicating with the workit server

## [Velas.CloseChannels](https://github.com/diegovelascommerce/VelasLightning/blob/70b67d025a7723794f181c100bca5338816b3fca/VelasLightningFramework/VelasLightningFramework/Velas.swift#L315)

close all channels

### params
- force : force close channels even if one of the nodes are down
