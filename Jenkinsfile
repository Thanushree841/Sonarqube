pipeline {
  agent any

  tools {
    maven 'Maven 3.9.4'
    sonarQubeScanner 'sonar-scanner'
  }

  environment {
    SONAR_TOKEN = credentials('SONAR_TOKEN') // Replace with your SonarQube token ID
  }

  parameters {
    string(name: 'BRANCH_NAME', defaultValue: 'main', description: 'Git branch to build')
  }

  stages {

    stage('Checkout SCM') {
      steps {
        git branch: "${params.BRANCH_NAME}", url: 'https://github.com/YourName/your-repo.git'
      }
    }

    stage('SonarQube Analysis') {
      steps {
        withSonarQubeEnv('MySonar') {
          sh 'mvn clean verify sonar:sonar'
        }
      }
    }

    stage('Quality Gate') {
      steps {
        timeout(time: 2, unit: 'MINUTES') {
          waitForQualityGate abortPipeline: true
        }
      }
    }

    stage('Build Artifacts') {
      steps {
        sh 'mvn package'
        archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
      }
    }
  }
}
