#!/usr/bin/env bash

source ./clientenv

peer channel create -o orderer:7050 -c blubc -f ./channel-artifacts/channel.tx --tls --cafile /workspace/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

peer channel join -b blubc.block

peer chaincode install -n mycc -v 1.0 -p /workspace/chaincode/
