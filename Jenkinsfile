pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    docker build -t my-dotnet-app:latest Docker 
                '''
            }
        }

        stage('Docker Push') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-token', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh '''
                            docker login -u $DOCKER_USER -p $DOCKER_PASSWORD
                            docker tag my-dotnet-app:latest orielias/my-dotnet-app:latest
                            docker push orielias/my-dotnet-app:latest
                        '''
                    }
                }
            }
        }

        stage('Deploy to web-app Namespace') {
            steps {
                sh '''
                    if ! kubectl get namespaces | grep -q 'web-app'; then
                        kubectl create namespace web-app
                    fi
                    kubectl apply -f K8S/PipelineFiles --namespace=web-app
                '''
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}