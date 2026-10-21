
package com.liveamenity.web;

import com.liveamenity.dao.BookingDAO;
import com.liveamenity.dao.FacilityDAO;
import com.liveamenity.model.Facility;
import com.liveamenity.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/book")
public class BookServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/index.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");

        try {
            String facilityIdParam = req.getParameter("facilityId");

            if (facilityIdParam == null || facilityIdParam.isBlank()) {
                throw new IllegalArgumentException("Please select a facility.");
            }

            int facilityId = Integer.parseInt(facilityIdParam);

            if (facilityId <= 0) {
                throw new IllegalArgumentException("Invalid facility ID.");
            }

            Facility facility = new FacilityDAO().findById(facilityId);

            if (facility == null) {
                throw new IllegalArgumentException("Facility not found.");
            }

            int bookingId = new BookingDAO().createBooking(user.getId(), facility);

            req.setAttribute("message", "Your booking has been created successfully.");
            req.setAttribute("bookingId", bookingId);
            req.setAttribute("facilityId", facility.getId());
            req.setAttribute("facilityName", facility.getName());

        } catch (NumberFormatException e) {
            req.setAttribute("error", "Invalid facility ID. Please select a valid facility.");
        } catch (Exception e) {
            req.setAttribute("error",
                    e.getMessage() != null ? e.getMessage() : "Something went wrong while booking.");
        }

        req.getRequestDispatcher("/result.jsp").forward(req, resp);
    }
}
