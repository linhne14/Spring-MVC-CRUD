package com.example.consumer.service;

import com.example.consumer.model.Message;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.support.KafkaHeaders;
import org.springframework.messaging.handler.annotation.Header;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class MessageProcessingService {
    
    private static final Logger logger = LoggerFactory.getLogger(MessageProcessingService.class);
    private final List<Message> processedMessages = new ArrayList<>();

    @KafkaListener(topics = "messages", groupId = "consumer-app-group")
    public void processMessage(@Payload Message message,
                              @Header(KafkaHeaders.RECEIVED_TOPIC) String topic,
                              @Header(KafkaHeaders.RECEIVED_PARTITION) int partition,
                              @Header(KafkaHeaders.OFFSET) long offset) {
        
        logger.info("🔥 Consumer App received message: {} from topic: {}, partition: {}, offset: {}", 
            message, topic, partition, offset);
            
        // Xử lý message business logic
        processBusinessLogic(message);
        
        // Lưu message đã xử lý
        synchronized (processedMessages) {
            processedMessages.add(message);
            // Chỉ giữ lại 100 message gần nhất
            if (processedMessages.size() > 100) {
                processedMessages.remove(0);
            }
        }
    }

    private void processBusinessLogic(Message message) {
        logger.info("📝 Processing business logic for message from {}: {}", 
            message.getSender(), message.getContent());
        
        // Simulate complex processing
        try {
            Thread.sleep(2000); // Simulate processing time
            
            // Business logic based on message content
            String content = message.getContent().toLowerCase();
            if (content.contains("urgent")) {
                logger.warn("⚡ URGENT message detected: {}", message.getId());
            } else if (content.contains("error")) {
                logger.error("❌ Error message detected: {}", message.getId());
            } else {
                logger.info("✅ Standard message processed: {}", message.getId());
            }
            
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            logger.error("Processing interrupted for message: {}", message.getId());
        }
    }

    public List<Message> getProcessedMessages() {
        synchronized (processedMessages) {
            return new ArrayList<>(processedMessages);
        }
    }
    
    public int getProcessedCount() {
        synchronized (processedMessages) {
            return processedMessages.size();
        }
    }
}