SHELL := /bin/bash

# === BEGIN USER OPTIONS ===
# import env file
# You can change the default config with `make env="youfile.env" build`
env ?= .env
include $(env)
export $(shell sed 's/=.*//' $(env))

include help.mk
include init.mk
include vm.mk
include provision.mk

USERNAME=$(shell whoami)
UID=$(shell id -u ${USERNAME})
GID=$(shell id -g ${USERNAME})

MFILECWD = $(shell pwd)
ETC=$(MFILECWD)/etc
SHARE=$(MFILECWD)/share
TLS=$(ETC)
PLYBK=$(MFILECWD)/playbook

#space separated string array ->
$(eval $(call defw,IP_ADDRESS,$(IP_ADDRESS)))
$(eval $(call defw,ENV,$(ENV)))
$(eval $(call defw,DOCKER,docker))
$(eval $(call defw,CURL,curl))
$(eval $(call defw,TART,tart))
$(eval $(call defw,SSH,ssh))
$(eval $(call defw,UNAME,$(UNAME_S)-$(UNAME_P)))

ifeq ($(UNAME_S),Darwin)
	IP_ADDRESS=$(shell ipconfig getifaddr en0 | awk '{print $$1}')
	USER_DEF=
	PLATFORM=--platform linux/arm64
	OPEN=open
else
	IP_ADDRESS=$(shell hostname -I | awk '{print $$1}')
	OPEN=xdg-open
	USER_DEF=--user $(UID):$(UID)
	PLATFORM=--platform linux/amd64
endif

ifeq ($(IP_ADDRESS),)
	IP_ADDRESS=127.0.0.1
endif

$(eval $(call defw,DOMAINS,localhost.lan www.localhost.lan login.localhost.lan dev.localhost.lan db.localhost.lan site.localhost.lan))
MAIN_DOMAIN=$(shell echo $(DOMAINS) | awk '{print $$1}')


# === END USER OPTIONS ===

### MISC

.PHONY: synctime
synctime: ##@misc Sync VM time
	@sudo sudo timedatectl set-ntp off
	@sudo timedatectl set-ntp on
	@date

.PHONY: versions
versions: ##@misc Print the "imporant" tools versions out for easier debugging.
	@echo "=== BEGIN Version Info ==="
	@echo "Project name: ${PROJECT}"
	@echo "version: ${VERSION}"
	@echo "Repo state: $$(git rev-parse --verify HEAD) (dirty? $$(if git diff --quiet; then echo 'NO'; else echo 'YES'; fi))"
	@echo "make: $$(command -v make)"
	@echo "kubectl: $$(command -v kubectl)"
	@echo "grep: $$(command -v grep)"
	@echo "cut: $$(command -v cut)"
	@echo "rsync: $$(command -v rsync)"
	@echo "openssl: $$(command -v openssl)"
	@echo "/dev/urandom: $$(if test -c /dev/urandom; then echo OK; else echo 404; fi)"
	@echo "=== END Version Info ==="

.EXPORT_ALL_VARIABLES: