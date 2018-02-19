#!/usr/bin/env bash

set -e
set -x

cd ./config/

function bundle {
    PEER=$1
    ORG=$2
    FOLDER=$3

    tar -zcf $PEER.$ORG.$FOLDER.tar.gz -C crypto-config/peerOrganizations/$ORG/peers/$PEER.$ORG $FOLDER
}

function bundle-orderer {
    FOLDER=$1

    tar -zcf orderer.example.com.$FOLDER.tar.gz -C crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com $FOLDER
}

bundle peer0 org1 msp
bundle peer0 org1 tls
bundle peer1 org1 msp
bundle peer1 org1 tls

bundle peer0 org2 msp
bundle peer0 org2 tls
bundle peer1 org2 msp
bundle peer1 org2 tls

bundle-orderer msp
bundle-orderer tls
