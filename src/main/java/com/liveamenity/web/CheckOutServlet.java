
package com.liveamenity.web;

import com.liveamenity.dao.BookingDAO;
import com.liveamenity.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/checkout")
public class CheckOutServlet extends HttpServlet {

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
            int bookingId = Integer.parseInt(req.getParameter("bookingId"));
            int facilityId = Integer.parseInt(req.getParameter("facilityId"));

            if (bookingId <= 0 || facilityId <= 0) {
                throw new IllegalArgumentException(
                        "Booking ID and Facility ID must be positive numbers."
                );
            }

            new BookingDAO().checkOut(bookingId, facilityId, user.getId());

            req.setAttribute("message", "Check-out successful. Your visit is complete.");

        } catch (NumberFormatException e) {
            req.setAttribute("error", "Enter valid numeric Booking ID and Facility ID.");
        } catch (Exception e) {
            req.setAttribute("error",
                    e.getMessage() != null ? e.getMessage() : "Check-out failed.");
        }

        req.getRequestDispatcher("/result.jsp").forward(req, resp);
    }
}
