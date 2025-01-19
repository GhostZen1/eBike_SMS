<?php
include("connection.php");

// Check connection
if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Connection failed: {$conn->connect_error}"]));
}
try {
    // Establish database connection
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Get the month and year from the request (e.g., via GET or POST)
    // Assuming month and year are passed as parameters
    if (isset($_GET['month']) && isset($_GET['year'])) {
        $month = (int)$_GET['month']; // The month passed (1 for January, 2 for February, etc.)
        $year = (int)$_GET['year'];  // The year passed (e.g., 2025)
    } else {
        // Default to current month and year if not provided
        $month = (int)date('m');
        $year = (int)date('Y');
    }

    // SQL query with dynamic month and year
    $sql = "SELECT 
                SUM(CASE WHEN DATE(transaction_date) = CURDATE() THEN transaction_total ELSE 0 END) AS total_today,
                SUM(CASE WHEN WEEK(transaction_date) = WEEK(CURDATE()) AND YEAR(transaction_date) = YEAR(CURDATE()) THEN transaction_total ELSE 0 END) AS total_week,
                SUM(CASE WHEN MONTH(transaction_date) = :month AND YEAR(transaction_date) = :year THEN transaction_total ELSE 0 END) AS total_month
            FROM transaction
            WHERE YEAR(transaction_date) = :year 
            AND MONTH(transaction_date) = :month";

    // Prepare the SQL statement
    $stmt = $pdo->prepare($sql);

    // Bind the parameters
    $stmt->bindParam(':month', $month, PDO::PARAM_INT);
    $stmt->bindParam(':year', $year, PDO::PARAM_INT);

    // Execute the query
    $stmt->execute();

    // Fetch the results
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    // Return the results as JSON (or any other response format you prefer)
    echo json_encode($result);

} catch (PDOException $e) {
    // Handle errors
    echo "Error: " . $e->getMessage();
}
?>
