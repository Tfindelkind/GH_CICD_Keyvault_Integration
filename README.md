# Overview
This simple CI/CD pipeline demonstrate how an artifact (digest of container) could be signed by Azure Keyvault and could be verified before deployment

# Preparation
Azure Subscription is needed
A Github Repo fork of this repo is needed
Clone the fork

# prepare.sh script
This script will prepare the Azure environment and Github.com environment and needs to run beforehand
In order to run this script you need to have:
- bash 
- "az" CLI installed
- "gh" CLI installed
- run: "az login" and "gh auth login"

./prepare.sh

# Deploying the application

echo "1.0.9" > ./version
git commit -m "release version 1.0.9"
git tag v1.0.9
git push origin main --tags



# cleanup after using
./cleanup.sh
