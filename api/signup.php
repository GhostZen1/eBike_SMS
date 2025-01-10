<?php
// Database connection
$host = "localhost";
$db_user = "root"; // Database username
$db_password = ""; // Database password
$db_name = "ebikesms"; // Database name

$conn = new mysqli($host, $db_user, $db_password, $db_name);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Get the posted JSON data
$data = json_decode(file_get_contents("php://input"), true);

if (isset($data['matric_number']) && isset($data['password'])) {
    $user_email = $conn->real_escape_string($data['user_email']);
    $matric_number = $conn->real_escape_string($data['matric_number']);
    $password = password_hash($data['password'], PASSWORD_BCRYPT); // Hash the password for security
    $username = $conn->real_escape_string($data['user_name']);
    $full_name = $conn->real_escape_string($data['full_name']);

    // Check if matric_number already exists
    $checkQuery = "SELECT * FROM user WHERE matric_number = '$matric_number'";
    $checkResult = $conn->query($checkQuery);

    if ($checkResult->num_rows > 0) {
        echo json_encode(["status" => "error", "message" => "Matric number already registered"]);
    } else {
        // Insert new user into the database
        $query = "INSERT INTO user (user_email,matric_number,password,user_name,full_name) VALUES ('$user_email','$matric_number', '$password', '$username','$full_name')";
        if ($conn->query($query) === TRUE) {
            echo json_encode(["status" => "success", "message" => "Registration successful"]);
        } else {
            echo json_encode(["status" => "error", "message" => "Failed to register user"]);
        }
    }
} else {
    echo json_encode(["status" => "error", "message" => "Invalid data"]);
}

$conn->close();
?>
