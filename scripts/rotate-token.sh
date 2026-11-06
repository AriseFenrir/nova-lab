#!/usr/bin/env bash
# rotate-token.sh : génère un nouveau jeton applicatif et le chiffre dans le Vault de l'environnement
# Usage : scripts/rotate-token.sh preprod|prod
set -euo pipefail
ENV="${1:?usage: $0 preprod|prod}"
cd /vagrant/ansible
VAULT_FILE="inventories/group_vars/${ENV}/vault.yml"

NEW_TOKEN="tok-${ENV}-$(openssl rand -hex 16)"    # 128 bits d'entropie
TMP="$(mktemp)"                                   # fichier temporaire local à la VM (pas /vagrant)
trap 'shred -u "$TMP" 2>/dev/null || rm -f "$TMP"' EXIT

printf 'vault_nova_api_token: "%s"\n' "$NEW_TOKEN" > "$TMP"
ansible-vault encrypt --encrypt-vault-id "$ENV" --output "$VAULT_FILE" "$TMP"

echo "Nouveau jeton chiffré dans ${VAULT_FILE}."
echo "Étape suivante : ansible-playbook playbooks/deploy.yml --limit ${ENV} -e nova_require_approval=false"
