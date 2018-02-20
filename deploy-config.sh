#!/usr/bin/env bash

set -e
set -x

cd ./config/

function deploy-secret {
    NAME=$1
    FILE=$2
    KEY=$3
    kubectl delete secret $NAME || true
    kubectl create secret generic $NAME --from-file=$KEY=$FILE
}

function deploy-config {
    NAME=$1
    FILE=$2
    KEY=$3
    kubectl delete configmap $NAME || true
    kubectl create configmap $NAME --from-file=$KEY=$FILE
}

function deploy-peer-bundle {
    PEER=$1
    ORG=$2
    FOLDER=$3

    deploy-secret $PEER-$ORG-$FOLDER ./$PEER.$ORG.$FOLDER.tar.gz bundle
}

function deploy-peer-bundle-all {
    deploy-peer-bundle $1 $2 msp
    deploy-peer-bundle $1 $2 tls
}

function deploy-user-bundle {
    USER=$1
    ORG=$2
    FOLDER=$3
    LOWERCASED=${USER,,}

    deploy-secret $LOWERCASED-$ORG-$FOLDER ./$USER@$ORG.$FOLDER.tar.gz bundle
}

function deploy-user-bundle-all {
    deploy-user-bundle $1 $2 msp
    deploy-user-bundle $1 $2 tls
}

deploy-peer-bundle-all peer0 org1
deploy-peer-bundle-all peer1 org1
deploy-user-bundle-all Admin org1
deploy-user-bundle-all User1 org1

deploy-peer-bundle-all peer0 org2
deploy-peer-bundle-all peer1 org2
deploy-user-bundle-all Admin org2
deploy-user-bundle-all User1 org2

deploy-secret orderer-genesis-block ./channel-artifacts/genesis.block file
deploy-secret orderer-example-com-msp ./orderer.example.com.msp.tar.gz bundle
deploy-secret orderer-example-com-tls ./orderer.example.com.tls.tar.gz bundle
deploy-user-bundle-all Admin example.com

deploy-config core-yaml ./core.yaml file
deploy-config orderer-yaml ./orderer.yaml file
