# hashistack-ansible

## Files and Purpose
* hosts.instruqt - Ansible inventory for our instruqt environment.
* play-hashi.yml - Installs HashiCorp products via Ansible roles.
* play-vault.yml - Run Vault roles separately. I use this if I want to perform Vault roles separately.

### Roles
* base - Install pre-requisites missed by Packer
* consul - Install Consul
* emerging - Dumping ground for new stuff like Waypoint and Boundary
* nomad - Install Nomad
* vault - Install Vault
* vault-init - Intialize Vault
* vault-unseal - Unseal and License Vault


## How to use
