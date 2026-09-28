package com.lumira.healthcare;

public final class UserProfile {
    private final String name;
    private final String phone;
    private final String email;

    public UserProfile(String name, String phone, String email) {
        this.name = name == null ? "" : name.trim();
        this.phone = phone == null ? "" : phone.trim();
        this.email = email == null ? "" : email.trim();
    }
    public String getName() { return name; }
    public String getPhone() { return phone; }
    public String getEmail() { return email; }
}
