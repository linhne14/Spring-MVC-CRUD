@echo off
echo ==========================================
echo 🐳 BUILD AND EXPORT DOCKER IMAGE
echo ==========================================
echo.

REM Set variables
set IMAGE_NAME=sso-application
set IMAGE_TAG=latest
set EXPORT_FILE=sso-application-latest.tar

echo 📦 Step 1: Building Docker image...
docker build -t %IMAGE_NAME%:%IMAGE_TAG% .

if %errorlevel% neq 0 (
    echo ❌ Failed to build Docker image
    exit /b 1
)

echo ✅ Docker image built successfully!
echo.

echo 📊 Image information:
docker images %IMAGE_NAME%:%IMAGE_TAG%
echo.

echo 💾 Step 2: Exporting Docker image to file...
docker save -o %EXPORT_FILE% %IMAGE_NAME%:%IMAGE_TAG%

if %errorlevel% neq 0 (
    echo ❌ Failed to export Docker image
    exit /b 1
)

echo ✅ Docker image exported successfully!
echo.

echo 📁 File information:
dir %EXPORT_FILE%
echo.

echo ==========================================
echo ✅ EXPORT COMPLETE
echo ==========================================
echo Image: %IMAGE_NAME%:%IMAGE_TAG%
echo Export file: %EXPORT_FILE%
echo.
echo To load this image on another machine:
echo   docker load -i %EXPORT_FILE%
echo.
echo To push to Docker Hub (optional):
echo   docker tag %IMAGE_NAME%:%IMAGE_TAG% your-dockerhub-username/%IMAGE_NAME%:%IMAGE_TAG%
echo   docker push your-dockerhub-username/%IMAGE_NAME%:%IMAGE_TAG%
echo ==========================================
pause