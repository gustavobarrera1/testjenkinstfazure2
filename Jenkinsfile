pipeline {
  agent any

  stages {
    stage('Terraform Infra Deployment') {
      steps {
        withCredentials([
          string(credentialsId: 'azureclient_id', variable: 'TF_VAR_client_id'),
          string(credentialsId: 'azureclient_secret', variable: 'TF_VAR_client_secret'),
          string(credentialsId: 'azuretenant_id', variable: 'TF_VAR_tenant_id'),
          string(credentialsId: 'azuresubscription_id', variable: 'TF_VAR_subscription_id')
        ]) {
          dir('terraform/infra') {
            sh """
              export ARM_CLIENT_ID=${TF_VAR_client_id}
              export ARM_CLIENT_SECRET=${TF_VAR_client_secret}
              export ARM_TENANT_ID=${TF_VAR_tenant_id}
              export ARM_SUBSCRIPTION_ID=${TF_VAR_subscription_id}

              echo Using subscription: \$ARM_SUBSCRIPTION_ID

              terraform init
              terraform apply -auto-approve
            """
          }
        }
      }
    }

    stage('Build and Push Docker Image') {
      steps {
        dir('docker') {
          sh """
            az acr login --name acrtfgbarrera
            ACR_LOGIN_SERVER=\$(az acr show --name acrtfgbarrera --query loginServer -o tsv)
            docker build -t \$ACR_LOGIN_SERVER/myapp:latest .
            docker push \$ACR_LOGIN_SERVER/myapp:latest
          """
        }
      }
    }

    stage('Terraform App Deployment') {
      steps {
        withCredentials([
          string(credentialsId: 'azureclient_id', variable: 'TF_VAR_client_id'),
          string(credentialsId: 'azureclient_secret', variable: 'TF_VAR_client_secret'),
          string(credentialsId: 'azuretenant_id', variable: 'TF_VAR_tenant_id'),
          string(credentialsId: 'azuresubscription_id', variable: 'TF_VAR_subscription_id')
        ]) {
          dir('terraform/app') {
            sh """
              export ARM_CLIENT_ID=${TF_VAR_client_id}
              export ARM_CLIENT_SECRET=${TF_VAR_client_secret}
              export ARM_TENANT_ID=${TF_VAR_tenant_id}
              export ARM_SUBSCRIPTION_ID=${TF_VAR_subscription_id}

              echo Using subscription: \$ARM_SUBSCRIPTION_ID

              terraform init
              terraform apply -auto-approve
            """
          }
        }
      }
    }
  }
}
