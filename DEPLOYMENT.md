# Deployment checklist

## 1. Install
- JDK 21
- Maven 3.9+
- MySQL 8+
- Apache Tomcat 10.1+

## 2. Database
Run:
mysql -u root -p < database/schema.sql

Then change USER/PASSWORD in:
src/main/java/com/liveamenity/util/DBConnection.java

## 3. Build
mvn clean package

WAR:
target/liveamenity.war

## 4. Tomcat
Copy the WAR to:
TOMCAT_HOME/webapps/

Start Tomcat.

Open:
http://localhost:8080/liveamenity/

## 5. JavaFX
Run:
mvn javafx:run

The JavaFX screen and JSP web application use the same MySQL database.

## Important
This is a college-project MVP. Passwords are stored as plain text only to keep the demo small. In a real system use password hashing, sessions with CSRF protection, validation, connection pooling, and HTTPS.
