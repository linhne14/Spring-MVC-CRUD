# Kafka Cluster với 2 Spring Boot Applications

Dự án này bao gồm:
- **Producer App** (port 8080): Gửi message JSON qua Kafka
- **Consumer App** (port 8081): Nhận và xử lý message JSON từ Kafka  
- **Kafka Cluster**: 3 broker với ZooKeeper cluster
- **Kafka UI** (port 8080): Giao diện quản lý Kafka

## 🚀 Cách chạy

### 1. Khởi động Kafka Cluster
```bash
# Chạy Docker Compose để khởi động cluster
docker-compose up -d

# Kiểm tra trạng thái containers
docker ps
```

### 2. Tạo topic và kiểm tra cluster
```bash
# Windows PowerShell
.\kafka-cluster-manager.ps1 -Action full-test

# hoặc Linux/Mac
chmod +x kafka-cluster-manager.sh
./kafka-cluster-manager.sh full-test
```

### 3. Chạy Spring Boot Applications

#### Producer App (Gốc)
```bash
# Từ thư mục root
mvn spring-boot:run
```

#### Consumer App  
```bash
# Từ thư mục consumer-app
cd consumer-app
mvn spring-boot:run
```

## 📡 Test APIs

### Gửi message (Producer)
```bash
curl -X POST http://localhost:8080/api/messages/send \
  -H "Content-Type: application/json" \
  -d '{"content": "Hello Kafka!", "sender": "User1"}'

curl -X POST http://localhost:8080/api/messages/send \
  -H "Content-Type: application/json" \
  -d '{"content": "URGENT: System alert!", "sender": "System"}'
```

### Kiểm tra Consumer
```bash
# Xem các message đã xử lý
curl http://localhost:8081/api/consumer/processed-messages

# Xem thống kê
curl http://localhost:8081/api/consumer/stats
```

### Kiểm tra health
```bash
curl http://localhost:8080/api/messages/health
curl http://localhost:8081/api/consumer/health
```

## 🔧 Kafka Cluster Management

### Kiểm tra cluster status
```powershell
.\kafka-cluster-manager.ps1 -Action status
```

### Tạo topic với replication
```powershell
.\kafka-cluster-manager.ps1 -Action create-topic
```

### Kiểm tra leader của từng partition
```powershell
.\kafka-cluster-manager.ps1 -Action check-leader
```

### Test failover - Dừng leader broker
```powershell
# Kiểm tra broker nào là leader trước
.\kafka-cluster-manager.ps1 -Action check-leader

# Dừng broker leader (ví dụ broker 1)
.\kafka-cluster-manager.ps1 -Action stop-leader -BrokerId 1

# Kiểm tra leader mới được bầu
.\kafka-cluster-manager.ps1 -Action check-leader

# Test gửi message khi thiếu 1 broker
curl -X POST http://localhost:8080/api/messages/send \
  -H "Content-Type: application/json" \
  -d '{"content": "Test during failover", "sender": "Tester"}'

# Khởi động lại broker
.\kafka-cluster-manager.ps1 -Action start-broker -BrokerId 1
```

## 🌐 Kafka UI

Truy cập http://localhost:8080 để xem giao diện quản lý Kafka:
- Xem topics, partitions, consumers
- Theo dõi message flow  
- Quản lý cluster

## 📊 Cấu hình Cluster

### ZooKeeper Cluster (3 nodes)
- zookeeper1:2181
- zookeeper2:2182  
- zookeeper3:2183

### Kafka Brokers (3 nodes)
- kafka1:9092 (Broker ID: 1)
- kafka2:9093 (Broker ID: 2)
- kafka3:9094 (Broker ID: 3)

### Topic Configuration
- **Topic**: messages
- **Partitions**: 3
- **Replication Factor**: 3
- **Min In-Sync Replicas**: 2

## 🔍 Troubleshooting

### Kiểm tra logs
```bash
# Kafka broker logs
docker logs kafka1
docker logs kafka2  
docker logs kafka3

# Spring Boot app logs
# Producer logs sẽ hiển thị trong console
# Consumer logs sẽ hiển thị message processing
```

### Reset cluster (nếu cần)
```bash
# Dừng tất cả
docker-compose down

# Xóa volumes (mất dữ liệu)
docker volume prune

# Khởi động lại
docker-compose up -d
```

## 📈 Test Scenarios

### 1. Normal Operation
1. Start cluster
2. Send messages via Producer API
3. Verify Consumer receives and processes messages

### 2. Leader Failover Test  
1. Identify current leader partition
2. Stop the leader broker
3. Verify new leader is elected
4. Send messages and verify they're still processed
5. Restart the stopped broker

### 3. High Availability Test
1. Send continuous messages
2. Stop one broker at a time
3. Verify system continues to work
4. Monitor rebalancing

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   ZooKeeper1    │    │   ZooKeeper2    │    │   ZooKeeper3    │
│    :2181        │    │    :2182        │    │    :2183        │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     Kafka1      │    │     Kafka2      │    │     Kafka3      │
│    :9092        │    │    :9093        │    │    :9094        │
│   Broker ID: 1  │    │   Broker ID: 2  │    │   Broker ID: 3  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                        ┌─────────────────┐
                        │   Kafka Topic   │
                        │   "messages"    │
                        │   RF: 3, P: 3   │
                        └─────────────────┘
                                 │
                ┌────────────────┴────────────────┐
                │                                 │
    ┌─────────────────┐                ┌─────────────────┐
    │ Producer App    │                │ Consumer App    │
    │    :8080        │                │    :8081        │
    │ (Sends JSON)    │                │ (Processes JSON)│
    └─────────────────┘                └─────────────────┘
```