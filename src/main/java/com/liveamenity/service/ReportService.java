package com.liveamenity.service;

import com.liveamenity.model.Facility;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.List;

public class ReportService {
    public File exportFacilities(List<Facility> facilities) throws IOException {
        File dir = new File("reports");
        if (!dir.exists()) dir.mkdirs();

        File file = new File(dir, "facility_report.csv");
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(file))) {
            writer.write("ID,Name,Type,Capacity,Occupancy,Location,Available");
            writer.newLine();

            for (Facility f : facilities) {
                writer.write(String.format("%d,%s,%s,%d,%d,%s,%s",
                        f.getId(), f.getName(), f.getType(),
                        f.getCapacity(), f.getOccupancy(),
                        f.getLocation(), f.isAvailable()));
                writer.newLine();
            }
        }
        return file;
    }
}
