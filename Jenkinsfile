pipeline {
  agent any

  stages {
    stage('Azure Login & Terraform Infra') {
      steps {
        // Inyectamos las credenciales directamente con el prefijo TF_VAR_
        withCredentials([
          string(credentialsId: 'azureclient_id', variable: 'TF_VAR_client_id'),
          string(credentialsId: 'azureclient_secret', variable: 'TF_VAR_client_secret'),
          string(credentialsId: 'azuretenant_id', variable: 'TF_VAR_tenant_id'),
          string(credentialsId: 'azuresubscription_id', variable: 'TF_VAR_subscription_id')
        ]) {
          // Aunque az login se ejecute, es opcional para Terraform si le pasas las variables
          // de forma explícita. Sin embargo, es buena práctica mantenerlo para otros comandos de az.
          sh 'az login --service-principal -u $TF_VAR_client_id -p $TF_VAR_client_secret --tenant $TF_VAR_tenant_id'
          sh 'az account set --subscription $TF_VAR_subscription_id'
          
          dir('terraform/infra') {
            // Terraform ahora debería tomar las variables de entorno TF_VAR_* automáticamente
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
          withCredentials([string(credentialsId: 'azureclient_id', variable: 'AZURE_CLIENT_ID')]) { // Necesitas el client_id para este paso
              sh '''
                az acr login --name acrtfgbarrera
                ACR_LOGIN_SERVER=$(az acr show --name acrtfgbarrera --query loginServer -o tsv)
                docker build -t $ACR_LOGIN_SERVER/myapp:latest .
                docker push $ACR_LOGIN_SERVER/myapp:latest
              '''
          }
        }
      }
    }

    stage('Deploy Container App') {
      steps {
        // En esta etapa, el dir de Terraform para la app también necesita las variables.
        // Volvemos a usar withCredentials para asegurarnos de que estén disponibles.
        withCredentials([
          string(credentialsId: 'azureclient_id', variable: 'TF_VAR_client_id'),
          string(credentialsId: 'azureclient_secret', variable: 'TF_VAR_client_secret'),
          string(credentialsId: 'azuretenant_id', variable: 'TF_VAR_tenant_id'),
          string(credentialsId: 'azuresubscription_id', variable: 'TF_VAR_subscription_id')
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