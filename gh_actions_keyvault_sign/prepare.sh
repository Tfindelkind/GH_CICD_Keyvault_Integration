## IMPORTANT: Make sure you are logged in to Azure (set Subscription if needed) and Github.com:
## IMPORTANT: az login 
## IMPORTANT: gh auth login 
## A certificate need to be created as 
## For example: openssl req -newkey rsa:4096  -x509  -sha512  -days 365 -nodes -out certificate.pem -keyout privatekey.pem
##              cat privatekey.pem  >> certificate.pem

## Set environment variable like ResourceGroup (RG), Location etc.
## for example 
RG=ghactionsav
LOCATION=WestEurope
CLUSTER="$RG"aks
ACR="$RG"acr
SP="$RG"sp
KV="$RG"kv
SUBSCRIPTION=$(az account show --query id --output tsv)


export RG
export LOCATION
export CLUSTER
export ACR
export SP
export KV
export SUBSCRIPTION

az group create \
    --location $LOCATION \
    --name $RG

 az aks create \
    --resource-group $RG \
    --name $CLUSTER

az acr create \
    --resource-group $RG \
    --name $ACR \
    --sku basic

az aks update \
    --resource-group $RG \
    --name $CLUSTER \
    --attach-acr $ACR

az ad sp create-for-rbac \
    --name $SP \
    --skip-assignment

SERVICE_PRINCIPAL_SECRET=$(az ad sp create-for-rbac --name $SP --query password --output tsv)
SERVICE_PRINCIPAL_APP_ID=$(az ad sp list --display-name $SP --query "[].appId" -o tsv)
SERVICE_PRINCIPAL_TENANT=$(az ad sp list --display-name $SP --query "[].appOwnerTenantId" -o tsv)
SERVICE_PRINCIPAL_OBJ_ID=$(az ad sp list --display-name $SP --query "[].objectId" -o tsv)

gh secret set SERVICE_PRINCIPAL_APP_ID -b $SERVICE_PRINCIPAL_APP_ID
gh secret set SERVICE_PRINCIPAL_SECRET -b $SERVICE_PRINCIPAL_SECRET
gh secret set SERVICE_PRINCIPAL_TENANT -b $SERVICE_PRINCIPAL_TENANT
gh secret set ACR_NAME -b $ACR
gh secret set CLUSTER_RESOURCE_GROUP_NAME -b $RG
gh secret set CLUSTER_NAME -b $CLUSTER

az role assignment create \
    --role AcrPush \
    --assignee-principal-type ServicePrincipal \
    --assignee-object-id $(az ad sp show \
        --id $SERVICE_PRINCIPAL_APP_ID \
        --query objectId -o tsv) \
    --scope $(az acr show --name $ACR --query id -o tsv)


az role assignment create \
    --role "Azure Kubernetes Service Cluster User Role" \
    --assignee-principal-type ServicePrincipal \
    --assignee-object-id $(az ad sp show \
        --id $SERVICE_PRINCIPAL_APP_ID \
        --query objectId -o tsv) \
    --scope $(az aks show \
        --resource-group $RG \
        --name $CLUSTER \
        --query id -o tsv)

az role assignment create \
    --role "Azure Kubernetes Service RBAC Writer" \
    --assignee-principal-type ServicePrincipal \
    --assignee-object-id $(az ad sp show \
        --id $SERVICE_PRINCIPAL_APP_ID \
        --query objectId -o tsv) \
    --scope "$(az aks show \
        --resource-group $RG \
        --name $CLUSTER \
        --query id -o tsv)/namespaces/default"

az keyvault create \
    --name $KV \
    --resource-group $RG \
    --location $LOCATION

#az role assignment create \
#    --role "Key Vault Certificates Officer" \
#    --assignee-principal-type ServicePrincipal \
#    --assignee-object-id $(az ad sp show \
#    --id $SERVICE_PRINCIPAL_APP_ID \
#    --query objectId -o tsv) \
#    --scope /subscriptions/$SUBSCRIPTION/resourcegroups/$RG


az keyvault set-policy \
    --name $KV \
    --object-id $SERVICE_PRINCIPAL_OBJ_ID \
    --secret-permissions backup restore \
    --key-permissions get list import \
    --certificate-permissions get list