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
          sh """
            az account clear
            az login --service-principal -u ${env.TF_VAR_client_id} -p ${env.TF_VAR_client_secret} --tenant ${env.TF_VAR_tenant_id}
            az account set --subscription ${env.TF_VAR_subscription_id}
          """

          dir('terraform/infra') {
            sh """
              cat > credentials.auto.tfvars <<EOF
              client_id       = "${env.TF_VAR_client_id}"
              client_secret   = "${env.TF_VAR_client_secret}"
              tenant_id       = "${env.TF_VAR_tenant_id}"
              subscription_id = "${env.TF_VAR_subscription_id}"
EOF
            """

            sh 'terraform init'
            sh 'terraform apply -auto-approve'
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

    stage('Deploy Container App') {
      steps {
        withCredentials([
          string(credentialsId: 'azureclient_id', variable: 'TF_VAR_client_id'),
          string(credentialsId: 'azureclient_secret', variable: 'TF_VAR_client_secret'),
          string(credentialsId: 'azuretenant_id', variable: 'TF_VAR_tenant_id'),
          string(credentialsId: 'azuresubscription_id', variable: 'TF_VAR_subscription_id')
        ]) {
          
          dir('terraform/app') {
            sh """
              cat > credentials.auto.tfvars <<EOF
              client_id       = "${env.TF_VAR_client_id}"
              client_secret   = "${env.TF_VAR_client_secret}"
              tenant_id       = "${env.TF_VAR_tenant_id}"
              subscription_id = "${env.TF_VAR_subscription_id}"
EOF
            """

            sh 'terraform init'
            sh 'terraform apply -auto-approve'
          }
        }
      }
    }
  }
}
