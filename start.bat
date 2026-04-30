@echo off
title WordPress Docker Setup
color 0A

echo.
echo  =====================================================
echo   WordPress Docker Setup - One Click Installer
echo  =====================================================
echo.

:: -------------------------------------------------------
:: STEP 1 - Check if Docker is installed
:: -------------------------------------------------------
echo [1/6] Checking Docker...
docker --version >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo.
    echo  ERROR: Docker is not installed!
    echo  Please install Docker Desktop from:
    echo  https://www.docker.com/products/docker-desktop
    echo.
    pause
    exit /b
)
echo  Docker found!

:: -------------------------------------------------------
:: STEP 2 - Add spark.wp.com to hosts file
:: -------------------------------------------------------
echo.
echo [2/6] Setting up hosts file...
findstr /C:"spark.wp.com" "C:\Windows\System32\drivers\etc\hosts" >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo 127.0.0.1 spark.wp.com >> "C:\Windows\System32\drivers\etc\hosts"
    echo  Added spark.wp.com to hosts file!
) ELSE (
    echo  spark.wp.com already in hosts file, skipping.
)

:: -------------------------------------------------------
:: STEP 3 - Setup .env file
:: -------------------------------------------------------
echo.
echo [3/6] Setting up environment file...
IF NOT EXIST ".env" (
    IF EXIST ".env.example" (
        copy ".env.example" ".env" >nul
        echo  .env file created from .env.example
    ) ELSE (
        echo  WARNING: .env.example not found. Skipping...
    )
) ELSE (
    echo  .env file already exists, skipping.
)

:: -------------------------------------------------------
:: STEP 4 - Stop any old containers
:: -------------------------------------------------------
echo.
echo [4/6] Stopping old containers (if any)...
docker compose down >nul 2>&1
echo  Done.

:: -------------------------------------------------------
:: STEP 5 - Start Docker containers
:: -------------------------------------------------------
echo.
echo [5/6] Starting WordPress, MySQL, phpMyAdmin, FTP...
echo  This may take 2-3 minutes on first run (downloading images)...
echo.
docker compose up -d
IF %ERRORLEVEL% NEQ 0 (
    echo.
    echo  ERROR: Docker Compose failed!
    echo  Make sure Docker Desktop is running and try again.
    pause
    exit /b
)

:: -------------------------------------------------------
:: STEP 6 - Wait for WordPress to be ready
:: -------------------------------------------------------
echo.
echo [6/6] Waiting for WordPress to be ready...
timeout /t 15 /nobreak >nul
echo  Done!

:: -------------------------------------------------------
:: SUCCESS
:: -------------------------------------------------------
echo.
echo  =====================================================
echo   Setup Complete!
echo  =====================================================
echo.
echo   WordPress Site   : http://spark.wp.com
echo   Admin Panel      : http://spark.wp.com/wp-admin
echo   phpMyAdmin       : http://localhost:8082
echo.
echo   Admin Username   : admin
echo   Admin Password   : admin@123
echo.
echo   FTP Host         : localhost
echo   FTP Port         : 21
echo  =====================================================
echo.

:: Open browser automatically
start http://spark.wp.com

pause
