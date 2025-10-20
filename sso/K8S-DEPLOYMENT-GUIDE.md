# 🚀 Kubernetes Deployment & Load Testing Guide

## 📋 Mục Lục
1. [Yêu Cầu Hệ Thống](#yêu-cầu-hệ-thống)
2. [Cài Đặt Kubernetes](#cài-đặt-kubernetes)
3. [Deploy Ứng Dụng](#deploy-ứng-dụng)
4. [Monitoring với Prometheus & Grafana](#monitoring)
5. [Load Testing với JMeter](#load-testing)
6. [Đánh Giá Autoscaling](#đánh-giá-autoscaling)

---

## 🔧 Yêu Cầu Hệ Thống

### Software Requirements:
- **Docker Desktop** (với Kubernetes enabled) HOẶC
- **Minikube** HOẶC  
- **Kind** (Kubernetes in Docker)
- **kubectl** - Kubernetes CLI
- **Apache JMeter** - Load testing tool
- **Git** - Version control

### Hardware Requirements:
- **RAM**: Tối thiểu 8GB (khuyến nghị 16GB)
- **CPU**: 4 cores trở lên
- **Disk**: 20GB free space

---

## 🎯 Cài Đặt Kubernetes

### Option 1: Docker Desktop (Khuyến nghị cho Windows)

1. **Cài đặt Docker Desktop**:
   - Download: https://www.docker.com/products/docker-desktop
   - Cài đặt và khởi động

2. **Enable Kubernetes**:
   - Settings → Kubernetes → Enable Kubernetes
   - Apply & Restart

3. **Verify**:
   ```powershell
   kubectl cluster-info
   kubectl get nodes
   ```

### Option 2: Minikube

1. **Cài đặt Minikube**:
   ```powershell
   choco install minikube
   ```

2. **Start cluster**:
   ```powershell
   minikube start --cpus=4 --memory=8192
   minikube addons enable metrics-server
   minikube addons enable ingress
   ```

3. **Verify**:
   ```powershell
   kubectl cluster-info
   minikube status
   ```

### Option 3: Kind (Kubernetes in Docker)

1. **Cài đặt Kind**:
   ```powershell
   choco install kind
   ```

2. **Create cluster**:
   ```powershell
   kind create cluster --name sso-cluster
   ```

---

## 🚀 Deploy Ứng Dụng

### Bước 1: Build Docker Image

```powershell
# Build image
docker build -t sso-application:latest .

# Verify
docker images | findstr sso-application
```

### Bước 2: Load Image vào Cluster

**For Minikube:**
```powershell
minikube image load sso-application:latest
```

**For Kind:**
```powershell
kind load docker-image sso-application:latest --name sso-cluster
```

**For Docker Desktop:** Không cần load, image đã available

### Bước 3: Deploy toàn bộ stack

```powershell
.\deploy-k8s.cmd
```

Hoặc thực hiện manual:

```powershell
# 1. Install metrics-server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# 2. Deploy application
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/autoscaling.yaml

# 3. Deploy monitoring
kubectl apply -f k8s/monitoring.yaml

# 4. Wait for deployments
kubectl wait --for=condition=available --timeout=300s deployment/sso-app -n sso-app
kubectl wait --for=condition=available --timeout=300s deployment/keycloak -n sso-app
```

### Bước 4: Verify Deployment

```powershell
# Check pods
kubectl get pods -n sso-app

# Check services
kubectl get svc -n sso-app

# Check HPA
kubectl get hpa -n sso-app

# Check logs
kubectl logs -f deployment/sso-app -n sso-app
```

### Bước 5: Access Application

**Port Forward:**
```powershell
kubectl port-forward -n sso-app svc/sso-service 8080:80
```

Access at: http://localhost:8080

**Via Ingress (if configured):**
```powershell
# Add to hosts file (C:\Windows\System32\drivers\etc\hosts)
# Get cluster IP
kubectl get nodes -o wide

# Add entry:
# <NODE-IP> sso.local keycloak.local
```

---

## 📊 Monitoring

### Access Prometheus

```powershell
# Via NodePort
http://localhost:30090

# Or via port-forward
kubectl port-forward -n monitoring svc/prometheus-service 9090:9090
```

**Useful Queries:**
```promql
# Request rate
rate(http_server_requests_seconds_count[5m])

# CPU usage
container_cpu_usage_seconds_total

# Memory usage
container_memory_usage_bytes

# Pod count
kube_deployment_status_replicas{deployment="sso-app"}
```

### Access Grafana

```powershell
# Via NodePort
http://localhost:30300

# Or via port-forward
kubectl port-forward -n monitoring svc/grafana-service 3000:3000
```

**Login:**
- Username: `admin`
- Password: `admin123`

**Setup Prometheus Data Source:**
1. Configuration → Data Sources → Add data source
2. Select Prometheus
3. URL: `http://prometheus-service:9090`
4. Save & Test

**Import Dashboards:**
- Kubernetes Cluster Monitoring: Dashboard ID `6417`
- JVM Micrometer: Dashboard ID `4701`
- Spring Boot Statistics: Dashboard ID `12900`

### Monitor Autoscaling Real-time

```powershell
.\monitor-autoscaling.cmd
```

Hoặc manual:

```powershell
# Watch HPA
kubectl get hpa -n sso-app -w

# Watch pods
kubectl get pods -n sso-app -w

# Top pods (resource usage)
kubectl top pods -n sso-app
```

---

## 🔥 Load Testing với JMeter

### Bước 1: Cài đặt JMeter

**Download:**
- https://jmeter.apache.org/download_jmeter.cgi
- Extract và add `bin` folder vào PATH

**Verify:**
```powershell
jmeter --version
```

### Bước 2: Chạy Load Test

**Via Script:**
```powershell
.\run-load-test.cmd
```

**Manual:**
```powershell
# CLI Mode
jmeter -n -t jmeter\sso-load-test.jmx -l results.jtl -e -o html-report

# GUI Mode (for editing)
jmeter -t jmeter\sso-load-test.jmx
```

### Bước 3: Test Scenarios

**Light Load Test:**
```powershell
jmeter -n -t jmeter\sso-load-test.jmx ^
    -JTHREADS=50 ^
    -JRAMP_UP=30 ^
    -JDURATION=180 ^
    -l results-light.jtl
```

**Medium Load Test:**
```powershell
jmeter -n -t jmeter\sso-load-test.jmx ^
    -JTHREADS=100 ^
    -JRAMP_UP=60 ^
    -JDURATION=300 ^
    -l results-medium.jtl
```

**Heavy Load Test:**
```powershell
jmeter -n -t jmeter\sso-load-test.jmx ^
    -JTHREADS=500 ^
    -JRAMP_UP=120 ^
    -JDURATION=600 ^
    -l results-heavy.jtl
```

**Stress Test:**
```powershell
jmeter -n -t jmeter\sso-load-test.jmx ^
    -JTHREADS=1000 ^
    -JRAMP_UP=180 ^
    -JDURATION=900 ^
    -l results-stress.jtl
```

---

## 📈 Đánh Giá Autoscaling

### Kịch Bản Test

#### 1. **Baseline Test** (Không Load)
```powershell
# Observe initial state
kubectl get hpa -n sso-app
kubectl top pods -n sso-app

# Expected: 2 replicas, low CPU/memory
```

#### 2. **Scale Up Test** (Tăng Load)
```powershell
# Terminal 1: Monitor
.\monitor-autoscaling.cmd

# Terminal 2: Run load test
jmeter -n -t jmeter\sso-load-test.jmx -JTHREADS=200 -JDURATION=600

# Observe:
# - CPU usage increases
# - HPA triggers scaling
# - New pods are created
# - Load is distributed
```

#### 3. **Scale Down Test** (Giảm Load)
```powershell
# After load test completes
# Observe:
# - CPU usage decreases
# - HPA waits for stabilization (5 minutes)
# - Pods gradually scale down to minimum
```

#### 4. **Spike Test** (Load đột ngột)
```powershell
# Sudden load increase
jmeter -n -t jmeter\sso-load-test.jmx -JTHREADS=500 -JRAMP_UP=10 -JDURATION=300

# Observe:
# - How quickly HPA responds
# - Pod startup time
# - Request success rate during scaling
```

### Metrics để Đánh Giá

1. **Scaling Speed:**
   - Time from trigger to new pods ready
   - Time from scale-up decision to pods receiving traffic

2. **Resource Utilization:**
   - CPU usage before/during/after scaling
   - Memory usage patterns
   - Network throughput

3. **Application Performance:**
   - Response time percentiles (P50, P95, P99)
   - Error rate during scaling
   - Throughput (requests/second)

4. **HPA Behavior:**
   - Scale-up threshold accuracy
   - Scale-down stability
   - Oscillation (rapid scale up/down)

### Commands để Thu Thập Metrics

```powershell
# HPA events
kubectl describe hpa sso-app-hpa -n sso-app

# Pod events
kubectl get events -n sso-app --sort-by='.lastTimestamp'

# Resource metrics
kubectl top pods -n sso-app

# Deployment history
kubectl rollout history deployment/sso-app -n sso-app

# Export metrics
kubectl get hpa sso-app-hpa -n sso-app -o yaml > hpa-status.yaml
```

---

## 📊 Kết Quả Mẫu

### Expected Autoscaling Behavior:

| Metric | Before Load | During Load | After Load |
|--------|-------------|-------------|------------|
| Replicas | 2 | 6-10 | 2 |
| CPU Usage | 10-20% | 70-80% | 10-20% |
| Memory | 256Mi | 400Mi | 256Mi |
| Response Time | <100ms | <300ms | <100ms |
| Throughput | Low | High | Low |

### HPA Configuration:

```yaml
minReplicas: 2
maxReplicas: 10
targetCPUUtilization: 70%
targetMemoryUtilization: 80%
scaleUpStabilization: 0s (immediate)
scaleDownStabilization: 300s (5 min)
```

---

## 🐛 Troubleshooting

### Pods Not Starting
```powershell
kubectl describe pod <pod-name> -n sso-app
kubectl logs <pod-name> -n sso-app
```

### HPA Not Scaling
```powershell
# Check metrics-server
kubectl get deployment metrics-server -n kube-system
kubectl top nodes
kubectl top pods -n sso-app

# Check HPA status
kubectl describe hpa sso-app-hpa -n sso-app
```

### Load Test Failing
```powershell
# Check service accessibility
kubectl get svc -n sso-app
kubectl port-forward -n sso-app svc/sso-service 8080:80

# Test manually
curl http://localhost:8080
```

---

## 🧹 Cleanup

```powershell
# Delete all resources
kubectl delete namespace sso-app
kubectl delete namespace monitoring

# Or delete specific resources
kubectl delete -f k8s/deployment.yaml
kubectl delete -f k8s/autoscaling.yaml
kubectl delete -f k8s/monitoring.yaml
```

---

## 📚 Tài Liệu Tham Khảo

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Horizontal Pod Autoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
- [Prometheus](https://prometheus.io/docs/)
- [Grafana](https://grafana.com/docs/)
- [Apache JMeter](https://jmeter.apache.org/usermanual/)

---

## 🎯 Checklist Hoàn Thành

- [ ] Kubernetes cluster đã setup
- [ ] Docker image đã build
- [ ] Application deployed thành công
- [ ] Metrics-server hoạt động
- [ ] HPA configured
- [ ] Prometheus & Grafana accessible
- [ ] JMeter installed
- [ ] Load test chạy thành công
- [ ] Autoscaling observed và documented
- [ ] Metrics collected
- [ ] Report completed