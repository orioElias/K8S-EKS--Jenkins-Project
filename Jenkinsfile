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

        stage('Restore') {
            steps {
                sh 'dotnet clean MySimpleWebApp/mySimpleWebApp.csproj'
                sh 'dotnet restore MySimpleWebApp/mySimpleWebApp.csproj'
            }
        }


        stage('Build') {
            steps {
                dir('MySimpleWebApp') {
                    // Assuming dotnetBuild is a custom step or comes from a plugin you are using
                    dotnetBuild(configuration: 'Release')
                }
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
