

.PHONY: dev/rest/editor
dev/rest/editor: ## Running hoppscotch
	$(DOCKER) compose -f ./etc/hoppscotch/docker-compose.yml up

.PHONY: dev/ufw/allow
dev/ufw/allow: ## Allow hoppscotch proxy to localhost
	@SUBNET=$(shell docker network inspect hoppscotch_default --format "{{(index .IPAM.Config 0).Subnet}}"); \
	sudo ufw allow from $$SUBNET

.PHONY: dev/ufw/deny
dev/ufw/deny: ## Deny hoppscotch proxy to localhost
	@SUBNET=$(shell docker network inspect hoppscotch_default --format "{{(index .IPAM.Config 0).Subnet}}"); \
	sudo ufw delete allow from $$SUBNET