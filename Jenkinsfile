pipeline {
  agent any

  tools {
    // <-- this must match the "Name" in your Global Tool Config
    sonarRunner 'sonar-scanner'
    terraform    'terraform'
  }

  environment {
    SONAR_TOKEN         = credentials('SONAR_TOKEN1')
    ARM_CLIENT_ID       = credentials('azure-client-id')
    ARM_CLIENT_SECRET   = credentials('azure-client-secret')
    ARM_TENANT_ID       = credentials('azure-tenant-id')
    ARM_SUBSCRIPTION_ID = credentials('azure-subscription-id')
  }

  stages {
    stage('SonarQube Analysis') {
      steps {
        withSonarQubeEnv('SonarQubeServer') {
          // now SONAR_RUNNER_HOME is set by the tools block
          bat "%SONAR_RUNNER_HOME%\\bin\\sonar-scanner.bat -Dsonar.login=%SONAR_TOKEN%"
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
