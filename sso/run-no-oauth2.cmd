@echo off
echo ==========================================
echo 🚀 RUN SSO APPLICATION WITHOUT OAUTH2
echo ==========================================
echo.
echo This will run the application in no-oauth2 mode
echo You can setup Keycloak later and switch to oauth2 profile
echo.

REM Stop any running java process on port 8080
echo Stopping any existing application...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8080') do (
    taskkill /F /PID %%a 2>nul
)

echo Starting application with no-oauth2 profile...
cd /d "%~dp0"

REM Set profile to no-oauth2
set SPRING_PROFILES_ACTIVE=no-oauth2
.\mvnw.cmd spring-boot:run

echo.
echo ==========================================
echo Application started at: http://localhost:8080
echo Profile: no-oauth2 (OAuth2 disabled)
echo ==========================================