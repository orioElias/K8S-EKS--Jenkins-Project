pipeline {
    agent any

    tools {
        // Define the .NET SDK tool
        dotnetsdk 'MyDotNetSDK'
    }

    environment {
        // Add this line to disable globalization
        SYSTEM_GLOBALIZATION_INVARIANT = 'true'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Restore') {
            steps {
                sh 'dotnet clean MySimpleWebApp/mySimpleWebApp.csproj'
                sh 'dotnet restore MySimpleWebApp/mySimpleWebApp.csproj'
            }
        }

        stage('Build') {
            steps {
                dir('MySimpleWebApp') {
                    sh 'dotnet build --configuration Release'
                }
            }
        }
        
        stage('Docker Build') {
            steps {
                sh '''
                    docker build -t my-dotnet-app:latest ./MySimpleWebApp
                '''
            }
        }

        stage('Docker Push') {
            steps {
                sh '''
                    docker tag my-dotnet-app:latest orielias/my-dotnet-app:latest
                    docker push orielias/my-dotnet-app:latest
                '''
            }
        }

        stage('Deploy to Deploy Namespace') {
            steps {
                sh '''
                    if ! kubectl get namespaces | grep -q 'deploy'; then
                        kubectl create namespace deploy
                    fi
                    kubectl apply -f deployment-deploy.yaml --namespace=deploy
                '''
            }
        }
    }
}
