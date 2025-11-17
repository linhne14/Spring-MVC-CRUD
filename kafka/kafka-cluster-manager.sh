#!/bin/bash

echo "=== Kafka Cluster Management Scripts ==="

# Function to check cluster status
check_cluster_status() {
    echo -e "\n🔍 Checking Kafka Cluster Status..."
    docker exec kafka1 kafka-topics --bootstrap-server localhost:9092 --list 2>/dev/null || echo "❌ Kafka1 not accessible"
    docker exec kafka2 kafka-topics --bootstrap-server localhost:9093 --list 2>/dev/null || echo "❌ Kafka2 not accessible"  
    docker exec kafka3 kafka-topics --bootstrap-server localhost:9094 --list 2>/dev/null || echo "❌ Kafka3 not accessible"
}

# Function to create topic with replication
create_topic() {
    echo -e "\n📝 Creating topic 'messages' with replication factor 3..."
    docker exec kafka1 kafka-topics --create \
        --bootstrap-server localhost:9092 \
        --topic messages \
        --partitions 3 \
        --replication-factor 3 \
        --if-not-exists
}

# Function to describe topic and find leader
check_topic_leader() {
    echo -e "\n👑 Checking topic leader information..."
    docker exec kafka1 kafka-topics --describe \
        --bootstrap-server localhost:9092 \
        --topic messages
}

# Function to check broker metadata
check_broker_metadata() {
    echo -e "\n🏢 Checking broker metadata..."
    docker exec kafka1 kafka-broker-api-versions --bootstrap-server localhost:9092
}

# Function to stop kafka leader (for testing failover)
stop_kafka_leader() {
    local broker_id=$1
    echo -e "\n⚠️  Stopping Kafka Broker $broker_id for failover test..."
    docker stop "kafka$broker_id"
    echo "✅ Kafka$broker_id stopped. Waiting 10 seconds for leader election..."
    sleep 10
    check_topic_leader
}

# Function to start kafka broker
start_kafka_broker() {
    local broker_id=$1
    echo -e "\n🚀 Starting Kafka Broker $broker_id..."
    docker start "kafka$broker_id"
    echo "✅ Kafka$broker_id started. Waiting 15 seconds for cluster sync..."
    sleep 15
    check_cluster_status
}

# Function to test message production
test_message_production() {
    echo -e "\n📤 Testing message production..."
    echo "Test message from script" | docker exec -i kafka1 kafka-console-producer \
        --bootstrap-server localhost:9092 \
        --topic messages
}

# Function to consume messages
test_message_consumption() {
    echo -e "\n📥 Testing message consumption (will timeout after 5 seconds)..."
    timeout 5 docker exec kafka1 kafka-console-consumer \
        --bootstrap-server localhost:9092 \
        --topic messages \
        --from-beginning || echo "Consumer test completed"
}

# Main menu
case "$1" in
    "status")
        check_cluster_status
        ;;
    "create-topic")
        create_topic
        ;;
    "check-leader")
        check_topic_leader
        ;;
    "metadata")
        check_broker_metadata
        ;;
    "stop-leader")
        if [ -z "$2" ]; then
            echo "Usage: $0 stop-leader <broker-id>"
            exit 1
        fi
        stop_kafka_leader $2
        ;;
    "start-broker")
        if [ -z "$2" ]; then
            echo "Usage: $0 start-broker <broker-id>"
            exit 1
        fi
        start_kafka_broker $2
        ;;
    "test-produce")
        test_message_production
        ;;
    "test-consume")
        test_message_consumption
        ;;
    "full-test")
        check_cluster_status
        create_topic
        check_topic_leader
        test_message_production
        test_message_consumption
        ;;
    *)
        echo "Usage: $0 {status|create-topic|check-leader|metadata|stop-leader <id>|start-broker <id>|test-produce|test-consume|full-test}"
        echo ""
        echo "Examples:"
        echo "  $0 status              # Check cluster status"
        echo "  $0 create-topic        # Create messages topic"
        echo "  $0 check-leader        # Show partition leaders"
        echo "  $0 stop-leader 1       # Stop kafka1 for failover test"
        echo "  $0 start-broker 1      # Start kafka1 back"
        echo "  $0 full-test           # Run complete test suite"
        ;;
esac