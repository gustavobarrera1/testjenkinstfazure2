pipeline {
  agent any

  stages {
    stage('Azure Login & Terraform Infra') {
      steps {
        withCredentials([
          string(credentialsId: 'azureclient_id', variable: 'TF_VAR_client_id'),
          string(credentialsId: 'azureclient_secret', variable: 'TF_VAR_client_secret'),
          string(credentialsId: 'azuretenant_id', variable: 'TF_VAR_tenant_id'),
          string(credentialsId: 'azuresubscription_id', variable: 'TF_VAR_subscription_id')
        ]) {
          sh '''
            # Limpiar la caché de autenticación de la CLI de Azure
            az account clear

            # Autenticarse con el Service Principal correcto.
            # La CLI de Azure puede usar los nombres de variables de Terraform.
            az login --service-principal -u $TF_VAR_client_id -p $TF_VAR_client_secret --tenant $TF_VAR_tenant_id
            az account set --subscription $TF_VAR_subscription_id
          '''

          // --- Inicio del bloque de depuración ---
          sh '''
            echo "Debugging Terraform variables..."
            echo "TF_VAR_client_id: $TF_VAR_client_id"
            echo "TF_VAR_tenant_id: $TF_VAR_tenant_id"
            echo "TF_VAR_subscription_id: $TF_VAR_subscription_id"
            echo "TF_VAR_client_secret: $TF_VAR_client_secret"
          '''
          // --- Fin del bloque de depuración ---

          dir('terraform/infra') {
            // Terraform ahora tomará las variables TF_VAR_* automáticamente.
            sh 'terraform init'
            sh 'terraform apply \
                -var="client_id=$TF_VAR_client_id" \
                -var="client_secret=$TF_VAR_client_secret" \
                -var="tenant_id=$TF_VAR_tenant_id" \
                -var="subscription_id=$TF_VAR_subscription_id" \
                -auto-approve'
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
          string(credentialsId: 'azureclient_id', variable: 'TF_VAR_client_id'),
          string(credentialsId: 'azureclient_secret', variable: 'TF_VAR_client_secret'),
          string(credentialsId: 'azuretenant_id', variable: 'TF_VAR_tenant_id'),
          string(credentialsId: 'azuresubscription_id', variable: 'TF_VAR_subscription_id')
        ]) {
          dir('terraform/app') {
            
          // --- Inicio del bloque de depuración ---
          sh '''
            echo "Debugging Terraform variables..."
            echo "TF_VAR_client_id: $TF_VAR_client_id"
            echo "TF_VAR_tenant_id: $TF_VAR_tenant_id"
            echo "TF_VAR_subscription_id: $TF_VAR_subscription_id"
            echo "TF_VAR_client_secret: $TF_VAR_client_secret"
          '''
          // --- Fin del bloque de depuración ---

            // Terraform tomará las variables TF_VAR_* automáticamente.
            sh 'terraform init'
            sh 'terraform apply \
                -var="client_id=$TF_VAR_client_id" \
                -var="client_secret=$TF_VAR_client_secret" \
                -var="tenant_id=$TF_VAR_tenant_id" \
                -var="subscription_id=$TF_VAR_subscription_id" \
                -auto-approve'
          }
        }
      }
    }
  }
}