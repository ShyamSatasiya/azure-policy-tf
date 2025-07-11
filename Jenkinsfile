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
        git url: 'https://github.com/your-org/azure-policy-tf.git', branch: 'master'
      }
    }

    stage('SonarQube Analysis') {
      steps {
        withSonarQubeEnv('SonarQubeServer') {
          // Run the official SonarScanner CLI Docker image
          bat """
            docker run --rm ^
              -v %WORKSPACE%:/usr/src ^
              -e SONAR_LOGIN=%SONAR_TOKEN% ^
              sonarsource/sonar-scanner-cli ^
              -Dsonar.login=$SONAR_LOGIN ^
              -Dsonar.projectKey=azure-policy-tf ^
              -Dsonar.sources=/usr/src \
              -Dsonar.inclusions=*.tf,policies/**/*.json
          """
        }
      }
    }

    stage('Quality Gate') {
      steps {
        waitForQualityGate abortPipeline: true
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
