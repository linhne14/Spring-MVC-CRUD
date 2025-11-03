# PowerShell Script để test CPU alert scenario

Write-Host "🚀 Starting CPU Alert Test Scenario..." -ForegroundColor Green

# Apply updated AlertManager config
Write-Host "📧 Updating AlertManager configuration..." -ForegroundColor Cyan
kubectl apply -f monitoring/alertmanager.yaml
kubectl rollout restart deployment/alertmanager -n monitoring

# Deploy CPU intensive application  
Write-Host "💻 Deploying CPU intensive application..." -ForegroundColor Cyan
kubectl apply -f monitoring/cpu-intensive-app.yaml

# Wait for deployment
Write-Host "⏳ Waiting for CPU intensive app to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=available --timeout=120s deployment/cpu-intensive-app -n sso-dev

# Get pod name
$CPU_POD = kubectl get pods -n sso-dev -l app=cpu-intensive-app -o jsonpath='{.items[0].metadata.name}'
Write-Host "📱 CPU intensive pod: $CPU_POD" -ForegroundColor Green

Write-Host @"

🎯 TEST SCENARIO: CPU Usage > 80% for 1 minute

📋 Steps to trigger alert:
1. Access CPU Stress App: http://localhost:30003
2. Click 'Start CPU Stress' to begin high CPU usage
3. Monitor in Prometheus: http://localhost:9090
4. Watch alerts in AlertManager: http://localhost:9093  
5. Check webhook logs: kubectl logs -f deployment/webhook-server -n monitoring
6. Alert should fire after 1 minute of high CPU usage

🔍 Monitoring Commands:
- Check pod CPU: kubectl top pod $CPU_POD -n sso-dev
- View pod logs: kubectl logs -f $CPU_POD -n sso-dev

📊 Expected Results:
✅ CPU usage reaches 80%+ within seconds
✅ PodHighCPUUsage alert fires after 1 minute  
✅ Email notification sent (if SMTP configured)
✅ Slack message posted (if webhook configured)
✅ Webhook receives HTTP POST with alert data

🛑 To stop stress test:
- Visit http://localhost:30003 and click 'Stop CPU Stress'
- Or run: kubectl delete -f monitoring/cpu-intensive-app.yaml

"@ -ForegroundColor White

# Setup port forwards
Write-Host "🌐 Setting up port forwards..." -ForegroundColor Cyan

Start-Job -ScriptBlock { kubectl port-forward svc/prometheus -n monitoring 9090:9090 } | Out-Null
Start-Job -ScriptBlock { kubectl port-forward svc/alertmanager -n monitoring 9093:9093 } | Out-Null  
Start-Job -ScriptBlock { kubectl port-forward svc/grafana -n monitoring 3001:3000 } | Out-Null

Start-Sleep -Seconds 3

Write-Host @"

✅ Setup complete! 

🔗 Access URLs:
- CPU Stress App: http://localhost:30003
- Prometheus: http://localhost:9090  
- AlertManager: http://localhost:9093
- Grafana: http://localhost:3001 (admin/admin123)

🚀 Start the stress test by visiting http://localhost:30003 and clicking 'Start CPU Stress'

"@ -ForegroundColor Green

# Open browser to stress app
Start-Process "http://localhost:30003"