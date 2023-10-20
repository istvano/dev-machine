.PHONY: pro/init
pro/init:  ##@provision Run ansible to init 
	(cd playbook && ansible-playbook -v init.yml --private-key=$(DEV_KEY))

.PHONY: ansible/provision
pro/run:  ##@provision Run ansible to setup machine
	(cd playbook && ansible-playbook -v main.yml --private-key=$(DEV_KEY))

.PHONY: ansible/ansible/install-reqs
pro/install-reqs:  ##@provision Install ansible requirements
	(cd playbook && ansible-galaxy install -r requirements.yml)