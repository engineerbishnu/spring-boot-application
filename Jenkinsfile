pipeline {
    agent any
    environment {
        SPRING_BOOT_IMAGE = "engineer442/spring-boot-application"
        DOCKER_CREDENTIALS_ID = "dockerhub-credentials"
        KUBE_CREDENTIALS_ID = "kubeconfig-id"
        SPRING_BOOT_IMAGE_TAG = "${env.SPRING_BOOT_IMAGE}:${env.BUILD_ID}"
        NAMESPACE = "development"
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
                    def imageExists = sh(script: "docker images -q ${env.SPRING_BOOT_IMAGE_TAG}", returnStdout: true).trim()
                    if (imageExists) {
                        echo "Docker image ${env.SPRING_BOOT_IMAGE_TAG} already exists."
                    } else {
                        echo "Building Docker image ${env.SPRING_BOOT_IMAGE_TAG}..."
                        docker.build("${env.SPRING_BOOT_IMAGE_TAG}")
                    }
                }
            }
        }
        stage('Push Docker Image') {
            steps {
                script {
                    withDockerRegistry([credentialsId: "${env.DOCKER_CREDENTIALS_ID}"]) {
                        echo "Pushing Docker image ${env.SPRING_BOOT_IMAGE_TAG}..."
                        sh "docker tag ${env.SPRING_BOOT_IMAGE_TAG} ${env.SPRING_BOOT_IMAGE}:latest"
                        sh "docker push ${env.SPRING_BOOT_IMAGE_TAG}"
                        sh "docker push ${env.SPRING_BOOT_IMAGE}:latest"
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
