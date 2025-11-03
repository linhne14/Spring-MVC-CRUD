#!/bin/bash

# Script để test CPU alert scenario

echo "🚀 Starting CPU Alert Test Scenario..."

# Apply updated AlertManager config
echo "📧 Updating AlertManager configuration..."
kubectl apply -f monitoring/alertmanager.yaml
kubectl rollout restart deployment/alertmanager -n monitoring

# Deploy CPU intensive application
echo "💻 Deploying CPU intensive application..."
kubectl apply -f monitoring/cpu-intensive-app.yaml

# Wait for deployment
echo "⏳ Waiting for CPU intensive app to be ready..."
kubectl wait --for=condition=available --timeout=120s deployment/cpu-intensive-app -n sso-dev

# Get pod name
CPU_POD=$(kubectl get pods -n sso-dev -l app=cpu-intensive-app -o jsonpath='{.items[0].metadata.name}')
echo "📱 CPU intensive pod: $CPU_POD"

echo "
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
- Port-forward services:
  kubectl port-forward svc/prometheus -n monitoring 9090:9090 &
  kubectl port-forward svc/grafana -n monitoring 3001:3000 &  
  kubectl port-forward svc/alertmanager -n monitoring 9093:9093 &

📊 Expected Results:
✅ CPU usage reaches 80%+ within seconds
✅ PodHighCPUUsage alert fires after 1 minute
✅ Email notification sent (if configured)
✅ Slack message posted (if configured) 
✅ Webhook receives HTTP POST with alert data

🛑 To stop stress test:
- Visit http://localhost:30003 and click 'Stop CPU Stress'
- Or delete deployment: kubectl delete -f monitoring/cpu-intensive-app.yaml
"

# Setup port forwards in background
echo "🌐 Setting up port forwards..."
kubectl port-forward svc/prometheus -n monitoring 9090:9090 > /dev/null 2>&1 &
kubectl port-forward svc/alertmanager -n monitoring 9093:9093 > /dev/null 2>&1 &
kubectl port-forward svc/grafana -n monitoring 3001:3000 > /dev/null 2>&1 &

echo "
✅ Setup complete! 

🔗 Access URLs:
- CPU Stress App: http://localhost:30003
- Prometheus: http://localhost:9090  
- AlertManager: http://localhost:9093
- Grafana: http://localhost:3001 (admin/admin123)

Start the stress test by visiting http://localhost:30003 and clicking 'Start CPU Stress'
"