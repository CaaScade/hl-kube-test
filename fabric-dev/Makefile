fabric-dev := .stack-work/install/x86_64-linux/lts-10.5/8.2.2/bin/fabric-dev-exe

$(fabric-dev): app src test package.yaml stack.yaml
	@stack build

root/bin/fabric: $(fabric-dev)
	@mkdir -p root/bin
	@cp $(fabric-dev) root/bin/fabric

root/bin/short:
	@mkdir -p root/bin
	@curl -Lo root/bin/short https://github.com/koki/short/releases/download/v0.4.0/short_linux_amd64
	@chmod u+x root/bin/short

root/bin/kubectl:
	@mkdir -p root/bin
	@curl -Lo root/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v1.9.3/bin/linux/amd64/kubectl
	@chmod u+x root/bin/kubectl

root/bin/minikube:
	@mkdir -p root/bin
	@curl -Lo root/bin/minikube https://github.com/kubernetes/minikube/releases/download/v0.25.0/minikube-linux-amd64
	@chmod u+x root/bin/minikube

root/bin/configtxgen root/bin/cryptogen root/bin/configtxlator:
	@mkdir -p root/bin
	@mkdir -p tmp
	@curl -Lo tmp/hlf.tar.gz https://nexus.hyperledger.org/content/repositories/releases/org/hyperledger/fabric/hyperledger-fabric/linux-amd64-1.0.5/hyperledger-fabric-linux-amd64-1.0.5.tar.gz
	@tar -C tmp -xvf tmp/hlf.tar.gz
	@cp tmp/bin/configtxgen root/bin
	@cp tmp/bin/cryptogen root/bin
	@cp tmp/bin/configtxlator root/bin
	@chmod u+x root/bin/configtxgen
	@chmod u+x root/bin/cryptogen
	@chmod u+x root/bin/configtxlator
	@rm -rf tmp

.PHONY: clean-package
clean-package: clean package

.PHONY: package
package: root/bin/fabric root/bin/short root/bin/kubectl root/bin/minikube root/bin/configtxgen root/bin/cryptogen root/bin/configtxlator

.PHONY: clean
clean:
	@rm -rf root/config-artifacts
	@rm -rf root/crypto-config
	@rm -rf root/channel-artifacts
	@rm -rf root/kube-config
	@rm -f root/short-config/*.config.yaml
	@rm -rf root/bin
