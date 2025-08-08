pipeline {
  agent any

  environment {
    // Variables para Terraform (si decides no usar .tfvars)
    TF_VAR_client_id       = credentials('azureclient_id')
    TF_VAR_client_secret   = credentials('azureclient_secret')

    TF_VAR_subscription_id = credentials('azuresubscription_id')
    TF_VAR_tenant_id       = credentials('azuretenant_id')
    // Para Azure CLI (az login)
    // AZURE_CLIENT_SECRET    = credentials('azureclient_secret')
  }

  stages {
    stage('Terraform Infra Deployment') {
      steps {
        dir('terraform/infra') {
          sh """
            export ARM_CLIENT_ID=${TF_VAR_client_id}
            export ARM_CLIENT_SECRET=${TF_VAR_client_secret}
            export ARM_TENANT_ID=${TF_VAR_tenant_id}
            export ARM_SUBSCRIPTION_ID=${TF_VAR_subscription_id}

            echo Using subscription: \$ARM_SUBSCRIPTION_ID

            terraform init
            terraform apply \
              -var="client_id=${TF_VAR_client_id}" \
              -var="client_secret=${TF_VAR_client_secret}" \
              -var="tenant_id=${TF_VAR_tenant_id}" \
              -var="subscription_id=${TF_VAR_subscription_id}" \
              -auto-approve
          """
        }
      }
    }

    stage('Build and Push Docker Image') {
      steps {
        dir('docker') {
          sh """
            az acr login --name acrtfgbarrera2
            ACR_LOGIN_SERVER=\$(az acr show --name acrtfgbarrera2 --query loginServer -o tsv)
            docker build -t \$ACR_LOGIN_SERVER/myapp:latest .
            docker push \$ACR_LOGIN_SERVER/myapp:latest
          """
        }
      }
    }

    stage('Terraform App Deployment') {
      steps {
        dir('terraform/app') {
          sh """
            export ARM_CLIENT_ID=${TF_VAR_client_id}
            export ARM_CLIENT_SECRET=${TF_VAR_client_secret}
            export ARM_TENANT_ID=${TF_VAR_tenant_id}
            export ARM_SUBSCRIPTION_ID=${TF_VAR_subscription_id}

            echo Using subscription: \$ARM_SUBSCRIPTION_ID

            terraform init
            terraform apply \
              -var="client_id=${TF_VAR_client_id}" \
              -var="client_secret=${TF_VAR_client_secret}" \
              -var="tenant_id=${TF_VAR_tenant_id}" \
              -var="subscription_id=${TF_VAR_subscription_id}" \
              -auto-approve
          """
        }
      }
    }
  }
}
