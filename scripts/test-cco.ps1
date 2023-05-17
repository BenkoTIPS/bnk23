#####################
# Init env
$envName = "bnk"
$rgACR = "rg-shared"
$acrName = "$envName"+"23cusacr"

###  DEMO STEPS
# 0. Create demo WebApp and API and connect them
# 1. Tye Run
# 2. Dockerfile & run each
# 3. Docker Compose UP
# 4. Push to ACR
# 5. Deploy to K8S from single manifest into demo namespace
# 6. Deploy to K8S from Folder
# 7. Github Actions to deploy from CI/CD
# 8. Helm Deploy
# 9. Helm deploy from CI/CD
###
###  SETUP
# -  Kubectl
# -  ACR registry
# -  AKS cluster
# -  Namespace
# -  Lens 


# create acr from command line with naming poc-ncus-shared-ACR-01 where poc is an env variable
az acr create -n $acrName -g $rgACR --sku Basic --admin-enabled true

# attach acr to aks
$aksRg = "rg-shared-cus"
$aksName = "$envName-shared-cus-aks"
$acrId = $(az acr show --name $acrName --resource-group $aksRG --query id -o tsv)

az aks update --name $aksName --resource-group $aksRg --attach-acr $acrId
# az role assignment create --assignee $acrId --role "AcrPull" --scope $aksId

az acr login -n $acrName


docker build -f ./code/imaWeb/Dockerfile -t mykuma:v0.1 ./code/ImaWeb --build-arg tag=v0.1
docker tag mykuma:v0.1 "$acrName.azurecr.io/mykuma:v0.1"
docker push "$acrName.azurecr.io/mykuma:v0.1"

docker build -f ./myMeshApi/Dockerfile -t mymeshapi:v0.1 ./mymeshapi --build-arg tag=v0.1
docker tag mymeshapi:latest "$acrName.azurecr.io/mymeshapi:v0.1"
docker push "$acrName.azurecr.io/mymeshapi:v0.1"


az acr repository list -n $acrName -o table
az acr repository show-tags -n $acrName --repository myapp -o table
#####################
