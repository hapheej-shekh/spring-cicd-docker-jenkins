@echo off

REM Jenkins local Custom Base Image Buld & Run

SET IMAGE_NAME=docker-maven-cli
SET CONTAINER_NAME=docker-maven-cli
SET HOST_PORT=8080
SET CONTAINER_PORT=8080

echo --- Building Custom Docker Base Image ---
docker build -t %IMAGE_NAME% Docker-Jenkins-Custom-Image

echo Stopping old container if running...
docker stop %CONTAINER_NAME% >nul 2>&1

echo Removing old container if exists...
docker rm %CONTAINER_NAME% >nul 2>&1

echo Running new container from image: %IMAGE_NAME%
docker run -d ^
  --name %CONTAINER_NAME% ^
  -p %HOST_PORT%:%CONTAINER_PORT% ^
  -p 50000:50000 ^
  -u root ^
  -v /var/run/docker.sock:/var/run/docker.sock ^
  -v jenkins_home:/var/jenkins_home ^
  %IMAGE_NAME%

echo Container %CONTAINER_NAME% started and exposed at http://localhost:%HOST_PORT%

pause
