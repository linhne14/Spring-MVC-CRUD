package com.example.sso.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClient;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClientService;
import org.springframework.security.oauth2.core.OAuth2AccessToken;
import org.springframework.security.oauth2.core.OAuth2RefreshToken;
import org.springframework.security.oauth2.core.oidc.user.OidcUser;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;

import java.time.Instant;
import java.util.HashMap;
import java.util.Map;

@Service
public class TokenService {

    @Autowired
    private OAuth2AuthorizedClientService authorizedClientService;

    private final WebClient webClient = WebClient.builder().build();

    public Map<String, Object> refreshToken(OAuth2AuthorizedClient authorizedClient) {
        OAuth2RefreshToken refreshToken = authorizedClient.getRefreshToken();
        
        if (refreshToken == null) {
            throw new RuntimeException("No refresh token available");
        }

        // Gọi Keycloak token endpoint để refresh token
        Map<String, Object> tokenResponse = webClient.post()
            .uri("http://localhost:8081/realms/spring-boot-sso/protocol/openid-connect/token")
            .header("Content-Type", "application/x-www-form-urlencoded")
            .body(BodyInserters.fromFormData("grant_type", "refresh_token")
                .with("refresh_token", refreshToken.getTokenValue())
                .with("client_id", authorizedClient.getClientRegistration().getClientId())
                .with("client_secret", authorizedClient.getClientRegistration().getClientSecret()))
            .retrieve()
            .bodyToMono(Map.class)
            .block();

        return tokenResponse;
    }

    public Map<String, Object> getUserProfile(Authentication authentication) {
        Map<String, Object> profile = new HashMap<>();
        
        if (authentication != null && authentication.getPrincipal() instanceof OidcUser) {
            OidcUser oidcUser = (OidcUser) authentication.getPrincipal();
            
            profile.put("sub", oidcUser.getSubject());
            profile.put("name", oidcUser.getFullName());
            profile.put("preferred_username", oidcUser.getPreferredUsername());
            profile.put("email", oidcUser.getEmail());
            profile.put("email_verified", oidcUser.getEmailVerified());
            profile.put("given_name", oidcUser.getGivenName());
            profile.put("family_name", oidcUser.getFamilyName());
            profile.put("roles", oidcUser.getAuthorities());
            
            // Thêm thông tin từ ID token claims
            profile.putAll(oidcUser.getClaims());
        }
        
        return profile;
    }

    public void logout(OAuth2AuthorizedClient authorizedClient) {
        OAuth2RefreshToken refreshToken = authorizedClient.getRefreshToken();
        
        if (refreshToken != null) {
            // Gọi Keycloak logout endpoint
            webClient.post()
                .uri("http://localhost:8081/realms/spring-boot-sso/protocol/openid-connect/logout")
                .header("Content-Type", "application/x-www-form-urlencoded")
                .body(BodyInserters.fromFormData("refresh_token", refreshToken.getTokenValue())
                    .with("client_id", authorizedClient.getClientRegistration().getClientId())
                    .with("client_secret", authorizedClient.getClientRegistration().getClientSecret()))
                .retrieve()
                .bodyToMono(String.class)
                .block();
        }
    }

    public boolean isTokenExpired(OAuth2AccessToken accessToken) {
        return accessToken.getExpiresAt() != null && 
               accessToken.getExpiresAt().isBefore(Instant.now());
    }

    public Map<String, Object> getTokenInfo(OAuth2AuthorizedClient authorizedClient) {
        Map<String, Object> tokenInfo = new HashMap<>();
        
        OAuth2AccessToken accessToken = authorizedClient.getAccessToken();
        OAuth2RefreshToken refreshToken = authorizedClient.getRefreshToken();
        
        tokenInfo.put("access_token", accessToken.getTokenValue());
        tokenInfo.put("token_type", accessToken.getTokenType().getValue());
        tokenInfo.put("expires_at", accessToken.getExpiresAt());
        tokenInfo.put("scopes", accessToken.getScopes());
        tokenInfo.put("is_expired", isTokenExpired(accessToken));
        
        if (refreshToken != null) {
            tokenInfo.put("refresh_token", refreshToken.getTokenValue());
            tokenInfo.put("refresh_token_expires_at", refreshToken.getExpiresAt());
        }
        
        return tokenInfo;
    }
}