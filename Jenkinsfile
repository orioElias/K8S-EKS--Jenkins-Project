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
                        // Install .NET Core SDK (update this part based on your Linux distribution)
                        sh '''
                            ls
                            help
                            lsb_release -a
                            sudo apt install -y wget
                            wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
                            dpkg -i packages-microsoft-prod.deb
                            sudo apt update
                            sudo apt install -y apt-transport-https
                            sudo apt update
                            sudo apt install -y dotnet-sdk-3.1
                        '''
                    }
                }
            }
        }
        
        stage('Build .NET Core App') {
            steps {
                sh '''
                    # Assuming you have the .NET SDK installed in your Jenkins agent
                    dotnet restore
                    dotnet build --configuration Release
                '''
            }
        }

        stage('Deploy to Devops Namespace') {
            steps {
                sh '''
                    # Apply the Kubernetes configurations
                    kubectl apply -f deployment-devops.yaml --namespace=devops
                '''
            }
        }

        stage('Deploy to Deploy Namespace') {
            steps {
                sh '''
                    # Apply the Kubernetes configurations
                    kubectl create namespace deploy
                    kubectl apply -f deployment-deploy.yaml --namespace=deploy
                '''
            }
        }
    }
}
