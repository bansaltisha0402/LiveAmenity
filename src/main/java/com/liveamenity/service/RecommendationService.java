package com.liveamenity.service;

import com.liveamenity.model.Facility;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;
import java.util.Objects;

/**
 * Rule-based, occupancy-aware recommendations.
 * The user's preferred facility stays visible even when it is full; alternatives
 * are then ranked using activity suitability (70%) and free capacity (30%).
 */
public class RecommendationService {
    private static final double ACTIVITY_WEIGHT = 0.70;
    private static final double CAPACITY_WEIGHT = 0.30;
    private static final int BUSY_THRESHOLD_PERCENT = 80;

    public List<Facility> recommend(List<Facility> facilities, String activity) {
        if (facilities == null || facilities.isEmpty() || activity == null || activity.isBlank()) {
            return List.of();
        }

        Facility preferred = findPreferredFacility(facilities, activity);
        List<Facility> alternatives = new ArrayList<>();
        for (Facility facility : facilities) {
            if (facility == null || !facility.isAvailable()) continue;
            if (preferred != null && facility.getId() == preferred.getId()) continue;
            if (isFull(facility)) continue;
            alternatives.add(facility);
        }
        alternatives.sort(Comparator
                .comparingDouble((Facility f) -> calculateScore(f, activity)).reversed()
                .thenComparingInt(Facility::getId));

        List<Facility> result = new ArrayList<>();
        if (preferred != null && preferred.isAvailable()) result.add(preferred);
        result.addAll(alternatives);
        return List.copyOf(result);
    }

    /** Returns the facility whose model declares the strongest match for the chosen activity. */
    public Facility findPreferredFacility(List<Facility> facilities, String activity) {
        if (facilities == null || activity == null || activity.isBlank()) return null;
        return facilities.stream()
                .filter(Objects::nonNull)
                .filter(Facility::isAvailable)
                .max(Comparator.comparingDouble((Facility f) -> safeMatch(f, activity))
                        .thenComparingInt(f -> -f.getId()))
                .orElse(null);
    }

    public double calculateScore(Facility facility, String activity) {
        if (facility == null || activity == null || activity.isBlank()) return 0.0;
        double activityMatch = clamp(safeMatch(facility, activity));
        double lowCrowd = 1.0 - clamp(facility.occupancyRate());
        return ACTIVITY_WEIGHT * activityMatch + CAPACITY_WEIGHT * lowCrowd;
    }

    public boolean isFull(Facility facility) {
        return facility == null || facility.getCapacity() <= 0
                || facility.getOccupancy() >= facility.getCapacity();
    }

    public boolean isBusy(Facility facility) {
        if (facility == null || facility.getCapacity() <= 0) return false;
        int percentage = (int) Math.round(facility.occupancyRate() * 100.0);
        return !isFull(facility) && percentage >= BUSY_THRESHOLD_PERCENT;
    }

    public String getRecommendationMessage(Facility preferred, String activity) {
        if (preferred == null) {
            return "No active facility matches this activity right now. Try another activity or recheck later.";
        }
        if (isFull(preferred)) {
            return preferred.getName() + " is at capacity. You cannot book it right now. Use Recheck to refresh availability, or choose one of the alternatives below that better fits your activity.";
        }
        if (isBusy(preferred)) {
            return preferred.getName() + " is " + Math.round(preferred.occupancyRate() * 100)
                    + "% occupied. It still has space, but the alternatives below may be quieter.";
        }
        return preferred.getName() + " is available for your selected activity. Alternatives are ranked by activity match and current free capacity.";
    }

    public String getReason(Facility facility, String activity, Facility preferred) {
        if (facility == null) return "Facility information is unavailable.";
        if (preferred != null && facility.getId() == preferred.getId()) {
            if (isFull(facility)) {
                return "This is the closest match for your chosen activity, but it is full. Recheck later or select an available alternative.";
            }
            if (isBusy(facility)) {
                return "This matches your chosen activity, but occupancy is high. Consider a quieter alternative if you prefer more space.";
            }
            return "Best match for your chosen activity; current occupancy is also considered.";
        }

        int occupancy = facility.getCapacity() <= 0 ? 100
                : (int) Math.round(facility.occupancyRate() * 100.0);
        double match = safeMatch(facility, activity);
        if (match >= 0.9 && occupancy < BUSY_THRESHOLD_PERCENT) {
            return "Strong match for your activity, with " + (100 - occupancy) + "% of capacity still free.";
        }
        if (occupancy < 40) {
            return "A quieter alternative with only " + occupancy + "% occupancy right now.";
        }
        if (match >= 0.65) {
            return "A relevant alternative with current occupancy considered.";
        }
        return "A lower-priority alternative; it is available and ranked using activity fit and free capacity.";
    }

    private double safeMatch(Facility facility, String activity) {
        try {
            return facility.getActivityMatch(activity.trim().toLowerCase(Locale.ROOT));
        } catch (RuntimeException ex) {
            return 0.0;
        }
    }

    private double clamp(double value) {
        if (Double.isNaN(value) || Double.isInfinite(value)) return 0.0;
        return Math.max(0.0, Math.min(1.0, value));
    }
}
