# YAML Syntax Validator for GitHub Actions
Write-Host "Validating GitHub Actions YAML syntax..." -ForegroundColor Cyan

$workflows = Get-ChildItem -Path ".github\workflows\*.yml"

foreach ($workflow in $workflows) {
    Write-Host "`nValidating: $($workflow.Name)" -ForegroundColor Yellow
    
    try {
        # Basic YAML structure check
        $content = Get-Content $workflow.FullName -Raw
        
        # Check for required fields
        $checks = @{
            "name:" = "Workflow name"
            "on:" = "Trigger events" 
            "jobs:" = "Jobs definition"
            "runs-on:" = "Runner specification"
            "steps:" = "Steps definition"
        }
        
        $passed = 0
        $total = $checks.Count
        
        foreach ($check in $checks.GetEnumerator()) {
            if ($content -match $check.Key) {
                Write-Host "  ✅ $($check.Value)" -ForegroundColor Green
                $passed++
            } else {
                Write-Host "  ❌ Missing: $($check.Value)" -ForegroundColor Red
            }
        }
        
        # Check for common syntax issues
        $issues = @()
        
        if ($content -match "\t") {
            $issues += "Contains tabs (use spaces for YAML)"
        }
        
        if ($content -match "^\s*-\s*$") {
            $issues += "Empty list items detected"
        }
        
        if ($issues.Count -gt 0) {
            Write-Host "  ⚠️  Potential issues:" -ForegroundColor Yellow
            foreach ($issue in $issues) {
                Write-Host "    - $issue" -ForegroundColor Yellow
            }
        }
        
        Write-Host "  📊 Score: $passed/$total" -ForegroundColor Cyan
        
    } catch {
        Write-Host "  ❌ Error reading file: $_" -ForegroundColor Red
    }
}

Write-Host "`n🔗 Online YAML validator: https://yamlchecker.com/" -ForegroundColor Blue
Write-Host "🔗 GitHub Actions syntax: https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions" -ForegroundColor Blue