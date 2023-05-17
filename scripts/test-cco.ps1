#####################
# Init env
$appName = "ima"
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


# Project Tye
dotnet tool update -g Microsoft.Tye --version "0.11.0-alpha.22111.1"

tye run
tye build
tye push -i
tye deploy -i

# Basic Dockerfile
cd .\myApp
dotnet build --configuration release
dotnet publish -c release -o dist
cd .\dist
dotnet myApp.dll
# add docker file to ./myApp folder

cd .\myApp\ # so we're in .\myApp
docker build -t imaweb.simple -f .\Dockerfile.simple .
docker image list
docker images --format "{{.Repository}}:{{.Tag}}"
docker run -p 80:80 -d imaweb.simple:latest
docker container list
docker container stop ed9
docker container rm 3d9

# Dockerbuild
cd myApp
docker build -f ./code/imaWeb/Dockerfile -t imaweb:v23 ./code/ImaWeb --build-arg tag=v0.1
docker run --name imaweb -p 3000:80 imaweb:v23

# add docker-compose to ./ folder
docker-compose build
docker-compose up -d
docker-compose down 


# Login to registry, tag and push
# using ghcr.io
docker login ghcr.io -u mbenko

docker image list

docker tag myapp ghcr.io/mbenko/myapp
docker tag myapi ghcr.io/mbenko/myapi
docker push ghcr.io/mbenko/myapp
docker push ghcr.io/mbenko/myapi

# using vsl22.azurecr.io

$acrName = "vsl22acr.azurecr.io"
az acr login -n vsl22acr

$rg = "vsl22-demos-rg"

# Docker build locally
docker build -f ./bnkApp/Dockerfile -t bnkapp:cli-v4 . --build-arg tag=v4
docker run -p 8080:80 -d bnkapp:cli-v4

# Docker build on ACR & push image
az acr build --image vsl22acr.azurecr.io/bnkapp:v4-test --registry vsl22acr -f ./bnkApp/Dockerfile . --build-arg tag=v4

# Deploy code to a linux container web app
$appHost = "vsl22-host"
az appservice plan create --name $appHost --resource-group $rg --sku B1 --is-linux
az webapp create --resource-group $rg --plan $appHost --name vsl22-app `
    --deployment-container-image-name vsl22acr.azurecr.io/bnkapp:v4-test
https://vsl22-app4.azurewebsites.net 



# Azure Container Apps
$rg = "vsl22-demos-rg"
$env = "vsl22-aca-env"
az containerapp up -n aca-myapp -g $rg --environment $env --source ./imaweb

az containerapp list -o table
az containerapp update -n vsl22-aca-myapp -g vsl22-demos-rg --set-env-vars "EnvName=ACA-myApp"


# Kubernetes
az aks get-credentials -n vsl22-aks -g vsl22-demos-rg
kubectl cluster-info

# Attach ACR to cluster
az aks update -n vsl22-aks -g vsl22-demos-rg --attach-acr vsl22acr

# Run some pods
kubectl run myapp-pod --image ghcr.io/mbenko/myapp:latest --env="EnvName=K8S"

kubectl exec -ti myapp-pod -- bash
kubectl port-forward myapp-pod 8080:80
kubectl get all
kubectl logs myapp-pod
kubectl delete pod myapp-pod

kubectl get all -A

# Deploy the VSL app
kubectl create namespace vsl-poc

kubectl apply -n vsl-poc -f k8s-vsl22.yml # deploy folder




