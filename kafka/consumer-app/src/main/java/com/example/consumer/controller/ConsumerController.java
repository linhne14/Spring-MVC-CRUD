package com.example.consumer.controller;

import com.example.consumer.model.Message;
import com.example.consumer.service.MessageProcessingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/consumer")
public class ConsumerController {

    @Autowired
    private MessageProcessingService messageProcessingService;

    @GetMapping("/processed-messages")
    public ResponseEntity<List<Message>> getProcessedMessages() {
        List<Message> messages = messageProcessingService.getProcessedMessages();
        return ResponseEntity.ok(messages);
    }
    
    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getStats() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalProcessed", messageProcessingService.getProcessedCount());
        stats.put("status", "running");
        stats.put("service", "Consumer Application");
        return ResponseEntity.ok(stats);
    }
    
    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Consumer service is running");
    }
}