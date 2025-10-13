@echo off
echo ==========================================
echo 🚀 RUN SSO APPLICATION WITH OAUTH2
echo ==========================================
echo.
echo ⚠️  PREREQUISITES:
echo   1. Keycloak must be running at http://localhost:8081
echo   2. Realm 'spring-boot-sso' must exist
echo   3. Client 'spring-boot-client' must be configured
echo.

REM Check if Keycloak realm exists
echo Checking Keycloak realm...
curl -s http://localhost:8081/realms/spring-boot-sso >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ ERROR: Realm 'spring-boot-sso' does not exist!
    echo.
    echo Please setup Keycloak first:
    echo   1. Go to http://localhost:8081/admin
    echo   2. Login: admin/admin123
    echo   3. Create realm: spring-boot-sso
    echo   4. Create client: spring-boot-client
    echo   5. Run setup-keycloak.cmd for detailed instructions
    echo.
    pause
    exit /b 1
)

echo ✅ Keycloak realm found!

REM Stop any running java process on port 8080
echo Stopping any existing application...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8080') do (
    taskkill /F /PID %%a 2>nul
)

echo Starting application with oauth2 profile...
cd /d "%~dp0"

REM Set profile to oauth2
mvn spring-boot:run -Dspring-boot.run.profiles=oauth2

echo.
echo ==========================================
echo Application started at: http://localhost:8080
echo Profile: oauth2 (OAuth2 enabled)
echo ==========================================