package com.liveamenity.model;

public abstract class Facility {
    protected int id;
    protected String name;
    protected String type;
    protected int capacity;
    protected int occupancy;
    protected String location;
    protected boolean available;

    public Facility(int id, String name, String type, int capacity,
                    int occupancy, String location, boolean available) {
        this.id = id;
        this.name = name;
        this.type = type;
        this.capacity = capacity;
        this.occupancy = occupancy;
        this.location = location;
        this.available = available;
    }

    public abstract String getRecommendationReason();

    public abstract double getActivityMatch(String activity);

    public double occupancyRate() {
        return capacity == 0 ? 1.0 : (double) occupancy / capacity;
    }

    public int getId() { return id; }
    public String getName() { return name; }
    public String getType() { return type; }
    public int getCapacity() { return capacity; }
    public int getOccupancy() { return occupancy; }
    public String getLocation() { return location; }
    public boolean isAvailable() { return available; }

    @Override
    public String toString() {
        return name + " (" + occupancy + "/" + capacity + ")";
    }
}
