.PHONY: all deps lint keys cluster harden deploy audit clean

ANSIBLE_DIR = /vagrant/ansible
PLAYBOOK    = cd $(ANSIBLE_DIR) && ansible-playbook

all: deps lint keys baseline cluster harden deploy audit
	@echo "=== Reconstruction complète terminée ==="

deps:
	@echo "=== Installation des dépendances Ansible ==="
	cd $(ANSIBLE_DIR) && ansible-galaxy collection install kubernetes.core community.general ansible.posix --force

lint:
	@echo "=== Lint des playbooks ==="
	cd $(ANSIBLE_DIR) && ansible-lint || true

keys:
	@echo "=== Génération des clés SSH (alice, bob) ==="
	@for u in alice bob; do \
		[ -f /home/vagrant/.ssh/$$u ] || ssh-keygen -t ed25519 -N "" -C "$$u@nova" -f /home/vagrant/.ssh/$$u; \
	done

baseline:
	@echo "=== Socle commun (chrony, paquets, timezone, bannière) ==="
	$(PLAYBOOK) playbooks/baseline.yml

cluster:
	@echo "=== Installation k3s + Helm ==="
	$(PLAYBOOK) playbooks/cluster.yml

harden:
	@echo "=== Durcissement + gestion des accès ==="
	$(PLAYBOOK) playbooks/harden.yml --skip-tags firewall
	$(PLAYBOOK) playbooks/harden.yml --tags firewall

deploy:
	@echo "=== Déploiement applicatif (Préprod puis Prod) ==="
	$(PLAYBOOK) playbooks/deploy.yml -e nova_require_approval=false

audit:
	@echo "=== Audit de conformité ==="
	$(PLAYBOOK) playbooks/audit.yml

clean:
	@echo "=== Nettoyage des sockets SSH ==="
	rm -f ~/.ansible/cp/*
