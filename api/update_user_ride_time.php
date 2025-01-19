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

    // Get the posted JSON data
    $data = json_decode(file_get_contents("php://input"), true);

    // Validate received data
    if (!isset($data['user_id'], $data['available_ride_time'])) {
        echo json_encode(["status" => "error", "message" => "Invalid or missing parameters."]);
        $conn->close();
        exit;
    }

    // Extract and validate data
    $user_id = intval($data['user_id']); // Convert to integer for safety
    $available_ride_time = intval($data['available_ride_time']); // Convert to integer for safety

    // Prepare the UPDATE query
    $query = "UPDATE user
              SET available_ride_time = ?
              WHERE user_id = ?";

    $stmt = $conn->prepare($query);
    if ($stmt === false) {
        echo json_encode(["status" => "error", "message" => "Failed to prepare the statement: " . $conn->error]);
        $conn->close();
        exit;
    }

    // Bind parameters
    $stmt->bind_param("ii", $available_ride_time, $user_id);

    // Execute the query
    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Ride session updated successfully."]);
    } else {
        echo json_encode(["status" => "error", "message" => "Failed to update ride session. Error: " . $stmt->error]);
    }

    // Close the statement and connection
    $stmt->close();
    $conn->close();
?>
