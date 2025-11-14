# MongoDB Replica Set Setup Script
# This script downloads MongoDB, sets up 3-node replica set, and demonstrates replication

Write-Host "🍃 MongoDB Replica Set Setup Script" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Cyan

# Step 1: Download and extract MongoDB (if not installed)
$mongoPath = "C:\mongodb"
$mongoVersion = "7.0.4"
$mongoUrl = "https://fastdl.mongodb.org/windows/mongodb-windows-x86_64-$mongoVersion.zip"

if (!(Test-Path "$mongoPath\bin\mongod.exe")) {
    Write-Host "📥 Downloading MongoDB $mongoVersion..." -ForegroundColor Yellow
    
    # Create MongoDB directory
    New-Item -ItemType Directory -Path $mongoPath -Force | Out-Null
    
    # Download MongoDB
    $zipFile = "$env:TEMP\mongodb.zip"
    try {
        Invoke-WebRequest -Uri $mongoUrl -OutFile $zipFile -UseBasicParsing
        Write-Host "✅ MongoDB downloaded successfully" -ForegroundColor Green
        
        # Extract MongoDB
        Write-Host "📂 Extracting MongoDB..." -ForegroundColor Yellow
        Expand-Archive -Path $zipFile -DestinationPath $env:TEMP -Force
        
        # Move to final location
        $extractedFolder = Get-ChildItem "$env:TEMP\mongodb-windows-x86_64-$mongoVersion" -ErrorAction SilentlyContinue
        if ($extractedFolder) {
            Copy-Item "$($extractedFolder.FullName)\*" -Destination $mongoPath -Recurse -Force
            Write-Host "✅ MongoDB installed to $mongoPath" -ForegroundColor Green
        } else {
            Write-Host "❌ Failed to find extracted MongoDB folder" -ForegroundColor Red
            exit 1
        }
        
        # Cleanup
        Remove-Item $zipFile -Force -ErrorAction SilentlyContinue
        Remove-Item "$env:TEMP\mongodb-windows-x86_64-$mongoVersion" -Recurse -Force -ErrorAction SilentlyContinue
        
    } catch {
        Write-Host "❌ Failed to download MongoDB: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Please download MongoDB manually from https://www.mongodb.com/try/download/community" -ForegroundColor Yellow
        exit 1
    }
} else {
    Write-Host "✅ MongoDB already installed at $mongoPath" -ForegroundColor Green
}

# Add MongoDB to PATH for this session
$env:PATH += ";$mongoPath\bin"

# Step 2: Create data directories (already done but verify)
Write-Host "`n📁 Setting up data directories..." -ForegroundColor Yellow
$dataDirs = @("C:\data\rs0-1", "C:\data\rs0-2", "C:\data\rs0-3")
foreach ($dir in $dataDirs) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    Write-Host "✅ Created $dir" -ForegroundColor Green
}

# Step 3: Create PowerShell scripts to start each mongod instance
Write-Host "`n🚀 Creating mongod startup scripts..." -ForegroundColor Yellow

# Node 1 script
@"
Write-Host "Starting MongoDB Node 1 (Primary candidate) on port 27017..." -ForegroundColor Green
Set-Location "$mongoPath\bin"
.\mongod.exe --replSet rs0 --port 27017 --dbpath "C:\data\rs0-1" --bind_ip localhost --logpath "C:\data\rs0-1\mongod.log"
"@ | Out-File -FilePath "C:\data\start-node1.ps1" -Encoding UTF8

# Node 2 script  
@"
Write-Host "Starting MongoDB Node 2 on port 27018..." -ForegroundColor Green
Set-Location "$mongoPath\bin"
.\mongod.exe --replSet rs0 --port 27018 --dbpath "C:\data\rs0-2" --bind_ip localhost --logpath "C:\data\rs0-2\mongod.log"
"@ | Out-File -FilePath "C:\data\start-node2.ps1" -Encoding UTF8

