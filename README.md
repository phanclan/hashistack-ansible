# hashistack-ansible

## Files
* hosts.instruqt - Ansible inventory for our instruqt environment.
* play-hashi.yml - Installs HashiCorp products via Ansible roles.
* play-vault.yml - Run Vault roles separately. I use this if I want to perform Vault roles separately.

## Roles
* base - Install pre-requisites missed by Packer
* consul - Install Consul
* emerging - Dumping ground for new stuff like Waypoint and Boundary
* nomad - Install Nomad
* vault - Install Vault
* vault-init - Intialize Vault
* vault-unseal - Unseal and License Vault

### Tags
* I tagged certains tasks with `home` or `instruqt` or etc.
  * These items might only be relevant to those specific environments
* `home` - used for home lab
* `instruqt` - used for instruqt lab


## How to use
* Clone repo and go into folder
```
git clone https://github.com/phanclan/hashistack-ansible.git && \
cd hashistack-ansible
```
* Run the playbook
  * `-i` to specify your hosts and variables
  * `--skip-tags` - Skip tasks with these tags
  * `--tags` - Only run tasks with these tags
```
ansible-playbook -i hosts.instruqt play-vault.yml --skip-tags home
```
