param environmentId string
@secure()
param storageConnectionString string
param location string = resourceGroup().location

resource containerApp 'Microsoft.Web/containerApps@2021-03-01' = {
  name: 'queue-reader-function'
  kind: 'containerapp'
  location: location
  properties: {
    kubeEnvironmentId: environmentId
    configuration: {
      activeRevisionsMode: 'single'
      secrets: [
        {
          name: 'storage-connection'
          value: storageConnectionString
        }
      ]   
    }
    template: {
      containers: [
        {
          image: 'thara0402/queue-reader-function:0.1.0'
          name: 'queue-reader-function'
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
