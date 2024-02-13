VM_NAME=ubuntu-dev

.PHONY: vm/tart/init
vm/tart/init:  vm/tart/clone vm/tart/set ##@tart Clone and set vm settings

.PHONY: vm/tart/clone
vm/tart/clone: ##@tart Clone ubuntu
	$(TART) clone $(TART_VM) $(TART_VM_NAME)
	@echo "Clone completed..."

.PHONY: vm/tart/set
vm/tart/set: ##@tart Configure vm settings
	$(TART) set $(TART_VM_NAME) --memory=$(VM_MEM) --cpu=$(VM_CPU)
	@echo "Tart vm config set up..."

.PHONY: vm/tart/start
vm/tart/start:  ##@tart Start Tart VM using tart
	@echo "Starting vm using Tart..."
	$(TART) run --dir=shared:$(SHARE) $(TART_VM_NAME)

.PHONY: vm/tart/stop
vm/tart/stop:  ##@tart Stop Tart VM using tart
	@echo "Starting vm using Tart..."
	$(TART) stop $(TART_VM_NAME)

.PHONY: vm/tart/delete
vm/tart/delete:  ##@tart Delete Tart VM
	@echo "deleting vm using Tart..."
	$(TART) delete $(TART_VM_NAME)

.PHONY: vm/tart/ssh
vm/tart/ssh:  ##@tart SSH into the VM, you need to install public key
	@VM_IP=$(shell $(TART) ip $(TART_VM_NAME)) ; \
	$(SSH) -i $(DEV_KEY) $(VM_USER)@$$VM_IP

.PHONY: vm/tart/mount
vm/tart/mount:  ##@tart Mount volume
	@VM_IP=$(shell $(TART) ip $(TART_VM_NAME)) ; \
	$(SSH) $(VM_USER)@$$VM_IP sudo mount -t virtiofs com.apple.virtio-fs.automount /mnt

.PHONY: vm/tart/automount
vm/tart/automount:  ##@tart Automount volume
	@VM_IP=$(shell $(TART) ip $(TART_VM_NAME)) ; \
	printf '%s\n' '#!/bin/sh' 'mount -t virtiofs com.apple.virtio-fs.automount /mnt' 'exit 0'  | $(SSH) -i $(DEV_KEY) $(VM_USER)@$$VM_IP sudo -u root tee /etc/rc.local; \
	$(SSH) -i $(DEV_KEY) $(VM_USER)@$$VM_IP sudo -u root chmod +x /etc/rc.local;


.PHONY: vm/tart/inventory
vm/tart/inventory:  ##@tart Create inventory file for tart
	@VM_IP=$(shell $(TART) ip $(TART_VM_NAME)) ; \
	$(SED) -e "s/--ip--/$$VM_IP/g" -e "s/--user--/$(VM_USER)/g" $(PLYBK)/inventory.tmpl > $(PLYBK)/inventory

.PHONY: vm/tart/install-public-key
vm/tart/install-public-key:  ##@tart Install public key
	@VM_IP=$(shell $(TART) ip $(TART_VM_NAME)) ; \
	$(SSH) -o PubkeyAuthentication=no -o PreferredAuthentications=password $(VM_USER)@$$VM_IP sh -c "'cat >> .ssh/authorized_keys'" < $(DEV_KEY).pub


.PHONY: vm/virtlib/install
vm/virtlib/install: ##@virtlib Install dependencies kvm qemu and libvirt
	sudo apt -y install guestfs-tools bridge-utils cpu-checker libvirt-clients libvirt-daemon qemu qemu-kvm virt-manager

.PHONY: vm/virtlib/setup
vm/virtlib/setup: ##@virtlib Set up libvirt
	sudo systemctl enable --now libvirtd
	sudo systemctl start libvirtd
	sudo systemctl status libvirtd

.PHONY: vm/virtlib/grantpermission
vm/virtlib/grantpermission: ##@virtlib Grant permission for virtlib to access files
	sudo usermod -aG kvm $USER
	sudo usermod -aG libvirt $USER
	sudo addgroup $(USERNAME) libvirt
	sudo addgroup $(USERNAME) kvm

