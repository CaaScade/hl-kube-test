#!/usr/bin/env bash

set -e

source ./clientenv

peer channel create -o orderer:7050 -c blubc -f ./channel-artifacts/channel.tx --tls --cafile /workspace/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

peer channel join -b blubc.block

peer chaincode install -n mycc -v 1.0 -p chaincode

peer chaincode instantiate -o orderer:7050 --tls --cafile /workspace/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C blubc -n mycc -v 1.0 -c '{"Args":["init","a", "100", "b","200"]}' -P "OR ('Org1MSP.member','Org2MSP.member')"
