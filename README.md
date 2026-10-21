# LiveAmenity 

### Smart Residential Amenity Booking & Occupancy Management

LiveAmenity is a Java-based web application designed to simplify the booking and management of shared residential facilities. Residents can explore amenities, make bookings, manage visits, and check in or out, while the system updates facility occupancy.

##  Key Features

- **Resident Login** — User authentication for accessing the application.
- **Dashboard** — Overview of facilities, recommendations, and availability.
- **Facility Management** — Browse shared residential amenities.
- **Amenity Booking** — Book facilities and receive a booking confirmation with a booking ID.
- **Check-In & Check-Out** — Update booking status and facility occupancy.
- **My Visits** — View personal bookings, facility details, booking dates, and statuses.
- **Availability & Occupancy** — Track facility usage and available capacity.

##  Technology Stack

- **Backend:** Java, Jakarta Servlets
- **Frontend:** JSP, HTML, CSS, JavaScript
- **Database:** MySQL
- **Server:** Apache Tomcat 10.1
- **Build Tool:** Apache Maven
- **Deployment Configuration:** Docker

##  Application Architecture

1. Residents interact with the web interface.
2. Servlets process login, booking, check-in, and check-out requests.
3. Data Access Objects (DAOs) communicate with the MySQL database.
4. The database stores user, facility, and booking information.
5. Booking and occupancy changes are reflected in the application.

##  Running the Project Locally

### Prerequisites

- Java Development Kit compatible with the project configuration
- Apache Maven
- Apache Tomcat 10.1
- MySQL Server

### Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/bansaltisha0402/LiveAmenity.git
   ```

2. Navigate to the project directory:

   ```bash
   cd LiveAmenity
   ```

3. Configure the required database connection environment variables:

   - `DB_URL`
   - `DB_USER`
   - `DB_PASSWORD`

4. Configure the MySQL database and tables using the project's database scripts. Review the scripts before execution, especially if they contain table-drop statements.

5. Build the application:

   ```bash
   mvn clean package
   ```

6. Deploy the generated WAR file from `target/liveamenity.war` to Apache Tomcat.

7. Start Tomcat and open the application using the configured local URL.

##  Configuration & Security

- Database credentials are supplied through environment variables.
- Do not commit database passwords, API keys, or other secrets to GitHub.
- Use fictional demo accounts for presentations and testing.

##  Project Objective

LiveAmenity aims to improve the convenience and organization of shared residential facilities by bringing amenity booking, visit management, and occupancy tracking into a single web application.

##  Project Status

The application has been tested locally for its core booking and visit-management workflows. Cloud deployment configuration is included in the repository, but a fully functional public deployment is not currently available.

##  Repository

[View LiveAmenity on GitHub](https://github.com/bansaltisha0402/LiveAmenity)

---

*Developed as a residential amenity management project.*
