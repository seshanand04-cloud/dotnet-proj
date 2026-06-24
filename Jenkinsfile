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

        // Kill w3wp if running (ignore error if not found)
        bat '''
            powershell -Command "
                $proc = Get-Process -Name w3wp -ErrorAction SilentlyContinue;
                if ($proc) { 
                    Stop-Process -Name w3wp -Force;
                    Write-Host 'w3wp.exe killed'
                } else { 
                    Write-Host 'w3wp.exe not running, skipping'
                }
            "
        '''

        // Wait
        bat 'powershell -Command "Start-Sleep -Seconds 3"'

        // Unzip and clean
        bat 'powershell -Command "Expand-Archive -Path \'C:\\inetpub\\wwwroot\\StudentPortal\\StudentPortal.zip\' -DestinationPath \'C:\\inetpub\\wwwroot\\StudentPortal\' -Force"'
        bat 'powershell -Command "Remove-Item \'C:\\inetpub\\wwwroot\\StudentPortal\\StudentPortal.zip\' -Force"'

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