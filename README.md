# azure_githubactions
Deploy azure infrastruture with github actions

Login to Azure:
```
az login
```

Then generate a service-principal to use for the resource creation
```
az ad sp create-for-rbac --name "sp-azure-githubactions" --role Contributor --sdk-auth
or
az ad sp create-for-rbac --name "sp-azure-githubactions" --role Contributor --scopes /subscriptions/subscription-id --sdk-auth
```

Create Initial RG, storage account, and container for the terraform state
```
az group create -g rg-azure-githubactions -l northeurope
az storage account create -n saazuregithubactions -g  rg-azure-githubactions -l northeurope --sku Standard_LRS
az storage container create -n azure-githubactions --account-name saazuregithubactions
```

Then add the code to your respository, and add the secret to github.