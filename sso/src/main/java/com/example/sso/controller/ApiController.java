package com.example.sso.controller;

import com.example.sso.service.TokenService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClient;
import org.springframework.security.oauth2.client.annotation.RegisteredOAuth2AuthorizedClient;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api")
public class ApiController {

    @Autowired
    private TokenService tokenService;

    @PostMapping("/refresh-token")
    public ResponseEntity<?> refreshToken(@RegisteredOAuth2AuthorizedClient OAuth2AuthorizedClient authorizedClient) {
        try {
            Map<String, Object> newTokens = tokenService.refreshToken(authorizedClient);
            return ResponseEntity.ok(newTokens);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", "Failed to refresh token: " + e.getMessage()));
        }
    }

    @GetMapping("/profile")
    public ResponseEntity<?> getProfile(Authentication authentication) {
        try {
            Map<String, Object> profile = tokenService.getUserProfile(authentication);
            return ResponseEntity.ok(profile);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", "Failed to get profile: " + e.getMessage()));
        }
    }

    @PostMapping("/logout")
    public ResponseEntity<?> logout(@RegisteredOAuth2AuthorizedClient OAuth2AuthorizedClient authorizedClient) {
        try {
            tokenService.logout(authorizedClient);
            return ResponseEntity.ok(Map.of("message", "Logged out successfully"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", "Failed to logout: " + e.getMessage()));
        }
    }
}