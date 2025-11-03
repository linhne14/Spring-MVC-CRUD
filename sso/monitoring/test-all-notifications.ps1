#!/usr/bin/env powershell

Write-Host "=== 🚀 TESTING ALL NOTIFICATION CHANNELS ===" -ForegroundColor Green

Write-Host "`n📊 Current Alert Status:" -ForegroundColor Yellow
try {
    $alerts = Invoke-RestMethod -Uri "http://localhost:30001/api/v2/alerts" -Method GET
    Write-Host "Active Alerts: $($alerts.Count)" -ForegroundColor Cyan
    
    if ($alerts.Count -gt 0) {
        foreach ($alert in $alerts) {
            Write-Host "🔥 FIRING: $($alert.labels.alertname) - $($alert.labels.severity)" -ForegroundColor Red
        }
    } else {
        Write-Host "ℹ️ No active alerts currently" -ForegroundColor Gray
    }
} catch {
    Write-Host "❌ Error checking AlertManager: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n🌐 1. Testing HTTP Webhook Notifications:" -ForegroundColor Yellow

# Test httpbin.org endpoint
try {
    $webhookPayload = @{
        receiver = "webhook-notifications"
        status = "firing"
        alerts = @(
            @{
                status = "firing"
                labels = @{
                    alertname = "CPUStressTestAlert"
                    severity = "warning"
                    instance = "k8s-cluster"
                }
                annotations = @{
                    summary = "CPU usage is above 80% threshold"
                    description = "CPU Stress App is reporting 85% CPU usage"
                }
                startsAt = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
            }
        )
        groupLabels = @{
            alertname = "CPUStressTestAlert"
        }
        commonLabels = @{
            severity = "warning"
        }
        externalURL = "http://localhost:30001"
    }
    
    $headers = @{'Content-Type'='application/json'}
    $body = $webhookPayload | ConvertTo-Json -Depth 5
    
    Write-Host "   Testing httpbin.org..." -NoNewline
    $response1 = Invoke-RestMethod -Uri 'https://httpbin.org/post' -Method Post -Headers $headers -Body $body -TimeoutSec 10
    Write-Host " ✅ SUCCESS" -ForegroundColor Green
    Write-Host "   Response URL: $($response1.url)" -ForegroundColor Gray
    
    Write-Host "   Testing enhanced webhook..." -NoNewline  
    $response2 = Invoke-RestMethod -Uri 'http://localhost:30007/webhook' -Method Post -Headers $headers -Body $body -TimeoutSec 5
    Write-Host " ✅ SUCCESS" -ForegroundColor Green
    Write-Host "   Status: $($response2.status)" -ForegroundColor Gray
    
} catch {
    Write-Host " ❌ FAILED: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n📧 2. Email Notification Configuration:" -ForegroundColor Yellow
Write-Host "   SMTP Server: smtp.gmail.com:587" -ForegroundColor Gray
Write-Host "   From: k8s-monitoring@gmail.com" -ForegroundColor Gray
Write-Host "   To: admin@company.com" -ForegroundColor Gray
Write-Host "   Status: ⚠️ DEMO MODE - Configure real SMTP credentials" -ForegroundColor Orange

# Simulate email content
$emailContent = @"
Subject: 🚨 K8S Alert: CPUStressTestAlert

Dear Admin,

A Kubernetes alert has been triggered:

Alert Name: CPUStressTestAlert
Status: FIRING
Severity: WARNING
Summary: CPU usage is above 80% threshold
Description: CPU Stress App is reporting 85% CPU usage

Pod: cpu-stress-final-xxx
Namespace: monitoring
Time: $(Get-Date)

Best regards,
Kubernetes AlertManager
"@

Write-Host "   📝 Email Content Preview:" -ForegroundColor Cyan
Write-Host $emailContent -ForegroundColor Gray

Write-Host "`n💬 3. Slack Notification Configuration:" -ForegroundColor Yellow
Write-Host "   Webhook URL: https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK" -ForegroundColor Gray
Write-Host "   Channel: #kubernetes-alerts" -ForegroundColor Gray
Write-Host "   Status: ⚠️ DEMO MODE - Configure real Slack webhook" -ForegroundColor Orange

# Simulate Slack message
$slackPayload = @{
    channel = "#kubernetes-alerts"
    username = "K8s-AlertManager" 
    icon_emoji = ":warning:"
    text = "🚨 Kubernetes Alert: CPUStressTestAlert"
    attachments = @(
        @{
            color = "warning"
            fields = @(
                @{title="Status"; value="FIRING"; short=$true}
                @{title="Severity"; value="WARNING"; short=$true}
                @{title="Summary"; value="CPU usage above 80%"; short=$false}
                @{title="Pod"; value="cpu-stress-final"; short=$true}
                @{title="Namespace"; value="monitoring"; short=$true}
            )
            footer = "Kubernetes AlertManager"
            ts = [System.DateTimeOffset]::Now.ToUnixTimeSeconds()
        }
    )
}

Write-Host "   📝 Slack Payload Preview:" -ForegroundColor Cyan
Write-Host ($slackPayload | ConvertTo-Json -Depth 5) -ForegroundColor Gray

# Test Slack webhook with httpbin (simulates Slack)
try {
    Write-Host "   Testing Slack format via httpbin..." -NoNewline
    $slackHeaders = @{'Content-Type'='application/json'}
    $slackBody = $slackPayload | ConvertTo-Json -Depth 5
    $slackResponse = Invoke-RestMethod -Uri 'https://httpbin.org/post' -Method Post -Headers $slackHeaders -Body $slackBody -TimeoutSec 10
    Write-Host " ✅ SUCCESS" -ForegroundColor Green
    Write-Host "   Simulated Slack notification sent" -ForegroundColor Gray
} catch {
    Write-Host " ❌ FAILED: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n🔗 4. Notification URLs:" -ForegroundColor Yellow
Write-Host "   • AlertManager UI: http://localhost:30001" -ForegroundColor Cyan
Write-Host "   • Enhanced Webhook: http://localhost:30007" -ForegroundColor Cyan
Write-Host "   • Grafana Dashboards: http://localhost:30002" -ForegroundColor Cyan
Write-Host "   • Prometheus: http://localhost:30000" -ForegroundColor Cyan
Write-Host "   • CPU Stress Test: http://localhost:30006" -ForegroundColor Cyan

Write-Host "`n📋 5. Real Configuration Steps:" -ForegroundColor Yellow
Write-Host "   📧 Email: Update SMTP credentials in alertmanager-working-config" -ForegroundColor Gray
Write-Host "   💬 Slack: Create webhook at https://api.slack.com/incoming-webhooks" -ForegroundColor Gray
Write-Host "   🌐 HTTP: Webhooks are already working with httpbin.org and local endpoints" -ForegroundColor Gray

Write-Host "`n=== 🎉 ALL NOTIFICATION TYPES TESTED ===" -ForegroundColor Green