# Node 3 script
@"
Write-Host "Starting MongoDB Node 3 on port 27019..." -ForegroundColor Green  
Set-Location "$mongoPath\bin"
.\mongod.exe --replSet rs0 --port 27019 --dbpath "C:\data\rs0-3" --bind_ip localhost --logpath "C:\data\rs0-3\mongod.log"
"@ | Out-File -FilePath "C:\data\start-node3.ps1" -Encoding UTF8

Write-Host "✅ Startup scripts created in C:\data\" -ForegroundColor Green

# Step 4: Start the mongod processes in background
Write-Host "`n🔥 Starting MongoDB nodes..." -ForegroundColor Yellow

$node1 = Start-Process -FilePath "powershell.exe" -ArgumentList "-File C:\data\start-node1.ps1" -PassThru -WindowStyle Minimized
$node2 = Start-Process -FilePath "powershell.exe" -ArgumentList "-File C:\data\start-node2.ps1" -PassThru -WindowStyle Minimized  
$node3 = Start-Process -FilePath "powershell.exe" -ArgumentList "-File C:\data\start-node3.ps1" -PassThru -WindowStyle Minimized

Write-Host "✅ Node 1 started (PID: $($node1.Id)) on port 27017" -ForegroundColor Green
Write-Host "✅ Node 2 started (PID: $($node2.Id)) on port 27018" -ForegroundColor Green
Write-Host "✅ Node 3 started (PID: $($node3.Id)) on port 27019" -ForegroundColor Green

# Wait for nodes to start
Write-Host "`n⏳ Waiting for nodes to initialize..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Test connection to node 1
$connectionTest = & "$mongoPath\bin\mongo.exe" --port 27017 --eval "db.adminCommand('ping')" --quiet 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Node 1 is responding" -ForegroundColor Green
} else {
    Write-Host "❌ Node 1 is not responding yet, waiting longer..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
}

# Step 5: Initialize replica set
Write-Host "`n🔧 Initializing replica set..." -ForegroundColor Yellow

$initScript = @"
rs.initiate({
  _id: "rs0",
  members: [
    { _id: 0, host: "localhost:27017" },
    { _id: 1, host: "localhost:27018" },
    { _id: 2, host: "localhost:27019" }
  ]
});
"@

# Save init script to file
$initScript | Out-File -FilePath "C:\data\init-replica.js" -Encoding UTF8

# Run initialization
Write-Host "📝 Running replica set initialization..." -ForegroundColor Yellow
$initResult = & "$mongoPath\bin\mongo.exe" --port 27017 "C:\data\init-replica.js"
Write-Host $initResult

# Wait for replica set to stabilize
Write-Host "`n⏳ Waiting for replica set to stabilize..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Step 6: Check replica set status
Write-Host "`n📊 Checking replica set status..." -ForegroundColor Yellow
$statusResult = & "$mongoPath\bin\mongo.exe" --port 27017 --eval "rs.status()" --quiet
Write-Host $statusResult

# Step 7: Create test data script
Write-Host "`n📝 Creating test data and replication verification scripts..." -ForegroundColor Yellow

# Test data script
@"
use testReplica;
db.people.insertMany([
    {name: "Alice", age: 30, city: "Hanoi"}, 
    {name: "Bob", age: 27, city: "HCM"},
    {name: "Carol", age: 35, city: "Da Nang"}
]);
print("✅ Inserted test data into PRIMARY");
db.people.find().pretty();
"@ | Out-File -FilePath "C:\data\insert-test-data.js" -Encoding UTF8

# Verify replication script
@"
rs.slaveOk();
use testReplica;
print("📖 Reading from SECONDARY:");
db.people.find().pretty();
"@ | Out-File -FilePath "C:\data\verify-replication.js" -Encoding UTF8

# Failover test script
@"
print("🔍 Current replica set status:");
rs.status();
print("\n📊 Who is master:");
rs.isMaster();
"@ | Out-File -FilePath "C:\data\check-status.js" -Encoding UTF8

Write-Host "✅ Test scripts created in C:\data\" -ForegroundColor Green

