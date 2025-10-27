# Simple test script for GitHub Actions workflow
Write-Host "Testing GitHub Actions workflow locally..." -ForegroundColor Cyan

# Setup Java 21
Write-Host "Setting up Java 21..." -ForegroundColor Yellow
$env:JAVA_HOME = "C:\Program Files\Java\jdk-21"
$env:PATH = "C:\Program Files\Java\jdk-21\bin;" + $env:PATH

Write-Host "Java version:"
java -version

# Test Maven build
Write-Host "`nTesting Maven build..." -ForegroundColor Yellow
try {
    & .\mvnw.cmd clean package -DskipTests
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Maven build: SUCCESS" -ForegroundColor Green
    } else {
        Write-Host "Maven build: FAILED" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "Maven build error: $_" -ForegroundColor Red
    exit 1
}

# Test Docker build
Write-Host "`nTesting Docker build..." -ForegroundColor Yellow
try {
    docker build -t sso-test:local .
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Docker build: SUCCESS" -ForegroundColor Green
    } else {
        Write-Host "Docker build: FAILED" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "Docker build error: $_" -ForegroundColor Red
    exit 1
}

Write-Host "`nAll tests passed! Ready for GitHub Actions!" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "1. git add ."
Write-Host "2. git commit -m 'Fix Java version for GitHub Actions'"
Write-Host "3. git push origin main"

# Cleanup
docker rmi sso-test:local 2>$null