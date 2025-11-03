#!/usr/bin/env powershell

param(
    [int]$Duration = 300,  # Monitor for 5 minutes
    [int]$Interval = 15    # Check every 15 seconds
)

Write-Host "=== REAL-TIME ALERT MONITORING ===" -ForegroundColor Green
Write-Host "Monitoring for $Duration seconds, checking every $Interval seconds" -ForegroundColor Yellow
Write-Host "Press Ctrl+C to stop early`n" -ForegroundColor Yellow

$startTime = Get-Date
$endTime = $startTime.AddSeconds($Duration)
$alertCount = 0

while ((Get-Date) -lt $endTime) {
    $currentTime = Get-Date -Format "HH:mm:ss"
    Write-Host "[$currentTime] Checking alerts..." -ForegroundColor Cyan
    
    try {
        # Check AlertManager
        $alerts = Invoke-RestMethod -Uri "http://localhost:30001/api/v2/alerts" -Method GET -TimeoutSec 5
        
        if ($alerts.Count -gt 0) {
            Write-Host "🚨 ACTIVE ALERTS FOUND: $($alerts.Count)" -ForegroundColor Red
            foreach ($alert in $alerts) {
                $alertName = $alert.labels.alertname
                $status = $alert.status.state
                $startsAt = $alert.startsAt
                Write-Host "  - Alert: $alertName | Status: $status | Started: $startsAt" -ForegroundColor Magenta
                $alertCount++
            }
        } else {
            Write-Host "✅ No active alerts" -ForegroundColor Green
        }
        
        # Check CPU stress apps status
        try {
            $stress1 = Invoke-RestMethod -Uri "http://localhost:30003/status" -Method GET -TimeoutSec 3
            $stress2 = Invoke-RestMethod -Uri "http://localhost:30004/status" -Method GET -TimeoutSec 3
            Write-Host "   CPU Stress Apps: sso-dev=$($stress1.status) monitoring=$($stress2.status)" -ForegroundColor Gray
        } catch {
            Write-Host "   Warning: Cannot check CPU stress app status" -ForegroundColor Yellow
        }
        
        # Check webhook logs for new alerts
        try {
            $webhookPod = kubectl get pods -n monitoring -l app=webhook-server -o jsonpath='{.items[0].metadata.name}' 2>$null
            if ($webhookPod) {
                $logs = kubectl logs -n monitoring $webhookPod --tail=3 --since=30s 2>$null
                if ($logs -and $logs.Trim() -ne "") {
                    Write-Host "📨 Recent webhook activity:" -ForegroundColor Blue
                    Write-Host "   $logs" -ForegroundColor Gray
                }
            }
        } catch {
            # Ignore webhook log errors
        }
        
    } catch {
        Write-Host "❌ Error checking AlertManager: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host "───────────────────────────────────────" -ForegroundColor DarkGray
    Start-Sleep -Seconds $Interval
}

Write-Host "`n=== MONITORING COMPLETE ===" -ForegroundColor Green
Write-Host "Total alert instances detected: $alertCount" -ForegroundColor Yellow

if ($alertCount -eq 0) {
    Write-Host "`n🔧 TROUBLESHOOTING SUGGESTIONS:" -ForegroundColor Yellow
    Write-Host "1. Check Prometheus targets: http://localhost:30000/targets"
    Write-Host "2. Check if CPU stress is actually consuming resources"
    Write-Host "3. Verify alert rules in Prometheus: http://localhost:30000/rules"
    Write-Host "4. Check Prometheus logs: kubectl logs -n monitoring deployment/prometheus"
}
}