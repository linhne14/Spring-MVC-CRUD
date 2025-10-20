$counter = 0 
while ($true) { 
    Clear-Host 
    Write-Host "===========================================" -ForegroundColor Cyan 
    Write-Host "   K8s Autoscaling Monitor - Refresh: $counter" -ForegroundColor Cyan 
    Write-Host "===========================================" -ForegroundColor Cyan 
    Write-Host "" 
    Write-Host "📊 HPA Status:" -ForegroundColor Yellow 
    kubectl get hpa -n sso-app 
    Write-Host "" 
    Write-Host "🔢 Pod Replicas:" -ForegroundColor Yellow 
    kubectl get deployment sso-app -n sso-app 
    Write-Host "" 
    Write-Host "📈 Resource Metrics:" -ForegroundColor Yellow 
    kubectl top pods -n sso-app 2>$null 
    Write-Host "" 
    Write-Host "📋 Pod Status:" -ForegroundColor Yellow 
    kubectl get pods -n sso-app -o wide 
    Write-Host "" 
    Write-Host "Last updated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray 
    Write-Host "Press Ctrl+C to stop monitoring" -ForegroundColor Gray 
    Start-Sleep -Seconds 10 
    $counter++ 
} 
