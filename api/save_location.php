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
$bike_id = $_POST['bike_id'];
$latitude = $_POST['latitude'];
$longitude = $_POST['longitude'];

// Insert data into the database
// $sql = "INSERT INTO locations (bike_id, latitude, longitude) VALUES ('$bike_id', '$latitude', '$longitude')";

// Update latitude and longitude where bike_id matches
$sql = "UPDATE bike SET current_latitude = '$latitude', current_longitude = '$longitude' WHERE bike_id = '$bike_id'";


if ($conn->query($sql) === TRUE) {
    echo "Data inserted successfully";
} else {
    echo "Error: " . $sql . "<br>" . $conn->error;
}

$conn->close();
?>
