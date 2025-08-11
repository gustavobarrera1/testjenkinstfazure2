pipeline {
  agent any

  environment {
    TF_VAR_client_id       = credentials('azureclient_id')
    TF_VAR_client_secret   = credentials('azureclient_secret')

    TF_VAR_subscription_id = credentials('azuresubscription_id')
    TF_VAR_tenant_id       = credentials('azuretenant_id')

    ACR_NAME               = 'acrtfgbarrera2'
    IMAGE_NAME             = 'myapp'
    IMAGE_TAG              = 'latest'
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
            az acr login --name $ACR_NAME
            ACR_LOGIN_SERVER=\$(az acr show --name $ACR_NAME --query loginServer -o tsv)
            docker build -t \$ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG .
            docker push \$ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG
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
