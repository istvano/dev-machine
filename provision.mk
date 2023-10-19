.PHONY: ansible/init
ansible/init:  ##@provision Run ansible to init 
	(cd playbook && ansible-playbook -vvv init.yml --ask-pass)

.PHONY: ansible/provision
ansible/provision:  ##@provision Run ansible to setup machine
	(cd playbook && ansible-playbook -vvv main.yml --ask-pass)

.PHONY: ansible/ansible/install-reqs
ansible/install-reqs:  ##@provision Install ansible requirements
	(cd playbook && ansible-galaxy install -r requirements.yml)