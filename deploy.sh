#!/bin/bash

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Function to handle errors
handle_error() {
    log "Error: $1"
    exit 1
}

# Prompt the user for environment (dev, test, prod)
read -p "Enter the environment (dev/test/prod): " environment

# Convert environment to lowercase
environment=$(echo "$environment" | tr '[:upper:]' '[:lower:]')

# Check if a valid environment is provided
if [[ ! "$environment" =~ ^(dev|test|prod)$ ]]; then
    handle_error "Invalid environment. Use dev, test, or prod."
fi

# Prompt the user for branch name
read -p "Enter the Git branch name: " git_branch

# Check if a Git branch is provided
if [ -z "$git_branch" ]; then
    handle_error "Git branch cannot be empty."
fi

# Log the selected environment and Git branch
log "Selected environment: $environment"
log "Selected Git branch: $git_branch"

# Execute the appropriate Ansible playbook
log "Running Ansible playbook for $environment environment..."
ansible-playbook -i /etc/ansible/hosts "$environment.yml" --extra-vars="git_branch=$git_branch" || handle_error "Failed to run Ansible playbook."

# Log completion
log "Deployment completed successfully."
