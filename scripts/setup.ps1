git init
dotnet new razor -o .\code\imaWeb
dotnet new webapi -o .\code\imaApi

git remote add origin https://github.com/BenkoTIPS/bnk23.git
git branch -M main
git push -u origin main
