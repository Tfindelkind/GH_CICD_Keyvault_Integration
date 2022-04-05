# Overview
This simple CI/CD pipeline demonstrate how an artifact (digest of container) could be signed by Azure Keyvault and could be verified before deployment

# Preparation
Azure Subscription is needed
A Github Repo fork of this repo is needed

# prepare.sh script
This script will prepare the Azure environment and Github.com environment and needs to run beforehand
In order to run this script you need to have:
- bash 
- "az" CLI installed
- "gh" CLI installed
- run: "az login" and "gh auth login"

./prepare.sh

# cleanup after using
./cleanup.sh
