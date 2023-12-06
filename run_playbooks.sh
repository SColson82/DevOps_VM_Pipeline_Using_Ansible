#!/bin/bash

# Run Ansible playbook for the specified environment
ansible-playbook -i /etc/ansible/hosts "$1.yml" --extra-vars="git_branch=master"
