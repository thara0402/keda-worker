# KEDA background processing with Azure Container Apps

## Build and Push Docker Images
```shell-session
$ docker build -t thara0402/queue-reader-function:0.1.0 ./
$ docker push thara0402/queue-reader-function:0.1.0
```

## Create Azure Container Apps and Azure Storage
```shell-session
$ az group create -n <ResourceGroup Name> -l canadacentral
$ az deployment group create -f ./deploy/main.bicep -g <ResourceGroup Name>
```

## Create Queue with Azure Storage
```shell-session
$ az storage queue create --name "myqueue-items" --account-name <Storage Name> --connection-string <Connection String>
```

## Send Message to the Queue
You need convert the content to base64.
```shell-session
$ az storage message put --content "Hello Gooner" -q "myqueue-items" --connection-string <Connection String>
```

## Show Replica Count
```shell-session
$ az containerapp revision show --app queue-reader-function -n <Revision Name> -g <ResourceGroup Name> -o table
```

## Query to Azure Log Analytics
```sql
ContainerAppConsoleLogs_CL |
project TimeGenerated, ContainerAppName_s, Log_s |
where ContainerAppName_s == "queue-reader-function" |
order by TimeGenerated desc
```

## Issue
As of 11/16/2021, it is not possible to configure KEDA's Scaling rules using the Azure CLI.  
"scale.rules" property is null.

### Create Azure Container Apps
```shell-session
$ az containerapp create -n queue-reader-function -g <ResourceGroup Name> \
    -e <Environment Name> -i thara0402/queue-reader-function:0.1.0 \
    --ingress internal --target-port 80 --revisions-mode single \
    --scale-rules ./deploy/queuescaler.json --max-replicas 10 --min-replicas 0 \
    -s storage-connection="<Storage Connection>" \
    -v FUNCTIONS_WORKER_RUNTIME=dotnet,AzureWebJobsStorage=secretref:storage-connection
```
