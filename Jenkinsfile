pipeline {
    agent any

    environment {
	
		// username/docker-hub-repo-name
        IMAGE_NAME = 'sheikhitech/spring-cicd-docker-jenkins'
		
		// dockerhub-creds defined in jenkins pipeline
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
                        dockerImage.push("latest") //Pushes same image with :latest tag name
                    }
                }
            }
        }

        stage('Deploy Locally') {
            steps {
                sh '''
				
				# docker-jenkins is container name supplied from run command
				
                docker stop docker-jenkins || true
                docker rm docker-jenkins || true
				
                # Run the new container
                docker run -d -p 8082:8082 --name docker-jenkins ${IMAGE_NAME}:${BUILD_NUMBER}
                '''
            }
        }
		
		stage('Cleanup Old Docker Tags') {
			steps {
				withCredentials([string(credentialsId: 'dockerhub-pat', variable: 'DOCKERHUB_DEL')]) {
					sh '''
					USERNAME=sheikhitech
					REPO=spring-cicd-docker-jenkins

					# Get tags from Docker Hub
					tags=$(curl -s -u "$USERNAME:$DOCKERHUB_DEL" "https://hub.docker.com/v2/repositories/$USERNAME/$REPO/tags?page_size=100" | jq -r '.results | sort_by(.last_updated) | reverse | .[].name')

					count=0
					keep=5

					for tag in $tags; do
					  count=$((count + 1))
					  if [ $count -le $keep ]; then
						echo "Keeping $tag"
					  else
						echo "Deleting $tag"
						curl -s -X DELETE -u "$USERNAME:$DOCKERHUB_DEL" "https://hub.docker.com/v2/repositories/$USERNAME/$REPO/tags/$tag/"
					  fi
					done
					'''
				}
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
