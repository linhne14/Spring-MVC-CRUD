#!/usr/bin/env powershell

Write-Host "=== DEBUGGING PROMETHEUS SCRAPING ===" -ForegroundColor Green

Write-Host "`n1. Checking Prometheus targets with sso-dev namespace:" -ForegroundColor Yellow
try {
    $targetsResponse = Invoke-RestMethod -Uri "http://localhost:30000/api/v1/targets" -Method GET
    $targets = $targetsResponse.data.activeTargets
    
    Write-Host "Total targets found: $($targets.Count)" -ForegroundColor Cyan
    
    # Filter for sso-dev namespace
    $ssoDevTargets = $targets | Where-Object { 
        $_.labels -and $_.labels.kubernetes_namespace -eq "sso-dev" 
    }
    
    if ($ssoDevTargets) {
        Write-Host "Targets in sso-dev namespace:" -ForegroundColor Green
        foreach ($target in $ssoDevTargets) {
            Write-Host "- Job: $($target.labels.job) | Instance: $($target.labels.instance) | Health: $($target.health)" -ForegroundColor Magenta
        }
    } else {
        Write-Host "No targets found in sso-dev namespace" -ForegroundColor Red
        
        # Check if any pods with prometheus.io/scrape annotation exist
        Write-Host "`nChecking for pods with prometheus annotations:" -ForegroundColor Yellow
        $allTargets = $targets | Where-Object { 
            $_.discoveredLabels -and 
            $_.discoveredLabels.__meta_kubernetes_pod_annotation_prometheus_io_scrape -eq "true"
        }
        
        if ($allTargets) {
            Write-Host "Found $($allTargets.Count) pods with prometheus.io/scrape=true:" -ForegroundColor Cyan
            foreach ($target in $allTargets) {
                $ns = $target.discoveredLabels.__meta_kubernetes_namespace
                $pod = $target.discoveredLabels.__meta_kubernetes_pod_name
                Write-Host "- Namespace: $ns | Pod: $pod | Health: $($target.health)" -ForegroundColor Magenta
            }
        } else {
            Write-Host "No pods found with prometheus.io/scrape=true annotation" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "Error checking targets: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n2. Direct metrics test from CPU stress app:" -ForegroundColor Yellow
try {
    $metrics = Invoke-WebRequest -Uri "http://localhost:30003/metrics" -UseBasicParsing
    Write-Host "CPU stress app metrics:" -ForegroundColor Cyan
    Write-Host $metrics.Content -ForegroundColor White
} catch {
    Write-Host "Error accessing CPU stress app metrics: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n3. Checking if Prometheus can access CPU stress app via service:" -ForegroundColor Yellow
try {
    # Get CPU stress app service IP
    $service = kubectl get service -n sso-dev cpu-intensive-service -o jsonpath='{.spec.clusterIP}' 2>$null
    if ($service) {
        Write-Host "CPU stress service cluster IP: $service" -ForegroundColor Cyan
        
        # Test if we can reach it from Prometheus perspective
        $prometheusTestUrl = "http://${service}:80/metrics"
        Write-Host "Testing URL that Prometheus should use: $prometheusTestUrl" -ForegroundColor Cyan
        
        # We can't test this directly from outside cluster, but we can check service endpoints
        kubectl get endpoints -n sso-dev cpu-intensive-service
    } else {
        Write-Host "Could not get service cluster IP" -ForegroundColor Red
    }
} catch {
    Write-Host "Error checking service: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== DEBUG COMPLETE ===" -ForegroundColor Green