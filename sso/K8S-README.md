# 📁 File Structure - Kubernetes Deployment

```
sso/
├── k8s/                              # Kubernetes manifests
│   ├── deployment.yaml               # Main deployment, services, ingress
│   ├── autoscaling.yaml             # HPA, PDB, resource quotas
│   ├── monitoring.yaml              # Prometheus & Grafana
│   └── metrics-server.yaml          # Metrics server config
│
├── jmeter/                          # Load testing
│   ├── sso-load-test.jmx           # JMeter test plan
│   └── results/                     # Test results (generated)
│
├── scripts/                         # Utility scripts
│   ├── deploy-k8s.cmd              # Deploy to Kubernetes
│   ├── monitor-autoscaling.cmd     # Monitor HPA in real-time
│   ├── run-load-test.cmd           # Run JMeter load test
│   ├── export-docker.cmd           # Export Docker image
│   └── quick-start-k8s.cmd         # Complete setup automation
│
├── docs/
│   └── K8S-DEPLOYMENT-GUIDE.md     # Detailed documentation
│
└── ... (existing SSO application files)
```

## 🚀 Quick Start

### Prerequisites
- Docker Desktop with Kubernetes enabled, OR
- Minikube, OR
- Kind (Kubernetes in Docker)

### One-Command Setup
```powershell
.\quick-start-k8s.cmd
```

This will:
1. Build Docker image
2. Deploy to Kubernetes
3. Setup monitoring
4. Configure autoscaling

### Manual Steps

#### 1. Build & Export Docker Image
```powershell
.\export-docker.cmd
```

#### 2. Deploy to Kubernetes
```powershell
.\deploy-k8s.cmd
```

#### 3. Monitor Autoscaling
```powershell
.\monitor-autoscaling.cmd
```

#### 4. Run Load Test
```powershell
.\run-load-test.cmd
```

## 📊 Monitoring & Metrics

### Prometheus
- **URL**: http://localhost:30090
- **Metrics**: Application metrics, JVM stats, HTTP requests

### Grafana
- **URL**: http://localhost:30300
- **Login**: admin / admin123
- **Dashboards**: Import IDs 6417, 4701, 12900

## 🔥 Load Testing

### Test Scenarios

**Light Load:**
```powershell
jmeter -n -t jmeter\sso-load-test.jmx -JTHREADS=50 -JDURATION=180
```

**Medium Load:**
```powershell
jmeter -n -t jmeter\sso-load-test.jmx -JTHREADS=100 -JDURATION=300
```

**Heavy Load:**
```powershell
jmeter -n -t jmeter\sso-load-test.jmx -JTHREADS=500 -JDURATION=600
```

## 📈 Autoscaling Configuration

### Current HPA Settings:
- **Min Replicas**: 2
- **Max Replicas**: 10
- **CPU Target**: 70%
- **Memory Target**: 80%
- **Scale Up**: Immediate (0s stabilization)
- **Scale Down**: 5 minutes stabilization

### Expected Behavior:
1. **At Rest**: 2 pods, ~10-20% CPU
2. **Under Load**: Scales up to 10 pods based on CPU/memory
3. **After Load**: Gradually scales down after 5 min stabilization

## 🔍 Useful Commands

### View Resources
```powershell
# All resources in sso-app namespace
kubectl get all -n sso-app

# HPA status
kubectl get hpa -n sso-app

# Pod metrics
kubectl top pods -n sso-app
```

### Logs
```powershell
# Application logs
kubectl logs -f deployment/sso-app -n sso-app

# Keycloak logs
kubectl logs -f deployment/keycloak -n sso-app
```

### Access Application
```powershell
# Port forward
kubectl port-forward -n sso-app svc/sso-service 8080:80

# Then access: http://localhost:8080
```

### Manual Scaling
```powershell
# Scale to 5 replicas
kubectl scale deployment/sso-app --replicas=5 -n sso-app

# Re-enable autoscaling
kubectl autoscale deployment sso-app --cpu-percent=70 --min=2 --max=10 -n sso-app
```

## 🧹 Cleanup

```powershell
# Delete everything
kubectl delete namespace sso-app
kubectl delete namespace monitoring

# Or selective cleanup
kubectl delete -f k8s/deployment.yaml
kubectl delete -f k8s/autoscaling.yaml
kubectl delete -f k8s/monitoring.yaml
```

## 📚 Documentation

See [K8S-DEPLOYMENT-GUIDE.md](K8S-DEPLOYMENT-GUIDE.md) for:
- Detailed setup instructions
- Troubleshooting guide
- Metrics interpretation
- Best practices
- Advanced configurations

## 🎯 Project Goals

✅ **Containerization**: Docker image with multi-stage build
✅ **Orchestration**: Kubernetes deployment with services
✅ **Monitoring**: Prometheus + Grafana stack
✅ **Autoscaling**: HPA with CPU/Memory metrics
✅ **Load Testing**: JMeter test plans
✅ **Documentation**: Complete guides and scripts

## 📞 Support

For issues or questions:
1. Check logs: `kubectl logs -f deployment/sso-app -n sso-app`
2. Check events: `kubectl get events -n sso-app`
3. Review documentation: `K8S-DEPLOYMENT-GUIDE.md`