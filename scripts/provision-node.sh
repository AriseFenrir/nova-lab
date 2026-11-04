#!/usr/bin/env bash
# provision-node.sh : exécuté par Vagrant (en root) sur preprod et prod
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

echo ">>> [1/3] Noms de machines du laboratoire"
grep -q "# nova-lab" /etc/hosts || cat >> /etc/hosts <<'HOSTS'
# nova-lab
192.168.56.10 ctrl
192.168.56.21 node-preprod
192.168.56.22 node-prod
HOSTS

echo ">>> [2/3] Autoriser la clé SSH de ctrl (Ansible se connecte avec elle)"
PUB=/vagrant/.ssh_share/ctrl.pub
AUTH=/home/vagrant/.ssh/authorized_keys
if [ -f "$PUB" ]; then
  grep -qxF "$(cat "$PUB")" "$AUTH" || cat "$PUB" >> "$AUTH"
else
  echo "!!! ctrl.pub absente : faire 'vagrant up ctrl' puis 'vagrant provision <nœud>'"
fi

echo ">>> [3/3] Python 3 (requis par les modules Ansible sur les nœuds gérés)"
apt-get update -qq
apt-get install -y -qq python3 python3-pip

echo ">>> nœud prêt."
