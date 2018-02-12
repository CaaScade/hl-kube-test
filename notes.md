# What needs to be done?

- ~~orderer service+deployment~~
- ~~peer service+deployment~~
- ~~configure Orderer using Kubernetes resources instead of files~~
- ~~configure Peer using Kubernetes resources instead of files~~

- configure Fabric components to use k8s-internal DNS names

- client pod for manually running commands:
    - create channel
    - add peer to channel
    - add org to channel
    - install chaincode on peer
    - send transaction to invoke chaincode
    - view results of chaincode invocation

- modified Peer runs chaincode through Kubernetes instead of Docker.

# Demo

- peers running without TLS
    - peer0 org1
    - peer0 org2
- tools container
    - config files
    - tool binaries
    - golang environment
    
# What doesn't work?

- peer TLS due to naming of k8s services
- instantiating chaincode using docker in k8s
    - Questions:
        * Why does it matter that the DNS name doesn't match the cert? Can we use the name on the cert?
        * Do we need TLS inside the cluster?
        * Externally-exposed peers vs internal-only peers?


# Notes for proposal

- crypto-gen tool outputs files grouped/named semantically
- persistence for orderer/peer state
- scoped config
    - core.yaml has peer-specific config
    - core.yaml has orderer-specific config
