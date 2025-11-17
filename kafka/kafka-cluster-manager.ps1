# Kafka Cluster Management Scripts for Windows PowerShell
param(
    [string]$Action,
    [string]$BrokerId
)

function Write-Header {
    param([string]$Message)
    Write-Host "`n=== $Message ===" -ForegroundColor Cyan
}

function Check-ClusterStatus {
    Write-Header "Checking Kafka Cluster Status"
    
    Write-Host "Checking Kafka1..." -ForegroundColor Yellow
    docker exec kafka1 kafka-topics --bootstrap-server localhost:9092 --list 2>$null
    if ($LASTEXITCODE -eq 0) { Write-Host "✅ Kafka1 is accessible" -ForegroundColor Green } 
    else { Write-Host "❌ Kafka1 not accessible" -ForegroundColor Red }
    
    Write-Host "Checking Kafka2..." -ForegroundColor Yellow
    docker exec kafka2 kafka-topics --bootstrap-server localhost:9093 --list 2>$null
    if ($LASTEXITCODE -eq 0) { Write-Host "✅ Kafka2 is accessible" -ForegroundColor Green }
    else { Write-Host "❌ Kafka2 not accessible" -ForegroundColor Red }
    
    Write-Host "Checking Kafka3..." -ForegroundColor Yellow
    docker exec kafka3 kafka-topics --bootstrap-server localhost:9094 --list 2>$null
    if ($LASTEXITCODE -eq 0) { Write-Host "✅ Kafka3 is accessible" -ForegroundColor Green }
    else { Write-Host "❌ Kafka3 not accessible" -ForegroundColor Red }
}

function Create-Topic {
    Write-Header "Creating topic 'messages' with replication factor 3"
    docker exec kafka1 kafka-topics --create --bootstrap-server localhost:9092 --topic messages --partitions 3 --replication-factor 3 --if-not-exists
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Topic 'messages' created successfully" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to create topic" -ForegroundColor Red
    }
}

function Check-TopicLeader {
    Write-Header "Checking topic leader information"
    docker exec kafka1 kafka-topics --describe --bootstrap-server localhost:9092 --topic messages
}

function Check-BrokerMetadata {
    Write-Header "Checking broker metadata"
    docker exec kafka1 kafka-broker-api-versions --bootstrap-server localhost:9092
}

function Stop-KafkaLeader {
    param([string]$BrokerId)
    Write-Header "Stopping Kafka Broker $BrokerId for failover test"
    
    docker stop "kafka$BrokerId"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Kafka$BrokerId stopped successfully" -ForegroundColor Green
        Write-Host "Waiting 10 seconds for leader election..." -ForegroundColor Yellow
        Start-Sleep -Seconds 10
        Check-TopicLeader
    } else {
        Write-Host "❌ Failed to stop Kafka$BrokerId" -ForegroundColor Red
    }
}

function Start-KafkaBroker {
    param([string]$BrokerId)
    Write-Header "Starting Kafka Broker $BrokerId"
    
    docker start "kafka$BrokerId"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Kafka$BrokerId started successfully" -ForegroundColor Green
        Write-Host "Waiting 15 seconds for cluster sync..." -ForegroundColor Yellow
        Start-Sleep -Seconds 15
        Check-ClusterStatus
    } else {
        Write-Host "❌ Failed to start Kafka$BrokerId" -ForegroundColor Red
    }
}

function Test-MessageProduction {
    Write-Header "Testing message production"
    $testMessage = "Test message from PowerShell script at $(Get-Date)"
    $testMessage | docker exec -i kafka1 kafka-console-producer --bootstrap-server localhost:9092 --topic messages
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Message sent successfully" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to send message" -ForegroundColor Red
    }
}

function Test-MessageConsumption {
    Write-Header "Testing message consumption (will timeout after 5 seconds)"
    # Start consumer job
    $job = Start-Job {
        docker exec kafka1 kafka-console-consumer --bootstrap-server localhost:9092 --topic messages --from-beginning
    }
    
    # Wait for 5 seconds
    Wait-Job $job -Timeout 5 | Out-Null
    
    # Stop the job
    Stop-Job $job -Force
    Remove-Job $job -Force
    
    Write-Host "Consumer test completed" -ForegroundColor Green
}

function Run-FullTest {
    Check-ClusterStatus
    Create-Topic
    Check-TopicLeader
    Test-MessageProduction
    Test-MessageConsumption
}

function Show-Usage {
    Write-Host @"
Usage: .\kafka-cluster-manager.ps1 -Action <action> [-BrokerId <id>]

Available Actions:
  status              # Check cluster status
  create-topic        # Create messages topic
  check-leader        # Show partition leaders
  metadata           # Show broker metadata
  stop-leader        # Stop kafka broker for failover test (requires -BrokerId)
  start-broker       # Start kafka broker (requires -BrokerId)
  test-produce       # Test message production
  test-consume       # Test message consumption
  full-test          # Run complete test suite

Examples:
  .\kafka-cluster-manager.ps1 -Action status
  .\kafka-cluster-manager.ps1 -Action create-topic
  .\kafka-cluster-manager.ps1 -Action check-leader
  .\kafka-cluster-manager.ps1 -Action stop-leader -BrokerId 1
  .\kafka-cluster-manager.ps1 -Action start-broker -BrokerId 1
  .\kafka-cluster-manager.ps1 -Action full-test
"@
}

# Main script logic
switch ($Action.ToLower()) {
    "status" { Check-ClusterStatus }
    "create-topic" { Create-Topic }
    "check-leader" { Check-TopicLeader }
    "metadata" { Check-BrokerMetadata }
    "stop-leader" { 
        if (-not $BrokerId) {
            Write-Host "Error: BrokerId parameter is required for stop-leader action" -ForegroundColor Red
            Show-Usage
            exit 1
        }
        Stop-KafkaLeader $BrokerId
    }
    "start-broker" {
        if (-not $BrokerId) {
            Write-Host "Error: BrokerId parameter is required for start-broker action" -ForegroundColor Red
            Show-Usage
            exit 1
        }
        Start-KafkaBroker $BrokerId
    }
    "test-produce" { Test-MessageProduction }
    "test-consume" { Test-MessageConsumption }
    "full-test" { Run-FullTest }
    default { Show-Usage }
}