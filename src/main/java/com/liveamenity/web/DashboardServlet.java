
package com.liveamenity.web;

import com.liveamenity.dao.FacilityDAO;
import com.liveamenity.dao.BookingDAO;
import com.liveamenity.model.Facility;
import com.liveamenity.model.User;
import com.liveamenity.service.RecommendationService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.Locale;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/index.jsp");
            return;
        }

        try {
            List<Facility> facilities = new FacilityDAO().findAll();
            req.setAttribute("facilities", facilities);

            User user = (User) session.getAttribute("user");
            req.setAttribute(
                    "myBookings",
                    new BookingDAO().findBookingsForUser(user.getId())
            );

            String activity = req.getParameter("activity");

            if (activity != null) {
                activity = activity.trim().toLowerCase(Locale.ROOT);
            }

            List<String> validActivities = List.of(
                    "exercise", "badminton", "swimming", "yoga", "study"
            );

            if (activity == null || !validActivities.contains(activity)) {
                activity = null;
            }

            req.setAttribute(
                    "selectedActivity",
                    activity == null ? "" : activity
            );

            if (activity != null) {
                RecommendationService service =
                        new RecommendationService();

                Facility preferred =
                        service.findPreferredFacility(facilities, activity);

                req.setAttribute(
                        "recommendedFacilities",
                        service.recommend(facilities, activity)
                );
                req.setAttribute("preferredFacility", preferred);
                req.setAttribute(
                        "preferredFacilityFull",
                        service.isFull(preferred)
                );
                req.setAttribute(
                        "preferredFacilityBusy",
                        service.isBusy(preferred)
                );
                req.setAttribute(
                        "recommendationMessage",
                        service.getRecommendationMessage(preferred, activity)
                );
                req.setAttribute("recommendationActivity", activity);
            }

            req.getRequestDispatcher("/dashboard.jsp")
                    .forward(req, resp);

        } catch (Exception e) {
            throw new ServletException("Could not load dashboard", e);
        }
    }
}
