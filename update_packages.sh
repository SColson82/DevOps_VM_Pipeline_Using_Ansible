#!/bin/bash

# Run Ansible playbook for updating packages
ansible-playbook -i /etc/ansible/hosts update_packages.yml || { echo "Failed to run Ansible playbook for updating packages."; exit 1; }
