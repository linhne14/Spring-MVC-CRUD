@echo off
echo ==========================================
echo 🚀 DEPLOY SSO APPLICATION TO KUBERNETES
echo ==========================================
echo.

echo 📋 Prerequisites Check:
echo.

REM Check if kubectl is installed
kubectl version --client >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ kubectl is not installed or not in PATH
    echo Please install kubectl: https://kubernetes.io/docs/tasks/tools/
    pause
    exit /b 1
)
echo ✅ kubectl found

REM Check if cluster is accessible
kubectl cluster-info >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Cannot connect to Kubernetes cluster
    echo Please ensure your cluster is running (minikube start, kind create cluster, etc.)
    pause
    exit /b 1
)
echo ✅ Kubernetes cluster is accessible
echo.

echo ==========================================
echo 📦 Step 1: Build and Load Docker Image
echo ==========================================
echo.

echo Building Docker image...
docker build -t sso-application:latest .
if %errorlevel% neq 0 (
    echo ❌ Failed to build Docker image
    pause
    exit /b 1
)

REM For minikube, load the image
kubectl get nodes | findstr minikube >nul 2>&1
if %errorlevel% equ 0 (
    echo Loading image to minikube...
    minikube image load sso-application:latest
)

REM For kind, load the image  
kubectl get nodes | findstr kind >nul 2>&1
if %errorlevel% equ 0 (
    echo Loading image to kind...
    kind load docker-image sso-application:latest
)

echo ✅ Docker image ready
echo.

echo ==========================================
echo 📊 Step 2: Install Metrics Server
echo ==========================================
echo.

kubectl get deployment metrics-server -n kube-system >nul 2>&1
if %errorlevel% neq 0 (
    echo Installing metrics-server...
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
    
    REM For local clusters, patch metrics-server
    timeout /t 5 /nobreak >nul
    kubectl patch deployment metrics-server -n kube-system --type='json' -p="[{\"op\": \"add\", \"path\": \"/spec/template/spec/containers/0/args/-\", \"value\": \"--kubelet-insecure-tls\"}]"
    
    echo Waiting for metrics-server to be ready...
    kubectl wait --for=condition=available --timeout=120s deployment/metrics-server -n kube-system
) else (
    echo ✅ Metrics server already installed
)
echo.

echo ==========================================
echo 🔧 Step 3: Deploy Application
echo ==========================================
echo.

echo Applying Kubernetes manifests...
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/autoscaling.yaml
echo.

echo Waiting for deployments to be ready...
kubectl wait --for=condition=available --timeout=300s deployment/keycloak -n sso-app
kubectl wait --for=condition=available --timeout=300s deployment/sso-app -n sso-app
echo.

echo ==========================================
echo 📈 Step 4: Deploy Monitoring Stack
echo ==========================================
echo.

kubectl apply -f k8s/monitoring.yaml
echo.

echo Waiting for monitoring stack...
kubectl wait --for=condition=available --timeout=120s deployment/prometheus -n monitoring
kubectl wait --for=condition=available --timeout=120s deployment/grafana -n monitoring
echo.

echo ==========================================
echo ✅ DEPLOYMENT COMPLETE
echo ==========================================
echo.

echo 📊 Deployment Status:
kubectl get all -n sso-app
echo.

echo 🔍 Monitoring Stack:
kubectl get all -n monitoring
echo.

echo 📍 Access Points:
echo.
echo SSO Application:
kubectl get svc -n sso-app sso-service
echo.
echo Keycloak:
kubectl get svc -n sso-app keycloak-service
echo.
echo Prometheus:
echo   http://localhost:30090
echo.
echo Grafana:
echo   http://localhost:30300
echo   Username: admin
echo   Password: admin123
echo.

echo 💡 Useful Commands:
echo   View pods:        kubectl get pods -n sso-app
echo   View HPA:         kubectl get hpa -n sso-app
echo   View logs:        kubectl logs -f deployment/sso-app -n sso-app
echo   Port forward SSO: kubectl port-forward -n sso-app svc/sso-service 8080:80
echo   Scale manually:   kubectl scale deployment/sso-app --replicas=5 -n sso-app
echo.

echo ==========================================
pause