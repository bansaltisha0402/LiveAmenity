package com.liveamenity.client;

import com.liveamenity.dao.FacilityDAO;
import com.liveamenity.dao.BookingDAO;
import com.liveamenity.model.Facility;
import com.liveamenity.model.User;
import com.liveamenity.service.AuthService;
import com.liveamenity.service.RecommendationService;
import javafx.application.Application;
import javafx.collections.FXCollections;
import javafx.geometry.Insets;
import javafx.scene.Scene;
import javafx.scene.control.*;
import javafx.scene.layout.*;
import javafx.stage.Stage;

import java.util.List;

public class LiveAmenityApp extends Application {
    private final AuthService authService = new AuthService();
    private final FacilityDAO facilityDAO = new FacilityDAO();
    private final BookingDAO bookingDAO = new BookingDAO();
    private final RecommendationService recommendationService = new RecommendationService();

    private User loggedInUser;
    private ListView<Facility> facilityList;

    @Override
    public void start(Stage stage) {
        showLogin(stage);
    }

    private void showLogin(Stage stage) {
        TextField email = new TextField("user@demo.com");
        PasswordField password = new PasswordField();
        password.setText("user123");
        Button login = new Button("Login");
        Label status = new Label();

        login.setOnAction(e -> {
            try {
                loggedInUser = authService.login(email.getText(), password.getText());
                showDashboard(stage);
            } catch (Exception ex) {
                status.setText(ex.getMessage());
            }
        });

        VBox root = new VBox(10,
                new Label("LiveAmenity JavaFX"),
                new Label("Email"), email,
                new Label("Password"), password,
                login, status);
        root.setPadding(new Insets(20));
        stage.setTitle("LiveAmenity");
        stage.setScene(new Scene(root, 420, 350));
        stage.show();
    }

    private void showDashboard(Stage stage) {
        facilityList = new ListView<>();
        refreshFacilities();

        TextField activity = new TextField("exercise");
        Button recommend = new Button("Recommend");
        Button book = new Button("Book Selected");
        Button checkIn = new Button("Check In");
        Button checkOut = new Button("Check Out");
        Label status = new Label();

        recommend.setOnAction(e -> {
            try {
                List<Facility> facilities = facilityDAO.findAll();
                facilityList.setItems(FXCollections.observableArrayList(
                        recommendationService.recommend(facilities, activity.getText())));
                status.setText("Sorted by activity match + lower occupancy.");
            } catch (Exception ex) {
                status.setText(ex.getMessage());
            }
        });

        book.setOnAction(e -> {
            Facility selected = facilityList.getSelectionModel().getSelectedItem();
            if (selected == null) {
                status.setText("Select a facility.");
                return;
            }
            try {
                int id = bookingDAO.createBooking(loggedInUser.getId(), selected);
                status.setText("Booking created. ID = " + id);
            } catch (Exception ex) {
                status.setText(ex.getMessage());
            }
        });

        checkIn.setOnAction(e -> status.setText(
                "Use the web check-in form with your booking ID for this demo."));
        checkOut.setOnAction(e -> status.setText(
                "Use the web check-out form with your booking ID for this demo."));

        VBox root = new VBox(10,
                new Label("Welcome, " + loggedInUser.getName()),
                new Label("What do you want to do?"), activity,
                recommend, facilityList, book, checkIn, checkOut, status);
        root.setPadding(new Insets(15));

        stage.setTitle("LiveAmenity Dashboard");
        stage.setScene(new Scene(root, 650, 650));
        stage.show();
    }

    private void refreshFacilities() {
        try {
            facilityList.setItems(FXCollections.observableArrayList(facilityDAO.findAll()));
        } catch (Exception e) {
            facilityList.setItems(FXCollections.observableArrayList());
        }
    }

    public static void main(String[] args) {
        launch(args);
    }
}
