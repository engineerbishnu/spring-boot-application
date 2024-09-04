pipeline {
    agent any
    environment {
        DOCKER_IMAGE = "engineer442/spring-boot-application"
        DOCKER_CREDENTIALS_ID = "dockerhub-credentials"
        KUBE_CREDENTIALS_ID = "kubeconfig-id"
        IMAGE_TAG = "${env.DOCKER_IMAGE}:${env.BUILD_ID}"
        DOCKER_COMPOSE_FILE = 'docker-compose.yml'
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${env.DOCKER_IMAGE}:${env.BUILD_ID}")
                }
            }
        }
        stage('Push Spring-Boot-Application Docker Image') {
            steps {
                script {
                    withDockerRegistry([credentialsId: "${env.DOCKER_CREDENTIALS_ID}"]) {
                        sh "docker tag ${env.DOCKER_IMAGE}:${env.BUILD_ID} ${env.DOCKER_IMAGE}:latest"
                        sh "docker push ${env.DOCKER_IMAGE}:${env.BUILD_ID}"
                        sh "docker push ${env.DOCKER_IMAGE}:latest"
                    }
                }
            }
        }
        stage('Build and Push Nginx-Reverse-Proxy Image') {
            steps {
                script {
                    withDockerRegistry([credentialsId: "${env.DOCKER_CREDENTIALS_ID}"]) {
                        def nginxImage = docker.build("${env.DOCKER_IMAGE}-nginx:${env.BUILD_ID}", "-f Dockerfile.nginx .")
                        
                        // Push the image with BUILD_ID tag
                        nginxImage.push()
                        
                        // Create and push the 'latest' tag
                        sh "docker tag ${env.DOCKER_IMAGE}-nginx:${env.BUILD_ID} ${env.DOCKER_IMAGE}-nginx:latest"
                        sh "docker push ${env.DOCKER_IMAGE}-nginx:latest"
                    }
                }
            }
        }
        stage('Build and Push Nginx Image') {
            steps {
                script {
                    withDockerRegistry([credentialsId: "${env.DOCKER_CREDENTIALS_ID}"]) {
                        // Build the Nginx image using the Dockerfile.nginx file
                        def nginxImage = docker.build("${env.DOCKER_IMAGE}-nginx:${env.BUILD_ID}", "-f Dockerfile.nginx .")

                        // Push the image with BUILD_ID tag

                        nginxImage.push()

                        // Create and push the 'latest' tag
                        sh "docker tag ${env.DOCKER_IMAGE}-nginx:${env.BUILD_ID} ${env.DOCKER_IMAGE}-nginx:latest"
                        sh "docker push ${env.DOCKER_IMAGE}-nginx:latest"
                    }
                }
            }
        }
        stage('Provision to Kubernetes') {
            steps {
                script {
                    sh "sed -e 's|IMAGE_TAG|${env.DOCKER_IMAGE}:${env.BUILD_ID}|g' -e 's|NGINX_IMAGE_TAG|${env.DOCKER_IMAGE}-nginx:${env.BUILD_ID}|g' kubernetes-deployment.yaml > k8s-deployment-updated.yaml"
                    kubeconfig(credentialsId: "${env.KUBE_CREDENTIALS_ID}") {
                        sh 'kubectl apply -f k8s-deployment-updated.yaml'
                    }
                }
            }
        }
    }
}
