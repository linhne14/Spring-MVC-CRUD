package com.example.testing_001.controller;

import com.example.testing_001.service.DifyAIService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/ai")
public class AIController {

    @Autowired
    private DifyAIService difyAIService;

    /**
     * API endpoint để hỏi AI
     */
    @PostMapping("/ask")
    public ResponseEntity<Map<String, String>> askAI(@RequestBody Map<String, String> request) {
        try {
            String question = request.get("question");
            String conversationId = request.getOrDefault("conversationId", "");

            if (question == null || question.trim().isEmpty()) {
                Map<String, String> error = new HashMap<>();
                error.put("error", "Câu hỏi không được để trống");
                return ResponseEntity.badRequest().body(error);
            }

            String answer = difyAIService.askDifyAI(question, conversationId);

            Map<String, String> response = new HashMap<>();
            response.put("question", question);
            response.put("answer", answer);
            response.put("conversationId", conversationId);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Lỗi server: " + e.getMessage());
            return ResponseEntity.status(500).body(error);
        }
    }

    /**
     * API endpoint để lấy gợi ý cho khóa học
     */
    @GetMapping("/course-suggestion")
    public ResponseEntity<Map<String, String>> getCourseSuggestion(@RequestParam String courseName) {
        try {
            String suggestion = difyAIService.getSuggestionsForCourse(courseName);

            Map<String, String> response = new HashMap<>();
            response.put("courseName", courseName);
            response.put("suggestion", suggestion);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Lỗi: " + e.getMessage());
            return ResponseEntity.status(500).body(error);
        }
    }

    /**
     * API endpoint để lấy tóm tắt khóa học
     */
    @GetMapping("/course-summary")
    public ResponseEntity<Map<String, String>> getCourseSummary(
            @RequestParam String courseName,
            @RequestParam String instructor) {
        try {
            String summary = difyAIService.getCourseSummary(courseName, instructor);

            Map<String, String> response = new HashMap<>();
            response.put("courseName", courseName);
            response.put("instructor", instructor);
            response.put("summary", summary);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Lỗi: " + e.getMessage());
            return ResponseEntity.status(500).body(error);
        }
    }
}
