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
   

    stage('Install SonarScanner') {
      steps {
        // Installs the dotnet-sonarscanner tool if it isn't already
        bat 'dotnet tool install --global dotnet-sonarscanner || exit 0'
      }
    }

    stage('SonarQube Begin') {
      steps {
        withSonarQubeEnv('SonarQubeServer') {
          bat '''
            REM Add the global tool path to PATH
            set PATH=%PATH%;C:\\WINDOWS\\system32\\config\\systemprofile\\.dotnet\\tools

            REM Kick off Sonar analysis
            dotnet sonarscanner begin ^
              /k:"azure-policy-tf" ^
              /d:sonar.login=%SONAR_TOKEN% ^
              /d:sonar.sources="." ^
              /d:sonar.inclusions="*.tf,policies/**/*.json"
          '''
        }
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

    stage('SonarQube End') {
      steps {
        bat '''
          set PATH=%PATH%;C:\\WINDOWS\\system32\\config\\systemprofile\\.dotnet\\tools
          dotnet sonarscanner end /d:sonar.login=%SONAR_TOKEN%
        '''
      }
    }
  }

  post {
    always {
      cleanWs()
    }
  }
}
