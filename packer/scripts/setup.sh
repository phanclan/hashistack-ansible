#!/bin/bash
set -x
#wait for box - 30
sleep 15

#base packages
sudo DEBIAN_FRONTEND=noninteractive apt-get install -qq vim curl wget unzip
#hashicorp packages
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

#azure packages
curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo apt-key add -
AZ_REPO=$(lsb_release -cs)
sudo apt-add-repository "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main"

#install packages
sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -qq awscli azure-cli \
  consul-enterprise=1.9.4+ent vault-enterprise=1.7.0+ent \
  nomad-enterprise=1.0.4+ent docker.io \
  jq python3-pip tree

/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync

exit 0