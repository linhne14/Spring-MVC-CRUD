# ArgoCD Installation Script for Windows PowerShell

Write-Host "🚀 Starting ArgoCD installation for SSO Application" -ForegroundColor Green

# Check if kubectl is available
try {
    kubectl version --client --output=json | Out-Null
    Write-Host "✅ kubectl found" -ForegroundColor Green
} catch {
    Write-Host "❌ kubectl is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install kubectl first: https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/" -ForegroundColor Yellow
    exit 1
}

# Create ArgoCD namespace
Write-Host "📦 Creating ArgoCD namespace..." -ForegroundColor Cyan
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Install ArgoCD
Write-Host "🔧 Installing ArgoCD..." -ForegroundColor Cyan
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
Write-Host "⏳ Waiting for ArgoCD to be ready (this may take a few minutes)..." -ForegroundColor Yellow
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Get ArgoCD admin password
Write-Host "🔑 Getting ArgoCD admin password..." -ForegroundColor Cyan
$passwordBytes = kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}"
$password = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($passwordBytes))

Write-Host ""
Write-Host "🎉 ArgoCD installed successfully!" -ForegroundColor Green
Write-Host "Admin Password: $password" -ForegroundColor Yellow
Write-Host ""

# Apply App of Apps
Write-Host "📱 Deploying SSO applications via ArgoCD..." -ForegroundColor Cyan
kubectl apply -f argocd/app-of-apps.yaml

Write-Host "✅ SSO applications deployed!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next steps:" -ForegroundColor White
Write-Host "1. Access ArgoCD UI:" -ForegroundColor White
Write-Host "   kubectl port-forward svc/argocd-server -n argocd 8080:443" -ForegroundColor Gray
Write-Host "2. Open browser: https://localhost:8080" -ForegroundColor White
Write-Host "3. Login:" -ForegroundColor White
Write-Host "   Username: admin" -ForegroundColor Gray
Write-Host "   Password: $password" -ForegroundColor Gray
Write-Host "4. Update domain in k8s-manifests/base/ingress.yaml" -ForegroundColor White
Write-Host ""

# Ask if user wants to start port-forwarding
$portForward = Read-Host "Do you want to start port-forwarding now? (y/N)"
if ($portForward -eq "y" -or $portForward -eq "Y") {
    Write-Host "🌐 Starting port-forward to ArgoCD..." -ForegroundColor Green
    Write-Host "Press Ctrl+C to stop port-forwarding" -ForegroundColor Yellow
    kubectl port-forward svc/argocd-server -n argocd 8080:443
}