
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.Objects" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LiveAmenity | Booking Result</title>
    <style>
        * { box-sizing: border-box; }

        body {
            margin: 0;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 24px;
            font-family: "Segoe UI", Arial, sans-serif;
            color: #edf7f2;
            background:
                radial-gradient(ellipse at top left, #203d35 0%, transparent 48%),
                linear-gradient(135deg, #101714, #17221e 55%, #101714);
        }

        .card {
            width: 100%;
            max-width: 540px;
            padding: 38px;
            border: 1px solid rgba(175, 224, 200, 0.19);
            border-radius: 24px;
            background: rgba(255, 255, 255, 0.055);
            box-shadow: 0 24px 70px rgba(0, 0, 0, 0.3);
        }

        .icon {
            width: 58px;
            height: 58px;
            display: grid;
            place-items: center;
            border-radius: 18px;
            margin-bottom: 22px;
            font-size: 28px;
            background: rgba(131, 226, 183, 0.13);
            color: #91edbd;
        }

        .eyebrow {
            color: #91edbd;
            font-size: 12px;
            font-weight: 700;
            letter-spacing: 2px;
            text-transform: uppercase;
        }

        h1 {
            margin: 10px 0 12px;
            font-size: clamp(27px, 5vw, 36px);
            line-height: 1.2;
        }

        .description {
            color: #b8c9c0;
            line-height: 1.7;
            margin-bottom: 26px;
        }

        .message {
            padding: 14px 16px;
            border-radius: 12px;
            margin: 18px 0;
            line-height: 1.5;
            overflow-wrap: anywhere;
        }

        .success {
            color: #a6f2c8;
            background: rgba(65, 180, 119, 0.12);
            border: 1px solid rgba(100, 220, 155, 0.24);
        }

        .error {
            color: #ffb8b8;
            background: rgba(225, 75, 75, 0.12);
            border: 1px solid rgba(255, 120, 120, 0.24);
        }

        .details {
            display: grid;
            gap: 12px;
            margin: 24px 0;
        }

        .detail {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 16px;
            padding: 15px;
            border-radius: 12px;
            background: rgba(255, 255, 255, 0.045);
        }

        .detail span {
            color: #b8c9c0;
            font-size: 14px;
        }

        .detail strong {
            text-align: right;
            overflow-wrap: anywhere;
        }

        .actions {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            margin-top: 28px;
        }

        .button {
            flex: 1;
            min-width: 160px;
            display: inline-flex;
            justify-content: center;
            align-items: center;
            padding: 14px 18px;
            border-radius: 12px;
            text-decoration: none;
            font-weight: 700;
            transition: transform 0.2s, background 0.2s;
        }

        .button:hover { transform: translateY(-2px); }

        .primary {
            color: #10231a;
            background: #91edbd;
        }

        .secondary {
            color: #edf7f2;
            border: 1px solid rgba(175, 224, 200, 0.23);
            background: rgba(255, 255, 255, 0.04);
        }

        .footnote {
            margin-top: 24px;
            color: #82968b;
            font-size: 12px;
            line-height: 1.6;
        }

        @media (max-width: 480px) {
            .card { padding: 25px; }
            .detail { align-items: flex-start; }
        }
    </style>
</head>
<body>
<%
    Object message = request.getAttribute("message");
    Object error = request.getAttribute("error");
    Object bookingId = request.getAttribute("bookingId");
    Object facilityId = request.getAttribute("facilityId");
    Object facilityName = request.getAttribute("facilityName");

    boolean successful = message != null;
%>

<main class="card">
    <div class="icon"><%= successful ? "✓" : "!" %></div>

    <div class="eyebrow">LiveAmenity · Resident Services</div>

    <h1><%= successful ? "Booking confirmed" : "Booking not completed" %></h1>

    <p class="description">
        <%= successful
            ? "Your booking request was processed. Keep these details handy for your visit."
            : "We couldn't complete your booking. Review the message below and try again if appropriate." %>
    </p>

    <% if (successful) { %>
        <div class="message success">
            <%= message %>
        </div>

        <div class="details">
            <% if (bookingId != null) { %>
                <div class="detail">
                    <span>Booking ID</span>
                    <strong>#<%= bookingId %></strong>
                </div>
            <% } %>

            <% if (facilityName != null) { %>
                <div class="detail">
                    <span>Facility</span>
                    <strong><%= facilityName %></strong>
                </div>
            <% } %>

            <% if (facilityId != null) { %>
                <div class="detail">
                    <span>Facility ID</span>
                    <strong><%= facilityId %></strong>
                </div>
            <% } %>

            <div class="detail">
                <span>Status</span>
                <strong>BOOKED</strong>
            </div>
        </div>
    <% } else { %>
        <div class="message error">
            <%= error != null ? error : "No booking confirmation was received." %>
        </div>
    <% } %>

    <div class="actions">
        <a class="button primary" href="<%= request.getContextPath() %>/dashboard">
            Back to Dashboard
        </a>
        <a class="button secondary" href="<%= request.getContextPath() %>/dashboard#visits">
            My Visits
        </a>
    </div>

    <div class="footnote">
        LiveAmenity · Shared spaces, made smarter.
        <% if (successful) { %>
            Keep your booking ID available when managing your visit.
        <% } %>
    </div>
</main>
</body>
</html>
