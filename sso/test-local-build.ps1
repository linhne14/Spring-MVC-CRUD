# Local GitHub Actions Test Script
# Test your workflow before pushing to GitHub

Write-Host "🧪 Testing GitHub Actions workflow locally..." -ForegroundColor Cyan

# Setup Java 21 environment
Write-Host "`n🔧 Setting up Java 21..." -ForegroundColor Yellow
$env:JAVA_HOME = "C:\Program Files\Java\jdk-21"
$javaPath = "C:\Program Files\Java\jdk-21\bin"
# Simply prepend Java 21 to PATH
$env:PATH = "$javaPath;" + $env:PATH
java -version

# 1. Test Maven build
Write-Host "`n📦 Step 1: Testing Maven build..." -ForegroundColor Yellow
try {
    & .\mvnw.cmd clean test
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Maven tests passed!" -ForegroundColor Green
    } else {
        throw "Maven tests failed with exit code $LASTEXITCODE"
    }
} catch {
    Write-Host "❌ Maven test failed: $_" -ForegroundColor Red
    exit 1
}

# 2. Test Maven package
Write-Host "`n📦 Step 2: Testing Maven package..." -ForegroundColor Yellow
try {
    & .\mvnw.cmd clean package -DskipTests
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Maven package successful!" -ForegroundColor Green
    } else {
        throw "Maven package failed with exit code $LASTEXITCODE"
    }
} catch {
    Write-Host "❌ Maven package failed: $_" -ForegroundColor Red
    exit 1
}

# 3. Test Docker build
Write-Host "`n🐳 Step 3: Testing Docker build..." -ForegroundColor Yellow
try {
    docker build -t sso-test:local .
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Docker build successful!" -ForegroundColor Green
    } else {
        throw "Docker build failed with exit code $LASTEXITCODE"
    }
} catch {
    Write-Host "❌ Docker build failed: $_" -ForegroundColor Red
    exit 1
}

# 4. Test container health
Write-Host "`n🚀 Step 4: Testing container health..." -ForegroundColor Yellow
$containerId = $null
try {
    $containerId = docker run -d -p 8082:8080 --name sso-test sso-test:local
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to start container"
    }
    
    Write-Host "Container started, waiting 30 seconds..." -ForegroundColor Gray
    Start-Sleep -Seconds 30
    
    $response = Invoke-RestMethod -Uri "http://localhost:8082/actuator/health" -TimeoutSec 10 -ErrorAction Stop
    if ($response.status -eq "UP") {
        Write-Host "✅ Container health check passed!" -ForegroundColor Green
    } else {
        throw "Health check returned: $($response.status)"
    }
} catch {
    Write-Host "❌ Container test failed: $_" -ForegroundColor Red
    if ($containerId) {
        Write-Host "Container logs:" -ForegroundColor Gray
        docker logs sso-test
    }
} finally {
    if ($containerId) {
        docker stop sso-test 2>$null
        docker rm sso-test 2>$null
    }
    docker rmi sso-test:local 2>$null
}

Write-Host "`n🎉 All tests passed! Ready for GitHub Actions!" -ForegroundColor Green
Write-Host "`n📋 Next steps to trigger GitHub Actions:" -ForegroundColor Yellow
Write-Host "1. git add .github/" -ForegroundColor White
Write-Host "2. git commit -m 'Add GitHub Actions workflows'" -ForegroundColor White
Write-Host "3. git push origin main" -ForegroundColor White
Write-Host "`n📊 Workflow will build and push to:" -ForegroundColor Cyan
Write-Host "   ghcr.io/linhne14/spring-mvc-crud:latest" -ForegroundColor White
Write-Host "   ghcr.io/linhne14/spring-mvc-crud:main-[sha]" -ForegroundColor White