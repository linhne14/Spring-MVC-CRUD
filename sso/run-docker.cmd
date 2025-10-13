@echo off
REM Run SSO application with Docker Compose

echo Starting SSO application with Docker Compose...
echo This will start both Keycloak and the SSO application...

REM Build and start services
docker-compose up -d --build

if %errorlevel% equ 0 (
    echo ✓ Services started successfully!
    echo.
    echo 🔑 Keycloak Admin Console: http://localhost:8081
    echo    Username: admin
    echo    Password: admin123
    echo.
    echo 🚀 SSO Application: http://localhost:8080
    echo.
    echo ⚠️  IMPORTANT: You need to configure Keycloak first!
    echo    Run: setup-keycloak.cmd for detailed instructions
    echo.
    echo Useful commands:
    echo   View logs:        docker-compose logs -f
    echo   Setup Keycloak:   setup-keycloak.cmd
    echo   Stop services:    docker-compose down
    echo   Restart:          docker-compose restart
    echo   View status:      docker-compose ps
) else (
    echo ✗ Failed to start services
    exit /b 1
)