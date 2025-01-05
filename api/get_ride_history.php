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

    // Fetch ride history for the user
    $stmt = $conn->prepare("
        SELECT 
            r.ride_id, 
            r.start_time, 
            r.end_time, 
            r.distance
        FROM 
            ride r
        INNER JOIN 
            bike b ON r.bike_id = b.bike_id
        WHERE 
            r.user_id = ?
        ORDER BY 
            r.start_time DESC
    ");
    if ($stmt === false) {
        die(json_encode(array("status" => "error", "message" => "SQL prepare failed: " . $conn->error)));
    }
    $stmt->bind_param("i", $user_id);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $ride_history = array();
        while ($row = $result->fetch_assoc()) {
            $ride_history[] = $row;
        }
        echo json_encode(array("status" => "success", "data" => $ride_history));
    } else {
        echo json_encode(array("status" => "error", "message" => "No ride history found for the user"));
    }

    $stmt->close();
} else {
    echo json_encode(array("status" => "error", "message" => "Invalid request method"));
}

$conn->close();
?>
