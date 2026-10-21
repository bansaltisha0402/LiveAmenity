package com.liveamenity.service;

import com.liveamenity.dao.UserDAO;
import com.liveamenity.exception.AuthenticationException;
import com.liveamenity.model.User;

public class AuthService {
    private final UserDAO userDAO = new UserDAO();

    public User login(String email, String password) throws Exception {
        User user = userDAO.authenticate(email, password);
        if (user == null) throw new AuthenticationException("Invalid email or password.");
        return user;
    }
}
