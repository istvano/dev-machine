.PHONY: ansible/provision
ansible/provision:  ##@provision Run ansible to setup machine
	(cd playbook && ansible-playbook main.yml --ask-pass)
