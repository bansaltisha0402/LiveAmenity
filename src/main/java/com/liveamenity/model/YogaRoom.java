package com.liveamenity.model;

public class YogaRoom extends Facility {
    public YogaRoom(int id, String name, int capacity, int occupancy,
                    String location, boolean available) {
        super(id, name, "YOGA", capacity, occupancy, location, available);
    }

    @Override
    public String getRecommendationReason() {
        return "Low-occupancy wellness option.";
    }

    @Override
    public double getActivityMatch(String activity) {
        return "yoga".equalsIgnoreCase(activity) ? 1.0 : 0.3;
    }
}
