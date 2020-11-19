# hashistack-ansible

## Files
* hosts.instruqt - Ansible inventory for our instruqt environment.
* play-hashi.yml - Installs HashiCorp products via Ansible roles.
* play-vault.yml - Run Vault roles separately. I use this if I want to perform Vault roles separately.

## Roles
* base - Install pre-requisites missed by Packer
* consul - Install Consul
  * config files, service files, license
* emerging - Dumping ground for new stuff like Waypoint and Boundary
* nomad - Install Nomad
  * config files, service files, license
  * docker pull images for instruqt
* vault - Install Vault
  * config files, service files
* vault-init - Intialize Vault
* vault-unseal - Unseal and License Vault
  * unseal and license

### Tags
* I tagged certains tasks with `home` or `instruqt` or etc.
  * These items might only be relevant to those specific environments
* `home` - used for home lab
* `instruqt` - used for instruqt lab

## How to use
* Clone repo and go into folder
```shell
git clone https://github.com/phanclan/hashistack-ansible.git && \
  cd hashistack-ansible
```

* Modify the hosts file. Play will reference hosts and groups to apply tasks.
* Run the playbook
  * `-i` to specify your hosts and variables
  * `--skip-tags` - Skip tasks with these tags
  * `--tags` - Only run tasks with these tags
```shell
ansible-playbook -i hosts.instruqt play-hashi.yml --skip-tags home
```
