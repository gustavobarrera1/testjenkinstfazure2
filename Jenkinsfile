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
            rm -rf ~/.azure
            az account clear

            # Autenticarse con el Service Principal correcto
            az login --service-principal -u $TF_VAR_client_id -p $TF_VAR_client_secret --tenant $TF_VAR_tenant_id
            az account set --subscription $TF_VAR_subscription_id
          '''

          dir('terraform/infra') {
            sh '''
              terraform init
              terraform apply \
                -var="client_id=$TF_VAR_client_id" \
                -var="client_secret=$TF_VAR_client_secret" \
                -var="tenant_id=$TF_VAR_tenant_id" \
                -var="subscription_id=$TF_VAR_subscription_id" \
                -auto-approve
            '''
          }
        }
      }
    }
    
    stage('Build and Push Docker Image') {
      // ... (el resto del pipeline es el mismo)
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
            sh '''
              terraform init
              terraform apply \
                -var="client_id=$TF_VAR_client_id" \
                -var="client_secret=$TF_VAR_client_secret" \
                -var="tenant_id=$TF_VAR_tenant_id" \
                -var="subscription_id=$TF_VAR_subscription_id" \
                -auto-approve
            '''
          }
        }
      }
    }
  }
}