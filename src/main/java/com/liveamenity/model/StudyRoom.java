
package com.liveamenity.model;

public class StudyRoom extends Facility {

    public StudyRoom(int id, String name, int capacity, int occupancy,
                     String location, boolean available) {
        super(id, name, "STUDY", capacity, occupancy, location, available);
    }

    @Override
    public String getRecommendationReason() {
        return "Suitable for studying and focused work, with current occupancy considered.";
    }

    @Override
    public double getActivityMatch(String activity) {
        return "study".equalsIgnoreCase(activity) ? 1.0 : 0.2;
    }
}
