A simple framework that cam be used to integrate lightning payment to your application using a none custodial approach.

There are Two Major peaces to this.

1. The LAPP backend with communicates with a Full Lightning node located at a remote server.
2. The Client Side which uses the LDK to spring up a lightweight lightning node for the LAPP to communicate and setup channels with.

# LAPP

The LAPP is a python REST Server writen in Flask.
It communicated with a Full Lightning Node using gRPC.

its main responsibilities is providing 
1. handling requests for the node information, such as the nodeId.
2. requests for creating a channel with the swift client
3. proccessing invoices incoded in bolt11 generated from the swift client


- It is perferable that calls to the LAPP are handled through a backend for security purposes and also recording application specific data that
  would coinside with the lighting data.
  
- the REST API for the LAPP uses https and jwt token for security purposes.

The LAPP has a REST API for the following actions.


# CLIENT

The Clent Code is packaged as a xcFramework and can be included into any XCode project.

The Client Code relies on the LDK and BDK.
The LDK is packaged also as a xcFramework and in bundled with the VelasLightning xcFramework.
However the BDK is a SPM package and must also be included in the project that will be using the VelasFramework.

