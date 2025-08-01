pipeline {
    agent any

    environment {
        IMAGE_NAME = 'sheikhitech/docker-jenkins-image'
        DOCKER_CREDENTIALS_ID = 'dockerhub-creds'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/hapheej-shekh/spring-cicd-docker-jenkins.git'
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
                # Find and stop any container using port 8082
                CONTAINER_ID=$(docker ps --format '{{.ID}} {{.Ports}}' | grep '0.0.0.0:8082->' | awk '{print $1}')
                if [ ! -z "$CONTAINER_ID" ]; then
                    echo "Stopping container using port 8082: $CONTAINER_ID"
                    docker stop $CONTAINER_ID
                    docker rm $CONTAINER_ID
                fi

                # Remove existing container by name if still there
                docker rm -f docker-jenkins-image || true

                # Run the new container
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
