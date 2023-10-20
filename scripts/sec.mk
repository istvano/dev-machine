
### CERTS

.PHONY: tls/create-cert
tls/create-cert:  ##@tls Create self sign certs for local machine
	@echo "Creating self signed certificate"
	docker run -it $(USER_DEF) \
		--mount "type=bind,src=$(TLS),dst=/home/mkcert" \
		--mount "type=bind,src=$(TLS),dst=/root/.local/share/mkcert" \
		istvano/mkcert:latest -install
	docker run -it $(USER_DEF) \
		--mount "type=bind,src=$(TLS),dst=/home/mkcert" \
		--mount "type=bind,src=$(TLS),dst=/root/.local/share/mkcert" \
		istvano/mkcert:latest -cert-file $(CRT_FILENAME) -key-file $(KEY_FILENAME) $(DOMAINS) localhost 127.0.0.1 ::1


.PHONY: delete-from-store
tls/delete-from-store: ##@tls delete self sign certs for local machine
	@[ -d ~/.pki/nssdb ] || mkdir -p ~/.pki/nssdb
	@(if [ -z $(shell certutil -d sql:$$HOME/.pki/nssdb -L | grep '$(MAIN_DOMAIN) cert authority' | head -n1 | awk '{print $$1;}') ]; \
	then \
		echo "not exists. skipping delete"; \
	else \
		certutil -d sql:$$HOME/.pki/nssdb -D -n '$(MAIN_DOMAIN) cert authority'; \
		echo "deleted"; \
	fi)
	@(if [ -z $(shell certutil -d sql:$$HOME/.pki/nssdb -L | grep '$(MAIN_DOMAIN)' | head -n1 | awk '{print $$1;}') ]; \
	then \
		echo "not exists. skipping delete"; \
	else \
		certutil -d sql:$$HOME/.pki/nssdb -D -n '$(MAIN_DOMAIN)'; \
		echo "deleted"; \
	fi)

.PHONY: tls/trust-cert
tls/trust-cert: tls/delete-from-store ##@tls Trust self signed cert by local browser
	@echo "Import self signed cert into user's truststore"
ifeq ($(UNAME_S),Darwin)
	sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain $(TLS)/.local/share/mkcert/rootCA.pem
else
	@[ -d ~/.pki/nssdb ] || mkdir -p ~/.pki/nssdb
	@certutil -d sql:$$HOME/.pki/nssdb -A -n '$(MAIN_DOMAIN) cert authority' -i $(TLS)/.local/share/mkcert/rootCA.pem -t TCP,TCP,TCP
	@certutil -d sql:$$HOME/.pki/nssdb -A -n '$(MAIN_DOMAIN)' -i $(TLS)/tls.pem -t P,P,P
endif
	@echo "Import successful..."

.PHONY: dev-key/create
dev-key/create:  ##@keys Create dev keys
	ssh-keygen -t rsa -b 2048 -C "$(VM_USER)@$(MAIN_DOMAIN)" -f $(DEV_KEY)
