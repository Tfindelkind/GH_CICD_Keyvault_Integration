## IMPORTANT: az login and set Azure Subscription as needed 
## IMPORTANT: github CLI need to be installed

## Set environment variable like ResourceGroup (RG), Location etc.
## for example 
RG=GHActionsKV
LOCATION=WestEurope
CLUSTER="$RG"AKS
ACR="$RG"ACR
SP="$RG"SP

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

gh secret set SERVICE_PRINCIPAL_APP_ID -b $SERVICE_PRINCIPAL_APP_ID
gh secret set SERVICE_PRINCIPAL_SECRET -b $SERVICE_PRINCIPAL_SECRET
gh secret set SERVICE_PRINCIPAL_TENANT -b $SERVICE_PRINCIPAL_TENANT

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

