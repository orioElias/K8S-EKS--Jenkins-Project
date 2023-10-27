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
                    docker build -t my-dotnet-app:latest .
                '''
            }
        }

       stage('Docker Push') {
            steps {
                script {
                    withDockerRegistry([credentialsId: 'docker-hub-token', url: '']) {
                        sh '''
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
                    kubectl apply -f deployment-web-app.yaml --namespace=web-app
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
