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
        // you can drop this if you're letting the SCM plugin auto-checkout
        checkout scm
      }
    }

    stage('SonarQube Analysis') {
      steps {
        withSonarQubeEnv('SonarQubeServer') {
          // run the generic SonarScanner CLI in Docker; 
          // pass SONAR_TOKEN into the container and reference it directly
          bat """
            docker run --rm ^
              -v %WORKSPACE%:/usr/src ^
              -e SONAR_TOKEN=%SONAR_TOKEN% ^
              sonarsource/sonar-scanner-cli ^
              -Dsonar.login=%SONAR_TOKEN% ^
              -Dsonar.projectKey=azure-policy-tf ^
              -Dsonar.sources=/usr/src ^
              -Dsonar.inclusions=*.tf,policies/**/*.json
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
