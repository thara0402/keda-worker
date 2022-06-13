# KEDA background processing with Azure Container Apps

## Build and Push Docker Images
```shell-session
$ docker build -t thara0402/queue-reader-function:0.1.0 ./
$ docker push thara0402/queue-reader-function:0.1.0
```

## Create Azure Container Apps and Azure Storage
```shell-session
$ az group create -n <ResourceGroup Name> -l japaneast
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
$ az containerapp revision show --revision <Revision Name> -n queue-reader-function -g <ResourceGroup Name> -o table
```

## Query to Azure Log Analytics
```sql
ContainerAppConsoleLogs_CL |
project TimeGenerated, ContainerAppName_s, Log_s |
where ContainerAppName_s == "queue-reader-function" |
order by TimeGenerated desc
```
