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
          // Depuración rápida de si se cargaron las credenciales
          echo "Credenciales cargadas:"
          echo "TF_VAR_client_id: ${env.TF_VAR_client_id ? 'OK' : 'MISSING'}"
          echo "TF_VAR_client_secret: ${env.TF_VAR_client_secret ? 'OK' : 'MISSING'}"
          echo "TF_VAR_tenant_id: ${env.TF_VAR_tenant_id ? 'OK' : 'MISSING'}"
          echo "TF_VAR_subscription_id: ${env.TF_VAR_subscription_id ? 'OK' : 'MISSING'}"

          sh """
            az account clear

            echo "Autenticando con Azure CLI..."
            az login --service-principal -u ${env.TF_VAR_client_id} -p ${env.TF_VAR_client_secret} --tenant ${env.TF_VAR_tenant_id}
            az account set --subscription ${env.TF_VAR_subscription_id}
          """

          sh """
            echo "Debugging Terraform variables..."
            echo "TF_VAR_client_id: ${env.TF_VAR_client_id}"
            echo "TF_VAR_tenant_id: ${env.TF_VAR_tenant_id}"
            echo "TF_VAR_subscription_id: ${env.TF_VAR_subscription_id}"
            echo "TF_VAR_client_secret: ${env.TF_VAR_client_secret}"
          """

          dir('terraform/infra') {
            sh 'terraform init'
            sh """
              terraform apply \
                -var="client_id=${env.TF_VAR_client_id}" \
                -var="client_secret=${env.TF_VAR_client_secret}" \
                -var="tenant_id=${env.TF_VAR_tenant_id}" \
                -var="subscription_id=${env.TF_VAR_subscription_id}" \
                -auto-approve
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
            echo "ACR login server: \$ACR_LOGIN_SERVER"
            docker build -t \$ACR_LOGIN_SERVER/myapp:latest .
            docker push \$ACR_LOGIN_SERVER/myapp:latest
          """
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
          echo "Credenciales cargadas:"
          echo "TF_VAR_client_id: ${env.TF_VAR_client_id ? 'OK' : 'MISSING'}"
          echo "TF_VAR_client_secret: ${env.TF_VAR_client_secret ? 'OK' : 'MISSING'}"
          echo "TF_VAR_tenant_id: ${env.TF_VAR_tenant_id ? 'OK' : 'MISSING'}"
          echo "TF_VAR_subscription_id: ${env.TF_VAR_subscription_id ? 'OK' : 'MISSING'}"

          dir('terraform/app') {
            sh """
              echo "Debugging Terraform variables..."
              echo "TF_VAR_client_id: ${env.TF_VAR_client_id}"
              echo "TF_VAR_tenant_id: ${env.TF_VAR_tenant_id}"
              echo "TF_VAR_subscription_id: ${env.TF_VAR_subscription_id}"
              echo "TF_VAR_client_secret: ${env.TF_VAR_client_secret}"
            """

            sh 'terraform init'
            sh """
              terraform apply \
                -var="client_id=${env.TF_VAR_client_id}" \
                -var="client_secret=${env.TF_VAR_client_secret}" \
                -var="tenant_id=${env.TF_VAR_tenant_id}" \
                -var="subscription_id=${env.TF_VAR_subscription_id}" \
                -auto-approve
            """
          }
        }
      }
    }
  }
}
