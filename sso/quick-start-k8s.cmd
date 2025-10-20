@echo off
echo ==========================================
echo 🚀 SSO K8s Quick Start
echo ==========================================
echo.

echo This script will guide you through the complete setup
echo.

echo 📋 What will be done:
echo   1. Build Docker image
echo   2. Setup Kubernetes cluster
echo   3. Deploy application
echo   4. Setup monitoring
echo   5. Configure autoscaling
echo.

choice /C YN /M "Continue with setup"
if %errorlevel% equ 2 exit /b 0

echo.
echo ==========================================
echo 📦 Step 1/5: Building Docker Image
echo ==========================================
echo.

call build-docker.cmd
if %errorlevel% neq 0 (
    echo ❌ Build failed
    pause
    exit /b 1
)

echo.
echo ==========================================
echo 🎯 Step 2/5: Checking Kubernetes
echo ==========================================
echo.

kubectl version --client >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ kubectl not found
    echo.
    echo Please install:
    echo   - Docker Desktop with Kubernetes, OR
    echo   - Minikube, OR
    echo   - Kind
    echo.
    echo See K8S-DEPLOYMENT-GUIDE.md for details
    pause
    exit /b 1
)

kubectl cluster-info >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ No Kubernetes cluster found
    echo.
    choice /C YN /M "Start minikube"
    if %errorlevel% equ 1 (
        minikube start --cpus=4 --memory=8192
    ) else (
        echo Please start your Kubernetes cluster and try again
        pause
        exit /b 1
    )
)

echo ✅ Kubernetes cluster ready

echo.
echo ==========================================
echo 🚀 Step 3/5: Deploying Application
echo ==========================================
echo.

call deploy-k8s.cmd
if %errorlevel% neq 0 (
    echo ❌ Deployment failed
    pause
    exit /b 1
)

echo.
echo ==========================================
echo 📊 Step 4/5: Verifying Deployment
echo ==========================================
echo.

timeout /t 10 /nobreak >nul

echo Checking pods...
kubectl get pods -n sso-app
echo.

echo Checking HPA...
kubectl get hpa -n sso-app
echo.

echo Checking services...
kubectl get svc -n sso-app
echo.

echo ==========================================
echo 🎉 Step 5/5: Setup Complete!
echo ==========================================
echo.

echo 📍 Access URLs:
echo.
echo   SSO Application (via port-forward):
echo     kubectl port-forward -n sso-app svc/sso-service 8080:80
echo     Then open: http://localhost:8080
echo.
echo   Prometheus:
echo     http://localhost:30090
echo.
echo   Grafana:
echo     http://localhost:30300
echo     Username: admin / Password: admin123
echo.

echo ==========================================
echo 📚 Next Steps:
echo ==========================================
echo.
echo 1. Monitor autoscaling:
echo      .\monitor-autoscaling.cmd
echo.
echo 2. Run load test:
echo      .\run-load-test.cmd
echo.
echo 3. View logs:
echo      kubectl logs -f deployment/sso-app -n sso-app
echo.
echo 4. Read full guide:
echo      K8S-DEPLOYMENT-GUIDE.md
echo.

choice /C YN /M "Start monitoring now"
if %errorlevel% equ 1 (
    start cmd /k .\monitor-autoscaling.cmd
)

echo.
echo ==========================================
pause