#!/usr/bin/env powershell

Write-Host "=== CHECKING MONITORING SYSTEM ===" -ForegroundColor Green

Write-Host "`n1. CPU Stress App Status:" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:30003/status" -Method GET
    Write-Host "Status: $($response.status)" -ForegroundColor Cyan
    Write-Host "Active Threads: $($response.active_threads)" -ForegroundColor Cyan
    Write-Host "CPU Cores: $($response.cpu_cores)" -ForegroundColor Cyan
} catch {
    Write-Host "Error checking CPU stress app: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n2. Pod Status:" -ForegroundColor Yellow
kubectl get pods -n sso-dev -l app=cpu-intensive-app
kubectl get pods -n monitoring

Write-Host "`n3. Webhook Server Logs (Last 10 lines):" -ForegroundColor Yellow
$webhookPod = kubectl get pods -n monitoring -l app=webhook-server -o jsonpath='{.items[0].metadata.name}' 2>$null
if ($webhookPod) {
    kubectl logs -n monitoring $webhookPod --tail=10
} else {
    Write-Host "No webhook pod found" -ForegroundColor Red
}

Write-Host "`n4. Testing AlertManager API:" -ForegroundColor Yellow
try {
    $alerts = Invoke-RestMethod -Uri "http://localhost:30001/api/v1/alerts" -Method GET
    Write-Host "Active Alerts: $($alerts.data.Count)" -ForegroundColor Cyan
    if ($alerts.data.Count -gt 0) {
        foreach ($alert in $alerts.data) {
            Write-Host "- Alert: $($alert.labels.alertname) | Status: $($alert.status.state)" -ForegroundColor Magenta
        }
    }
} catch {
    Write-Host "Error checking AlertManager: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n5. Testing Prometheus Query:" -ForegroundColor Yellow
try {
    $query = [System.Web.HttpUtility]::UrlEncode('(sum(rate(container_cpu_usage_seconds_total{container!="POD",container!=""}[1m])) by (pod, namespace) / sum(container_spec_cpu_quota{container!="POD",container!=""}/container_spec_cpu_period{container!="POD",container!=""}) by (pod, namespace)) * 100')
    $prometheusUrl = "http://localhost:30000/api/v1/query?query=$query"
    $result = Invoke-RestMethod -Uri $prometheusUrl -Method GET
    
    if ($result.status -eq "success" -and $result.data.result.Count -gt 0) {
        Write-Host "CPU Usage Query Results:" -ForegroundColor Cyan
        foreach ($metric in $result.data.result) {
            $value = [math]::Round([double]$metric.value[1], 2)
            Write-Host "- Pod: $($metric.metric.pod) | Namespace: $($metric.metric.namespace) | CPU: $value%" -ForegroundColor Magenta
        }
    } else {
        Write-Host "No CPU metrics found or query failed" -ForegroundColor Red
    }
} catch {
    Write-Host "Error querying Prometheus: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== CHECK COMPLETE ===" -ForegroundColor Green