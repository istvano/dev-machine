
CRT_FILENAME?=tls.pem
KEY_FILENAME?=tls.key

.PHONY: init ## Running init tasks (create tls, dns and network)
init: tls/create-cert tls/trust-cert ## Running init tasks (create tls, dns
	@echo "Init completed"

.PHONY: cleanup
cleanup: network/delete volume/delete ## Running cleanup tasks tasks (dns and network)
	@echo "Cleanup completed"

### DNS

.PHONY: dns/insert
dns/insert: dns/remove ##@dns Create dns
	@echo "Creating HOST DNS entries for the project ..."
	@for v in $(DOMAINS) ; do \
		echo $$v; \
		sudo -- sh -c -e "echo '$(IP_ADDRESS)	$$v' >> /etc/hosts"; \
	done
	@echo "Completed..."

.PHONY: dns/remove
dns/remove: ##@dns Delete dns entries
	@echo "Removing HOST DNS entries ..."
	@for v in $(DOMAINS) ; do \
		echo $$v; \
		sudo -- sh -c "sed -i.bak \"/$(IP_ADDRESS)	$$v/d\" /etc/hosts && rm /etc/hosts.bak"; \
	done
	@echo "Completed..."