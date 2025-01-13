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
    echo json_encode(["status" => "error", "message" => "Invalid request method"]);
    exit;
}

// Get the posted JSON data (from the application)
$input = json_decode(file_get_contents("php://input"), true);

// Get data from request
$available_ride_time = $input['available_ride_time'] ?? '';
$user_id = $input['user_id'] ?? '';

// Validate input
if (empty($available_ride_time) || empty($user_id)) {
    echo json_encode(["status" => "error", "message" => "Missing required fields."]);
    exit;
}

// Update query to modify user ride time
$query = "UPDATE user
          SET available_ride_time = ?
          WHERE user_id = ? AND user_type = 'Rider'";

// Prepare statement
$stmt = $conn->prepare($query);

if ($stmt === false) {
    echo json_encode(["status" => "error", "message" => "Failed to prepare the statement: " . $conn->error]);
    exit;
}

// Bind parameters
$stmt->bind_param("ss", $available_ride_time, $user_id);

// Execute the statement
if ($stmt->execute()) {
    if ($stmt->affected_rows > 0) {
        echo json_encode([
            "status" => "success",
            "message" => "User ride time updated successfully."
        ]);
    } else {
        echo json_encode([
            "status" => "error",
            "message" => "No rows were updated. Ensure the user exists and has the correct user type."
        ]);
    }
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Failed to update user data. Error: " . $stmt->error
    ]);
}

// Close the statement and database connection
$stmt->close();
$conn->close();
?>