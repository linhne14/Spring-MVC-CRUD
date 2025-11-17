package com.example.kafka.controller;

import com.example.kafka.service.MessageProducerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/messages")
public class MessageController {

    @Autowired
    private MessageProducerService messageProducerService;

    @PostMapping("/send")
    public ResponseEntity<String> sendMessage(@RequestBody Map<String, String> request) {
        String content = request.get("content");
        String sender = request.get("sender");
        
        if (content == null || sender == null) {
            return ResponseEntity.badRequest().body("Content and sender are required");
        }
        
        try {
            messageProducerService.sendMessage(content, sender);
            return ResponseEntity.ok("Message sent successfully");
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("Failed to send message: " + e.getMessage());
        }
    }
    
    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Message service is running");
    }
}