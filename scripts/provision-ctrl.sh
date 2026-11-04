#!/usr/bin/env bash
# provision-ctrl.sh : exécuté par Vagrant (en root) à la création de la VM "ctrl"
set -euo pipefail                     # stop à la 1re erreur, variable non définie = erreur
export DEBIAN_FRONTEND=noninteractive # aucune question posée par apt

echo ">>> [1/5] Noms de machines du laboratoire"
grep -q "# nova-lab" /etc/hosts || cat >> /etc/hosts <<'HOSTS'
# nova-lab
192.168.56.10 ctrl
192.168.56.21 node-preprod
192.168.56.22 node-prod
HOSTS

echo ">>> [2/5] Paquets système"
apt-get update -qq
apt-get install -y -qq python3-pip git curl jq unzip make sshpass bash-completion

echo ">>> [3/5] Ansible + outils qualité (ansible-core 2.17 = dernière branche compatible Python 3.10)"
pip3 install --quiet "ansible-core~=2.17.0" ansible-lint yamllint

echo ">>> [4/5] Helm 3 (pour 'helm lint' et 'helm template' côté ctrl)"
if ! command -v helm >/dev/null; then
  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
    | DESIRED_VERSION=v3.16.4 bash
fi

echo ">>> [5/5] Clé SSH de l'automate + configuration Ansible"
sudo -u vagrant bash -c '[ -f ~/.ssh/id_ed25519 ] || ssh-keygen -q -t ed25519 -N "" -C ansible@ctrl -f ~/.ssh/id_ed25519'
mkdir -p /vagrant/.ssh_share                                  # dossier d'échange (ignoré par Git)
cp /home/vagrant/.ssh/id_ed25519.pub /vagrant/.ssh_share/ctrl.pub
echo 'export ANSIBLE_CONFIG=/vagrant/ansible/ansible.cfg' > /etc/profile.d/nova-ansible.sh

echo ">>> ctrl prête."