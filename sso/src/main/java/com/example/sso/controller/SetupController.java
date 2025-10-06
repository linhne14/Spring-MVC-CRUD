package com.example.sso.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class SetupController {

    @GetMapping("/setup-guide")
    public String setupGuide(Model model) {
        model.addAttribute("keycloakPort", "8081");
        model.addAttribute("springBootPort", "8080");
        return "setup-guide";
    }
}