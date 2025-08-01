pipeline {
  agent any

  stages {
    stage('Azure Login & Terraform Infra') {
      steps {
        withCredentials([
          string(credentialsId: 'azureclient_id', variable: 'AZURE_CLIENT_ID'),
          string(credentialsId: 'azureclient_secret', variable: 'AZURE_CLIENT_SECRET'),
          string(credentialsId: 'azuretenant_id', variable: 'AZURE_TENANT_ID'),
          string(credentialsId: 'azuresubscription_id', variable: 'AZURE_SUBSCRIPTION_ID')
        ]) {
          sh '''
            # Limpiar la caché de autenticación de la CLI de Azure
            az account clear

            # Autenticarse con el Service Principal correcto
            az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID
            az account set --subscription $AZURE_SUBSCRIPTION_ID
          '''

          dir('terraform/infra') {
            sh 'terraform init'
            sh 'terraform apply -auto-approve'
          }
        }
      }
    }
    
    stage('Build and Push Docker Image') {
      steps {
        dir('docker') {
          // El az acr login usará la sesión de az ya iniciada.
          sh '''
            az acr login --name acrtfgbarrera
            ACR_LOGIN_SERVER=$(az acr show --name acrtfgbarrera --query loginServer -o tsv)
            docker build -t $ACR_LOGIN_SERVER/myapp:latest .
            docker push $ACR_LOGIN_SERVER/myapp:latest
          '''
        }
      }
    }

    stage('Deploy Container App') {
      steps {
        withCredentials([
          string(credentialsId: 'azureclient_id', variable: 'AZURE_CLIENT_ID'),
          string(credentialsId: 'azureclient_secret', variable: 'AZURE_CLIENT_SECRET'),
          string(credentialsId: 'azuretenant_id', variable: 'AZURE_TENANT_ID'),
          string(credentialsId: 'azuresubscription_id', variable: 'AZURE_SUBSCRIPTION_ID')
        ]) {
          dir('terraform/app') {
            sh 'terraform init'
            sh 'terraform apply -auto-approve'
          }
        }
      }
    }
  }
}