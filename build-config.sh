#!/usr/bin/env bash

cd ./config/

../tools/cryptogen generate --config=./crypto-config.yaml

mkdir -p ./channel-artifacts

FABRIC_CFG_PATH=$PWD

# Orderer things:
###
# create orderer genesis.block
../tools/configtxgen -profile TwoOrgsOrdererGenesis -outputBlock ./channel-artifacts/genesis.block

# Channel things:
###
# create channel configuration tx
../tools/configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID blubc
# create anchor peers
../tools/configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID blubc -asOrg Org1MSP
../tools/configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID blubc -asOrg Org2MSP

