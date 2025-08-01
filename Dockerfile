# -------------------------------
# Use a lightweight Java 11 base image
FROM openjdk:11-jdk-slim

# Optional: Set timezone (if needed for logs)
ENV TZ=Asia/Kolkata

# Set environment variable for active Spring profile (override via `docker run -e`)
ENV SPRING_PROFILES_ACTIVE=dev

# Set working directory
WORKDIR /spring-cicd-docker-jenkins

# Copy JAR file to container
# IMPORTANT: Replace with your actual JAR name
#COPY target/spring-cicd-docker-jenkins-0.0.1.jar docker-jenkins-app.jar
COPY target/*.jar docker-jenkins-app.jar

# Expose the port your docker-app listens on (default: 8080)
EXPOSE 8082

# Run the application
ENTRYPOINT ["java", "-jar", "docker-jenkins-app.jar"]
