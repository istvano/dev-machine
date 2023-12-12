# dev-machine
Setup Ubuntu based development machine with ansible. At the moment, Tart is supported as a VM provider to spin 
up a virtual ubuntu instance.

## Pre reqs
You need to install ssh, git, docker and ansible and sshpass

## Usage

Execute `make` to get a list of command you can do

### Install pre requisites

* `sudo apt install ansible openssh-server make` installs ansible and ssh

### Download the release

* `cd ~ && mkdir setup && cd setup && wget https://github.com/istvano/dev-machine/archive/refs/tags/0.0.4.tar.gz`
* `tar -xzvf 0.0.4.tar.gz`
* `cd dev-machine-0.0.4`
* `cp .env.sample .env`
* `make dev-key/create` will create a developer x.509 key pair for ssh access

### Init vm with tart

if you use a vm like tart, you can create the vm with the following commands:

* `make vm/tart/clone` will create an ubuntu vm
* `make vm/tart/set` will change the vm settings using .env cpu and mem values
* `make vm/tart/start` will start the vitual machine

Wait for the machine to boot up ...

### Prepare provisioning with tart

if you use a vm like tart, you can set up the vm and ansible inventory with the following commands:

* `make vm/tart/install-public-key` will install the dev key onto the vm to easy ssh access
* `make vm/tart/inventory` will create an ansible inventory file using the VM's ip

### Use it with a local server instead of tart

In case you are using this against a local machine, use the following commands to install your PK onto the machine
and create an inventory file for localhost

* `make local/install-public-key` Install public key for local machine
* `make local/inventory` Create inventory file for local machine

### run provisioning with ansible

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

> Please note: if you running the provisioning against a server where you need sudo password, you can add
> the -K to PRO_PARAMS in .env

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