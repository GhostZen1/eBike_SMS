<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

$servername = "localhost";
$dbUsername = "root";
$dbPassword = "";
$dbname = "ebikesms";

// Create connection
$conn = new mysqli($servername, $dbUsername, $dbPassword, $dbname);

// Check connection
if ($conn->connect_error) {
    die(json_encode(array("status" => "error", "message" => "Connection failed: " . $conn->connect_error)));
}

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    // Get user_id from query parameters
    $user_id = $_GET['user_id'] ?? '';

    if (empty($user_id)) {
        echo json_encode(array("status" => "error", "message" => "User ID is required"));
        exit;
    }

    // Fetch user details
    $stmt = $conn->prepare("SELECT
                            user_id,
                            user_type,
                            user_name,
                            full_name,
                            user_email,
                            matric_number,
                            available_ride_time
                            FROM user WHERE user_id = ?");
    if ($stmt === false) {
        die(json_encode(array("status" => "error", "message" => "SQL prepare failed: " . $conn->error)));
    }

    $stmt->bind_param("i", $user_id);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $user_data = $result->fetch_assoc();
        echo json_encode(array("status" => "success", "data" => $user_data));
    } else {
        echo json_encode(array("status" => "error", "message" => "User not found"));
    }

    $stmt->close();
} else {
    echo json_encode(array("status" => "error", "message" => "Invalid request method"));
}

$conn->close();
?>