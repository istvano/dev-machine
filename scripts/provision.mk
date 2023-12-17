.PHONY: pro/install-reqs
pro/install-reqs:  ##@provision Install ansible requirements
	(cd playbook && ansible-galaxy install -r requirements.yml --force)

.PHONY: pro/init
pro/init:  ##@provision Run ansible to init 
	(cd playbook && ansible-playbook -v init.yml --private-key=$(DEV_KEY) --extra-vars "my_user=$(ANSIBLE_USER)" $(PRO_PARAMS))

.PHONY: pro/desktop
pro/desktop:  ##@provision Run ansible to setup desktop
	(cd playbook && ansible-playbook -v desktop.yml --private-key=$(DEV_KEY) --extra-vars "my_user=$(ANSIBLE_USER)" $(PRO_PARAMS))

.PHONY: pro/dev
pro/dev:  ##@provision Run ansible to setup machine with dev tools
	(cd playbook && ansible-playbook -v dev.yml --private-key=$(DEV_KEY) --extra-vars "my_user=$(ANSIBLE_USER)" $(PRO_PARAMS))

.PHONY: pro/workspace
pro/workspace:  ##@provision Run ansible to setup machine's workspace
	(cd playbook && ansible-playbook -v workspace.yml --private-key=$(DEV_KEY) --extra-vars "my_user=$(ANSIBLE_USER) git_user_name=$(GIT_USER) git_user_email=$(GIT_EMAIL) git_user_force=$(GIT_FORCE)" $(PRO_PARAMS))

.PHONY: pro/snaps
pro/snaps:  ##@provision Run ansible to setup machine with snaps
	(cd playbook && ansible-playbook -v snaps.yml --private-key=$(DEV_KEY) --extra-vars "my_user=$(ANSIBLE_USER)" $(PRO_PARAMS))

.PHONY: pro/snaps-alternative
pro/without-snaps:  ##@provision Run ansible to setup machine without snaps
	(cd playbook && ansible-playbook -v snaps-alternative.yml --private-key=$(DEV_KEY) --extra-vars "my_user=$(ANSIBLE_USER)" $(PRO_PARAMS))

.PHONY: pro/misc
pro/misc:  ##@provision Run ansible to setup office and vm tools 
	(cd playbook && ansible-playbook -v misc.yml --private-key=$(DEV_KEY) --extra-vars "my_user=$(ANSIBLE_USER)" $(PRO_PARAMS))

.PHONY: pro/security
pro/security:  ##@provision Run ansible to setup machine's security
	(cd playbook && ansible-playbook -v security.yml --private-key=$(DEV_KEY) --extra-vars "my_user=$(ANSIBLE_USER)" $(PRO_PARAMS))

.PHONY: pro/sync
pro/sync:  ##@provision Run ansible to setup file syncing
	(cd playbook && ansible-playbook -v sync.yml --private-key=$(DEV_KEY) --extra-vars "my_user=$(ANSIBLE_USER)" $(PRO_PARAMS))

.PHONY: pro/db
pro/db:  ##@provision Run ansible to setup db editors
	(cd playbook && ansible-playbook -v db.yml --private-key=$(DEV_KEY) --extra-vars "my_user=$(ANSIBLE_USER)" $(PRO_PARAMS))


.PHONY: pro/test
pro/test:
	(cd playbook && ansible-playbook -v test.yml --private-key=$(DEV_KEY) --extra-vars "my_user=$(ANSIBLE_USER)" $(PRO_PARAMS))
