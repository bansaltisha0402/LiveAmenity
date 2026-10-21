
package com.liveamenity.dao;

import com.liveamenity.model.*;
import com.liveamenity.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class FacilityDAO {

    public List<Facility> findAll() throws SQLException {
        List<Facility> result = new ArrayList<>();

        String sql = """
                SELECT * FROM facilities
                ORDER BY
                    CASE WHEN capacity = 0 THEN 1
                         ELSE occupancy * 1.0 / capacity END,
                    name
                """;

        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                result.add(map(rs));
            }
        }

        return result;
    }

    public Facility findById(int id) throws SQLException {
        String sql = "SELECT * FROM facilities WHERE id=?";

        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    public void updateOccupancy(int id, int delta) throws SQLException {
        String sql = """
                UPDATE facilities
                SET occupancy = GREATEST(0, LEAST(capacity, occupancy + ?))
                WHERE id=?
                """;

        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, delta);
            ps.setInt(2, id);
            ps.executeUpdate();
        }
    }

    private Facility map(ResultSet rs) throws SQLException {
        int id = rs.getInt("id");
        String name = rs.getString("name");
        String type = rs.getString("type");
        int capacity = rs.getInt("capacity");
        int occupancy = rs.getInt("occupancy");
        String location = rs.getString("location");
        boolean available = rs.getBoolean("available");

        String normalizedType = type == null
                ? ""
                : type.trim().toUpperCase(Locale.ROOT);

        String normalizedName = name == null
                ? ""
                : name.trim().toLowerCase(Locale.ROOT);

        if (normalizedType.equals("GYM")) {
            return new Gym(id, name, capacity, occupancy, location, available);
        }

        if (normalizedType.equals("COURT")
                || normalizedType.equals("BADMINTON")
                || normalizedName.contains("badminton")
                || normalizedName.contains("court")) {
            return new Court(id, name, capacity, occupancy, location, available);
        }

        if (normalizedType.equals("POOL")
                || normalizedType.equals("SWIMMING")
                || normalizedName.contains("pool")
                || normalizedName.contains("swimming")) {
            return new Pool(id, name, capacity, occupancy, location, available);
        }

        if (normalizedType.equals("STUDY")
                || normalizedType.equals("STUDY_ROOM")
                || normalizedName.contains("study")) {
            return new StudyRoom(id, name, capacity, occupancy, location, available);
        }

        if (normalizedType.equals("YOGA")
                || normalizedType.equals("YOGA_ROOM")
                || normalizedName.contains("yoga")) {
            return new YogaRoom(id, name, capacity, occupancy, location, available);
        }

        // Preserve the existing fallback for other facility types.
        return new YogaRoom(id, name, capacity, occupancy, location, available);
    }
}
