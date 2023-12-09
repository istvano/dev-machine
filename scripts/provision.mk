.PHONY: pro/install-reqs
pro/install-reqs:  ##@provision Install ansible requirements
	(cd playbook && ansible-galaxy install -r requirements.yml --force)

.PHONY: pro/init
pro/init:  ##@provision Run ansible to init 
	(cd playbook && ansible-playbook -v init.yml --private-key=$(DEV_KEY) --extra-vars "my_user=$(VM_USER)")

.PHONY: pro/desktop
pro/desktop:  ##@provision Run ansible to setup desktop
	(cd playbook && ansible-playbook -v desktop.yml --private-key=$(DEV_KEY) --extra-vars "my_user=$(VM_USER)")

.PHONY: pro/dev
pro/dev:  ##@provision Run ansible to setup machine with dev tools
	(cd playbook && ansible-playbook -v dev.yml --private-key=$(DEV_KEY) --extra-vars "my_user=$(VM_USER)")

.PHONY: pro/workspace
pro/workspace:  ##@provision Run ansible to setup machine's workspace
	(cd playbook && ansible-playbook -v workspace.yml --private-key=$(DEV_KEY) --extra-vars "my_user=$(VM_USER)")

.PHONY: pro/snaps
pro/snaps:  ##@provision Run ansible to setup machine with snaps
	(cd playbook && ansible-playbook -v snaps.yml --private-key=$(DEV_KEY) --extra-vars "my_user=$(VM_USER)")

.PHONY: pro/snaps-alternative
pro/without-snaps:  ##@provision Run ansible to setup machine without snaps
	(cd playbook && ansible-playbook -v snaps-alternative.yml --private-key=$(DEV_KEY) --extra-vars "my_user=$(VM_USER)")

.PHONY: pro/misc
pro/misc:  ##@provision Run ansible to setup office and vm tools 
	(cd playbook && ansible-playbook -v misc.yml --private-key=$(DEV_KEY) --extra-vars "my_user=$(VM_USER)")

.PHONY: pro/security
pro/security:  ##@provision Run ansible to setup machine's security
	(cd playbook && ansible-playbook -v security.yml --private-key=$(DEV_KEY) --extra-vars "my_user=$(VM_USER)")