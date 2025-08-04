@echo off
SETLOCAL

REM === Set working directory to the script's directory ===
cd /d %~dp0

REM === Variables for base image (custom Jenkins + AWS CLI, Maven, etc.) ===
SET BASE_IMAGE_DIR=Docker-Jenkins-Custom-Image
SET BASE_IMAGE_NAME=docker-maven-cli
SET JENKINS_CONTAINER_NAME=docker-maven-jenkins
SET JENKINS_PORT=8080

REM === Variables for Spring Boot project ===
SET PROJECT_IMAGE_NAME=project-maven-jenkins
SET PROJECT_CONTAINER_NAME=project-jenkins-cont
SET HOST_PORT=8084
SET CONTAINER_PORT=8084


echo ===============================
echo STEP 0: Cleanup old Jenkins container (if broken)
echo ===============================
docker rm -f %JENKINS_CONTAINER_NAME% >nul 2>&1


echo ===============================
echo STEP 1: Build Base Image (%BASE_IMAGE_NAME%)
echo ===============================
cd %BASE_IMAGE_DIR%
docker build -t %BASE_IMAGE_NAME% .
IF ERRORLEVEL 1 (
    echo Base image build failed!
    pause
    exit /b
)
cd ..


echo ==================================================
echo STEP 2: Fix Jenkins Volume Permissions (if needed)
echo ==================================================
docker run --rm -u root -v jenkins_home:/var/jenkins_home alpine sh -c "chown -R 1000:1000 /var/jenkins_home"


echo ===============================
echo STEP 3: Run Jenkins Container
echo ===============================
docker run -d ^
  --name %JENKINS_CONTAINER_NAME% ^
  -p %JENKINS_PORT%:8080 ^
  -v jenkins_home:/var/jenkins_home ^
  %BASE_IMAGE_NAME%

IF ERRORLEVEL 1 (
    echo Failed to run Jenkins container!
    pause
    exit /b
)


REM === Print port mapping for Jenkins ===
echo Jenkins is running on:
docker port %JENKINS_CONTAINER_NAME%

echo =================================
echo STEP 4: Build Spring Boot Project
echo =================================
call mvn clean install -DskipTests
IF ERRORLEVEL 1 (
    echo Maven build failed!
    pause
    exit /b
)

IF NOT EXIST target (
    echo Build failed or target folder missing.
    pause
    exit /b
)


echo ===============================
echo STEP 5: Build Project Docker Image (%PROJECT_IMAGE_NAME%)
echo ===============================
docker build -t %PROJECT_IMAGE_NAME% .


echo ===============================
echo STEP 6: Run Project Docker Container
echo ===============================
docker stop %PROJECT_CONTAINER_NAME% >nul 2>&1
docker rm %PROJECT_CONTAINER_NAME% >nul 2>&1

docker run -d ^
  --name %PROJECT_CONTAINER_NAME% ^
  -p %HOST_PORT%:%CONTAINER_PORT% ^
  %PROJECT_IMAGE_NAME%

echo --------------------------------
echo Jenkins: http://localhost:%JENKINS_PORT%
echo App    : http://localhost:%HOST_PORT%
echo --------------------------------

echo Host Jenkins Password
docker exec %JENKINS_CONTAINER_NAME% cat /var/jenkins_home/secrets/initialAdminPassword

pause
