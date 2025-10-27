# Set Java 21 Environment
# Run this script before building to ensure correct Java version

Write-Host "🔧 Setting up Java 21 environment..." -ForegroundColor Green

# Set JAVA_HOME to Java 21
$env:JAVA_HOME = "C:\Program Files\Java\jdk-21"

# Update PATH to use Java 21
$javaPath = "C:\Program Files\Java\jdk-21\bin"
$currentPath = $env:PATH

# Remove old Java paths
$cleanedPath = $currentPath -replace "C:\\Program Files\\Java\\jdk[^;]*;?", ""
$cleanedPath = $cleanedPath -replace "C:\\Program Files \(x86\)\\Java\\[^;]*;?", ""

# Add Java 21 to the beginning of PATH
$env:PATH = $javaPath + ";" + $cleanedPath

Write-Host "✅ Java environment configured:" -ForegroundColor Green
Write-Host "   JAVA_HOME: $env:JAVA_HOME" -ForegroundColor Gray
Write-Host "   Java Path: $javaPath" -ForegroundColor Gray

# Verify Java version
Write-Host "`n🔍 Verifying Java version..." -ForegroundColor Yellow
java -version

Write-Host "`n🚀 Ready for Maven builds with Java 21!" -ForegroundColor Cyan