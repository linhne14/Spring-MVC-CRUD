@echo off
echo ==========================================
echo 🔍 MONITOR KUBERNETES AUTOSCALING
echo ==========================================
echo.

echo This script monitors HPA (Horizontal Pod Autoscaler) in real-time
echo Press Ctrl+C to stop monitoring
echo.

REM Check if kubectl is installed
kubectl version --client >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ kubectl is not installed
    pause
    exit /b 1
)

echo ==========================================
echo 📊 Current Status
echo ==========================================
echo.

echo Pods:
kubectl get pods -n sso-app
echo.

echo HPA Status:
kubectl get hpa -n sso-app
echo.

echo Metrics:
kubectl top nodes
echo.
kubectl top pods -n sso-app
echo.

echo ==========================================
echo 🔄 Starting Real-time Monitoring
echo ==========================================
echo.

REM Create a PowerShell script for monitoring
echo $counter = 0 > monitor.ps1
echo while ($true) { >> monitor.ps1
echo     Clear-Host >> monitor.ps1
echo     Write-Host "===========================================" -ForegroundColor Cyan >> monitor.ps1
echo     Write-Host "   K8s Autoscaling Monitor - Refresh: $counter" -ForegroundColor Cyan >> monitor.ps1
echo     Write-Host "===========================================" -ForegroundColor Cyan >> monitor.ps1
echo     Write-Host "" >> monitor.ps1
echo     Write-Host "📊 HPA Status:" -ForegroundColor Yellow >> monitor.ps1
echo     kubectl get hpa -n sso-app >> monitor.ps1
echo     Write-Host "" >> monitor.ps1
echo     Write-Host "🔢 Pod Replicas:" -ForegroundColor Yellow >> monitor.ps1
echo     kubectl get deployment sso-app -n sso-app >> monitor.ps1
echo     Write-Host "" >> monitor.ps1
echo     Write-Host "📈 Resource Metrics:" -ForegroundColor Yellow >> monitor.ps1
echo     kubectl top pods -n sso-app 2^>$null >> monitor.ps1
echo     Write-Host "" >> monitor.ps1
echo     Write-Host "📋 Pod Status:" -ForegroundColor Yellow >> monitor.ps1
echo     kubectl get pods -n sso-app -o wide >> monitor.ps1
echo     Write-Host "" >> monitor.ps1
echo     Write-Host "Last updated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray >> monitor.ps1
echo     Write-Host "Press Ctrl+C to stop monitoring" -ForegroundColor Gray >> monitor.ps1
echo     Start-Sleep -Seconds 10 >> monitor.ps1
echo     $counter++ >> monitor.ps1
echo } >> monitor.ps1

powershell -ExecutionPolicy Bypass -File monitor.ps1

del monitor.ps1