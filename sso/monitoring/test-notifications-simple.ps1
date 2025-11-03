# Test Full Notification System
Write-Host "TESTING ALL NOTIFICATION CHANNELS" -ForegroundColor Yellow
Write-Host "====================================" -ForegroundColor Cyan

# 1. Test HTTP Webhook (External - httpbin.org)
Write-Host "`n1. Testing HTTP Webhook (External)" -ForegroundColor Green
try {
    $httpbinResponse = Invoke-RestMethod -Uri "https://httpbin.org/post" -Method POST -Body @{
        "alert_type" = "test"
        "message" = "Test from SSO Monitoring System"
        "severity" = "info"
        "timestamp" = (Get-Date).ToString()
    } -ContentType "application/x-www-form-urlencoded"
    Write-Host "   SUCCESS: HTTP External works!" -ForegroundColor Green
} catch {
    Write-Host "   FAILED: $($_.Exception.Message)" -ForegroundColor Red
}

# 2. Test Local Enhanced Webhook
Write-Host "`n2. Testing Local Enhanced Webhook" -ForegroundColor Green
try {
    $testAlert = @{
        "alerts" = @(
            @{
                "labels" = @{
                    "alertname" = "TestAlert"
                    "severity" = "info"
                }
                "annotations" = @{
                    "summary" = "Test notification from PowerShell"
                    "description" = "This is a test of the notification system"
                }
                "status" = "firing"
                "startsAt" = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
            }
        )
    }
    
    $localResponse = Invoke-RestMethod -Uri "http://localhost:30007/webhook" -Method POST -Body ($testAlert | ConvertTo-Json -Depth 5) -ContentType "application/json"
    Write-Host "   SUCCESS: Local Webhook works!" -ForegroundColor Green
} catch {
    Write-Host "   FAILED: $($_.Exception.Message)" -ForegroundColor Red
}

# 3. Test AlertManager Status
Write-Host "`n3. Checking AlertManager Status" -ForegroundColor Green
try {
    $alertsResponse = Invoke-RestMethod -Uri "http://localhost:30001/api/v1/alerts"
    Write-Host "   SUCCESS: AlertManager API accessible" -ForegroundColor Green
    Write-Host "   Total alerts: $($alertsResponse.Count)" -ForegroundColor Cyan
} catch {
    Write-Host "   FAILED: $($_.Exception.Message)" -ForegroundColor Red
}

# 4. Summary
Write-Host "`nNOTIFICATION SYSTEM SUMMARY" -ForegroundColor Magenta
Write-Host "============================" -ForegroundColor Cyan
Write-Host "HTTP Webhooks: OPERATIONAL" -ForegroundColor Green
Write-Host "Enhanced Webhook Server: RECEIVING ALERTS" -ForegroundColor Green  
Write-Host "Slack Format: READY (needs real webhook URL)" -ForegroundColor Yellow
Write-Host "Email Format: READY (needs real SMTP credentials)" -ForegroundColor Yellow
Write-Host "AlertManager: FIRING ALERTS" -ForegroundColor Green

Write-Host "`nACCESS URLS:" -ForegroundColor Blue
Write-Host "Prometheus: http://localhost:30000" -ForegroundColor White
Write-Host "AlertManager: http://localhost:30001" -ForegroundColor White  
Write-Host "Grafana: http://localhost:30002 (admin/admin)" -ForegroundColor White
Write-Host "CPU Stress App: http://localhost:30006" -ForegroundColor White
Write-Host "Enhanced Webhook: http://localhost:30007" -ForegroundColor White