pipeline {
    agent any

    tools {
        maven 'Maven 3.9.4'
        sonarQubeScanner 'sonar-scanner'
    }

    environment {
        SONAR_TOKEN = credentials('SONAR_TOKEN')
    }

    parameters {
        string(name: 'BRANCH_NAME', defaultValue: 'thanu.developer')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('SonarQube Scan') {
            steps {
                withSonarQubeEnv('MySonar') {
                    sh 'mvn clean verify sonar:sonar -Dsonar.login=$SONAR_TOKEN'
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

        stage('Build & Package') {
            steps {
                sh 'mvn package'
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }
    }
}
