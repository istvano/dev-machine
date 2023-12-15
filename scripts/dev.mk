

.PHONY: init
dev/rest/editor: ## Running hoppscotch
	$(DOCKER) compose -f ./etc/hoppscotch/docker-compose.yml up

