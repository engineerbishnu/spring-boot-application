pipeline {
    agent any
    environment {
        SPRING_BOOT_IMAGE = "engineer442/spring-boot-application"
        DOCKER_CREDENTIALS_ID = "dockerhub-credentials"
        KUBE_CREDENTIALS_ID = "kubeconfig-id"
        SPRING_BOOT_IMAGE_TAG = "${env.SPRING_BOOT_IMAGE}:${env.BUILD_ID}"
        HELM_CHART_REPO = "https://kubernetes.github.io/ingress-nginx" // NGINX Ingress Controller Helm repo
        HELM_RELEASE_NAME = "nginx-ingress"
        NAMESPACE = "development" // Namespace for both Ingress Controller and application
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
        stage('Provision NGINX Ingress Controller') {
            steps {
                script {
                    kubeconfig(credentialsId: "${env.KUBE_CREDENTIALS_ID}") {
                        // Add Helm repository
                        sh "helm repo add ingress-nginx ${env.HELM_CHART_REPO}"
                        sh "helm repo update"

                        // Install or upgrade NGINX Ingress Controller in the 'development' namespace
                        sh "helm upgrade --install ${env.HELM_RELEASE_NAME} ingress-nginx/ingress-nginx --namespace ${env.NAMESPACE} --create-namespace"
                    }
                }
            }
        }
        stage('Provision Spring Boot Application') {
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
