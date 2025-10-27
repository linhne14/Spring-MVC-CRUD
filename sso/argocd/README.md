# SSO Application CI/CD với GitHub Actions và ArgoCD

Dự án này triển khai complete CI/CD pipeline cho ứng dụng SSO Spring Boot sử dụng GitHub Actions (CI) và ArgoCD (CD).

## 🏗️ Kiến trúc CI/CD

### CI Pipeline (GitHub Actions)
- **Build & Test**: Tự động build và test code khi có push/PR
- **Docker Build**: Tạo Docker image với multi-platform support
- **Registry Push**: Đẩy image lên GitHub Container Registry
- **Security**: Scan vulnerabilities và dependencies

### CD Pipeline (ArgoCD)
- **GitOps**: Tự động deploy dựa trên Git repository
- **Multi-Environment**: Support dev, staging, prod environments
- **Auto-Sync**: Tự động đồng bộ khi có thay đổi
- **Self-Healing**: Tự động khôi phục khi có sự cố

## 📁 Cấu trúc dự án

```
sso/
├── .github/workflows/          # GitHub Actions workflows
│   ├── build-push.yml         # CI/CD Pipeline chính
│   └── test.yml              # Unit tests
├── argocd/                   # ArgoCD configurations
│   ├── applications/         # Application definitions
│   │   ├── sso-dev.yaml     # Dev environment
│   │   └── sso-prod.yaml    # Prod environment
│   ├── app-of-apps.yaml     # App of Apps pattern
│   └── install-argocd.sh    # Installation script
├── k8s-manifests/           # Kubernetes manifests
│   ├── base/               # Base configurations
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── ingress.yaml
│   │   └── kustomization.yaml
│   └── overlays/          # Environment-specific configs
│       ├── dev/          # Development environment
│       └── prod/         # Production environment
└── src/                  # Application source code
```

## 🚀 Cài đặt và triển khai

### 1. Cài đặt ArgoCD

```bash
# Chạy script cài đặt
chmod +x argocd/install-argocd.sh
./argocd/install-argocd.sh
```

### 2. Truy cập ArgoCD UI

```bash
# Port forward để truy cập ArgoCD
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Truy cập: https://localhost:8080
- Username: `admin`
- Password: Xem trong output của script cài đặt

### 3. Cấu hình domain (Production)

Cập nhật file `k8s-manifests/base/ingress.yaml`:
```yaml
spec:
  tls:
  - hosts:
    - your-domain.com  # Thay đổi domain của bạn
    secretName: sso-tls-secret
  rules:
  - host: your-domain.com  # Thay đổi domain của bạn
```

## 🔄 Workflow CI/CD

### CI Process (GitHub Actions)
1. **Trigger**: Push code hoặc tạo Pull Request
2. **Test**: Chạy unit tests và integration tests
3. **Build**: Build Docker image với tag phù hợp
4. **Scan**: Security scan cho dependencies và container
5. **Push**: Đẩy image lên GitHub Container Registry

### CD Process (ArgoCD)
1. **Detect**: ArgoCD phát hiện thay đổi trong Git repo
2. **Sync**: Tự động sync configuration với Kubernetes
3. **Deploy**: Deploy application lên môi trường tương ứng
4. **Monitor**: Giám sát health và status của application

## 🌍 Environments

### Development
- **Namespace**: `sso-dev`
- **Replicas**: 1
- **Resources**: Minimal (256Mi RAM, 100m CPU)
- **Image Tag**: `dev`

### Production
- **Namespace**: `sso-prod`
- **Replicas**: 3
- **Resources**: High (1Gi RAM, 500m CPU)
- **Image Tag**: `latest`

## 📊 Monitoring và Troubleshooting

### ArgoCD Dashboard
- Xem status của tất cả applications
- Sync history và events
- Resource health và status

### Kubectl Commands
```bash
# Xem pods trong dev environment
kubectl get pods -n sso-dev

# Xem logs của application
kubectl logs -f deployment/dev-sso-app -n sso-dev

# Xem ArgoCD applications
kubectl get applications -n argocd
```

### GitHub Actions
- Xem build logs tại GitHub Actions tab
- Check container registry tại Packages section
- Monitor security alerts

## 🔧 Customization

### Thêm môi trường mới
1. Tạo overlay mới trong `k8s-manifests/overlays/`
2. Tạo ArgoCD application trong `argocd/applications/`
3. Commit và push changes

### Cập nhật cấu hình
1. Chỉnh sửa files trong `k8s-manifests/`
2. Commit changes
3. ArgoCD sẽ tự động detect và sync

## 🔒 Security

- **GHCR Authentication**: Sử dụng GitHub token
- **TLS**: Automatic HTTPS với cert-manager
- **RBAC**: Kubernetes Role-Based Access Control
- **Security Scanning**: Dependency và container scanning

## 📝 Notes

- GitHub Container Registry: `ghcr.io/linhne14/spring-mvc-crud`
- ArgoCD sử dụng App of Apps pattern để quản lý multiple applications
- Kustomize được sử dụng để manage environment-specific configurations
- Auto-sync và self-healing được enable cho production environments