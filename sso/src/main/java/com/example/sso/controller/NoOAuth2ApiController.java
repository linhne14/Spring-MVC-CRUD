package com.example.sso.controller;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api")
@ConditionalOnProperty(name = "spring.profiles.active", havingValue = "no-oauth2")
public class NoOAuth2ApiController {

    @PostMapping("/refresh-token")
    public ResponseEntity<?> refreshToken() {
        return ResponseEntity.ok(Map.of("message", "OAuth2 is disabled. Enable OAuth2 profile to use this feature."));
    }

    @GetMapping("/profile")
    public ResponseEntity<?> getProfile(Authentication authentication) {
        Map<String, Object> profile = new HashMap<>();
        
        if (authentication != null) {
            profile.put("name", authentication.getName());
            profile.put("authorities", authentication.getAuthorities());
            profile.put("authenticated", authentication.isAuthenticated());
            profile.put("principal", authentication.getPrincipal().toString());
        } else {
            profile.put("message", "No authentication information available");
        }
        
        return ResponseEntity.ok(profile);
    }

    @PostMapping("/logout")
    public ResponseEntity<?> logout() {
        return ResponseEntity.ok(Map.of("message", "OAuth2 is disabled. Use standard logout."));
    }

    @GetMapping("/status")
    public ResponseEntity<?> getStatus() {
        Map<String, Object> status = new HashMap<>();
        status.put("oauth2_enabled", false);
        status.put("profile", "no-oauth2");
        status.put("message", "Application is running without OAuth2 authentication");
        return ResponseEntity.ok(status);
    }
}