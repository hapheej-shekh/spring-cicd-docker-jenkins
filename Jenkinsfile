pipeline {
    agent any

    environment {
        IMAGE_NAME = 'sheikhitech/docker-jenkins-image'
        DOCKER_CREDENTIALS_ID = 'dockerhub-creds'
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/hapheej-shekh/docker-jenkins-image.git'
            }
        }

        stage('Build JAR') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("${IMAGE_NAME}:${BUILD_NUMBER}")
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', "${DOCKER_CREDENTIALS_ID}") {
                        dockerImage.push()
                        dockerImage.push("latest")
                    }
                }
            }
        }

        stage('Deploy Locally') {
            steps {
                sh '''
                docker stop docker-jenkins-image || true
                docker rm docker-jenkins-image || true
                docker run -d -p 8082:8082 --name docker-jenkins-image ${IMAGE_NAME}:${BUILD_NUMBER}
                '''
            }
        }
    }

    post {
        success {
            echo '🚀 Deployment Success!'
        }
        failure {
            echo '❌ Build failed!'
        }
    }
}
