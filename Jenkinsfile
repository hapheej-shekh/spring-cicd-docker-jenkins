pipeline {

    agent any

    environment {
	
		// username/docker-hub-repo-name
        IMAGE_NAME = 'sheikhitech/spring-cicd-docker-jenkins'
		
		// dockerhub-creds defined in jenkins pipeline
        DOCKER_CREDENTIALS_ID = 'dockerhub-creds'
		
		REPO = 'spring-cicd-docker-jenkins'
		
		CONTAINER_NAME = 'project-jenkins-cont'
		WEB_PORT = 8084
		HOST_PORT = 8084
    }

    stages {
        

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
                    // dockerImage = docker.build("${IMAGE_NAME}:${BUILD_NUMBER}")
					
					// Build the Docker image quietly to suppress verbose logs
					sh "docker build --quiet -t ${IMAGE_NAME}:${BUILD_NUMBER} ."
					
					// Reference the built image for later use (e.g., push)
					dockerImage = docker.image("${IMAGE_NAME}:${BUILD_NUMBER}")
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
				
                docker stop ${CONTAINER_NAME} || true
                docker rm ${CONTAINER_NAME} || true
				
                # Run the new container
                docker run -d -p --name ${CONTAINER_NAME} ${WEB_PORT}:${HOST_PORT} ${IMAGE_NAME}:${BUILD_NUMBER}
                '''
            }
        }
		
		stage('Cleanup Old Local Images') {
			steps {
				sh '''
				# List all image IDs (excluding 'latest') sorted by creation date, then delete all but the last 2
				IMAGE_REPO="sheikhitech/spring-cicd-docker-jenkins"
				
				# Get image IDs sorted by creation date (older first), exclude latest
				images=$(docker images --format "{{.Repository}}:{{.Tag}} {{.ID}}" | grep "$IMAGE_REPO" | grep -v latest | sort -u | awk '{print $2}')
				
				# Count how many images
				total=$(echo "$images" | wc -l)
				
				# If more than 2, delete older ones
				if [ "$total" -gt 2 ]; then
					echo "$images" | head -n $(($total - 2)) | xargs -r docker rmi || true
				fi
				'''
			}
		}
		
		stage('Cleanup Old Docker Hub Tags') {
			steps {
				withCredentials([
				  usernamePassword(
					credentialsId: 'dockerhub-creds',
					usernameVariable: 'DOCKERHUB_USER',
					passwordVariable: 'DOCKERHUB_PASS'
				  )
				]) {
					sh(script: '''#!/bin/bash
					set +x  # Disable command echoing
					
						# Install jq if not available for JSON
						if ! command -v jq >/dev/null 2>&1; then
							apt-get update && apt-get install -y jq || apk add --no-cache jq
						fi

						# Get JWT token from DockerHub
						
						TOKEN=$(curl -s -H "Content-Type: application/json" \\
						  -X POST https://hub.docker.com/v2/users/login/ \\
						  -d '{"username": "'"$DOCKERHUB_USER"'", "password": "'"$DOCKERHUB_PASS"'"}' | jq -r '.token')

						if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then
							echo "❌ Failed to get JWT token from DockerHub"
							exit 1
						fi

						echo "JWT token acquired"

						# Get list of tags sorted by last updated (latest first)
						tags=$(curl -s -H "Authorization: JWT $TOKEN" \\
						  https://hub.docker.com/v2/repositories/$DOCKERHUB_USER/$REPO/tags?page_size=100 |
						  jq -r '.results | sort_by(.last_updated) | reverse | .[].name')

						count=$(echo "$tags" | wc -l)

						if [ "$count" -gt 2 ]; then
							echo "$tags" | tail -n +3 | while read tag; do
								echo "Deleting tag: $tag"
								curl -s -X DELETE -H "Authorization: JWT $TOKEN" \\
									https://hub.docker.com/v2/repositories/$DOCKERHUB_USER/$REPO/tags/$tag/
							done
						else
							echo "Less than 3 tags, skipping deletion."
						fi

					set -x  # Re-enable echoing if needed
					''')
					echo "Repo deletion done."
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
