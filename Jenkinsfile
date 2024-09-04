pipeline {
    agent any
    environment {
        DOCKER_IMAGE = "engineer442/spring-boot-application"
        DOCKER_CREDENTIALS_ID = "dockerhub-credentials" // ID of Docker Hub credentials in Jenkins (already set up)
        KUBE_CREDENTIALS_ID = "kubeconfig-id" // ID of Kubernetes credentials in Jenkins (already set up)
        IMAGE_TAG = "${env.DOCKER_IMAGE}:${env.BUILD_ID}" // Use for unique build ID
        DOCKER_COMPOSE_FILE = 'docker-compose.yml'
        NGINX_CONF_FILE = 'nginx.conf'
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Build Docker Images') {
            steps {
                script {
                    // Build Docker images as defined in docker-compose.yml
                    sh "docker-compose -f ${env.DOCKER_COMPOSE_FILE} build"
                }
            }
        }
        stage('Push Docker Images') {
            steps {
                script {
                    withDockerRegistry([credentialsId: "${env.DOCKER_CREDENTIALS_ID}", url: 'https://index.docker.io/v1/']) {
                        sh "docker tag ${env.DOCKER_IMAGE}:${env.BUILD_ID} ${env.DOCKER_IMAGE}:latest"
                        sh "docker push ${env.DOCKER_IMAGE}:${env.BUILD_ID}"
                        sh "docker push ${env.DOCKER_IMAGE}:latest"
                    }
                }
            }
        }
        stage('Deploy with Docker Compose') {
            steps {
                script {
                    // Deploy the Docker Compose setup
                    sh "docker-compose -f ${env.DOCKER_COMPOSE_FILE} up -d"
                }
            }
        }
        stage('Provision to Kubernetes') {
            steps {
                script {
                    // Generate Kubernetes manifests from Docker Compose if needed
                    // Alternatively, apply Kubernetes manifests directly if they are already present
                    sh "sed 's|IMAGE_TAG|${env.DOCKER_IMAGE}:${env.BUILD_ID}|g' kubernetes-deployment.yaml > k8s-deployment-updated.yaml"
                    kubeconfig(credentialsId: "${env.KUBE_CREDENTIALS_ID}", serverUrl: 'https://0.0.0.0:41709') {
                        sh 'kubectl apply -f k8s-deployment-updated.yaml'
                    }
                }
            }
        }
    }
}
