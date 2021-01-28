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
* `dns` - dns changes. newer versions of Ubuntu have system-resolv on port 53

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

Example for instruqt.

```shell
ansible-playbook -i hosts.instruqt play-hashistack.yml --skip-tags home -e @vars-instruqt.yml
```

- `vars-instruqt.yml` file specifies values specific for instruqt environment.
- Same with `hosts.instruqt`.
- We are skippings tasks tagged with `home`. These are not relevant to instruqt.

Ex - Vagrant
```
ansible-playbook -i hosts play-hashistack.yml --skip-tags dns,hashicups
```

### Task Order Template
bear://x-callback-url/open-note?id=E032F39B-21F9-40CE-BD0D-4877437C7F7A-64296-0006425DF95AEEE4&header=Task%20Order%20Template

