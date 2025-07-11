pipeline {
  agent any

  environment {
    SONAR_TOKEN         = credentials('sonar-token')
    ARM_CLIENT_ID       = credentials('azure-client-id')
    ARM_CLIENT_SECRET   = credentials('azure-client-secret')
    ARM_TENANT_ID       = credentials('azure-tenant-id')
    ARM_SUBSCRIPTION_ID = credentials('azure-subscription-id')
  }

  stages {

    stage('SonarQube Analysis') {
      steps {
        withSonarQubeEnv('SonarQubeServer') {
          // Run the official SonarScanner CLI image
          bat """
            docker run --rm ^
              -v %WORKSPACE%:/usr/src ^
              -e SONAR_LOGIN=%SONAR_TOKEN% ^
              sonarsource/sonar-scanner-cli ^
              -Dsonar.login=$SONAR_LOGIN ^
              -Dsonar.projectKey=azure-policy-tf ^
              -Dsonar.sources=/usr/src
          """
        }
      }
    }

    stage('Azure Login') {
      steps {
        bat """
          az login --service-principal ^
            -u %ARM_CLIENT_ID% ^
            -p %ARM_CLIENT_SECRET% ^
            --tenant %ARM_TENANT_ID%
          az account set --subscription %ARM_SUBSCRIPTION_ID%
        """
      }
    }

    stage('Terraform Init & Plan') {
      steps {
        bat 'terraform init -input=false'
        bat 'terraform plan -out=tfplan -input=false'
        archiveArtifacts artifacts: 'tfplan', onlyIfSuccessful: true
      }
    }

    stage('Approve & Apply') {
      steps {
        input message: 'Apply Terraform changes to Azure?'
        bat 'terraform apply -input=false tfplan'
      }
    }
  }

  post {
    always {
      cleanWs()
    }
  }
}
