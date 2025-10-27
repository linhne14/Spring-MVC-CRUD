# Monitor GitHub Actions - Simple Version
Write-Host "Monitoring GitHub Actions..." -ForegroundColor Green

$repo = "linhne14/Spring-MVC-CRUD"
$apiUrl = "https://api.github.com/repos/$repo/actions/runs"

while ($true) {
    try {
        $response = Invoke-RestMethod -Uri $apiUrl
        $latestRuns = $response.workflow_runs | Select-Object -First 3
        
        Clear-Host
        Write-Host "GitHub Actions Status - $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Gray
        
        foreach ($run in $latestRuns) {
            $status = $run.status
            $name = $run.name
            $branch = $run.head_branch
            $commit = $run.head_sha.Substring(0,7)
            
            if ($status -eq "in_progress") {
                Write-Host "RUNNING: $name ($branch) - $commit" -ForegroundColor Yellow
            } elseif ($status -eq "completed") {
                if ($run.conclusion -eq "success") {
                    Write-Host "SUCCESS: $name ($branch) - $commit" -ForegroundColor Green
                } else {
                    Write-Host "FAILED: $name ($branch) - $commit" -ForegroundColor Red
                }
            } else {
                Write-Host "QUEUED: $name ($branch) - $commit" -ForegroundColor Cyan
            }
        }
        
        Write-Host "`nView on GitHub: https://github.com/$repo/actions" -ForegroundColor Blue
        
        # Check if any are still running
        $running = $latestRuns | Where-Object { $_.status -eq "in_progress" }
        if ($running.Count -eq 0) {
            Write-Host "`nAll workflows completed!" -ForegroundColor Green
            break
        }
        
    } catch {
        Write-Host "Error: $_" -ForegroundColor Red
    }
    
    Start-Sleep -Seconds 15
}