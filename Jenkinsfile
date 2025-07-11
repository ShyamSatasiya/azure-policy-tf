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

    stage('SonarQube Begin') {
            steps {
                withSonarQubeEnv('SonarQubeServer') { 
                    bat '''
                        set PATH=%PATH%;C:\\WINDOWS\\system32\\config\\systemprofile\\.dotnet\\tools
                        dotnet sonarscanner begin /k:"demo-sonarproject" /d:sonar.host.url="http://localhost:9000" /d:sonar.token=%SONAR_TOKEN%
                    '''
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

  stage('SonarQube End') {
            steps {
                bat '''
                    set PATH=%PATH%;C:\\WINDOWS\\system32\\config\\systemprofile\\.dotnet\\tools
                    dotnet sonarscanner end /d:sonar.token=%SONAR_TOKEN%
                '''
            }
        }
    
}
