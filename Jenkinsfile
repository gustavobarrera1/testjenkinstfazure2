pipeline {
  agent any

  environment {
    // Variables para Terraform (si decides no usar .tfvars)
    TF_VAR_client_secret   = credentials('azureclient_secret')

    // Para Azure CLI (az login)
    // AZURE_CLIENT_SECRET    = credentials('azureclient_secret')
  }

  stages {
    stage('Terraform Infra Deployment') {
      steps {
        dir('terraform/infra') {
          sh """
            export ARM_CLIENT_ID=39a8af82-58e1-4533-ac23-0a0022c8e745
            export ARM_CLIENT_SECRET=${TF_VAR_client_secret}
            export ARM_TENANT_ID=68e258f3-5801-48ce-9128-520f28ecc0a4
            export ARM_SUBSCRIPTION_ID=9734eafc-3f58-4aa1-9930-1d6a4a9c500c

            echo Using subscription: \$ARM_SUBSCRIPTION_ID

            terraform init
            terraform apply \
              -var="client_id=39a8af82-58e1-4533-ac23-0a0022c8e745" \
              -var="client_secret=${TF_VAR_client_secret}" \
              -var="tenant_id=68e258f3-5801-48ce-9128-520f28ecc0a4" \
              -var="subscription_id=9734eafc-3f58-4aa1-9930-1d6a4a9c500c" \
              -auto-approve
          """
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
        dir('terraform/app') {
          sh """
            export ARM_CLIENT_ID=39a8af82-58e1-4533-ac23-0a0022c8e745
            export ARM_CLIENT_SECRET=${TF_VAR_client_secret}
            export ARM_TENANT_ID=68e258f3-5801-48ce-9128-520f28ecc0a4
            export ARM_SUBSCRIPTION_ID=9734eafc-3f58-4aa1-9930-1d6a4a9c500c

            echo Using subscription: \$ARM_SUBSCRIPTION_ID

            terraform init
            terraform apply \
              -var="client_id=39a8af82-58e1-4533-ac23-0a0022c8e745" \
              -var="client_secret=${TF_VAR_client_secret}" \
              -var="tenant_id=68e258f3-5801-48ce-9128-520f28ecc0a4" \
              -var="subscription_id=9734eafc-3f58-4aa1-9930-1d6a4a9c500c" \
              -auto-approve
          """
        }
      }
    }
  }
}
