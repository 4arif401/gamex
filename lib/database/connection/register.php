<?php
include("dbconnection.php"); // Include your database connection file
$con = dbconnection(); // Establish database connection

// Check if all required fields are provided via POST request
if (isset($_POST['email']) && isset($_POST['display_name']) && isset($_POST['password'])) {
    $email = mysqli_real_escape_string($con, $_POST['email']); // Sanitize input
    $displayName = mysqli_real_escape_string($con, $_POST['display_name']); // Sanitize input
    $password = mysqli_real_escape_string($con, $_POST['password']); // Sanitize input

    // Check if email already exists in database
    $checkQuery = "SELECT * FROM user WHERE email = '$email'";
    $checkResult = mysqli_query($con, $checkQuery);

    if (mysqli_num_rows($checkResult) > 0) {
        // Email already registered
        header('Content-Type: application/json');
        echo json_encode(array('status' => 'error', 'message' => 'Email already registered'));
        exit();
    } else {
        // Insert new user into database
        $insertQuery = "INSERT INTO user (email, display_name, password, `rank`) VALUES ('$email', '$displayName', '$password', 0)";
        $insertResult = mysqli_query($con, $insertQuery);

        if ($insertResult) {
            // Registration successful
            header('Content-Type: application/json');
            echo json_encode(array('status' => 'success', 'message' => 'User registered successfully'));
            exit();
        } else {
            // Handle query execution error
            header('Content-Type: application/json');
            echo json_encode(array('status' => 'error', 'message' => 'Error registering user: ' . mysqli_error($con)));
            exit();
        }
    }
} else {
    // Handle case where all fields are not provided
    header('Content-Type: application/json');
    echo json_encode(array('status' => 'error', 'message' => 'Email, display name, and password are required'));
    exit();
}

// Close database connection
mysqli_close($con);
?>
