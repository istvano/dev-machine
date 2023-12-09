.PHONY: pro/init
pro/init:  ##@provision Run ansible to init 
	(cd playbook && ansible-playbook -v init.yml --private-key=$(DEV_KEY) --extra-vars "my_user=$(VM_USER)")

.PHONY: pro/run
pro/run:  ##@provision Run ansible to setup machine
	(cd playbook && ansible-playbook -v main.yml --private-key=$(DEV_KEY) --extra-vars "my_user=$(VM_USER)")

.PHONY: pro/run-desktop
pro/run-desktop:  ##@provision Run ansible to setup desktop
	(cd playbook && ansible-playbook -v desktop.yml --private-key=$(DEV_KEY) --extra-vars "my_user=$(VM_USER)")

.PHONY: pro/run-snaps
pro/run-snaps:  ##@provision Run ansible to setup machine with snaps
	(cd playbook && ansible-playbook -v snaps.yml --private-key=$(DEV_KEY) --extra-vars "my_user=$(VM_USER)")

.PHONY: pro/run-no-snaps
pro/run-no-snaps:  ##@provision Run ansible to setup machine without snaps
	(cd playbook && ansible-playbook -v no-snaps.yml --private-key=$(DEV_KEY) --extra-vars "my_user=$(VM_USER)")

.PHONY: pro/workspace
pro/workspace:  ##@provision Run ansible to setup machine's workspace
	(cd playbook && ansible-playbook -v workspace.yml --private-key=$(DEV_KEY) --extra-vars "my_user=$(VM_USER)")

.PHONY: pro/install-reqs
pro/install-reqs:  ##@provision Install ansible requirements
	(cd playbook && ansible-galaxy install -r requirements.yml --force)