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

deploy-secret peer0-org1-msp ./peer0.org1.msp.tar.gz bundle
deploy-secret peer1-org1-msp ./peer1.org1.msp.tar.gz bundle
deploy-secret peer0-org2-msp ./peer0.org2.msp.tar.gz bundle
deploy-secret peer1-org2-msp ./peer1.org2.msp.tar.gz bundle

deploy-secret peer0-org1-tls ./peer0.org1.tls.tar.gz bundle
deploy-secret peer1-org1-tls ./peer1.org1.tls.tar.gz bundle
deploy-secret peer0-org2-tls ./peer0.org2.tls.tar.gz bundle
deploy-secret peer1-org2-tls ./peer1.org2.tls.tar.gz bundle

deploy-secret orderer-genesis-block ./channel-artifacts/genesis.block file
deploy-secret orderer-example-com-msp ./orderer.example.com.msp.tar.gz bundle
deploy-secret orderer-example-com-tls ./orderer.example.com.tls.tar.gz bundle

deploy-config core-yaml ./core.yaml file
deploy-config orderer-yaml ./orderer.yaml file
