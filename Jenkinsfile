pipeline {
  agent any

  environment {
    // Variables para Terraform (si decides no usar .tfvars)
    TF_VAR_client_id       = 'b24fa600-ff3d-414a-9802-79047c858bce'
    TF_VAR_client_secret   = credentials('azureclient_secret') // Usar el ID de credencial de Jenkins
    TF_VAR_tenant_id       = '8ee9d595-4f94-41e5-a20c-b29b4e64578b'
    TF_VAR_subscription_id = credentials('azuresubscription_id')

    // Para Azure CLI (az login)
    AZURE_CLIENT_ID        = 'b24fa600-ff3d-414a-9802-79047c858bce'
    AZURE_CLIENT_SECRET    = credentials('azureclient_secret')
    AZURE_TENANT_ID        = '8ee9d595-4f94-41e5-a20c-b29b4e64578b'
    
    ACR_NAME               = 'acrtfgbarrera'
    IMAGE_NAME             = 'myapp'
    IMAGE_TAG              = 'latest'
    RESOURCE_GROUP         = 'rg-gbarrera'
  }

  stages {
    stage('Login to Azure & ACR') {
      steps {
        // Enlaza credenciales para que sean accesibles en el shell
        withCredentials([string(credentialsId: 'azureclient_secret', variable: 'AZURE_CLIENT_SECRET')]) {
            sh '''
            az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID
            az acr login --name $ACR_NAME
            '''
        }
      }
    }
    
    stage('Deploy Terraform Infra') {
      steps {
        dir('terraform/infra') {
          // Terraform Init no necesita las variables de cliente para la autenticación si ya estás logueado en az
          sh 'terraform init'
          sh 'terraform apply -auto-approve'
        }
      }
    }

    stage('Build and Push Docker Image') {
      steps {
        dir('docker') {
          sh '''
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
          sh 'terraform init'
          sh 'terraform apply -auto-approve'
        }
      }
    }
  }
}