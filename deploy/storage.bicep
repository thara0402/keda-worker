param storageAccountName string
param location string = resourceGroup().location

var strageSku = 'Standard_LRS'

resource stg 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageAccountName
  location: location
  kind: 'Storage'
  sku:{
    name: strageSku
  }
}

output storageId string = stg.id
