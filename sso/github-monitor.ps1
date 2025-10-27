# GitHub Token Setup and Monitoring Script
# Setup your GitHub Personal Access Token for enhanced monitoring

param(
    [string]$Token = $env:GITHUB_TOKEN
)

if (-not $Token) {
    Write-Host "🔑 GitHub Token Setup Required" -ForegroundColor Yellow
    Write-Host "1. Go to: https://github.com/settings/tokens/new" -ForegroundColor Cyan
    Write-Host "2. Create token with scopes: repo, actions, packages:read, workflow" -ForegroundColor Cyan
    Write-Host "3. Run this script with: ./github-monitor.ps1 -Token YOUR_TOKEN" -ForegroundColor Cyan
    Write-Host "   Or set environment variable: `$env:GITHUB_TOKEN = 'YOUR_TOKEN'" -ForegroundColor Cyan
    exit 1
}

# GitHub API Configuration
$repo = "linhne14/Spring-MVC-CRUD"
$headers = @{
    "Authorization" = "Bearer $Token"
    "Accept" = "application/vnd.github.v3+json"
    "User-Agent" = "PowerShell-GitHub-Monitor"
}

# API Endpoints
$workflowsUrl = "https://api.github.com/repos/$repo/actions/runs"
$packagesUrl = "https://api.github.com/users/linhne14/packages/container/spring-mvc-crud/versions"

Write-Host "🔍 GitHub Actions Monitor with Token Authentication" -ForegroundColor Green
Write-Host "Repository: $repo" -ForegroundColor White
Write-Host "Press Ctrl+C to stop monitoring`n" -ForegroundColor Gray

function Get-WorkflowRuns {
    try {
        $response = Invoke-RestMethod -Uri $workflowsUrl -Headers $headers
        return $response.workflow_runs | Select-Object -First 5
    } catch {
        Write-Host "❌ Error fetching workflows: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

function Get-PackageVersions {
    try {
        $response = Invoke-RestMethod -Uri $packagesUrl -Headers $headers
        return $response | Select-Object -First 3
    } catch {
        Write-Host "❌ Error fetching packages: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

function Show-DetailedStatus {
    param($runs, $packages)
    
    Clear-Host
    Write-Host "🚀 GitHub Actions & Container Registry Status" -ForegroundColor Cyan
    Write-Host "Updated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
    
    # Workflow Status
    Write-Host "`n📊 Workflow Runs:" -ForegroundColor Yellow
    foreach ($run in $runs) {
        $emoji = switch ($run.status) {
            "in_progress" { "🔄" }
            "completed" { 
                switch ($run.conclusion) {
                    "success" { "✅" }
                    "failure" { "❌" }
                    "cancelled" { "🚫" }
                    default { "⚪" }
                }
            }
            "queued" { "⏳" }
            default { "⚪" }
        }
        
        $duration = if ($run.updated_at) {
            $start = [DateTime]::Parse($run.created_at)
            $end = [DateTime]::Parse($run.updated_at)
            $diff = $end - $start
            "$($diff.Minutes)m $($diff.Seconds)s"
        } else { "Running..." }
        
        Write-Host "  $emoji $($run.name)" -NoNewline -ForegroundColor White
        Write-Host " [$($run.head_branch)]" -NoNewline -ForegroundColor Cyan
        Write-Host " - $($run.head_sha.Substring(0,7))" -NoNewline -ForegroundColor Gray
        Write-Host " ($duration)" -ForegroundColor DarkGray
        
        if ($run.status -eq "in_progress") {
            Write-Host "    🔗 Live: $($run.html_url)" -ForegroundColor Blue
        }
    }
    
    # Package Status
    if ($packages) {
        Write-Host "`n📦 Container Images:" -ForegroundColor Yellow
        foreach ($pkg in $packages) {
            $created = [DateTime]::Parse($pkg.created_at).ToString("MM/dd HH:mm")
            $size = [math]::Round($pkg.metadata.container.size / 1MB, 1)
            Write-Host "  🐳 Tag: $($pkg.metadata.container.tags -join ', ')" -NoNewline -ForegroundColor White
            Write-Host " - ${size}MB" -NoNewline -ForegroundColor Gray
            Write-Host " ($created)" -ForegroundColor DarkGray
        }
        
        Write-Host "`n📥 Pull Command:" -ForegroundColor Green
        Write-Host "  docker pull ghcr.io/linhne14/spring-mvc-crud:latest" -ForegroundColor White
    }
    
    Write-Host "`n═══════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
    Write-Host "🌐 Actions: https://github.com/$repo/actions" -ForegroundColor Blue
    Write-Host "📦 Packages: https://github.com/$repo/pkgs/container/spring-mvc-crud" -ForegroundColor Blue
}

# Main monitoring loop
try {
    while ($true) {
        $runs = Get-WorkflowRuns
        $packages = Get-PackageVersions
        
        if ($runs) {
            Show-DetailedStatus $runs $packages
            
            # Check if workflows are still running
            $activeRuns = $runs | Where-Object { $_.status -eq "in_progress" -or $_.status -eq "queued" }
            if ($activeRuns.Count -eq 0) {
                Write-Host "`n🎉 All workflows completed!" -ForegroundColor Green
                Write-Host "Final status summary:" -ForegroundColor Yellow
                foreach ($run in $runs | Select-Object -First 2) {
                    $status = if ($run.conclusion -eq "success") { "✅ SUCCESS" } else { "❌ $($run.conclusion.ToUpper())" }
                    Write-Host "  $status - $($run.name)" -ForegroundColor $(if ($run.conclusion -eq "success") { "Green" } else { "Red" })
                }
                break
            }
        }
        
        Start-Sleep -Seconds 20
    }
} catch [System.Management.Automation.RuntimeException] {
    Write-Host "`n👋 Monitoring stopped by user." -ForegroundColor Yellow
} catch {
    Write-Host "`n❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}