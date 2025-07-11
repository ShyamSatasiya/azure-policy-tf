pipeline {
  agent any

  environment {
    SONAR_TOKEN         = credentials('SONAR_TOKEN1')
    ARM_CLIENT_ID       = credentials('azure-client-id')
    ARM_CLIENT_SECRET   = credentials('azure-client-secret')
    ARM_TENANT_ID       = credentials('azure-tenant-id')
    ARM_SUBSCRIPTION_ID = credentials('azure-subscription-id')
  }

  stages {
    stage('Checkout') {
      steps {
        git url: 'https://github.com/ShyamSatasiya/azure-policy-tf.git', branch: 'master'
      }
    }

    stage('SonarQube Analysis') {
      steps {
        withSonarQubeEnv('SonarQubeServer') {
          // SONAR_SCANNER_HOME is provided by the plugin
          bat "%SONAR_SCANNER_HOME%\\bin\\sonar-scanner.bat -Dsonar.login=%SONAR_TOKEN%"
        }
      }
    }

    stage('Azure CLI Login') {
      steps {
        bat """
          az login --service-principal ^
            -u %ARM_CLIENT_ID% ^
            -p %ARM_CLIENT_SECRET% ^
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
