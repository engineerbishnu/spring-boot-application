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
        stage('Push Docker Image') {
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
        stage('Build Docker Images with Docker Compose') {
            steps {
                script {
                    sh "docker-compose -f ${env.DOCKER_COMPOSE_FILE} build"
                }
            }
        }
        stage('Deploy with Docker Compose') {
            steps {
                script {
                    sh "docker-compose -f ${env.DOCKER_COMPOSE_FILE} up -d"
                }
            }
        }
        stage('Provision to Kubernetes') {
            steps {
                script {
                    sh "sed 's|IMAGE_TAG|${env.DOCKER_IMAGE}:${env.BUILD_ID}|g' kubernetes-deployment.yaml > k8s-deployment-updated.yaml"
                    kubeconfig(credentialsId: "${env.KUBE_CREDENTIALS_ID}") {
                        sh 'kubectl apply -f k8s-deployment-updated.yaml'
                    }
                }
            }
        }
    }
}
