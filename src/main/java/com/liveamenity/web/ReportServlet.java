
package com.liveamenity.web;

import com.liveamenity.dao.FacilityDAO;
import com.liveamenity.model.Facility;
import com.liveamenity.service.ReportService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.util.List;

@WebServlet("/report")
public class ReportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        try {
            List<Facility> facilities = new FacilityDAO().findAll();
            File file = new ReportService().exportFacilities(facilities);

            resp.setContentType("text/csv; charset=UTF-8");
            resp.setCharacterEncoding(StandardCharsets.UTF_8.name());
            resp.setHeader(
                    "Content-Disposition",
                    "attachment; filename=\"LiveAmenity_Facility_Report.csv\""
            );
            resp.setContentLengthLong(file.length());

            Files.copy(file.toPath(), resp.getOutputStream());
            resp.getOutputStream().flush();

        } catch (Exception e) {
            if (!resp.isCommitted()) {
                throw new ServletException("Unable to generate facility CSV report.", e);
            }
        }
    }
}
