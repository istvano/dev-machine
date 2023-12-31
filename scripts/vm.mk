.PHONY: vm/tart/init
vm/tart/init:  vm/tart/clone vm/tart/set ##@vm Clone and set vm settings

.PHONY: vm/tart/clone
vm/tart/clone: ##@vm Clone ubuntu
	$(TART) clone $(TART_VM) $(TART_VM_NAME)
	@echo "Clone completed..."

.PHONY: vm/tart/set
vm/tart/set: ##@vm Configure vm settings
	$(TART) set $(TART_VM_NAME) --memory=$(VM_MEM) --cpu=$(VM_CPU)
	@echo "Tart vm config set up..."

.PHONY: vm/tart/start
vm/tart/start:  ##@vm Start Tart VM using tart
	@echo "Starting vm using Tart..."
	$(TART) run --dir=shared:$(SHARE) $(TART_VM_NAME)

.PHONY: vm/tart/stop
vm/tart/stop:  ##@vm Stop Tart VM using tart
	@echo "Starting vm using Tart..."
	$(TART) stop $(TART_VM_NAME)

.PHONY: vm/tart/delete
vm/tart/delete:  ##@vm Delete Tart VM
	@echo "deleting vm using Tart..."
	$(TART) delete $(TART_VM_NAME)

.PHONY: vm/tart/ssh
vm/tart/ssh:  ##@vm SSH into the VM, you need to install public key
	@VM_IP=$(shell $(TART) ip $(TART_VM_NAME)) ; \
	$(SSH) -i $(DEV_KEY) $(VM_USER)@$$VM_IP

.PHONY: vm/tart/mount
vm/tart/mount:  ##@vm Mount volume
	@VM_IP=$(shell $(TART) ip $(TART_VM_NAME)) ; \
	$(SSH) $(VM_USER)@$$VM_IP sudo mount -t virtiofs com.apple.virtio-fs.automount /mnt

.PHONY: vm/tart/automount
vm/tart/automount:  ##@vm Automount volume
	@VM_IP=$(shell $(TART) ip $(TART_VM_NAME)) ; \
	printf '%s\n' '#!/bin/sh' 'mount -t virtiofs com.apple.virtio-fs.automount /mnt' 'exit 0'  | $(SSH) -i $(DEV_KEY) $(VM_USER)@$$VM_IP sudo -u root tee /etc/rc.local; \
	$(SSH) -i $(DEV_KEY) $(VM_USER)@$$VM_IP sudo -u root chmod +x /etc/rc.local;


.PHONY: vm/tart/inventory
vm/tart/inventory:  ##@vm Create inventory file for tart
	@VM_IP=$(shell $(TART) ip $(TART_VM_NAME)) ; \
	$(SED) -e "s/--ip--/$$VM_IP/g" -e "s/--user--/$(VM_USER)/g" $(PLYBK)/inventory.tmpl > $(PLYBK)/inventory

.PHONY: vm/tart/install-public-key
vm/tart/install-public-key:  ##@vm Install public key
	@VM_IP=$(shell $(TART) ip $(TART_VM_NAME)) ; \
	$(SSH) -o PubkeyAuthentication=no -o PreferredAuthentications=password $(VM_USER)@$$VM_IP sh -c "'cat >> .ssh/authorized_keys'" < $(DEV_KEY).pub

