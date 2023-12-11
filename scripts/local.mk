.PHONY: local/inventory
local/inventory:  ##@local Create inventory file for local machine
	@VM_IP=$(LOCAL_ADDRESS) ; \
	$(SED) -e "s/--ip--/$$VM_IP/g" -e "s/--user--/$(LOCAL_USER)/g" $(PLYBK)/inventory.tmpl > $(PLYBK)/inventory

.PHONY: local/install-public-key
local/install-public-key:  ##@local Install public key for local machine
	@VM_IP=$(LOCAL_ADDRESS) ; \
	$(SSH) -o PubkeyAuthentication=no -o PreferredAuthentications=password $(LOCAL_USER)@$$VM_IP sh -c "'cat >> .ssh/authorized_keys'" < $(DEV_KEY).pub
