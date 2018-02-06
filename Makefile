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
