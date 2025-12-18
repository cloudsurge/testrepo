#!/usr/bin/env bash

# Install Terraform
TERRAFORM_VERSION=${TERRAFORM_VERSION:-1.14.3}
echo "=====> Installing Terraform ${TERRAFORM_VERSION}"
wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
unzip -q terraform_${TERRAFORM_VERSION}_linux_amd64.zip
chmod +x terraform
sudo mv terraform /usr/local/bin/
terraform version

# Install scanning software
echo "=====> Installing security scanning: checkov latest"
pip3 install checkov