package com.liveamenity.model;

public class Pool extends Facility {
    public Pool(int id, String name, int capacity, int occupancy,
                String location, boolean available) {
        super(id, name, "POOL", capacity, occupancy, location, available);
    }

    @Override
    public String getRecommendationReason() {
        return "Swimming facility ranked using activity match and occupancy.";
    }

    @Override
    public double getActivityMatch(String activity) {
        return "swimming".equalsIgnoreCase(activity)
                || "exercise".equalsIgnoreCase(activity) ? 1.0 : 0.35;
    }
}
