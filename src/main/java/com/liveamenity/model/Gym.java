package com.liveamenity.model;

public class Gym extends Facility {
    public Gym(int id, String name, int capacity, int occupancy,
               String location, boolean available) {
        super(id, name, "GYM", capacity, occupancy, location, available);
    }

    @Override
    public String getRecommendationReason() {
        return "Good for general exercise with current occupancy considered.";
    }

    @Override
    public double getActivityMatch(String activity) {
        return "exercise".equalsIgnoreCase(activity) ? 1.0 : 0.5;
    }
}
