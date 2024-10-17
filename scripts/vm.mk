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


.PHONY: vm/libvirt/install
vm/libvirt/install: ##@virtlib Install dependencies kvm qemu and libvirt
	sudo apt -y install guestfs-tools bridge-utils cpu-checker libvirt-clients libvirt-daemon qemu qemu-kvm virt-manager

.PHONY: vm/libvirt/setup
vm/libvirt/setup: ##@virtlib Set up libvirt
	sudo systemctl enable --now libvirtd
	sudo systemctl start libvirtd
	sudo systemctl status libvirtd

.PHONY: vm/libvirt/grantpermission
vm/libvirt/grantpermission: ##@virtlib Grant permission for virtlib to access files
	sudo usermod -aG kvm $USER
	sudo usermod -aG libvirt $USER
	sudo addgroup $(USERNAME) libvirt
	sudo addgroup $(USERNAME) kvm

.PHONY: vm/libvirt/create-bridge
vm/libvirt/create-bridge: ##@virtlib Create a network
	nmcli con add type bridge ifname br0
	nmcli con add type bridge-slave ifname enp1s0 master br0 con-name br0-enp0s3
	nmcli con up br0-enp0s3
	nmcli connection show --active

.PHONY: vm/libvirt/delete-bridge
vm/libvirt/delete-bridge: ##@virtlib Create a network
	nmcli -f bridge con delete br0-enp0s3
	nmcli connection delete br0
	nmcli connection show --active

#	connection editor nm-connection-editor
#	sudo ip link add br0 type bridge
#	sudo ip link set enp1s0 master br0
#	sudo ip address add dev br0 192.168.68.1/24
#	sudo ip addr show br0

.PHONY: vm/libvirt/create-bridge-net
vm/libvirt/create-bridge-net: ##@virtlib Create a network
	virsh net-define $(ETC)/br0.xml
	virsh net-start br0
	virsh net-autostart br0
	virsh net-list --all
#	virsh -c qemu:///session net-define # in case of session level

# ufw https://www.cyberciti.biz/faq/kvm-forward-ports-to-guests-vm-with-ufw-on-linux/
# see https://apiraino.github.io/qemu-bridge-networking/
.PHONY: vm/libvirt/allow-bridge
vm/libvirt/allow-bridge: ##@virtlib Allow bridge for qemu
	sudo mkdir -p /etc/qemu
	echo 'allow all' | sudo tee /etc/qemu/${USER}.conf
	echo "include /etc/qemu/${USER}.conf" | sudo tee --append /etc/qemu/bridge.conf
	sudo chown root:${USER} /etc/qemu/${USER}.conf
	sudo chmod 640 /etc/qemu/${USER}.conf
	sudo chmod u+s /usr/lib/qemu/qemu-bridge-helper

.PHONY: vm/libvirt/list-net
vm/libvirt/list-net: ##@virtlib List a network
	virsh -c qemu:///session net-list

.PHONY: vm/libvirt/create-image
vm/libvirt/create-image: ##@virtlib Create a vm image based on a template
	(cd $(TMP) && sudo virt-builder debian-12 \
		-o $(VM_IMAGE) \
		--format qcow2 \
		--root-password password:password \
		--hostname dev-machine \
		--network \
		--size $(VM_DISK)G \
		--run-command 'apt-get --allow-releaseinfo-change update' \
		--run-command 'dpkg-reconfigure --frontend=noninteractive openssh-server' \
		--run-command 'useradd -m -p "" -s /bin/bash debian || true ; adduser debian sudo' \
		--run-command 'useradd -m -p "" -s /bin/bash $(VM_USER) || true ; adduser $(VM_USER) sudo' \
		--install 'vim,htop,sudo,net-tools,network-manager,snapd' \
		--firstboot-command 'echo -e "$(VM_CRED)" | passwd $(VM_USER)'; \
		sudo virt-sysprep -a $(VM_IMAGE) \
		--run-command 'dpkg-reconfigure --frontend=noninteractive openssh-server' \
		--edit '/etc/network/interfaces: s/ens2/enp1s0/' \
		--ssh-inject debian:file:$(HOME)/.ssh/id_rsa.pub \
		--ssh-inject $(VM_USER):file:$(HOME)/.ssh/id_rsa.pub; \
		sudo chown $(USERNAME):$(USERNAME) $(VM_IMAGE))

.PHONY: vm/libvirt/create-vm
vm/libvirt/create-vm: ##@virtlib Create a vm
	virt-install \
		--connect qemu:///session \
		--name $(VM_NAME) \
		--ram $(VM_MEM) \
		--vcpus $(VM_CPU) \
		--disk path=$(TMP)/$(VM_IMAGE),format=qcow2,cache=none --import \
		--os-variant debian12 \
		--network bridge:virbr0 \
		--console pty,target_type=serial

#		--network=default,model=virtio \
#		--network=bridge=br0,model=virtio \

.PHONY: vm/libvirt/delete
vm/libvirt/delete: ##@virtlib Delete the vm
	$(VIRSH) destroy $(VM_NAME)

.PHONY: vm/libvirt/edit
vm/libvirt/edit: ##@virtlib Delete the vm
	$(VIRSH) edit $(VM_NAME)

.PHONY: vm/libvirt/start
vm/libvirt/start: ##@virtlib Start the vm
	$(VIRSH) start $(VM_NAME)

.PHONY: vm/libvirt/stop
vm/libvirt/stop: ##@virtlib Stop the vm
	$(VIRSH) shutdown $(VM_NAME)

.PHONY: vm/libvirt/list
vm/libvirt/list: ##@virtlib List vms
	$(VIRSH) list --all

.PHONY: vm/libvirt/ip
vm/libvirt/ip: ##@virtlib List vms
	@MAC="$(shell $(VIRSH) dumpxml $(VM_NAME) | grep 'mac address'| grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}')"; arp -an | grep $$MAC | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'
