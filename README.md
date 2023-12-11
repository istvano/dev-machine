# dev-machine
Setup Ubuntu based development machine with ansible. At the moment, Tart is supported as a VM provider to spin 
up a virtual ubuntu instance.

## Pre reqs
You need to install ssh, git, docker and ansible and sshpass

## Usage

Execute `make` to get a list of command you can do

### Init

* `make dev-key/create` will create a developer x.509 key pair for ssh access
* `make vm/tart/clone` will create an ubuntu vm
* `make vm/tart/set` will change the vm settings using .env cpu and mem values
* `make vm/tart/start` will start the vitual machine

Wait for the machine to boot up

### Provision

* `make vm/tart/install-public-key` will install the dev key onto the vm to easy ssh access
* `make vm/tart/inventory` will create an ansible inventory file using the VM's ip
* `make pro/install-reqs` will install ansible requirements
* `make pro/init` set up required keys and repositories
* `make pro/dekstop` will run ansible and provision the desktop if you are running a server version
* `make pro/dev` will run ansible and provision the vm with dev tools python, vscode, intellij
* `make pro/snaps` will run ansible and installs postman and other snap packages postman
* `make pro/workspace` will run ansible and provision dev workspace e.g. gitconfig
* `make pro/misc` will run ansible and provision multimedia and office, backup apps and browser
* `make pro/security` will run ansible and enable firewall

### Params

* LOCAL_ADDRESS the address of the machine for local provisioning, used to create inventory for local run
* LOCAL_USER the user to connect to the local address
* PRO_PARAMS any parameters for ansible e.g. -k (ssh password) -K (become password)

## Info

Open the requirements.yml to find details about the external ansible roles
in the playbook/roles folder you can find some addition roles that is used by the setup

## Shell

* https://starship.rs/
* https://github.com/spaceship-prompt/spaceship-prompt
* https://github.com/viasite-ansible/ansible-role-zsh

## Missing packages

* https://github.com/wagoodman/dive
* https://github.com/bcicen/ctop
* https://github.com/mikefarah/yq
* https://github.com/watchexec/watchexec

* sed alternative https://github.com/chmln/sd
* ps alternative https://github.com/dalance/procs
* ls alternative https://github.com/lsd-rs/lsd
* github cli https://github.com/cli/cli 
* du alternative https://github.com/bootandy/dust