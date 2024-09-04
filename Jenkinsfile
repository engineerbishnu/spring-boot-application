pipeline {
    agent any
    environment {
        DOCKER_IMAGE = "engineer442/spring-boot-application"
        DOCKER_CREDENTIALS_ID = "dockerhub-credentials" // ID my Docker Hub credentials in Jenkins (already setup)
        KUBE_CREDENTIALS_ID = "kubeconfig-id" // ID Kubernetes credentials in Jenkins (already setup)
        IMAGE_TAG = "${env.DOCKER_IMAGE}:${env.BUILD_ID}" // Use for unique build ID
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Build') {
            steps {
                script {
                    dockerImage = docker.build("${env.DOCKER_IMAGE}:${env.BUILD_ID}")
                }
            }
        }
        stage('Push') {
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
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    // Create a temporary file with the updated image tag
                    sh "sed 's|IMAGE_TAG|${env.DOCKER_IMAGE}:${env.BUILD_ID}|g' kubernetes-deployment.yaml > k8s-deployment-updated.yaml"
                    kubeconfig(credentialsId: "${env.KUBE_CREDENTIALS_ID}", serverUrl: 'https://0.0.0.0:37079') {
                        sh 'kubectl apply -f k8s-deployment-updated.yaml'
                    }
                }
            }
        }
    }
}
