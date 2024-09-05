pipeline {
    agent any
    environment {
        DOCKER_CREDENTIALS_ID = "dockerhub-credentials"
        KUBE_CREDENTIALS_ID = "kubeconfig-id"
        NAMESPACE = "development"
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Login to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: "${env.DOCKER_CREDENTIALS_ID}", passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                        echo 'Logging in to Docker Hub...'
                        sh "echo ${DOCKER_PASSWORD} | docker login -u ${DOCKER_USERNAME} --password-stdin"
                        
                        // Set environment variables based on extracted credentials
                        env.DOCKER_REPO = DOCKER_USERNAME
                        env.IMAGE_NAME = 'spring-boot-application'
                        env.SPRING_BOOT_IMAGE_TAG = "${DOCKER_REPO}/${env.IMAGE_NAME}:${env.BUILD_ID}"
                        env.SPRING_BOOT_IMAGE_LATEST = "${DOCKER_REPO}/${env.IMAGE_NAME}:latest"
                    }
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image ${env.SPRING_BOOT_IMAGE_TAG}..."
                    docker.build("${env.SPRING_BOOT_IMAGE_TAG}")
                    
                    // Tag the image as 'latest'
                    echo "Tagging Docker image ${env.SPRING_BOOT_IMAGE_TAG} as 'latest'..."
                    sh "docker tag ${env.SPRING_BOOT_IMAGE_TAG} ${env.SPRING_BOOT_IMAGE_LATEST}"
                }
            }
        }
        stage('Push Docker Image') {
            steps {
                script {
                    withDockerRegistry([credentialsId: "${env.DOCKER_CREDENTIALS_ID}"]) {
                        echo "Pushing Docker image ${env.SPRING_BOOT_IMAGE_TAG}..."
                        sh "docker push ${env.SPRING_BOOT_IMAGE_TAG}"
                        
                        echo "Pushing Docker image ${env.SPRING_BOOT_IMAGE_LATEST}..."
                        sh "docker push ${env.SPRING_BOOT_IMAGE_LATEST}"
                    }
                }
            }
        }
        stage('Provision Spring Boot Application With Kubernetes') {
            steps {
                script {
                    // Replace the image tag in the Kubernetes deployment YAML
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
                sh "docker rmi ${env.SPRING_BOOT_IMAGE_LATEST} || true"
            }
        }
    }
}
