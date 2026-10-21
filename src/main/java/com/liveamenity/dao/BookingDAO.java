
package com.liveamenity.dao;

import com.liveamenity.exception.BookingException;
import com.liveamenity.model.Facility;
import com.liveamenity.util.DBConnection;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class BookingDAO {

    public int createBooking(int userId, Facility facility)
            throws SQLException, BookingException {

        if (facility == null) {
            throw new BookingException("Please select a valid facility.");
        }

        if (!facility.isAvailable()) {
            throw new BookingException("Facility is not available.");
        }

        if (facility.getOccupancy() >= facility.getCapacity()) {
            throw new BookingException("Facility is currently full.");
        }

        String sql = """
                INSERT INTO bookings
                    (user_id, facility_id, booking_time, status)
                VALUES (?, ?, ?, ?)
                """;

        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(
                     sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, userId);
            ps.setInt(2, facility.getId());
            ps.setTimestamp(3, Timestamp.valueOf(LocalDateTime.now()));
            ps.setString(4, "BOOKED");

            ps.executeUpdate();

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        }

        throw new SQLException("Booking could not be created.");
    }

    public void checkIn(int bookingId, int facilityId, int userId)
            throws SQLException, BookingException {

        updateVisitStatus(
                bookingId,
                facilityId,
                userId,
                "BOOKED",
                "CHECKED_IN",
                1
        );
    }

    public void checkOut(int bookingId, int facilityId, int userId)
            throws SQLException, BookingException {

        updateVisitStatus(
                bookingId,
                facilityId,
                userId,
                "CHECKED_IN",
                "COMPLETED",
                -1
        );
    }

    private void updateVisitStatus(
            int bookingId,
            int facilityId,
            int userId,
            String currentStatus,
            String newStatus,
            int occupancyChange)
            throws SQLException, BookingException {

        String bookingSql = """
                UPDATE bookings
                SET status = ?
                WHERE id = ?
                  AND facility_id = ?
                  AND user_id = ?
                  AND status = ?
                """;

        String occupancySql;

        if (occupancyChange > 0) {
            occupancySql = """
                    UPDATE facilities
                    SET occupancy = occupancy + 1
                    WHERE id = ?
                      AND occupancy < capacity
                    """;
        } else {
            occupancySql = """
                    UPDATE facilities
                    SET occupancy = occupancy - 1
                    WHERE id = ?
                      AND occupancy > 0
                    """;
        }

        try (Connection c = DBConnection.getConnection()) {
            boolean previousAutoCommit = c.getAutoCommit();
            c.setAutoCommit(false);

            try {
                // Update only the authenticated resident's matching booking.
                try (PreparedStatement ps = c.prepareStatement(bookingSql)) {
                    ps.setString(1, newStatus);
                    ps.setInt(2, bookingId);
                    ps.setInt(3, facilityId);
                    ps.setInt(4, userId);
                    ps.setString(5, currentStatus);

                    if (ps.executeUpdate() != 1) {
                        throw new BookingException(
                                "Booking not found, does not belong to you, " +
                                        "or is not in the required status."
                        );
                    }
                }

                // Update occupancy in the same transaction.
                try (PreparedStatement ps = c.prepareStatement(occupancySql)) {
                    ps.setInt(1, facilityId);

                    if (ps.executeUpdate() != 1) {
                        throw new BookingException(
                                occupancyChange > 0
                                        ? "Facility is full or could not be found."
                                        : "Facility occupancy is already zero or could not be found."
                        );
                    }
                }

                c.commit();

            } catch (SQLException | BookingException e) {
                try {
                    c.rollback();
                } catch (SQLException rollbackError) {
                    e.addSuppressed(rollbackError);
                }
                throw e;

            } finally {
                try {
                    c.setAutoCommit(previousAutoCommit);
                } catch (SQLException ignored) {
                    // Connection will be closed after this operation.
                }
            }
        }
    }

    public List<String> findBookingsForUser(int userId)
            throws SQLException {

        List<String> rows = new ArrayList<>();

        String sql = """
                SELECT b.id, b.facility_id, f.name,
                       b.booking_time, b.status
                FROM bookings b
                JOIN facilities f ON f.id = b.facility_id
                WHERE b.user_id = ?
                ORDER BY b.id DESC
                """;

        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    rows.add(
                            "Booking #" + rs.getInt("id")
                                    + " | Facility: " + rs.getString("name")
                                    + " (Facility ID: " + rs.getInt("facility_id") + ")"
                                    + " | Booked: " + rs.getTimestamp("booking_time")
                                    + " | Status: " + rs.getString("status")
                    );
                }
            }
        }

        return rows;
    }

    public List<String> findRecentBookings() throws SQLException {

        List<String> rows = new ArrayList<>();

        String sql = """
                SELECT b.id, u.name, f.name,
                       b.booking_time, b.status
                FROM bookings b
                JOIN users u ON u.id = b.user_id
                JOIN facilities f ON f.id = b.facility_id
                ORDER BY b.id DESC
                LIMIT 20
                """;

        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                rows.add(
                        "#" + rs.getInt(1)
                                + " | " + rs.getString(2)
                                + " | " + rs.getString(3)
                                + " | " + rs.getTimestamp(4)
                                + " | " + rs.getString(5)
                );
            }
        }

        return rows;
    }
}
