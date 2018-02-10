# CRYPTO CONFIG SECTION

build-admin-example-com-cert:
	@kubectl delete configmap admin-example-com-cert || true
	@kubectl create configmap admin-example-com-cert --from-file=cert=./crypto/Admin@example.com-cert.pem

build-admin-example-com-sk:
	@kubectl delete secret admin-example-com-sk || true
	@kubectl create secret generic admin-example-com-sk --from-file=sk=./crypto/Admin@example.com-sk

build-admin-org1-example-com-cert:
	@kubectl delete configmap admin-org1-example-com-cert || true
	@kubectl create configmap admin-org1-example-com-cert --from-file=cert=./crypto/Admin@org1.example.com-cert.pem

build-ca-example-com-cert:
	@kubectl delete configmap ca-example-com-cert || true
	@kubectl create configmap ca-example-com-cert --from-file=cert=./crypto/ca.example.com-cert.pem

build-ca-org1-example-com-cert:
	@kubectl delete configmap ca-org1-example-com-cert || true
	@kubectl create configmap ca-org1-example-com-cert --from-file=cert=./crypto/ca.org1.example.com-cert.pem

build-orderer-example-com-cert:
	@kubectl delete configmap orderer-example-com-cert || true
	@kubectl create configmap orderer-example-com-cert --from-file=cert=./crypto/orderer.example.com-cert.pem

build-orderer-example-com-sk:
	@kubectl delete secret orderer-example-com-sk || true
	@kubectl create secret generic orderer-example-com-sk --from-file=sk=./crypto/orderer.example.com-sk

build-orderer-example-com-tls-cert:
	@kubectl delete configmap orderer-example-com-tls-cert || true
	@kubectl create configmap orderer-example-com-tls-cert --from-file=cert=./crypto/orderer.example.com-tls.crt

build-orderer-example-com-tls-sk:
	@kubectl delete secret orderer-example-com-tls-sk || true
	@kubectl create secret generic orderer-example-com-tls-sk --from-file=sk=./crypto/orderer.example.com-tls.key

build-peer0-org1-example-com-cert:
	@kubectl delete configmap peer0-org1-example-com-cert || true
	@kubectl create configmap peer0-org1-example-com-cert --from-file=cert=./crypto/peer0.org1.example.com-cert.pem

build-peer0-org1-example-com-sk:
	@kubectl delete secret peer0-org1-example-com-sk || true
	@kubectl create secret generic peer0-org1-example-com-sk --from-file=sk=./crypto/peer0.org1.example.com-sk

build-peer0-org1-example-com-tls-cert:
	@kubectl delete configmap peer0-org1-example-com-tls-cert || true
	@kubectl create configmap peer0-org1-example-com-tls-cert --from-file=cert=./crypto/peer0.org1.example.com-tls.crt

build-peer0-org1-example-com-tls-sk:
	@kubectl delete secret peer0-org1-example-com-tls-sk || true
	@kubectl create secret generic peer0-org1-example-com-tls-sk --from-file=sk=./crypto/peer0.org1.example.com-tls.key

build-tlsca-example-com-cert:
	@kubectl delete configmap tlsca-example-com-cert || true
	@kubectl create configmap tlsca-example-com-cert --from-file=cert=./crypto/tlsca.example.com-cert.pem

build-tlsca-org1-example-com-cert:
	@kubectl delete configmap tlsca-org1-example-com-cert || true
	@kubectl create configmap tlsca-org1-example-com-cert --from-file=cert=./crypto/tlsca.org1.example.com-cert.pem

build-orderer-crypto-config: build-admin-example-com-cert build-ca-example-com-cert build-orderer-example-com-cert build-orderer-example-com-sk build-orderer-example-com-tls-cert build-orderer-example-com-tls-sk build-tlsca-example-com-cert

build-org1peer0-crypto-config: build-admin-org1-example-com-cert build-ca-org1-example-com-cert build-peer0-org1-example-com-cert build-peer0-org1-example-com-sk build-peer0-org1-example-com-tls-cert build-peer0-org1-example-com-tls-sk build-tlsca-org1-example-com-cert

build-crypto-config: build-orderer-crypto-config build-org1peer0-crypto-config

build-orderer-example-com-genesis-block:
	@kubectl delete secret orderer-example-com-genesis-block || true
	@kubectl create secret generic orderer-example-com-genesis-block --from-file=block=./crypto/orderer.genesis.block

build-core-config:
	@kubectl delete configmap core-config || true
	@kubectl create configmap core-config --from-file=config=./config/core.yaml

build-orderer-example-com-config:
	@kubectl delete configmap orderer-example-com-config || true
	@kubectl create configmap orderer-example-com-config --from-file=config=./config/orderer.yaml

build-config: build-crypto-config build-orderer-example-com-genesis-block build-core-config build-orderer-example-com-config

# ORDERER

# msp/admincerts/Admin@example.com-cert.pem
#     ^- admin-example-com-cert
# msp/cacerts/ca.example.com-cert.pem
#     ^- ca-example-com-cert
# msp/keystore/a18..._sk
#     ^- orderer-example-com-sk
# msp/signcerts/orderer.example.com-cert.pem
#     ^- orderer-example-com-cert
# msp/tlscacerts/tlsca.example.com-cert.pem
#     ^- tlsca-example-com-cert

# tls/ca.crt
#     ^- tlsca-example-com-cert
# tls/server.crt
#     ^- orderer-example-com-tls-cert
# tls/server.key
#     ^- orderer-example-com-tls-sk

build-orderer:
	@cp /home/kynan/workspace/go/src/github.com/hyperledger/fabric/build/image/orderer/payload/orderer orderer/
	@tar -xf /home/kynan/workspace/go/src/github.com/hyperledger/fabric/build/image/orderer/payload/sampleconfig.tar.bz2 -C orderer/sampleconfig/
	@docker build -t "${ECRNAME}/test-bundle-orderer" -f Dockerfile.orderer .

push-orderer: build-orderer
	@docker push "${ECRNAME}/test-bundle-orderer"

deploy-orderer:
	@short -k -f orderer.short.yaml > orderer.kube.yaml
	@kubectl create -f orderer.kube.yaml

kill-orderer:
	@kubectl delete pod orderer || exit 0

reload-orderer: kill-orderer push-orderer deploy-orderer

# ORG1 PEER0

build-org1peer0:
	@cp /home/kynan/workspace/go/src/github.com/hyperledger/fabric/build/image/peer/payload/peer peer/
	@tar -xf /home/kynan/workspace/go/src/github.com/hyperledger/fabric/build/image/peer/payload/sampleconfig.tar.bz2 -C peer/sampleconfig/
	@docker build -t "${ECRNAME}/test-bundle-org1peer0" -f Dockerfile.org1peer0 .

push-org1peer0: build-org1peer0
	@docker push "${ECRNAME}/test-bundle-org1peer0"

deploy-org1peer0:
	@short -k -f org1peer0.short.yaml > org1peer0.kube.yaml
	@kubectl create -f org1peer0.kube.yaml

kill-org1peer0:
	@kubectl delete pod org1peer0 || exit 0

reload-org1peer0: kill-org1peer0 push-org1peer0 deploy-org1peer0
