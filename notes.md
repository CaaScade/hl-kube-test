# What needs to be done?

- orderer service+deployment
- peer service+deployment
- configure Orderer using Kubernetes resources instead of files
- configure Peer using Kubernetes resources instead of files

- client pod for manually running commands:
    - create channel
    - add peer to channel
    - add org to channel
    - install chaincode on peer
    - send transaction to invoke chaincode
    - view results of chaincode invocation

- modified Peer runs chaincode through Kubernetes instead of Docker.
