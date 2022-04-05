DIGEST=$(az acr repository show-manifests --detail -n $1 --repository $2 --query "[].digest" -o tsv --orderby time_desc --top 1)
echo $DIGEST
az keyvault certificate download --vault-name $3 -n MyCertificate -f cert.pem
cat cert.pem  