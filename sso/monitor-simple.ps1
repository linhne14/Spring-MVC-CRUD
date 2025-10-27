# Simple GitHub Actions Monitor with Token
Write-Host "GitHub Actions Monitor - Real-time Status" -ForegroundColor Cyan

$repo = "linhne14/Spring-MVC-CRUD"
$token = $env:GITHUB_TOKEN
$headers = @{
    "Authorization" = "Bearer $token"
    "Accept" = "application/vnd.github.v3+json"
}

function Get-Workflows {
    try {
        $url = "https://api.github.com/repos/$repo/actions/runs"
        $response = Invoke-RestMethod -Uri $url -Headers $headers
        return $response.workflow_runs | Select-Object -First 5
    } catch {
        Write-Host "Error: $_" -ForegroundColor Red
        return $null
    }
}

Write-Host "Monitoring workflows for: $repo" -ForegroundColor White
Write-Host "Press Ctrl+C to stop" -ForegroundColor Gray
Write-Host ""

while ($true) {
    $runs = Get-Workflows
    
    if ($runs) {
        Clear-Host
        Write-Host "GitHub Actions Status - $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Cyan
        Write-Host "===============================================" -ForegroundColor Gray
        
        foreach ($run in $runs) {
            $emoji = switch ($run.status) {
                "in_progress" { "RUNNING" }
                "completed" {
                    switch ($run.conclusion) {
                        "success" { "SUCCESS" }
                        "failure" { "FAILED" }
                        default { "DONE" }
                    }
                }
                default { "WAITING" }
            }
            
            $color = switch ($run.status) {
                "in_progress" { "Yellow" }
                "completed" {
                    switch ($run.conclusion) {
                        "success" { "Green" }
                        "failure" { "Red" }
                        default { "White" }
                    }
                }
                default { "Cyan" }
            }
            
            Write-Host "$emoji : $($run.name)" -ForegroundColor $color
            Write-Host "   Branch: $($run.head_branch) | Commit: $($run.head_sha.Substring(0,7))" -ForegroundColor Gray
            
            if ($run.status -eq "in_progress") {
                Write-Host "   View live: $($run.html_url)" -ForegroundColor Blue
            }
        }
        
        Write-Host ""
        Write-Host "GitHub Actions: https://github.com/$repo/actions" -ForegroundColor Blue
        Write-Host "Container Registry: https://github.com/$repo/pkgs/container/spring-mvc-crud" -ForegroundColor Blue
        
        # Check if any workflows are running
        $running = $runs | Where-Object { $_.status -eq "in_progress" }
        if ($running.Count -eq 0) {
            Write-Host ""
            Write-Host "All workflows completed!" -ForegroundColor Green
            break
        }
    }
    
    Start-Sleep -Seconds 15
}