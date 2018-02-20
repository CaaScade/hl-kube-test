.PHONY: build-config build-orderer build-org1peer0

build-config:
	@rm -rf ./config/channel-artifacts
	@rm -rf ./config/crypto-config
	@./build-config.sh
	@./bundle-config.sh
	@./deploy-config.sh

# ORDERER

deploy-orderer:
	@short -k -f orderer.short.yaml > orderer.kube.yaml
	@kubectl create -f orderer.kube.yaml

kill-orderer:
	@kubectl delete service orderer || true
	@kubectl delete deployment orderer-example-com || true

reload-orderer: kill-orderer deploy-orderer

# ORG1 PEER0

deploy-org1peer0:
	@short -k -f org1peer0.short.yaml > org1peer0.kube.yaml
	@kubectl create -f org1peer0.kube.yaml

# TODO: delete service <what is the service name really?>
kill-org1peer0:
	@kubectl delete service peer0 || true
	@kubectl delete deployment org1peer0 || true

reload-org1peer0: kill-org1peer0 deploy-org1peer0

# ORG1 PEER0 ADMIN CLIENT

kill-org1admin:
	@kubectl delete pod org1admin || true

deploy-org1admin:
	@short -k -f org1admin.short.yaml > org1admin.kube.yaml
	@kubectl create -f org1admin.kube.yaml

copy-org1admin:
	@kubectl cp ./config org1admin:/workspace -c org1admin
	@kubectl cp ./chaincode org1admin:/opt/gopath/src/chaincode -c org1admin

# ALL

reload-all: kill-orderer kill-org1peer0 kill-org1admin build-config deploy-orderer deploy-org1peer0
