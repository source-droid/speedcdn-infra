#!/bin/bash
# One-command deployment script - s23150618

set -e  # Exit on error

echo "========================================="
echo "SpeedyCDN Deployment Script"
echo "Student: s23150618"
echo "========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as correct user
if [ "$USER" != "s23150618" ]; then
    echo -e "${YELLOW}Warning: Running as $USER, not s23150618${NC}"
fi

# Check Ansible installation
if ! command -v ansible &> /dev/null; then
    echo -e "${RED}Ansible not found. Installing...${NC}"
    sudo apt update && sudo apt install ansible -y
fi

# Check SSH key
if [ ! -f ~/.ssh/ansible_key ]; then
    echo -e "${YELLOW}SSH key not found. Generating...${NC}"
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/ansible_key -N ""
    echo -e "${GREEN}SSH key generated. Copy to server with:${NC}"
    echo "ssh-copy-id -i ~/.ssh/ansible_key.pub s23150618@192.168.8.110"
    exit 1
fi

# Get server IP if not provided
SERVER_IP=${1:-"192.168.8.110"}
echo -e "${GREEN}Target server: $SERVER_IP${NC}"

# Update inventory file
sed -i "s/ansible_host=.*/ansible_host=$SERVER_IP/" inventory/production/hosts

# Run syntax check
echo -e "\n${YELLOW}Checking playbook syntax...${NC}"
ansible-playbook -i inventory/production/hosts playbooks/site.yml --syntax-check
if [ $? -ne 0 ]; then
    echo -e "${RED}Syntax check failed!${NC}"
    exit 1
fi
echo -e "${GREEN}Syntax check passed${NC}"

# Test connection
echo -e "\n${YELLOW}Testing connection to server...${NC}"
ansible -i inventory/production/hosts webservers -m ping
if [ $? -ne 0 ]; then
    echo -e "${RED}Connection failed!${NC}"
    echo "Make sure you can SSH to $SERVER_IP"
    exit 1
fi
echo -e "${GREEN}Connection successful${NC}"

# Run deployment
echo -e "\n${YELLOW}Starting deployment...${NC}"
ansible-playbook -i inventory/production/hosts playbooks/site.yml \
  --extra-vars "student_id=s23150618 enable_monitoring=true"

if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}=========================================${NC}"
    echo -e "${GREEN}Deployment Successful!${NC}"
    echo -e "${GREEN}=========================================${NC}"
    echo "Access your services at:"
    echo "  Nginx:   http://$SERVER_IP:8080"
    echo "  Varnish: http://$SERVER_IP:80"
    echo "  Grafana: http://$SERVER_IP:3000 (admin/admin)"
    echo "  Prometheus: http://$SERVER_IP:9090"
    echo ""
    echo "Student ID: s23150618 verified"
else
    echo -e "\n${RED}Deployment failed!${NC}"
    exit 1
fi
