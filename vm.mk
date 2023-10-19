.PHONY: vm/tart/clone
vm/tart/clone:  ##@vm Clone Tart VM using tart
	@echo "Cleanup completed"
	$(TART) clone $(TART_VM) $(TART_VM_NAME)

.PHONY: vm/tart/start
vm/tart/start:  ##@vm Start Tart VM using tart
	@echo "Starting vm using Tart..."
	$(TART) run --dir=shared:$(SHARE) $(TART_VM_NAME)

.PHONY: vm/tart/ssh
vm/tart/ssh:  ##@vm SSH into the VM
	@VM_IP=$(shell $(TART) ip $(TART_VM_NAME)) ; \
	$(SSH) $(VM_USER)@$$VM_IP

.PHONY: vm/tart/mount
vm/tart/mount:  ##@vm Mount volume
	@VM_IP=$(shell $(TART) ip $(TART_VM_NAME)) ; \
	$(SSH) $(VM_USER)@$$VM_IP sudo mount -t virtiofs com.apple.virtio-fs.automount /mnt