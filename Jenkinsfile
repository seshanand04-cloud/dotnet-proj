pipeline {
    agent any

    environment {
        DOTNET_CLI_HOME = "C:\\Windows\\Temp"
        DOTNET_NOLOGO = "true"
        DOTNET_CLI_TELEMETRY_OPTOUT = "true"
        PUBLISH_OUTPUT = "C:\\inetpub\\wwwroot\\StudentPortal"
        ZIP_PATH = "C:\\inetpub\\wwwroot\\StudentPortal\\StudentPortal.zip"
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Pulling latest code from GitHub...'
                checkout scm
            }
        }

        stage('Restore') {
            steps {
                echo 'Restoring NuGet packages...'
                bat 'dotnet restore StudentPortal.csproj'
            }
        }

        stage('Publish') {
            steps {
                echo 'Publishing .NET project...'
                bat 'dotnet publish StudentPortal.csproj -c Release -o .\\output'
            }
        }

        stage('Zip Output') {
            steps {
                echo 'Zipping publish output...'
                bat 'powershell -Command "Compress-Archive -Path .\\output\\* -DestinationPath .\\StudentPortal.zip -Force"'
            }
        }

        stage('Copy ZIP to wwwroot') {
            steps {
                echo 'Copying ZIP to deployment folder...'
                bat 'copy /Y StudentPortal.zip "%PUBLISH_OUTPUT%\\StudentPortal.zip"'
            }
        }

        stage('Deploy') {
            steps {
                echo 'Running deployment script...'

                // Stop IIS
                bat 'powershell -Command "Stop-WebAppPool -Name \'DefaultAppPool\'"'
                bat 'powershell -Command "Start-Sleep -Seconds 5"'
                bat 'powershell -Command "Stop-WebSite -Name \'Studentportal\'"'
                bat 'powershell -Command "Start-Sleep -Seconds 3"'
                bat 'taskkill /F /IM w3wp.exe || exit /b 0'
                bat 'timeout /t 3'

                // Unzip and clean
                bat 'powershell -Command "Expand-Archive -Path \'%ZIP_PATH%\' -DestinationPath \'%PUBLISH_OUTPUT%\' -Force"'
                bat 'powershell -Command "Remove-Item \'%ZIP_PATH%\' -Force"'

                // Start IIS
                bat 'powershell -Command "Start-WebAppPool -Name \'DefaultAppPool\'"'
                bat 'powershell -Command "Start-WebSite -Name \'Studentportal\'"'

                echo 'Deployment done!'
            }
        }

    }

    post {
        success {
            echo '✅ Build and Deploy Successful!'
        }
        failure {
            echo '❌ Pipeline Failed — check Console Output!'
        }
        always {
            cleanWs()
        }
    }
}