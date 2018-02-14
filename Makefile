.PHONY: build-config build-orderer build-org1peer0

build-config:
	@rm -rf ./config/channel-artifacts
	@rm -rf ./config/crypto-config
	@./build-config.sh

# ORDERER

build-orderer:
	@docker build -t "${ECRNAME}/test-bundle-orderer" -f Dockerfile.orderer .

push-orderer: build-orderer
	@docker push "${ECRNAME}/test-bundle-orderer"

deploy-orderer:
	@short -k -f orderer.short.yaml > orderer.kube.yaml
	@kubectl create -f orderer.kube.yaml

kill-orderer:
	@kubectl delete service orderer || true
	@kubectl delete deployment orderer-example-com || true

reload-orderer: kill-orderer push-orderer deploy-orderer

# ORG1 PEER0

build-org1peer0:
	@docker build -t "${ECRNAME}/test-bundle-org1peer0" -f Dockerfile.org1peer0 .

push-org1peer0: build-org1peer0
	@docker push "${ECRNAME}/test-bundle-org1peer0"

deploy-org1peer0:
	@short -k -f org1peer0.short.yaml > org1peer0.kube.yaml
	@kubectl create -f org1peer0.kube.yaml

# TODO: delete service <what is the service name really?>
kill-org1peer0:
	@kubectl delete service peer0 || true
	@kubectl delete deployment org1peer0 || true

reload-org1peer0: kill-org1peer0 push-org1peer0 deploy-org1peer0

# ALL

reload-all: kill-orderer kill-org1peer0 build-config push-orderer push-org1peer0 deploy-orderer deploy-org1peer0
