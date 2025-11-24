package com.example.testing_001.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.Map;

@Service
public class DifyAIService {

    @Value("${dify.api-key:}")
    private String apiKey;

    @Value("${dify.api-url:https://api.dify.ai/v1}")
    private String apiUrl;

    private final RestTemplate restTemplate = new RestTemplate();
    private final ObjectMapper objectMapper = new ObjectMapper();

    /**
     * Gửi câu hỏi đến Dify AI và nhận câu trả lời
     * Sử dụng /messages endpoint cho Personal API (app-* key)
     */
    public String askDifyAI(String question, String conversationId) {
        try {
            String endpoint = apiUrl + "/messages";

            // Tạo request body cho messages endpoint
            Map<String, Object> requestBody = new HashMap<>();
            requestBody.put("inputs", new HashMap<>());
            requestBody.put("query", question);
            requestBody.put("response_mode", "blocking");
            requestBody.put("user", "default-user");

            // Tạo headers với API key
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.set("Authorization", apiKey);

            // Tạo HTTP request
            HttpEntity<String> request = new HttpEntity<>(
                    objectMapper.writeValueAsString(requestBody),
                    headers
            );

            System.out.println("=== Dify API Request ===");
            System.out.println("URL: " + endpoint);
            System.out.println("Body: " + objectMapper.writeValueAsString(requestBody));
            System.out.println("API Key (first 20 chars): " + (apiKey != null ? apiKey.substring(0, Math.min(20, apiKey.length())) : "null"));

            // Gửi request
            String response = restTemplate.postForObject(endpoint, request, String.class);

            System.out.println("Response: " + response);
            System.out.println("=== End Dify API Request ===");

            // Parse response và lấy answer
            return parseAIResponse(response);

        } catch (Exception e) {
            System.out.println("Error: " + e.getClass().getName() + " - " + e.getMessage());
            e.printStackTrace();
            return "Lỗi khi gọi API Dify: " + e.getMessage();
        }
    }

    /**
     * Parse response từ Dify API
     */
    @SuppressWarnings("unchecked")
    private String parseAIResponse(String response) {
        try {
            Map<String, Object> responseMap = objectMapper.readValue(response, Map.class);
            
            // Thử lấy answer từ response
            Object answer = responseMap.get("answer");
            if (answer != null) {
                return answer.toString();
            }
            
            // Nếu không có answer, thử lấy text
            Object text = responseMap.get("text");
            if (text != null) {
                return text.toString();
            }
            
            // Nếu vẫn không có, trả về toàn bộ response
            return response;
            
        } catch (Exception e) {
            return "Lỗi khi xử lý phản hồi: " + e.getMessage();
        }
    }

    /**
     * Lấy suggestion cho khóa học dựa trên tên
     */
    public String getSuggestionsForCourse(String courseName) {
        String question = "Hãy đưa ra gợi ý về khóa học: " + courseName;
        return askDifyAI(question, "");
    }

    /**
     * Lấy mô tả chi tiết cho khóa học
     */
    public String getCourseSummary(String courseName, String instructor) {
        String question = "Hãy tóm tắt khóa học '" + courseName + "' của giảng viên " + instructor;
        return askDifyAI(question, "");
    }
}

