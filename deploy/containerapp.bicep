param containerAppName string
param location string = resourceGroup().location
param environmentId string
param containerImage string
param revisionSuffix string
@allowed([
  'multiple'
  'single'
])
param revisionMode string = 'single'
@secure()
param storageConnectionString string

resource containerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: containerAppName
  location: location
  properties: {
    managedEnvironmentId: environmentId
    configuration: {
      activeRevisionsMode: revisionMode
      dapr:{
        enabled:false
      }
      secrets: [
        {
          name: 'storage-connection'
          value: storageConnectionString
        }
      ]   
    }
    template: {
      revisionSuffix: revisionSuffix
      containers: [
        {
          image: containerImage
          name: containerAppName
          resources: {
            cpu: '0.25'
            memory: '0.5Gi'
          }
          env: [
            {
              name: 'AzureWebJobsStorage'
              secretref: 'storage-connection'
            }
            {
              name: 'FUNCTIONS_WORKER_RUNTIME'
              value: 'dotnet'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 10
        rules: [
          {
            name: 'queue-scaling-rule'
            azureQueue: {
              queueName: 'myqueue-items'
              queueLength: 3
              auth: [
                {
                  secretRef: 'storage-connection'
                  triggerParameter: 'connection'
                }
              ]
            }
          }
        ]
      }
    }
  }
}
