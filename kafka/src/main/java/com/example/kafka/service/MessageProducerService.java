package com.example.kafka.service;

import com.example.kafka.model.Message;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.SendResult;
import org.springframework.stereotype.Service;

import java.util.UUID;
import java.util.concurrent.CompletableFuture;

@Service
public class MessageProducerService {
    
    private static final Logger logger = LoggerFactory.getLogger(MessageProducerService.class);
    private static final String TOPIC = "messages";

    @Autowired
    private KafkaTemplate<String, Message> kafkaTemplate;

    public void sendMessage(String content, String sender) {
        Message message = new Message(UUID.randomUUID().toString(), content, sender);
        
        try {
            CompletableFuture<SendResult<String, Message>> future = 
                kafkaTemplate.send(TOPIC, message.getId(), message);
                
            future.whenComplete((result, ex) -> {
                if (ex == null) {
                    logger.info("Sent message=[{}] with offset=[{}]", 
                        message, result.getRecordMetadata().offset());
                } else {
                    logger.error("Unable to send message=[{}] due to : {}", 
                        message, ex.getMessage());
                }
            });
        } catch (Exception e) {
            logger.error("Error sending message: {}", e.getMessage());
            throw e;
        }
    }
}