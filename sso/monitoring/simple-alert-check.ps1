Write-Host "=== TESTING ALERT SYSTEM ===" -ForegroundColor Green

Write-Host "`n1. Checking AlertManager status:" -ForegroundColor Yellow
try {
    $alerts = Invoke-RestMethod -Uri "http://localhost:30001/api/v2/alerts" -Method GET
    Write-Host "Active Alerts: $($alerts.Count)" -ForegroundColor Cyan
    
    if ($alerts.Count -gt 0) {
        foreach ($alert in $alerts) {
            Write-Host "- $($alert.labels.alertname): $($alert.status.state)" -ForegroundColor Magenta
        }
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n2. Checking Prometheus rules:" -ForegroundColor Yellow
try {
    $rules = Invoke-RestMethod -Uri "http://localhost:30000/api/v1/rules" -Method GET
    $ruleGroups = $rules.data.groups
    foreach ($group in $ruleGroups) {
        Write-Host "Group: $($group.name)" -ForegroundColor Cyan
        foreach ($rule in $group.rules) {
            if ($rule.type -eq "alerting") {
                $state = $rule.state
                Write-Host "  - $($rule.name): $state" -ForegroundColor $(if($state -eq "firing"){"Red"}else{"Green"})
            }
        }
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n3. CPU Stress Apps status:" -ForegroundColor Yellow
try {
    $app1 = Invoke-RestMethod -Uri "http://localhost:30003/status" -Method GET
    $app2 = Invoke-RestMethod -Uri "http://localhost:30004/status" -Method GET
    Write-Host "sso-dev app: $($app1.status) ($($app1.active_threads) threads)" -ForegroundColor Cyan
    Write-Host "monitoring app: $($app2.status) ($($app2.active_threads) threads)" -ForegroundColor Cyan
} catch {
    Write-Host "Error checking apps: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n4. Webhook server logs:" -ForegroundColor Yellow
kubectl logs -n monitoring deployment/webhook-server --tail=10 | Select-Object -First 10

Write-Host "`n=== TEST COMPLETE ===" -ForegroundColor Green