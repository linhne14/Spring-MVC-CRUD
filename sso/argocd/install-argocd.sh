#!/bin/bash

# ArgoCD Installation and Setup Script for SSO Application

echo "🚀 Starting ArgoCD installation and SSO application deployment"

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed. Please install kubectl first."
    exit 1
fi

# Create ArgoCD namespace
echo "📦 Creating ArgoCD namespace..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Install ArgoCD
echo "🔧 Installing ArgoCD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
echo "⏳ Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Get ArgoCD admin password
echo "🔑 Getting ArgoCD admin password..."
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "ArgoCD Admin Password: $ARGOCD_PASSWORD"

# Port forward ArgoCD server (optional)
echo "🌐 You can access ArgoCD UI by running:"
echo "kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "Then visit: https://localhost:8080"
echo "Username: admin"
echo "Password: $ARGOCD_PASSWORD"

# Apply App of Apps
echo "📱 Deploying SSO applications via ArgoCD..."
kubectl apply -f argocd/app-of-apps.yaml

echo "✅ ArgoCD installation and SSO application deployment completed!"
echo ""
echo "📋 Next steps:"
echo "1. Access ArgoCD UI: kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "2. Login with admin/$ARGOCD_PASSWORD"
echo "3. Check your applications status in ArgoCD dashboard"
echo "4. Update ingress domain in k8s-manifests/base/ingress.yaml to your actual domain"
echo "5. Configure your DNS to point to your ingress controller"