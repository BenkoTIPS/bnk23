
###  SETUP
# -  Git init and create apps
# -  Kubectl
# -  ACR registry
# -  AKS cluster
# -  Namespace
# -  Lens 

git init
dotnet new razor -o .\code\imaWeb
dotnet new webapi -o .\code\imaApi

git remote add origin https://github.com/BenkoTIPS/bnk23.git
git branch -M main
git push -u origin main

# create acr from command line with naming poc-ncus-shared-ACR-01 where poc is an env variable
az acr create -n $acrName -g $rgACR --sku Basic --admin-enabled true

# attach acr to aks
$aksRg = "rg-shared-cus"
$aksName = "$envName-shared-cus-aks"
$acrId = $(az acr show --name $acrName --resource-group $aksRG --query id -o tsv)

az aks update --name $aksName --resource-group $aksRg --attach-acr $acrId
# az role assignment create --assignee $acrId --role "AcrPull" --scope $aksId

az acr login -n $acrName


docker build -f ./code/imaWeb/Dockerfile -t imaweb23:v0.1 ./code/ImaWeb --build-arg tag=v0.1
docker tag imaweb23:v0.1 "$acrName.azurecr.io/imaweb23:v0.1"
docker push "$acrName.azurecr.io/imaweb23:v0.1"

docker build -f ./myMeshApi/Dockerfile -t mymeshapi:v0.1 ./mymeshapi --build-arg tag=v0.1
docker tag mymeshapi:latest "$acrName.azurecr.io/mymeshapi:v0.1"
docker push "$acrName.azurecr.io/mymeshapi:v0.1"


az acr repository list -n $acrName -o table
az acr repository show-tags -n $acrName --repository myapp -o table
#####################
