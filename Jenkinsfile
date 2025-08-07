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
              export ARM_CLIENT_ID=39a8af82-58e1-4533-ac23-0a0022c8e745
              export ARM_CLIENT_SECRET=${TF_VAR_client_secret}
              export ARM_TENANT_ID=68e258f3-5801-48ce-9128-520f28ecc0a4
              export ARM_SUBSCRIPTION_ID=9734eafc-3f58-4aa1-9930-1d6a4a9c500c

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
              export ARM_CLIENT_ID=39a8af82-58e1-4533-ac23-0a0022c8e745
              export ARM_CLIENT_SECRET=${TF_VAR_client_secret}
              export ARM_TENANT_ID=68e258f3-5801-48ce-9128-520f28ecc0a4
              export ARM_SUBSCRIPTION_ID=9734eafc-3f58-4aa1-9930-1d6a4a9c500c

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
