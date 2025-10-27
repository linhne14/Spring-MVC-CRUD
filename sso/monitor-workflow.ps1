# Monitor GitHub Actions Workflow Status
# Real-time monitoring script for GitHub Actions

Write-Host "🔍 Monitoring GitHub Actions Workflows..." -ForegroundColor Cyan
Write-Host "Repository: linhne14/Spring-MVC-CRUD" -ForegroundColor White
Write-Host "Press Ctrl+C to stop monitoring`n" -ForegroundColor Gray

# GitHub API endpoint
$repo = "linhne14/Spring-MVC-CRUD"
$apiUrl = "https://api.github.com/repos/$repo/actions/runs"

# Function to get workflow status
function Get-WorkflowStatus {
    try {
        $response = Invoke-RestMethod -Uri $apiUrl -Headers @{
            "Accept" = "application/vnd.github.v3+json"
            "User-Agent" = "PowerShell-Monitor"
        }
        return $response.workflow_runs | Select-Object -First 5
    } catch {
        Write-Host "❌ Error fetching workflow data: $_" -ForegroundColor Red
        return $null
    }
}

# Function to display status
function Show-WorkflowStatus($runs) {
    Clear-Host
    Write-Host "🔄 GitHub Actions Status - $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Gray
    
    foreach ($run in $runs) {
        $status = $run.status
        $conclusion = $run.conclusion
        $name = $run.name
        $branch = $run.head_branch
        $commit = $run.head_sha.Substring(0,7)
        $createdAt = [DateTime]::Parse($run.created_at).ToString("MM/dd HH:mm")
        
        # Status emoji and color
        $emoji = switch ($status) {
            "in_progress" { "🔄" }
            "completed" { 
                switch ($conclusion) {
                    "success" { "✅" }
                    "failure" { "❌" }
                    "cancelled" { "🚫" }
                    default { "⚪" }
                }
            }
            "queued" { "⏳" }
            default { "⚪" }
        }
        
        $color = switch ($status) {
            "in_progress" { "Yellow" }
            "completed" { 
                switch ($conclusion) {
                    "success" { "Green" }
                    "failure" { "Red" }
                    "cancelled" { "Gray" }
                    default { "White" }
                }
            }
            "queued" { "Cyan" }
            default { "White" }
        }
        
        Write-Host "$emoji " -NoNewline
        Write-Host "$name " -ForegroundColor $color -NoNewline
        Write-Host "($branch)" -ForegroundColor Gray -NoNewline
        Write-Host " - $commit - $createdAt" -ForegroundColor DarkGray
        
        if ($status -eq "in_progress") {
            Write-Host "   🔄 Running..." -ForegroundColor Yellow
        } elseif ($status -eq "completed") {
            Write-Host "   ✓ $conclusion" -ForegroundColor $color
        }
    }
    
    Write-Host "`n═══════════════════════════════════════════════════════════════" -ForegroundColor Gray
    Write-Host "🌐 View Details: https://github.com/$repo/actions" -ForegroundColor Blue
    Write-Host "📦 Packages: https://github.com/$repo/pkgs/container/spring-mvc-crud" -ForegroundColor Blue
}

# Main monitoring loop
try {
    while ($true) {
        $runs = Get-WorkflowStatus
        if ($runs) {
            Show-WorkflowStatus $runs
            
            # Check if any workflows are still running
            $runningWorkflows = $runs | Where-Object { $_.status -eq "in_progress" -or $_.status -eq "queued" }
            if ($runningWorkflows.Count -eq 0) {
                Write-Host "`n🎉 All workflows completed!" -ForegroundColor Green
                break
            }
        }
        
        Start-Sleep -Seconds 10
    }
} catch {
    Write-Host "`n👋 Monitoring stopped." -ForegroundColor Yellow
}