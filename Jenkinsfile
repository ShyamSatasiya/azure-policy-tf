pipeline {
  agent any

  tools {
    // assumes you have configured these tool installations in Jenkins → Global Tool Configuration
    sonarScanner 'SonarQubeScanner'   
    terraform    'terraform'          
  }

  environment {
    // sonar-token1 is your SonarQube auth token credential ID
    SONAR_TOKEN        = credentials('SONAR_TOKEN1') 
    // these three can come from a single SPN credential if you like
    ARM_CLIENT_ID      = credentials('azure-client-id')
    ARM_CLIENT_SECRET  = credentials('azure-client-secret')
    ARM_TENANT_ID      = credentials('azure-tenant-id')
    ARM_SUBSCRIPTION_ID= credentials('azure-subscription-id')
  }

  stages {
    stage('Checkout') {
      steps {
        git url: 'https://github.com/ShyamSatasiya/CI-CD-azure-DevOps-with-different-environments.git', branch: 'master'
      }
    }

    stage('SonarQube Analysis') {
      steps {
        withSonarQubeEnv('SonarQubeServer') {
          // sonar-scanner is now on PATH via the `tools` block
          bat 'sonar-scanner -Dsonar.login=%SONAR_TOKEN%'
        }
      }
    }

    stage('Azure CLI Login') {
      steps {
        // log in so Terraform can query/validate providers
        bat """
          az login --service-principal \\
            -u %ARM_CLIENT_ID% \\
            -p %ARM_CLIENT_SECRET% \\
            --tenant %ARM_TENANT_ID%
        """
      }
    }

    stage('Terraform Init & Plan') {
      steps {
        bat 'terraform init'
        bat 'terraform plan -out=tfplan'
      }
    }

    stage('Terraform Apply') {
      steps {
        input message: 'Approve Policy Deployment?'
        bat 'terraform apply tfplan'
      }
    }
  }

  post {
    always {
      cleanWs()
    }
  }
}
