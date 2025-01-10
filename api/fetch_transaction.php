<?php
    // Database connection
    $host = "localhost";
    $user = "root"; // Database username
    $password = ""; // Database password
    $database = "ebikesms"; // Database name

    $conn = new mysqli($host, $user, $password, $database);

    // Check connection
    if ($conn->connect_error) {
        die(json_encode(["status" => "error", "message" => "Connection failed: " . $conn->connect_error]));
    }

    // Set content header (must match with what's defined in Flutter)
    header("Content-Type: application/json");

    // First SQL query: Get transaction details along with the username
    $sql_details = "SELECT 
                        t.transaction_id,
                        t.transaction_date,
                        t.transaction_total,
                        t.obtained_ride_time,
                        u.user_name AS user_name
                    FROM 
                        transaction t
                    INNER JOIN 
                        user u ON t.user_id = u.user_id
                    ORDER BY 
                        t.transaction_date DESC";

    // Execute query
    $result_details = $conn->query($sql_details);

    // Initialize an array to hold the detailed data
    $transaction_data = [];
    if ($result_details->num_rows > 0) {
        // Fetch and store each row of detailed transaction data
        while ($row = $result_details->fetch_assoc()) {
            $transaction_data[] = [
                "transaction_id" => $row['transaction_id'],
                "transaction_date" => $row['transaction_date'],
                "transaction_total" => $row['transaction_total'],
                "obtained_ride_time" => $row['obtained_ride_time'],
                "user_name" => $row['user_name'],
            ];
        }
    }

    // Second SQL query: Get transactions grouped by month with total revenue and transaction count
    $sql_grouped = "SELECT
                        DATE_FORMAT(transaction_date, '%Y-%m') AS month,
                        SUM(transaction_total) AS total_revenue,
                        COUNT(transaction_id) AS total_transactions
                    FROM
                        transaction
                    GROUP BY
                        DATE_FORMAT(transaction_date, '%Y-%m')
                    ORDER BY
                        month DESC";

    // Execute the grouping query
    $result_grouped = $conn->query($sql_grouped);

    // Initialize an array to hold the monthly data
    $monthly_data = [];
    if ($result_grouped->num_rows > 0) {
        // Fetch and store each row of monthly grouped data
        while ($row = $result_grouped->fetch_assoc()) {
            $monthly_data[] = [
                "month" => $row['month'],
                "total_revenue" => $row['total_revenue'],
                "total_transactions" => $row['total_transactions'],
            ];
        }
    }

    // Combine both datasets into one response
    $response = [
        "transaction_details" => $transaction_data,
        "monthly_grouped" => $monthly_data,
    ];

    // Return the result as a JSON response
    echo json_encode($response);

    // Close the database connection
    $conn->close();
?>
