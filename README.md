Welcome to the VelasLightning Framework.  
A simple framework that cam be used to integrate lightning payment to your application in a none custodial way.

There are Two Major peaces to this project.

1. A client side which uses the LDK(Lightning Development Kit) to transform you mobile app into a light weight Lightning node.
2. A backend REST API that communicates with a LAPP(Lightning Application) for creating an managing channels, payments, etc, with a remote Lightning Node.
  - the LAPP is just a python application that communicates with a Lighting Node using gRPC

# Client LDK

the client uses the LDK to turn you application into a lightweight lightning node.

it can connect to another lightning peer.

it can request for the backend to create a channel with it

it can create bolt11 invoices and submit it to the backend LAPP for processing.

# BackEnd LAPP

The backend is a REST API written in python.
It communicated with a LAPP(Lightning Application) which communicates with a remote lighting node.

its main responsibilities is providing 
1. handling requests for the node information, such as the nodeId.
2. requests for creating a channel
3. processing invoices encoded in bolt11



## REST API

the rest api is using Flask for implementing HTTPS request.

for security reasons, all requests that have to do with lightning are encoded using https.
- for testing purposes the test server velastestnet (45.33.22.210) uses a self signed certificate.
- however, in production the client needs to communicate with a backend that is signed with a public certification authority.
  otherwise the app might be rejects by apple.

also for security reason, all request that have to do with lightning require a JWT(Json Web Token) token in the header of the request.
- for testing purposes the jwt used for communicating with velastestnet(45.33.22.210) was created usings the secret phrase, literally, 'secret'.
  in production it will be expected that the jwt will be created with a much more secure secret phrase.
  
### getinfo
