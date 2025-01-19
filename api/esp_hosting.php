<?php
// Database credentials
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "ebikesms";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Get data from POST request
$landmark_id = $_POST['landmark_id'];
$testing = $_POST['latitude'];



// Update latitude and longitude where bike_id matches
$sql = "UPDATE landmark SET landmark_name_malay = '$testing' WHERE landmark_id = '$landmark_id'";


if ($conn->query($sql) === TRUE) {
    echo "Data inserted successfully";
} else {
    echo "Error: " . $sql . "<br>" . $conn->error;
}


$conn->close();
?>
