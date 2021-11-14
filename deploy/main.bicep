param environmentName string = 'env-${resourceGroup().name}'
param storageAccountName string = resourceGroup().name

module environment 'environment.bicep' = {
  name: 'container-app-environment'
  params: {
    environmentName: environmentName
  }
}

module storage 'storage.bicep' = {
  name: 'storage'
  params: {
    storageAccountName: storageAccountName
  }
}
