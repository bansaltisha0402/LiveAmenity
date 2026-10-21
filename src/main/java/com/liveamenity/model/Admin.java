package com.liveamenity.model;

public class Admin extends User {
    public Admin(int id, String name, String email) {
        super(id, name, email, "ADMIN");
    }

    @Override
    public boolean isAdmin() {
        return true;
    }
}
