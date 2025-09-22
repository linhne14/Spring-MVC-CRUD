package com.example.securingweb.model;

public class PendingUser {
    private String username;
    private String password;
    private String email;
    private String otp;

    public PendingUser(String username, String password, String email, String otp) {
        this.username = username;
        this.password = password;
        this.email = email;
        this.otp = otp;
    }

    public String getUsername() { return username; }
    public String getPassword() { return password; }
    public String getEmail() { return email; }
    public String getOtp() { return otp; }
    public void setOtp(String otp) { this.otp = otp; }
}
