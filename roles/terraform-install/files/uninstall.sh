# https://support.hashicorp.com/hc/en-us/articles/360043134793-Uninstalling-Terraform-Enterprise
echo "#==> stop the Terraform Enterprise application"
replicatedctl app stop
replicatedctl app status
echo "#==> stop the Replicated services"
sudo systemctl stop replicated replicated-ui replicated-operator
sudo systemctl disable replicated replicated-ui replicated-operator

echo "#==> stop and remove the Replicated containers:"

sudo docker rm -f replicated replicated-ui replicated-operator \
  replicated-premkit retraced-api retraced-processor \
  retraced-cron retraced-nsqd retraced-postgres
  # replicated-statsd

echo "#==> Remove all Replicated files and executable from the host:"

sudo rm -rf /etc/default/replicated* /etc/init.d/replicated* \
  /etc/init/replicated* /etc/replicated* /etc/sysconfig/replicated* \
  /etc/systemd/system/multi-user.target.wants/replicated* \
  /etc/systemd/system/replicated* /run/replicated* /usr/local/bin/replicated* \
  /var/lib/replicated* /var/log/upstart/replicated*

echo "#==> Remove unused data."
sudo docker system prune --all --volumes -f