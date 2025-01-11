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
    
    $query = "SELECT bike_id, status, current_latitude, current_longitude FROM bike;";

    // Execute query
    $result = $conn->query($query);

    if ($result === FALSE) {
        echo json_encode(["status" => "error", "message" => "Failed to execute query. Error: " . $conn->error]);
    } 
    // Check if no results were returned
    elseif ($result->num_rows < 1) {
        echo json_encode(["status" => "error", "message" => "It appears there are no locations in the system."]);
    } 
    // If query succeeded and results are available
    else {
        $locations = [];
        while ($row = $result->fetch_assoc()) {
            $locations[] = [
                "bike_id" => $row['bike_id'],
                "status" => $row['status'],
                "current_latitude" => $row['current_latitude'],
                "current_longitude" => $row['current_longitude']
            ]; 
        }
        echo json_encode([
            "status" => "success", 
            "message" => "Bike information forwarded.", 
            "data" => $locations]
        );
    }

    // Close the database connection
    $conn->close();
?>
