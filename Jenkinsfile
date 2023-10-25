pipeline {
    agent any

    tools {
        // Define the .NET SDK tool
        dotnetsdk 'MyDotNetSDK'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

         stage('Install Dependencies') {
            steps {
                sh '''
                    sudo apt-get update
                    sudo apt-get install -y libicu-dev
                '''
            }
        }


        stage('Build .NET Core App') {
            steps {
                // Use the plugin's steps for .NET operations
                sh 'dotnet restore RazorPagesApp/MyRazorPagesApp.csproj'  
                dotnetBuild(configuration: 'Release')
            }
        }


        stage('Deploy to Devops Namespace') {
            steps {
                sh '''
                    kubectl apply -f deployment-devops.yaml --namespace=devops
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
