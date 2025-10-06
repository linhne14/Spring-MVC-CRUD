package com.example.sso.controller;

import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClient;
import org.springframework.security.oauth2.client.annotation.RegisteredOAuth2AuthorizedClient;
import org.springframework.security.oauth2.core.oidc.user.OidcUser;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.Map;

@Controller
public class HomeController {

    @GetMapping("/")
    public String home() {
        return "index";
    }

    @GetMapping("/dashboard")
    public String dashboard(Model model, Authentication authentication) {
        if (authentication != null && authentication.getPrincipal() instanceof OidcUser) {
            OidcUser oidcUser = (OidcUser) authentication.getPrincipal();
            model.addAttribute("user", oidcUser);
            model.addAttribute("idToken", oidcUser.getIdToken().getTokenValue());
        }
        return "dashboard";
    }

    @GetMapping("/userinfo")
    @ResponseBody
    public Map<String, Object> userInfo(Authentication authentication) {
        if (authentication != null && authentication.getPrincipal() instanceof OidcUser) {
            OidcUser oidcUser = (OidcUser) authentication.getPrincipal();
            return oidcUser.getClaims();
        }
        return Map.of("error", "No authenticated user");
    }

    @GetMapping("/token")
    @ResponseBody
    public Map<String, Object> token(Authentication authentication,
                                   @RegisteredOAuth2AuthorizedClient OAuth2AuthorizedClient authorizedClient) {
        if (authentication != null && authentication.getPrincipal() instanceof OidcUser) {
            OidcUser oidcUser = (OidcUser) authentication.getPrincipal();
            
            return Map.of(
                "idToken", oidcUser.getIdToken().getTokenValue(),
                "accessToken", authorizedClient.getAccessToken().getTokenValue(),
                "refreshToken", authorizedClient.getRefreshToken() != null ? 
                    authorizedClient.getRefreshToken().getTokenValue() : "N/A",
                "expiresAt", authorizedClient.getAccessToken().getExpiresAt()
            );
        }
        return Map.of("error", "No authenticated user");
    }
}