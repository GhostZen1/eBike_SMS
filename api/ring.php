<?php
// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Set response type to JSON
header('Content-Type: application/json');

// Database connection details
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "esp8266_control";

// Connect to the database
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die(json_encode(["error" => "Database connection failed: " . $conn->connect_error]));
}

// Check if the `endpoint` parameter is set
if (isset($_GET['endpoint'])) {
    $endpoint = $_GET['endpoint'];

    if ($endpoint === 'ring') {
        // Handle the "ring" endpoint (add a command to the database)
        $sql = "INSERT INTO commands (command, status) VALUES ('ring', 'pending')";
        if ($conn->query($sql) === TRUE) {
            echo json_encode(["message" => "Ring command added successfully"]);
        } else {
            echo json_encode(["error" => "Failed to add command: " . $conn->error]);
        }
        $conn->close();
        exit; // Terminate script execution
    } elseif ($endpoint === 'command') {
        // Handle the "command" endpoint (fetch the latest pending command)
        $sql = "SELECT * FROM commands WHERE status = 'pending' ORDER BY created_at ASC LIMIT 1";
        $result = $conn->query($sql);

        if ($result->num_rows > 0) {
            $row = $result->fetch_assoc();

            // Return the pending command
            echo json_encode([
                "id" => $row['id'],
                "command" => $row['command'],
                "status" => $row['status'],
                "created_at" => $row['created_at']
            ]);

            // Update the status of the command to 'completed'
            $updateSql = "UPDATE commands SET status = 'completed' WHERE id = " . $row['id'];
            $conn->query($updateSql);
        } else {
            echo json_encode(["message" => "No pending commands"]);
        }
        $conn->close();
        exit; // Terminate script execution
    } else {
        // Handle invalid endpoint
        echo json_encode(["error" => "Invalid request or endpoint"]);
        $conn->close();
        exit; // Terminate script execution
    }
} else {
    // Handle missing `endpoint` parameter
    echo json_encode(["error" => "Missing endpoint parameter"]);
    $conn->close();
    exit; // Terminate script execution
}
?>
