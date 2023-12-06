# Automated Server Configuration, Deployment, and Maintenance for Multiple Environments

## Project Overview

SwollenHippo Enterprises aims to automate server configuration, web application deployment, and maintenance across different environments. This documentation provides a guide on how to set up the system, deploy web applications, and maintain server packages.

## Table of Contents

1. [Server Environment Setup](#1-server-environment-setup)
2. [Ansible Playbooks](#2-ansible-playbooks)
3. [Bash Shell Scripting](#3-bash-shell-scripting)
4. [Cron Jobs](#4-cron-jobs)


## 1. Server Environment Setup

### VM Configuration

- VM1: Web Server (Apache and Node.js)
- VM2: Web Server (Apache and Node.js)
- VM3: Database Server (MariaDB)

### Create the VMs for the Ansible Control Nodes:
We will do the following for the management node. 

* In the GCP Console (https://console.cloud.google.com), navigate to the Compute Engine section.
* Click on "Create Instance" to create a new VM instance.
* Under Name I will use the following conventions for clarity. 
    * m01

Note: this naming convention is for tutorial purposes and may not be acceptable for security reasons. It should not be taken as standard.

* Choose a region. I will be using us-central1 (Iowa) for this tutorial but it may be more secure to vary the locations in the future. 
* Choose E2
* Change the machine type to e2-small
* Under "Boot disk", choose Centos and version Centos 7 (I will use Centos 7 for all of the machines)
* Then click on "Create"

Next we will create development, testing, and production machines for two different environments: one that will be a web server which we will call vm1 and the other that will be both a web server and a database server which we will call vm2. This will create six new machines for a total of nine machines. You will do the following six times, once for each name.

* Click on "Create Instance" to create a new VM instance.
* Under Name I will use the following conventions for clarity. 
    * vm1test
    * vm1dev
    * vm1prod
    * vm2test
    * vm2dev
    * vm2prod
* Choose a region.  
* Choose E2
* Change the machine type to e2-small
* Under "Boot disk", choose Centos and version Centos 7 (I will use Centos 7 for all of the machines)
* Under "Firewall" check "Allow HTTP traffic" and "Allow HTTPS traffic"
* Then click on "Create"


## Configuring Management Node
This section pertains to m01.
* Click on the three dots to the right of m01 and click on start/resume
* Click on the dropdown next to ssh to the right of mdev and open in browser. 
* Click on authorize.

This should look familiar if you have worked in a Linux or CLI type environment before. You should see something like the following:

![CLI Interface](images/mdevCLIinterface.png)

First, set a password:

$ ```sudo passwd```

Note that you will not be able to see what you are typing here. Also, you will be asked for confirmation. 

![Set Password](images/SetPassword.png)

This environment is pretty close to empty. The following installs will probably be handy:

$ ```sudo yum install -y nano git ansible```

* sudo will allow you to install these as the root user
* yum is used because this is a Centos environment, if you created a Debian environment you will need to use apt-get
* -y confirms the installation command, otherwise you will need to type 'yes' when prompted
* nano git ansible are the 3 primary packages being installed. You will see pages of dependencies being installed with this command as each of these packages relies on other packages to do their work. 

### Adding Groups

```
$ cd /etc/ansible/
$ sudo nano hosts
```
At the very bottom of the hosts script you will need to add the following:

Note: IP addresses (the 10.128.0.15 type number), vary and you should not simply copy and paste what you see below. The Internal IP addresses found to the right of the VM names should be used here. 

```
# Grouped WebServer Prod Hosts
 [webserverprod]
 10.128.0.15
 10.142.0.4

 [webserverprod:vars]
 ansible_user=root
 ansible_password=Mickey2023!

# Grouped WebServer Dev Hosts
 [webserverdev]
 10.128.0.14
 10.128.0.16

 [webserverdev:vars]
 ansible_user=root
 ansible_password=Mickey2023!

# Grouped Webserver Test Hosts
 [webservertest]
 10.128.0.13
 10.128.0.17

 [webservertest:vars]
 ansible_user=root
 ansible_password=Mickey2023!

# Grouped DatabaseServer Prod Hosts
 [dbserverprod]
 10.142.0.4

 [dbserverprod:vars]
 ansible_user=root
 ansible_password=Mickey2023!

# Grouped DatabaseServer Dev Hosts
 [dbserverdev]
 10.128.0.16

 [dbserverdev:vars]
 ansible_user=root
 ansible_password=Mickey2023!

# Grouped Database Server Test Hosts
 [dbservertest]
 10.128.0.17

 [dbservertest:vars]
 ansible_user=root
 ansible_password=Mickey2023!

```

To save these changes and exit, hit ctrl+c followed by y (for yes) and then enter. 

### SSH Configuration

```
sudo nano /etc/ssh/sshd_config
```

1. Set `PermitRootLogin` to `yes` in `/etc/ssh/sshd_config` on all VMs.

2. Uncomment `PasswordAuthentication yes` and comment out `PasswordAuthentication no`.

To save these changes and exit, hit ctrl+c followed by y (for yes) and then enter.

Change your root password (using 'sudo passwd') and alter the sshd_config file like this in each of your vms. 

You may also want to:

```
sudo yum install -y nano
```
### Ansible Configuration

1. Disable host key checking 

```
sudo nano /etc/ansible/ansible.cfg
```


Find `host_key_checking = False` and uncomment it. 

To save these changes and exit, hit ctrl+c followed by y (for yes) and then enter.

### Exit from your management node and start/restart all of your vms.

### Adding Management Node's Public Key to the Remote VMs
Restart m01 and run the following.
```
ssh-keygen
```
Use the default file location and add your passphrase.

## 2. Ansible Playbooks

### Playbooks

- `dev.yml`, `test.yml`, `prod.yml`: Environment-specific playbooks for server setup and web application deployment.
- `update_packages.yml`: Playbook for updating server packages.
- These can all be found in the ansible-playbooks directory.

### Usage

bash

```
ansible-playbook -i /etc/ansible/hosts dev.yml
ansible-playbook -i /etc/ansible/hosts update_packages.yml
```

### Playbook Content

- `web-server.yaml` for each environment:
  - Install Apache and Node.js.
  - Deploy the web application using a shell script.
- `db-server.yaml` for each environment:
  - Install MariaDB.

## 3. Bash Shell Scripting

### Script Structure

Create a bash script for server environment setup and deployment:

- `deploy.sh`

### Script Content

- Prompt the user for configuration parameters (e.g., IP addresses, Git branch).
- Invoke the relevant Ansible playbook based on the specified environment.
- Implement error handling and logging.

### Usage

bash

```
sh ./deploy.sh
```


## 4. Cron Jobs

### Cron Job Setup

Create two separate shell scripts for cron jobs:

- `run_playbooks.sh`
  - Schedule to run Ansible playbooks for environment setup and web app deployment every minute.

- `update_packages.sh`
  - Schedule to check for new package updates once per day.

### Running the Cron Jobs
```
export VISUAL=nano
# Edit cron jobs
crontab -e
```

Add these lines:

```
# Runs the Ansible playbooks for the dev environment setup and web app deployment every minute.
* * * * * ./run_playbooks.sh dev > /var/log/ansible_dev.log 2>&1

# Runs the update_packages.yml once per day to check for package updates 
0 2 * * * ./update_packages.sh > /var/log/ansible_update_packages.log 2>&1
```
To save these changes and exit, hit ctrl+c followed by y (for yes) and then enter.













