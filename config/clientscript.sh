#!/usr/bin/env bash

set -e
set -x

source ./clientenv

peer channel create -o orderer:7050 -c blubc -f ./channel-artifacts/channel.tx

peer channel join -b blubc.block

peer chaincode install -n mycc -v 1.0 -p chaincode

peer chaincode instantiate -o orderer:7050 -C blubc -n mycc -v 1.0 -c '{"Args":["init","a", "100", "b","200"]}' -P "OR ('Org1MSP.member','Org2MSP.member')"

#peer chaincode query -C blubc -n mycc -c '{"Args":["query","a"]}'
