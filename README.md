# Welcome to the VelasLightning Framework.

A simple framework that cam be used to integrate lightning payment to your application in a none custodial way.

There are two pieces to this project.

1. A client library which uses the LDK ([Lightning Development Kit](https://lightningdevkit.org/)) and the BDK ([Bitcoin Development Kit](https://bitcoindevkit.org/)) to transform your mobile app into a light weight *lightning* node.
 
2. A REST API that communicates with a LAPP([Lightning Application](https://www.youtube.com/watch?v=8-CYfqVfa08)) to connect to peers, create channels, and process payments with a remote *full* *lightning* Node.
  - the LAPP is just a python application that communicates with the remote lighting node using [gRPC](https://www.youtube.com/watch?v=gnchfOojMk4)


- Checkout this link if you want to see how VelasFramework works on the client side.  [VelasFramework](VelasLightningFrameWork/README.md)

- Checkout this link if you want to see how VelasFramework works on the server side.  [VelasFrameworkAPI](VelasLightningAPI/README.md)