.PHONY: vm/virtlib/create-bridge
vm/virtlib/create-bridge: ##@virtlib Create a network
	nmcli con add type bridge ifname br0
	nmcli con add type bridge-slave ifname enp1s0 master br0 con-name br0-enp0s3
	nmcli con up br0-enp0s3
	nmcli connection show --active

.PHONY: vm/virtlib/delete-bridge
vm/virtlib/delete-bridge: ##@virtlib Create a network
	nmcli -f bridge con delete br0-enp0s3
	nmcli connection delete br0
	nmcli connection show --active

#	connection editor nm-connection-editor
#	sudo ip link add br0 type bridge
#	sudo ip link set enp1s0 master br0
#	sudo ip address add dev br0 192.168.68.1/24
#	sudo ip addr show br0

.PHONY: vm/virtlib/create-net
vm/virtlib/create-net: ##@virtlib Create a network
	virsh net-define $(ETC)/br0.xml
	virsh net-start br0
	virsh net-autostart br0
	virsh net-list --all
#	virsh -c qemu:///session net-define # in case of session level

.PHONY: vm/virtlib/allow-bridge
vm/virtlib/allow-bridge: ##@virtlib Allow bridge for qemu
	sudo mkdir -p /etc/qemu
	echo 'allow all' | sudo tee /etc/qemu/${USER}.conf
	echo "include /etc/qemu/${USER}.conf" | sudo tee --append /etc/qemu/bridge.conf
	sudo chown root:${USER} /etc/qemu/${USER}.conf
	sudo chmod 640 /etc/qemu/${USER}.conf

.PHONY: vm/virtlib/list-net
vm/virtlib/list-net: ##@virtlib List a network
	virsh -c qemu:///session net-list

.PHONY: vm/virtlib/create-image
vm/virtlib/create-image: ##@virtlib Create a vm image based on a template
	(cd $(TMP) && sudo virt-builder debian-12 \
		-o debian-12.qcow2 \
		--format qcow2 \
		--root-password password:password \
		--hostname dev-machine \
		--install "vim,htop,sudo,net-tools" \
		--size $(VM_DISK)G \
		--firstboot-command 'useradd -m -p "" $(VM_USER) ; \
							adduser $(VM_USER) sudo ; echo -e "$(VM_CRED)" | passwd $(VM_USER)'; \
							sudo chown $(USERNAME):$(USERNAME) *.qcow2)

.PHONY: vm/virtlib/create-vm
vm/virtlib/create-vm: ##@virtlib Create a vm
	virt-install \
		--connect qemu:///session \
		--name $(VM_NAME) \
		--ram $(VM_MEM) \
		--vcpus $(VM_CPU) \
		--disk path=$(TMP)/debian-12.qcow2,format=qcow2,cache=none --import \
		--os-variant debian12 \
		--network=default,model=virtio \
		--console pty,target_type=serial

#		--network=bridge=br0,model=virtio \

.PHONY: vm/virtlib/delete
vm/virtlib/delete: ##@virtlib Delete the vm
	$(VIRSH) destroy $(VM_NAME)

.PHONY: vm/virtlib/edit
vm/virtlib/edit: ##@virtlib Delete the vm
	$(VIRSH) edit $(VM_NAME)

.PHONY: vm/virtlib/start
vm/virtlib/start: ##@virtlib Start the vm
	$(VIRSH) start $(VM_NAME)

.PHONY: vm/virtlib/stop
vm/virtlib/stop: ##@virtlib Stop the vm
	$(VIRSH) shutdown $(VM_NAME)

.PHONY: vm/virtlib/list
vm/virtlib/list: ##@virtlib List vms
	$(VIRSH) list --all

.PHONY: vm/virtlib/ip
vm/virtlib/ip: ##@virtlib List vms
	$(VIRSH) domifaddr br0
