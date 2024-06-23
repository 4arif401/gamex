<?php
include("dbconnection.php"); // Include your database connection file
$con = dbconnection(); // Establish database connection

// Check if email and password are provided via POST request
if (isset($_POST['email']) && isset($_POST['password'])) {
    $email = mysqli_real_escape_string($con, $_POST['email']); // Sanitize input
    $password = mysqli_real_escape_string($con, $_POST['password']); // Sanitize input

    // Construct SQL query to check if user exists with given email and password
    $query = "SELECT * FROM user WHERE email = '$email' AND password = '$password'";

    // Execute the query
    $exe = mysqli_query($con, $query);

    if ($exe) {
        if (mysqli_num_rows($exe) == 1) {
            // Fetch user details
            $row = mysqli_fetch_array($exe);

            // Output JSON response with user details
            header('Content-Type: application/json');
            echo json_encode(array(
                'status' => 'success',
                'user_id' => $row['user_id'],
                'email' => $row['email'], // Include email
                'display_name' => $row['display_name'],
                'rank' => $row['rank'], // Include rank
                'phone' => $row['phone'] // Include phone if needed
            ));
        } else {
            // Invalid email or password
            echo json_encode(array('status' => 'error', 'message' => 'Invalid email or password'));
        }
    } else {
        // Handle query execution error
        echo json_encode(array('status' => 'error', 'message' => 'Error executing query: ' . mysqli_error($con)));
    }
} else {
    // Handle case where email or password is not provided
    echo json_encode(array('status' => 'error', 'message' => 'Email and password are required'));
}

// Close database connection
mysqli_close($con);
?>
