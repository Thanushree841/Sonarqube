pipeline {
  agent any

  tools {
    maven 'Maven 3.9.4'
  }

  environment {
    SONAR_TOKEN        = credentials('SONAR_TOKEN')
    NEXUS_MAVEN        = credentials('NEXUS_MAVEN')
    NEXUS_DOCKER_REPO  = 'http://13.127.83.102:5000/docker-dev'
    SONAR_HOST         = 'http://3.109.153.26:30900/'
  }

  parameters {
    string(name: 'BRANCH_NAME', defaultValue: 'thanu.developer', description: 'Git branch to build')
  }

  triggers {
    githubPush()
  }

  stages {

    stage('Checkout Code') {
      steps {
        echo "📥 Checking out branch: ${params.BRANCH_NAME}"
        checkout([
          $class: 'GitSCM',
          branches: [[name: "*/${params.BRANCH_NAME}"]],
          userRemoteConfigs: [[url: 'https://github.com/Thanushree841/Sonarqube.git']]
        ])
      }
    }

    stage('Check SonarQube') {
      steps {
        echo '🔍 Verifying SonarQube server availability...'
        sh 'curl -s --fail $SONAR_HOST/ > /dev/null || { echo "❌ SonarQube is not reachable!"; exit 1; }'
      }
    }

    stage('SonarQube Scan') {
      steps {
        echo '🚀 Running SonarQube Scan...'
        withSonarQubeEnv('MySonar') {
          sh '''
            mvn clean verify sonar:sonar \
              -Dsonar.projectKey=myproject \
              -Dsonar.login=$SONAR_TOKEN
          '''
        }
      }
    }

    stage('Quality Gate') {
      steps {
        echo '🚦 Waiting for SonarQube Quality Gate result...'
        timeout(time: 10, unit: 'MINUTES') {
          waitForQualityGate abortPipeline: true
        }
      }
    }

    stage('Build & Package') {
      steps {
        echo '📦 Building project and generating artifact...'
        sh 'mvn clean package'
        archiveArtifacts artifacts: '**/target/*.jar', fingerprint: true
      }
    }

    stage('Deploy Artifact to Nexus') {
      steps {
        echo '📤 Uploading artifact to Nexus Maven repo...'
        withCredentials([
          usernamePassword(credentialsId: 'NEXUS_MAVEN', usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')
        ]) {
          configFileProvider([
            configFile(fileId: 'c20a0ce7-4a99-4c4a-939a-747e59f9141b', targetLocation: 'settings.xml')
          ]) {
            sh '''
              sed -i "s|<username>.*</username>|<username>${NEXUS_USER}</username>|" settings.xml
              sed -i "s|<password>.*</password>|<password>${NEXUS_PASS}</password>|" settings.xml
              mvn deploy -s settings.xml -DskipTests
            '''
          }
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        echo '🐳 Building Docker image...'
        script {
          def image = "${NEXUS_DOCKER_REPO.replace('http://', '')}/sonarqube-app:1.0.0-SNAPSHOT"
          sh "docker build -t ${image} ."
        }
      }
    }

    stage('Push Docker Image to Nexus') {
      steps {
        echo '📦 Pushing Docker image to Nexus...'
        withCredentials([
          usernamePassword(credentialsId: 'nexus-docker-creds', usernameVariable: 'NEXUS_DOCKER_USR', passwordVariable: 'NEXUS_DOCKER_PSW')
        ]) {
          script {
            def image = "${NEXUS_DOCKER_REPO.replace('http://', '')}/sonarqube-app:1.0.0-SNAPSHOT"
            sh """
              echo "$NEXUS_DOCKER_PSW" | docker login 13.127.83.102:5000 -u "$NEXUS_DOCKER_USR" --password-stdin
              docker push ${image}
              docker logout 13.127.83.102:5000
            """
          }
        }
      }
    }
  }

  post {
    success {
      echo '✅ Full CI/CD pipeline successful.'
    }
    failure {
      echo '❌ Pipeline failed.'
    }
  }
}
