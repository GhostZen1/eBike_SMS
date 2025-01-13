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
if (!isset($data['user_id'], $data['bike_id'], $data['start_datetime'], $data['end_datetime'], $data['total_distance'])) {
    echo json_encode(["status" => "error", "message" => "Invalid or missing parameters."]);
    $conn->close();
    exit;
}

// Extract data from the request
$user_id = $conn->real_escape_string($data['user_id']);
$bike_id = $conn->real_escape_string($data['bike_id']);
$start_dateime = $conn->real_escape_string($data['start_datetime']);
$end_dateime = $conn->real_escape_string($data['end_datetime']);
$total_distance = (int)$data['total_distance'];

// Prepare the INSERT query
$query = "INSERT INTO ride (user_id, bike_id, start_datetime, end_datetime, total_distance) 
          VALUES ('$user_id', '$bike_id', '$start_dateime', '$end_dateime', $total_distance)";

// Execute the query
if ($conn->query($query) === TRUE) {
    echo json_encode(["status" => "success", "message" => "Ride session added successfully."]);
} else {
    echo json_encode(["status" => "error", "message" => "Failed to add ride session. Error: " . $conn->error]);
}

// Close the database connection
$conn->close();
?>