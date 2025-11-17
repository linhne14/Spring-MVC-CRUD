package com.example.kafka.service;

import com.example.kafka.model.Message;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.annotation.TopicPartition;
import org.springframework.kafka.support.KafkaHeaders;
import org.springframework.messaging.handler.annotation.Header;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.stereotype.Service;

@Service
public class MessageConsumerService {
    
    private static final Logger logger = LoggerFactory.getLogger(MessageConsumerService.class);

    @KafkaListener(topics = "messages", groupId = "message-consumer-group")
    public void consume(@Payload Message message,
                       @Header(KafkaHeaders.RECEIVED_TOPIC) String topic,
                       @Header(KafkaHeaders.RECEIVED_PARTITION) int partition,
                       @Header(KafkaHeaders.OFFSET) long offset) {
        
        logger.info("Consumed message: {} from topic: {}, partition: {}, offset: {}", 
            message, topic, partition, offset);
            
        // Xử lý message ở đây
        processMessage(message);
    }

    private void processMessage(Message message) {
        logger.info("Processing message from {}: {}", message.getSender(), message.getContent());
        
        // Simulate some processing time
        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        
        logger.info("Message processed successfully: {}", message.getId());
    }
}