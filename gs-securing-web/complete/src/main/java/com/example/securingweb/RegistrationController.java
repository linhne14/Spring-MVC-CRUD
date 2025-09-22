package com.example.securingweb;

import com.example.securingweb.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class RegistrationController {

    @Autowired
    private UserService userService;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @GetMapping("/register")
    public String showRegisterForm(Model model) {
        return "register";
    }

    @PostMapping("/register")
    public String registerUser(@RequestParam String username, @RequestParam String password, @RequestParam String email, Model model) {
        // Kiểm tra hợp lệ
        if (username == null || username.length() < 4 || password.length() < 6 || !email.contains("@")) {
            model.addAttribute("error", "Thông tin không hợp lệ!");
            return "register";
        }
        try {
            userService.registerUser(username, password);
            model.addAttribute("success", "Đăng ký thành công! Bạn có thể đăng nhập.");
        } catch (Exception e) {
            model.addAttribute("error", "Đăng ký thất bại! Username đã tồn tại hoặc lỗi hệ thống.");
        }
        return "register";
    }
}
