pipeline {
  agent any

  environment {
    // Variables no secretas. Las credenciales se inyectan en los 'steps'.
    ACR_NAME               = 'acrtfgbarrera'
    IMAGE_NAME             = 'myapp'
    IMAGE_TAG              = 'latest'
    RESOURCE_GROUP         = 'rg-gbarrera'
  }

  stages {
    stage('Azure Login & Terraform Infra') {
      steps {
        // Se exponen todas las credenciales de Azure en este bloque.
        withCredentials([
          string(credentialsId: 'azureclient_id', variable: 'AZURE_CLIENT_ID'),
          string(credentialsId: 'azureclient_secret', variable: 'AZURE_CLIENT_SECRET'),
          string(credentialsId: 'azuretenant_id', variable: 'AZURE_TENANT_ID'),
          string(credentialsId: 'azuresubscription_id', variable: 'AZURE_SUBSCRIPTION_ID')
        ]) {
          // El login a Azure CLI se hace con las variables inyectadas.
          sh '''
            az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID
            az account set --subscription $AZURE_SUBSCRIPTION_ID
          '''

          // Se inicializa y aplica la infraestructura de Terraform.
          // Terraform detecta la autenticación de Azure CLI y las variables de entorno de Azure.
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
          // El login a ACR se hace con la sesión de az ya iniciada.
          sh '''
            az acr login --name $ACR_NAME
            ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer -o tsv)
            docker build -t $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG .
            docker push $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG
          '''
        }
      }
    }

    stage('Deploy Container App') {
      steps {
        dir('terraform/app') {
          // Terraform para la app usará la sesión de az activa.
          sh 'terraform init'
          sh 'terraform apply -auto-approve'
        }
      }
    }
  }
}