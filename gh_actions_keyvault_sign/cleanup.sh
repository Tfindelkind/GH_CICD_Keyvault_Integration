## IMPORTANT: az login and set Azure Subscription as needed 
## IMPORTANT: github CLI need to be installed
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

az group delete --name $RG

SERVICE_PRINCIPAL_APP_ID=$(az ad sp list --display-name $SP --query "[].appId" -o tsv)

az ad sp delete --id $SERVICE_PRINCIPAL_APP_ID

gh secret remove SERVICE_PRINCIPAL_APP_ID
gh secret remove SERVICE_PRINCIPAL_SECRET
gh secret remove SERVICE_PRINCIPAL_TENANT
gh secret remove ACR_NAME
gh secret remove CLUSTER_RESOURCE_GROUP_NAME
gh secret remove CLUSTER_NAME


#az keyvault set-policy \
#    --name $KV \
#    --object-id $SERVICE_PRINCIPAL_OBJ_ID \
#    --secret-permissions backup restore \
#    --key-permissions get list import \
#    --certificate-permissions get list