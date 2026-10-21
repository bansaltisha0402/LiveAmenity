package com.liveamenity.model;

public class Court extends Facility {
    public Court(int id, String name, int capacity, int occupancy,
                 String location, boolean available) {
        super(id, name, "COURT", capacity, occupancy, location, available);
    }

    @Override
    public String getRecommendationReason() {
        return "Activity match is strong for court-based sports.";
    }

    @Override
    public double getActivityMatch(String activity) {
        return ("badminton".equalsIgnoreCase(activity)
                || "sports".equalsIgnoreCase(activity)) ? 1.0 : 0.4;
    }
}
