#!/usr/bin/env bash

# Variables
aws_region="your_aws_region"
key_pair_name="your_key_pair_name"
security_group_name="ansible_security_group"
instance_type="t2.micro"
ami_id="ami-xxxxxxxxxxxxxxxxx"  # Use the appropriate AMI for your region and distribution (e.g., Ubuntu)

# Create Security Group
aws ec2 create-security-group --group-name "$security_group_name" --description "Ansible Security Group" --region "$aws_region"
aws ec2 authorize-security-group-ingress --group-name "$security_group_name" --protocol tcp --port 22 --cidr 0.0.0.0/0 --region "$aws_region"

# Launch EC2 Instance
instance_id=$(aws ec2 run-instances --image-id "$ami_id" --count 1 --instance-type "$instance_type" \
  --key-name "$key_pair_name" --security-groups "$security_group_name" --region "$aws_region" \
  --query 'Instances[0].InstanceId' --output text)

# Wait for the instance to be running
aws ec2 wait instance-running --instance-ids "$instance_id" --region "$aws_region"

# Get the public IP address of the instance
public_ip=$(aws ec2 describe-instances --instance-ids "$instance_id" --query 'Reservations[0].Instances[0].PublicIpAddress' --output text --region "$aws_region")

# Output instance details
echo "Ansible Control Node instance created successfully."
echo "Instance ID: $instance_id"
echo "Public IP Address: $public_ip"
echo "SSH into the instance using: ssh -i <your_key.pem> ubuntu@$public_ip"
