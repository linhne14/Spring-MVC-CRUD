package com.example.restapie.controller;

import com.example.restapie.model.Blog;
import com.example.restapie.model.User;
import com.example.restapie.service.BlogService;
import com.example.restapie.service.UserService;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/blogs")
@CrossOrigin(origins = "http://localhost:3000")
public class BlogController {

    @Autowired
    private BlogService blogService;

    @Autowired
    private UserService userService;

    // Test endpoint không cần JWT
    @GetMapping("/test")
    public ResponseEntity<?> test() {
        return ResponseEntity.ok("API is running");
    }

    // Lấy tất cả blog
    @GetMapping
    public ResponseEntity<?> getAllBlogs(Authentication authentication) {
        try {
            String username = authentication.getName();
            User user = userService.findByUsername(username)
                    .orElseThrow(() -> new RuntimeException("User not found"));

            List<Blog> blogs;
            if ("ADMIN".equals(user.getRole())) {
                blogs = blogService.getAllBlogs();
            } else {
                blogs = blogService.getBlogsByUser(user);
            }
            return ResponseEntity.ok(blogs);
        } catch (Exception e) {
            Map<String, String> response = new HashMap<>();
            response.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
}
