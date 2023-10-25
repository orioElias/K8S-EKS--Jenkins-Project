pipeline {
    agent any 

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install .NET Core SDK if needed') {
            steps {
                script {
                    // Check if .NET Core SDK is already installed
                    def isDotnetInstalled = sh(script: 'which dotnet', returnStatus: true) == 0
                    if (!isDotnetInstalled) {
                        sh '''
                            apt-get update
                            apt-get install -y wget apt-transport-https
                            wget -q https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
                            dpkg -i packages-microsoft-prod.deb
                            apt-get update
                            apt-get install -y dotnet-sdk-3.1
                        '''
                    }
                }
            }
        }
        
        stage('Build .NET Core App') {
            steps {
                sh '''
                    dotnet restore
                    dotnet build --configuration Release
                '''
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
