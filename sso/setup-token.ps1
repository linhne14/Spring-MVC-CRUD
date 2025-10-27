# GitHub Token Setup Helper
# Hướng dẫn setup và test GitHub Token

Write-Host "🔑 GitHub Token Setup Helper" -ForegroundColor Cyan
Write-Host "══════════════════════════════════════════" -ForegroundColor Gray

# Check if token exists
if ($env:GITHUB_TOKEN) {
    Write-Host "✅ GitHub Token found in environment!" -ForegroundColor Green
    Write-Host "Token: $($env:GITHUB_TOKEN.Substring(0,4))..." -ForegroundColor Gray
} else {
    Write-Host "❌ No GitHub Token found!" -ForegroundColor Red
    Write-Host "`n📋 Steps to create token:" -ForegroundColor Yellow
    Write-Host "1. Go to: https://github.com/settings/tokens/new" -ForegroundColor White
    Write-Host "2. Note: 'SSO-Application-Monitoring'" -ForegroundColor White
    Write-Host "3. Scopes: repo, actions, packages:read, workflow" -ForegroundColor White
    Write-Host "4. Click 'Generate token'" -ForegroundColor White
    Write-Host "5. Copy the token (starts with ghp_)" -ForegroundColor White
    
    Write-Host "`n💡 How to set token:" -ForegroundColor Yellow
    Write-Host "Temporary (current session):" -ForegroundColor Gray
    Write-Host '  $env:GITHUB_TOKEN = "ghp_your_token_here"' -ForegroundColor White
    
    Write-Host "`nPermanent (user profile):" -ForegroundColor Gray
    Write-Host '1. Run: notepad $PROFILE' -ForegroundColor White
    Write-Host '2. Add: $env:GITHUB_TOKEN = "ghp_your_token_here"' -ForegroundColor White
    Write-Host "3. Restart PowerShell" -ForegroundColor White
    
    $token = Read-Host "`nPaste your GitHub token here (or Enter to skip)"
    if ($token) {
        $env:GITHUB_TOKEN = $token
        Write-Host "✅ Token set for current session!" -ForegroundColor Green
    }
}

# Test token if available
if ($env:GITHUB_TOKEN) {
    Write-Host "`n🧪 Testing token..." -ForegroundColor Yellow
    try {
        $headers = @{
            "Authorization" = "Bearer $env:GITHUB_TOKEN"
            "User-Agent" = "PowerShell-Test"
        }
        $response = Invoke-RestMethod -Uri "https://api.github.com/user" -Headers $headers
        Write-Host "✅ Token works! Authenticated as: $($response.login)" -ForegroundColor Green
        
        # Test repository access
        $repoResponse = Invoke-RestMethod -Uri "https://api.github.com/repos/linhne14/Spring-MVC-CRUD" -Headers $headers
        Write-Host "✅ Repository access confirmed!" -ForegroundColor Green
        
        Write-Host "`n🚀 Ready to monitor! Run:" -ForegroundColor Cyan
        Write-Host "  ./github-monitor.ps1" -ForegroundColor White
        
    } catch {
        Write-Host "❌ Token test failed: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Please check your token and try again." -ForegroundColor Yellow
    }
}

Write-Host "`n📚 Available commands:" -ForegroundColor Blue
Write-Host "  ./github-monitor.ps1           - Start monitoring with token" -ForegroundColor White
Write-Host "  ./simple-monitor.ps1           - Basic monitoring (no token)" -ForegroundColor White
Write-Host "  ./setup-token.ps1              - This script" -ForegroundColor White