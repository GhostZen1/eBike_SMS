<?php
    // Database connection
    $host = "localhost";
    $db_user = "root"; // Database username
    $db_password = ""; // Database password
    $db_name = "ebikesms"; // Database name

    $conn = new mysqli($host, $db_user, $db_password, $db_name);

    // Check connection
    if ($conn->connect_error) {
        die(json_encode(["status" => "error", "message" => "Connection failed: {$conn->connect_error}"]));
    }

    // Set content header (must match with what's defined in Flutter)
    header("Content-Type: application/json");

    // Invalid request method
    if ($_SERVER['REQUEST_METHOD'] != 'POST') {
        echo json_encode(array("status" => "error", "message" => "Invalid request method"));
        exit;
    }

    // Get the posted JSON data (from the application)
    $input = json_decode(file_get_contents("php://input"), true);

    // Get data from request
    $bikeId = $input['bike_id'] ?? '';
    $status = $input['status'] ?? '';
    $currentLatitude = $input['current_latitude'] ?? '';
    $currentLongitude = $input['current_longitude'] ?? '';

    // Validate input
    if (empty($bikeId) || empty($status) || empty($currentLatitude) || empty($currentLongitude)) {
        echo json_encode(["status" => "error", "message" => "Missing required fields."]);
        exit;
    }

    // Update query to modify bike status and location
    $query = "UPDATE bike
              SET status = ?, current_latitude = ?, current_longitude = ?
              WHERE bike_id = ?";

    // Prepare statement
    $stmt = $conn->prepare($query);

    if ($stmt === false) {
        echo json_encode(["status" => "error", "message" => "Failed to prepare the statement: " . $conn->error]);
        exit;
    }

    // Bind parameters
    $stmt->bind_param("sdss", $status, $currentLatitude, $currentLongitude, $bikeId);

    // Execute the statement
    if ($stmt->execute()) {
        echo json_encode([
            "status" => "success",
            "message" => "Bike data updated successfully."
        ]);
    } else {
        echo json_encode([
            "status" => "error",
            "message" => "Failed to update bike data. Error: " . $stmt->error
        ]);
    }

    // Close the statement and database connection
    $stmt->close();
    $conn->close();
?>