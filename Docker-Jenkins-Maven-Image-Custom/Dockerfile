FROM jenkins/jenkins:lts

USER root

# Install Maven, Git, and dependencies for Docker CLI setup
RUN apt-get update && \
    apt-get install -y maven git curl gnupg2 lsb-release software-properties-common && \
    apt-get clean

# Add Docker CLI
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y docker-ce-cli

USER jenkins
