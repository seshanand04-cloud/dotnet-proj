pipeline {
    agent any

    environment {
        DOTNET_CLI_HOME = "C:\\Windows\\Temp"
        DOTNET_NOLOGO = "true"
        DOTNET_CLI_TELEMETRY_OPTOUT = "true"
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Pulling latest code from GitHub...'
                checkout scm
            }
        }

        stage('Publish') {
            steps {
                echo 'Publishing .NET project...'
                bat 'dotnet publish StudentPortal.csproj -c Release -o .\\output'
            }
        }

        stage('Stop IIS') {
            steps {
                echo 'Stopping IIS...'
                bat 'iisreset /stop'
            }
        }

        stage('Deploy Files') {
            steps {
                echo 'Copying files to wwwroot...'
                bat 'powershell -Command "Copy-Item -Path .\\output\\* -Destination C:\\inetpub\\wwwroot\\StudentPortal\\ -Recurse -Force"'
            }
        }

        stage('Start IIS') {
            steps {
                echo 'Starting IIS...'
                bat 'iisreset /start'
            }
        }

    }

    post {
        success {
            echo '✅ Build and Deploy Successful!'
        }
        failure {
            echo '❌ Pipeline Failed!'
            bat 'iisreset /start'
        }
        always {
            cleanWs()
        }
    }
}