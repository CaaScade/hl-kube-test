#!/usr/bin/env bash

set -e
set -x

cd ./config/

../bin/cryptogen generate --config=./crypto-config.yaml

mkdir -p ./channel-artifacts

FABRIC_CFG_PATH=$PWD

# Orderer things:
###
# create orderer genesis.block
../bin/configtxgen -profile TwoOrgsOrdererGenesis -outputBlock ./channel-artifacts/genesis.block

# Channel things:
###
# create channel configuration tx
../bin/configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID blubc
# create anchor peers
../bin/configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID blubc -asOrg Org1MSP
../bin/configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID blubc -asOrg Org2MSP

