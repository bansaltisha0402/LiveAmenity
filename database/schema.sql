CREATE DATABASE IF NOT EXISTS liveamenity;
USE liveamenity;

DROP TABLE IF EXISTS bookings;
DROP TABLE IF EXISTS facilities;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'USER'
);

CREATE TABLE facilities (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL,
    capacity INT NOT NULL,
    occupancy INT NOT NULL DEFAULT 0,
    location VARCHAR(150) NOT NULL,
    available BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE bookings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    facility_id INT NOT NULL,
    booking_time DATETIME NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'BOOKED',
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (facility_id) REFERENCES facilities(id)
);

INSERT INTO users(name,email,password,role) VALUES
('Demo User','user@demo.com','user123','USER'),
('Admin User','admin@demo.com','admin123','ADMIN');

INSERT INTO facilities(name,type,capacity,occupancy,location,available) VALUES
('Main Gym','GYM',40,12,'Block A',TRUE),
('Badminton Court','COURT',8,3,'Sports Complex',TRUE),
('Yoga Room','YOGA',20,4,'Block B',TRUE),
('Swimming Pool','POOL',30,18,'Sports Complex',TRUE),
('Study Room 1','STUDY',12,2,'Library',TRUE);