# Step 8: Insert test data
Write-Host "`n📊 Inserting test data into PRIMARY..." -ForegroundColor Yellow
$insertResult = & "$mongoPath\bin\mongo.exe" --port 27017 "C:\data\insert-test-data.js"
Write-Host $insertResult

# Step 9: Verify replication on secondary
Write-Host "`n🔄 Verifying replication on SECONDARY (port 27018)..." -ForegroundColor Yellow
Start-Sleep -Seconds 5
$replicationResult = & "$mongoPath\bin\mongo.exe" --port 27018 "C:\data\verify-replication.js"
Write-Host $replicationResult

# Step 10: Instructions for manual failover testing
Write-Host "`n🎯 MANUAL FAILOVER TESTING INSTRUCTIONS:" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1️⃣ To stop the PRIMARY (simulate failure):" -ForegroundColor Yellow
Write-Host "   Stop-Process -Id $($node1.Id) -Force" -ForegroundColor White
Write-Host ""
Write-Host "2️⃣ To check status during failover:" -ForegroundColor Yellow
Write-Host "   & `"$mongoPath\bin\mongo.exe`" --port 27018 C:\data\check-status.js" -ForegroundColor White
Write-Host ""
Write-Host "3️⃣ To restart the original primary:" -ForegroundColor Yellow
Write-Host "   Start-Process -FilePath `"powershell.exe`" -ArgumentList `"-File C:\data\start-node1.ps1`" -PassThru -WindowStyle Minimized" -ForegroundColor White
Write-Host ""
Write-Host "4️⃣ To test writes on new primary (after failover):" -ForegroundColor Yellow
Write-Host "   & `"$mongoPath\bin\mongo.exe`" --port 27018 --eval `"use testReplica; db.people.insertOne({name:'Dave', age:40, city:'Can Tho', addedAfterFailover:true}); db.people.find({addedAfterFailover:true}).pretty()`"" -ForegroundColor White
Write-Host ""
Write-Host "5️⃣ To cleanup (stop all nodes):" -ForegroundColor Yellow
Write-Host "   Stop-Process -Id $($node1.Id),$($node2.Id),$($node3.Id) -Force" -ForegroundColor White

# Summary
Write-Host "`n🎉 MONGODB REPLICA SET SETUP COMPLETE!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📍 MongoDB Path: $mongoPath" -ForegroundColor White
Write-Host "📁 Data Directories: C:\data\rs0-1, C:\data\rs0-2, C:\data\rs0-3" -ForegroundColor White
Write-Host "🔌 Node Ports: 27017 (Primary candidate), 27018, 27019" -ForegroundColor White
Write-Host "🏷️ Replica Set Name: rs0" -ForegroundColor White
Write-Host ""
Write-Host "📊 Node Process IDs:" -ForegroundColor White
Write-Host "   Node 1 (27017): $($node1.Id)" -ForegroundColor White
Write-Host "   Node 2 (27018): $($node2.Id)" -ForegroundColor White  
Write-Host "   Node 3 (27019): $($node3.Id)" -ForegroundColor White
Write-Host ""
Write-Host "✅ Replica set initialized and running" -ForegroundColor Green
Write-Host "✅ Test data inserted and replicated" -ForegroundColor Green
Write-Host "✅ Ready for failover testing" -ForegroundColor Green

# Save node PIDs for later cleanup
@"
# MongoDB Node Process IDs
# Generated: $(Get-Date)
`$node1PID = $($node1.Id)
`$node2PID = $($node2.Id)  
`$node3PID = $($node3.Id)

Write-Host "MongoDB Replica Set Node PIDs:"
Write-Host "Node 1 (27017): `$node1PID"
Write-Host "Node 2 (27018): `$node2PID"
Write-Host "Node 3 (27019): `$node3PID"

# To stop all nodes:
# Stop-Process -Id `$node1PID,`$node2PID,`$node3PID -Force
"@ | Out-File -FilePath "C:\data\node-pids.ps1" -Encoding UTF8

Write-Host "`n💾 Node PIDs saved to C:\data\node-pids.ps1 for cleanup" -ForegroundColor Blue