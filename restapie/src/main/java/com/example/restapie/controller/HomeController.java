package com.example.restapie.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.http.ResponseEntity;
import java.util.HashMap;
import java.util.Map;

@RestController
public class HomeController {

    @GetMapping("/")
    public ResponseEntity<?> home() {
        Map<String, String> response = new HashMap<>();
        response.put("message", "API đang chạy. Hãy truy cập /api/blogs để xem dữ liệu.");
        response.put("status", "success");
        return ResponseEntity.ok(response);
    }
}
