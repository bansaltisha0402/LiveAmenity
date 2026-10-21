package com.liveamenity.model;

public class Member extends User {
    public Member(int id, String name, String email) {
        super(id, name, email, "USER");
    }

    @Override
    public boolean isAdmin() {
        return false;
    }
}
