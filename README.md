# LiveAmenity — Java Project

A Java implementation of the LiveAmenity idea:
Observe -> Predict -> Recommend -> Optimize.

## Stack
- Java 21
- JavaFX desktop client
- Jakarta Servlet + JSP web interface
- JDBC + MySQL
- Maven
- Apache Tomcat 10.1+

## Main features
- User login
- Facility listing and live occupancy
- Intent-based recommendation
- Booking
- Check-in/check-out
- Admin facility management
- CSV report/file handling
- Custom exceptions
- Collections
- OOP inheritance/polymorphism/abstract classes
- JDBC
- Servlet/JSP

## Demo accounts
- User: user@demo.com / user123
- Admin: admin@demo.com / admin123

## Setup
1. Create MySQL database using `database/schema.sql`.
2. Edit DB credentials in `src/main/java/com/liveamenity/util/DBConnection.java`.
3. Run `mvn clean package`.
4. Deploy `target/liveamenity.war` to Tomcat `webapps`.
5. Open `http://localhost:8080/liveamenity/`.
6. For JavaFX, run `mvn javafx:run`.

The JavaFX client uses the same database and is intentionally kept separate from the Servlet/JSP web UI.
