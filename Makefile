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

# PEERS

deploy-peers:
	@short -k -f peers.short.yaml > peers.kube.yaml
	@kubectl create -f peers.kube.yaml

kill-peers:
	@kubectl delete -f peers.kube.yaml

reload-peers: kill-peers deploy-peers

# CLIS

deploy-clis:
	@short -k -f clis.short.yaml > clis.kube.yaml
	@kubectl create -f clis.kube.yaml

kill-clis:
	@kubectl delete -f clis.kube.yaml

reload-clis: kill-clis deploy-clis

#copy-org1admin:
#	@kubectl cp ./config org1admin:/workspace -c org1admin
#	@kubectl cp ./chaincode org1admin:/opt/gopath/src/chaincode -c org1admin

# ALL

reload-all: kill-orderer kill-peers kill-clis build-config deploy-orderer deploy-peers deploy-clis
