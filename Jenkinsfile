pipeline {
    agent any
    environment {
        SPRING_BOOT_IMAGE = "engineer442/spring-boot-application"
        NGINX_IMAGE= "engineer442/nginx-reverse-proxy"
        DOCKER_CREDENTIALS_ID = "dockerhub-credentials"
        KUBE_CREDENTIALS_ID = "kubeconfig-id"
        SPRING_BOOT_IMAGE_TAG = "${env.SPRING_BOOT_IMAGE}:${env.BUILD_ID}"
        NAMESPACE = "development"
        NGINX_IMAGE_TAG = "${env.NGINX_IMAGE}:${env.BUILD_ID}"
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
                    docker.build("${env.SPRING_BOOT_IMAGE_TAG}")
                }
            }
        }
        stage('Push Docker Image') {
            steps {
                script {
                    withDockerRegistry([credentialsId: "${env.DOCKER_CREDENTIALS_ID}"]) {
                        sh "docker tag ${env.SPRING_BOOT_IMAGE_TAG} ${env.SPRING_BOOT_IMAGE}:latest"
                        sh "docker push ${env.SPRING_BOOT_IMAGE_TAG}"
                        sh "docker push ${env.SPRING_BOOT_IMAGE}:latest"
                    }
                }
            }
        }
        stage('Build and Push Nginx Docker Image') {
            steps {
                script {
                    withDockerRegistry([credentialsId: "${env.DOCKER_CREDENTIALS_ID}"]) {
                        def nginxImage = docker.build("${env.NGINX_IMAGE_TAG}", "-f Dockerfile.nginx .")

                        // Push the image with BUILD_ID tag
                        nginxImage.push()

                        // Create and push the 'latest' tag
                        sh "docker tag ${env.NGINX_IMAGE_TAG} ${env.NGINX_IMAGE}:latest"
                        sh "docker push ${env.NGINX_IMAGE_TAG}"
                        sh "docker push ${env.NGINX_IMAGE}:latest"
                    }
                }
            }
        }
        stage('Provision Spring Boot Application With Kubernetes') {
            steps {
                script {
                    sh "sed -e 's|SPRING_BOOT_IMAGE_TAG|${env.SPRING_BOOT_IMAGE_TAG}|g' kubernetes-deployment.yaml > k8s-deployment-updated.yaml"
                    kubeconfig(credentialsId: "${env.KUBE_CREDENTIALS_ID}") {
                        sh 'kubectl apply -f k8s-deployment-updated.yaml'
                    }
                }
            }
        }
    }
    post {
        success {
            echo 'Deployment to Kubernetes completed successfully.'
        }
        failure {
            echo 'Deployment to Kubernetes failed.'
        }
        always {
            script {
                // Remove local Docker images to free up space
                sh "docker rmi ${env.SPRING_BOOT_IMAGE_TAG} || true"
                sh "docker rmi ${env.SPRING_BOOT_IMAGE}:latest || true"
            }
        }
    }
}
