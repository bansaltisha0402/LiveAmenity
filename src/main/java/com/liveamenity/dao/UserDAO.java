
package com.liveamenity.dao;

import com.liveamenity.model.Admin;
import com.liveamenity.model.Member;
import com.liveamenity.model.User;
import com.liveamenity.util.DBConnection;
import com.liveamenity.util.PasswordUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UserDAO {

    public User authenticate(String email, String password)
            throws SQLException {

        if (email == null || password == null
                || email.isBlank() || password.isEmpty()) {
            return null;
        }

        String sql = """
                SELECT id, name, email, role, flat_number, password
                FROM users
                WHERE email = ?
                """;

        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setString(1, email.trim());

            int id;
            String name;
            String userEmail;
            String role;
            String flatNumber;
            String storedPassword;

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }

                id = rs.getInt("id");
                name = rs.getString("name");
                userEmail = rs.getString("email");
                role = rs.getString("role");
                flatNumber = rs.getString("flat_number");
                storedPassword = rs.getString("password");
            }

            if (storedPassword == null) {
                return null;
            }

            boolean isHashed = storedPassword.startsWith("PBKDF2$");
            boolean passwordMatches;

            if (isHashed) {
                passwordMatches =
                        PasswordUtil.verifyPassword(
                                password, storedPassword);
            } else {
                passwordMatches =
                        storedPassword.equals(password);
            }

            if (!passwordMatches) {
                return null;
            }

            if (!isHashed) {
                upgradePasswordHash(
                        c, id, storedPassword, password);
            }

            User user = "ADMIN".equalsIgnoreCase(role)
                    ? new Admin(id, name, userEmail)
                    : new Member(id, name, userEmail);

            user.setFlatNumber(flatNumber);

            return user;
        }
    }

    private void upgradePasswordHash(
            Connection c,
            int userId,
            String oldPassword,
            String plainPassword) throws SQLException {

        String sql = """
                UPDATE users
                SET password = ?
                WHERE id = ? AND password = ?
                """;

        String hashedPassword =
                PasswordUtil.hashPassword(plainPassword);

        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, hashedPassword);
            ps.setInt(2, userId);
            ps.setString(3, oldPassword);
            ps.executeUpdate();
        }
    }
}
