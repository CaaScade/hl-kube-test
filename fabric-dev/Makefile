fabric-dev := .stack-work/install/x86_64-linux/lts-10.5/8.2.2/bin/fabric-dev-exe

$(fabric-dev): app src test package.yaml stack.yaml
	@stack build

.PHONY: clean-package
clean-package: clean package

.PHONY: package
package: $(fabric-dev)
	@cp $(fabric-dev) root/bin/fabric

.PHONY: clean
clean:
	@rm -rf root/config-artifacts
	@rm -rf root/crypto-config
	@rm -rf root/channel-artifacts
	@rm -rf root/kube-config
	@rm -f root/short-config/*.config.yaml
	@rm -f root/bin/fabric
