#!/usr/bin/env bash

set -e
set -x

cd ./config/

function bundle-peer {
    PEER=$1
    ORG=$2
    FOLDER=$3

    tar -zcf $PEER.$ORG.$FOLDER.tar.gz -C crypto-config/peerOrganizations/$ORG/peers/$PEER.$ORG $FOLDER
}

function bundle-peer-all {
    bundle-peer $1 $2 msp
    bundle-peer $1 $2 tls
}

function bundle-orderer {
    FOLDER=$1

    tar -zcf orderer.example.com.$FOLDER.tar.gz -C crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com $FOLDER
}

function bundle-orderer-all {
    bundle-orderer msp
    bundle-orderer tls

    bundle-user Admin example.com msp orderer
    bundle-user Admin example.com tls orderer
}

function bundle-user {
    USER=$1
    ORG=$2
    FOLDER=$3
    TYPE=$4

    tar -zcf $USER@$ORG.$FOLDER.tar.gz -C crypto-config/${TYPE}Organizations/$ORG/users/$USER@$ORG $FOLDER
}

function bundle-peer-user-all {
    bundle-user $1 $2 msp peer
    bundle-user $1 $2 tls peer
}

function bundle-peer-org-all {
    ORG=$1

    bundle-peer-all peer0 $ORG
    bundle-peer-all peer1 $ORG
    bundle-peer-user-all Admin $ORG
    bundle-peer-user-all User1 $ORG
}

bundle-peer-org-all org1
bundle-peer-org-all org2
bundle-orderer-all
